/******************************************************************/
//MODULE:       GR
//FILE NAME:    GR.v
//VERSION:		1.1
//DATE:			May,2022
//AUTHOR: 		charlotte-mu
//CODE TYPE:	RTL
//DESCRIPTION:	rotation mode of QR factorization with CORDIC 
//
//MODIFICATION HISTORY:
// VERSION Date Description
// 1.0 05/23/2022 Complete a cycle for 12 iterations,tatol 12 iterations
// 1.1 05/25/2022 Update to a cycle for 3 iterations,tatol 12 iterations
/******************************************************************/
`define bit_size 26

module GR(
    input clk,reset,
    input signed [12:0]data_in,
    input last_end_in,first,
    input [2:0]di_in,
    output signed[12:0]data_out,
    output wire last_out
);
parameter shift_valid = 4;
wire signed [8:0]k;
assign k = 9'b010011011;

reg [2:0]conter;
reg [8:0]last_end_shift;
reg signed [12:0]data_in_shift[7:0];

reg signed [`bit_size-1:0]x_reg[3:0];
reg signed [`bit_size-1:0]y_reg[3:0];
reg signed [`bit_size-1:0]data_out_temp;
wire signed [`bit_size-1:0]x_reg_k;

assign x_reg_k = (x_reg[3] * k) >>> 8;
assign data_out = data_out_temp >>> shift_valid;
assign last_out = last_end_shift[3];

always @(*)
begin
    if(last_end_shift[7])
    begin
        if(last_end_shift[8])
            data_out_temp <= data_in_shift[7] <<< shift_valid;
        else
            data_out_temp <= y_reg[0];
    end
    else
    begin
        data_out_temp <= (y_reg[3] * k) >>> 8;
    end
end

always @(posedge clk,negedge reset)
begin
    if(!reset)
    begin
        x_reg[0] <= `bit_size'd0;
        y_reg[0] <= `bit_size'd0;
        conter <= 3'd3;
    end
    else 
    begin
        if(conter == 3'd3)
        begin
            conter <= 3'd0;
            if(last_end_shift[4])
            begin
                x_reg[0] <= x_reg[0];
                y_reg[0] <= y_reg[0];
            end
            else if(first)
            begin
                x_reg[0] <= data_in <<< shift_valid;
                y_reg[0] <= x_reg[0];
            end
            else
            begin
                x_reg[0] <= data_in <<< shift_valid;
                y_reg[0] <= x_reg_k;
            end 
        end
        else
        begin
            if(first || last_end_shift[4])
            begin
                x_reg[0] <= x_reg[0];
                y_reg[0] <= y_reg[0];
            end
            else
            begin
                x_reg[0] <= x_reg[3];
                y_reg[0] <= y_reg[3];
            end 
            conter <= conter + 3'd1;
        end
    end
end
integer i;
always @(posedge clk,negedge reset)
begin
    if(!reset)
    begin
        for(i=0; i<=7; i=i+1)
            data_in_shift[i] <= 13'd0;
        for(i=0; i<=8; i=i+1)
            last_end_shift[i] <= 1'b0;
    end
    else 
    begin
        data_in_shift[0] <= data_in;
        for(i=0; i<7; i=i+1)
            data_in_shift[i+1] <= data_in_shift[i];
        last_end_shift[0] <= last_end_in;
        for(i=0; i<8; i=i+1)
            last_end_shift[i+1] <= last_end_shift[i];
    end
end

integer index;
always@(*)
begin
    for (index=0 ; index<3 ; index=index+1 ) begin
        xy_next(x_reg[index+1] ,y_reg[index+1] ,di_in[index] ,x_reg[index] ,y_reg[index] ,(index+(conter*3)));
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