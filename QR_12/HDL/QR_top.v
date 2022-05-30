module QR_top(
    input clk, reset,
    input signed [12:0]data_inA, data_inB, data_inC, data_inD,
    input last_end,
    output reg signed [12:0]data_outA, data_outB, data_outC, data_outD, 
    output finish_out,valid
    // output validA, validB, validC, validD
);

wire [11:0]di_outA, di_outB, di_outC, di_outD;
wire last_endA, last_endB, last_endC, last_endD, last_endE, last_endF;
wire signed [12:0]dataW_A, dataW_B, dataW_C, dataW_D, dataW_E, dataW_F;
wire finishA, finishB, finishC, finishD;
wire firstA, firstB, firstC, firstD;

wire valid_shift;
reg [5:0]valid_arr;

wire signed [12:0] dataA_shift, dataB_shift, dataC_shift, dataD_shift;
reg signed [12:0] dataA_shift_arr [5:0];
reg signed [12:0] dataB_shift_arr [3:0];
reg signed [12:0] dataC_shift_arr [1:0];

integer index;

assign valid = valid_arr[5];

always @(posedge clk, negedge reset) 
begin
    if(!reset)
    begin
        for(index=0; index<=5 ; index=index+1)
            dataA_shift_arr[index] <= 13'd0;
        for(index=0; index<=3 ; index=index+1)
            dataB_shift_arr[index] <= 13'd0;
        for(index=0; index<=1 ; index=index+1)
            dataC_shift_arr[index] <= 13'd0;
        valid_arr <= 6'd0;
        data_outA <= 13'd0;
        data_outB <= 13'd0;
        data_outC <= 13'd0;
        data_outD <= 13'd0;
    end
    else
    begin
        dataA_shift_arr[0] <= dataA_shift;
        for(index=0; index<=4 ; index=index+1)
            dataA_shift_arr[index+1] <= dataA_shift_arr[index];

        dataB_shift_arr[0] <= dataB_shift;
        for(index=0; index<=2 ; index=index+1)
            dataB_shift_arr[index+1] <= dataB_shift_arr[index];
        
        dataC_shift_arr[0] <= dataC_shift;
        dataC_shift_arr[1] <= dataC_shift_arr[0];
        
        valid_arr[0] <= valid_shift;
        for(index=0; index<=4 ; index=index+1)
            valid_arr[index+1] <= valid_arr[index];
        data_outA <= dataA_shift_arr[5];
        data_outB <= dataB_shift_arr[3];
        data_outC <= dataC_shift_arr[1];
        data_outD <= dataD_shift;
    end
end

GG u1 ( .clk(clk), .reset(reset), .data_in(data_inA), .last_end_in(last_end), .first(firstA), .di_out(di_outA), .data_out(dataA_shift), .last_out(finishA)   );
GR u2 ( .clk(clk), .reset(reset), .data_in(data_inB), .last_end_in(last_end), .first(firstA), .di_in (di_outA), .data_out(dataW_A),      .last_out(last_endA) );
GR u3 ( .clk(clk), .reset(reset), .data_in(data_inC), .last_end_in(last_end), .first(firstA), .di_in (di_outA), .data_out(dataW_B),      .last_out(last_endB) );
GR u4 ( .clk(clk), .reset(reset), .data_in(data_inD), .last_end_in(last_end), .first(firstA), .di_in (di_outA), .data_out(dataW_C),      .last_out(last_endC) );

GG u5 ( .clk(clk), .reset(reset), .data_in(dataW_A), .last_end_in(last_endA), .first(firstB), .di_out(di_outB), .data_out(dataB_shift), .last_out(finishB)   );
GR u6 ( .clk(clk), .reset(reset), .data_in(dataW_B), .last_end_in(last_endB), .first(firstB), .di_in (di_outB), .data_out(dataW_D),      .last_out(last_endD) );
GR u7 ( .clk(clk), .reset(reset), .data_in(dataW_C), .last_end_in(last_endC), .first(firstB), .di_in (di_outB), .data_out(dataW_E),      .last_out(last_endE) );

GG u8 ( .clk(clk), .reset(reset), .data_in(dataW_D), .last_end_in(last_endD), .first(firstC), .di_out(di_outC), .data_out(dataC_shift), .last_out(finishC)   );
GR u9 ( .clk(clk), .reset(reset), .data_in(dataW_E), .last_end_in(last_endE), .first(firstC), .di_in (di_outC), .data_out(dataW_F),      .last_out(last_endF) );

GG u10( .clk(clk), .reset(reset), .data_in(dataW_F), .last_end_in(last_endF), .first(firstD), .di_out(di_outD), .data_out(dataD_shift),     .last_out(finishD)   );

reg [3:0]conter;

assign valid_shift = (conter >= 4'd3) && !finishD;
assign finish_out = (conter >= 4'd9) && !valid;

assign firstA = (conter <= 4'd1)? 1'd1 : 1'd0;
assign firstB = (conter <= 4'd3)? 1'd1 : 1'd0;
assign firstC = (conter <= 4'd4)? 1'd1 : 1'd0;
assign firstD = (conter <= 4'd5)? 1'd1 : 1'd0;

always@(posedge clk, negedge reset)
begin
    if(!reset)
    begin
        conter <= 4'd0;
    end
    else
    begin
        if(conter != 4'd10)
            conter <= conter + 4'd1;
    end
end
    
endmodule