/*============================================================================
*
*  LOGIC CORE:          TFT驱动模块		
*  MODULE NAME:         tft_driver
*	author:					Verdvana
*  REVISION HISTORY:  
*
*    Revision 1.0  2019/4/12     
*
*  FUNCTIONAL DESCRIPTION:
===========================================================================*/


module tft_driver(
							input 				clk,    			//33.3M
							input 				rst_n,
							input 	[23:0] 	data_in,   		//待显示数据
							
							output 	[10:0] 	hcount,			//x坐标
							output 	[10:0] 	vcount,			//y坐标
							output				tft_request,	//数据请求信号
							
							output 				tft_clk,			//驱动时钟
							output				tft_de,			//使能
							output 				tft_blank_n,
							output 				tft_hsync,
							output 				tft_vsync,	
							output 	[23:0] 	tft_rgb,   //TFT数据输出
							output 				tft_pwm

);

//800*480 时序参数	
parameter  H_SYNC   =  11'd2;      //行同步
parameter  H_BACK   =  11'd44;     //行显示后沿
parameter  H_DISP   =  11'd800;    //行有效数据
parameter  H_FRON   =  11'd210;    //行显示前沿
parameter  H_TOTAL  =  11'd1056;   //行扫描周期
   
parameter  V_SYNC   =  11'd2;      //场同步
parameter  V_BACK   =  11'd22;     //场显示后沿
parameter  V_DISP   =  11'd480;    //场有效数据
parameter  V_FRONT  =  11'd22;     //场显示前沿
parameter  V_TOTAL  =  11'd524;    //场扫描周期  


//需要显示区域
parameter	X_START	=	12'd24;
parameter	X_ZOOM	=	12'd752;
parameter	Y_START	=	12'd0;
parameter	Y_ZOOM	=	12'd480; 

	
	
assign tft_clk=clk;
assign tft_pwm=rst_n;
	
//TFT驱动部分
reg [10:0] hcount_r;   //TFT行扫描计数器
reg [10:0] vcount_r;		//TFT场扫描计数器
//行扫扫描
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		hcount_r<=11'd0;
		
	else if(hcount_r == H_TOTAL)
		hcount_r<=11'd0;
		
	else
		hcount_r<=hcount_r+11'd1;
		
end		
	
//场扫描
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		vcount_r<=11'd0;
		
	else if(hcount_r == H_TOTAL)
		begin
			if(vcount_r==V_TOTAL)
				vcount_r<=11'd0;
				
			else
				vcount_r<=vcount_r+11'd1;
		end
		
	else
		vcount_r<=vcount_r;
end		
	
//数据、同频信号输出
assign tft_de=((hcount_r>= (H_SYNC + H_BACK)) && (hcount_r< (H_SYNC + H_BACK + H_DISP)))
				&&((vcount_r>= (V_SYNC + V_BACK)) && (vcount_r< (V_SYNC + V_BACK + V_DISP))) ? 1'b1:1'b0;
				
assign tft_hsync=(hcount_r> H_SYNC -1);
assign tft_vsync=(vcount_r> V_SYNC -1);
assign tft_rgb=(tft_request)?data_in:24'h0000;
assign tft_blank_n = tft_de;
					 
assign tft_request = ((hcount_r>= (H_SYNC + H_BACK + X_START)) && (hcount_r< (H_SYNC + H_BACK  + X_START + X_ZOOM )))
				&&((vcount_r>= (V_SYNC + V_BACK + Y_START )) && (vcount_r< (V_SYNC + V_BACK  + Y_START + Y_ZOOM)));
							 
assign hcount=tft_request ? (hcount_r - H_SYNC - H_BACK - X_START):11'd0;  
assign vcount=tft_request ? (vcount_r - V_SYNC - V_BACK - Y_START):11'd0;
							
	
	
endmodule
