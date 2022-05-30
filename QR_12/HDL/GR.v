`define bit_size 26

module GR(
    input clk,reset,
    input signed [12:0]data_in,
    input last_end_in,first,
    input [11:0]di_in,
    output signed[12:0]data_out,
    output reg last_out
);

parameter shift_valid = 4;

reg signed [`bit_size-1:0]x_reg[12:0];
reg signed [`bit_size-1:0]y_reg[12:0];
reg signed [`bit_size-1:0]data_out_temp;
reg last_end_shift1, last_end_shift2;
reg [12:0]data_in_shift1, data_in_shift2;
wire signed [8:0]k;
wire signed [`bit_size-1:0]x_reg_k;

assign k = 9'b010011011;
assign x_reg_k = (x_reg[12] * k) >>> 8;
assign data_out = data_out_temp >>> shift_valid;

always @(*)
begin
    if(last_end_shift1)
    begin
        if(last_end_shift2)
            data_out_temp <= data_in_shift2 <<< shift_valid;
        else
            data_out_temp <= y_reg[0];
    end
    else
    begin
        data_out_temp <= (y_reg[12] * k) >>> 8;
    end
end

always @(posedge clk,negedge reset)
begin
    if(!reset)
    begin
        x_reg[0] <= `bit_size'd0;
        y_reg[0] <= `bit_size'd0;
        last_end_shift1 <= 1'b0;
        last_end_shift2 <= 1'b0;
        last_out <= 1'd0;
        data_in_shift1 <= 13'd0;
        data_in_shift2 <= 13'd0;
    end
    else 
    begin
        data_in_shift1 <= data_in;
        data_in_shift2 <= data_in_shift1;
        last_out <= last_end_in;
        last_end_shift1 <= last_out;
        last_end_shift2 <= last_end_shift1;
        x_reg[0] <= data_in <<< shift_valid;

        if(first)
            y_reg[0] <= x_reg[0];
        else
            y_reg[0] <= x_reg_k;
    end
end

integer index;
always@(*)
begin
    for (index=0 ; index<12 ; index=index+1 ) begin
        xy_next(x_reg[index+1] ,y_reg[index+1] ,di_in[index] ,x_reg[index] ,y_reg[index] ,index);
    end
end

task xy_next;
    output signed [`bit_size-1:0]x_out,y_out;
    input di_in;
    input signed [`bit_size-1:0]x_in,y_in;
    input [3:0]index;

    reg signed [`bit_size-1:0]x_temp,y_temp;
begin
    if(di_in)
    begin
        x_temp = y_in;
        y_temp = x_in;
    end
    else
    begin
        x_temp = -y_in;
        y_temp = -x_in;
    end
    x_out = x_in - (x_temp >>> index);
    y_out = y_in + (y_temp >>> index);
end
endtask
    
endmodule