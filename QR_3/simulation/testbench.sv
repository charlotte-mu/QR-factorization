/******************************************************************/
//MODULE:       testbench
//FILE NAME:    testbench.v
//VERSION:		1.1
//DATE:			May,2022
//AUTHOR: 		charlotte-mu
//CODE TYPE:	RTL
//DESCRIPTION:	Testbench of QR factorization with CORDIC
//
//MODIFICATION HISTORY:
// VERSION Date Description
// 1.0 05/23/2022 Complete a cycle for 12 iterations,tatol 12 iterations
// 1.1 05/25/2022 Update to a cycle for 3 iterations,tatol 12 iterations
/******************************************************************/
`timescale 1ns/10ps
`define CYCLE      10 
`define End_CYCLE  100
`define SDFFILE    "./QR_top_syn.sdf"
`define PAT        "./testdata.txt"
`define ANS        "./ans.txt"

module testbench();
integer fd,fd_ans;
integer charcount;
string line;
reg signed [12:0]ansA, ansB, ansC ,ansD;
integer conter;
integer error;
reg signed [12:0]dataA_array[8:0];
reg signed [12:0]dataB_array[8:0];
reg signed [12:0]dataC_array[8:0];
reg signed [12:0]dataD_array[8:0];
reg [8:0]last_end_array;
//=========IO define
reg clk = 0;
reg reset =0;

reg signed [12:0]data_inA, data_inB, data_inC, data_inD;
reg last_end;
wire signed [12:0]data_outA, data_outB, data_outC, data_outD;
wire finish_out;
// wire validA, validB, validC, validD;
wire valid,value;

QR_top u_QR(
    .clk(clk),
    .reset(reset),
    .data_inA(data_inA),
    .data_inB(data_inB),
    .data_inC(data_inC),
    .data_inD(data_inD),
    .last_end(last_end),

    .data_outA(data_outA), 
    .data_outB(data_outB), 
    .data_outC(data_outC), 
    .data_outD(data_outD),
    .finish_out(finish_out),
    .valid(valid),
    .value(value)
);

`ifdef SDF
    initial $sdf_annotate(`SDFFILE, u_QR);
`endif

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
    $display("----------------------");
    $display("-- Simulation Start --");
    $display("----------------------");
    @(posedge clk);  #2 reset = 1'b0; 
    #(`CYCLE*2);  
    @(posedge clk);  #2  reset = 1'b1;
end

reg [22:0] cycle=0;

always @(posedge clk) begin
    if (!reset)
        cycle=0;
    else
        cycle=cycle+1;
    if (cycle > `End_CYCLE) begin
        $display("--------------------------------------------------");
        $display("-- Failed waiting valid signal, Simulation STOP --");
        $display("--------------------------------------------------");
        $fclose(fd);
        $fclose(fd_ans);
        $finish;
    end
end

initial begin
    fd = $fopen(`PAT,"r");
    fd_ans = $fopen(`ANS,"r");
    if (fd == 0 || fd_ans == 0) begin
        $display("----------------------");
        $display("--pattern handle null-");
        $display("----------------------");
        $finish;
    end
end

integer ap_num;
integer non_read;
integer index;
always @(negedge clk ) begin
    if (!reset) begin
        for(index=0; index<9; index=index+1)
        begin
            dataA_array[index] = 0;
            dataB_array[index] = 0;
            dataC_array[index] = 0;
            dataD_array[index] = 0;
            last_end_array[index] = 0;
        end
        ap_num = 0;
        non_read = 0;
    end 
    else begin
        if(!non_read)begin
            if (!$feof(fd)) begin
                charcount = $fgets (line, fd);
                if(charcount != 0) begin
                    while( line.substr(1, 2) == "//") charcount = $fgets (line, fd);

                    if(ap_num == 9) begin
                        ap_num = ap_num;
                    end 
                    else begin
                        charcount = $sscanf(line, "%d %d %d %d %d",last_end_array[ap_num] ,dataA_array[ap_num] ,dataB_array[ap_num] ,dataC_array[ap_num] ,dataD_array[ap_num] );
                        $display("index %d:  %d, %d, %d, %d, %d",ap_num ,last_end_array[ap_num] ,dataA_array[ap_num] ,dataB_array[ap_num] ,dataC_array[ap_num] ,dataD_array[ap_num] );
                        ap_num = ap_num+1;
                    end
                end
            end
            else begin
                $fclose(fd);
                non_read = 1;
            end
        end
    end
end
integer ap_num2;
always @(negedge clk ) begin
    if (!reset) begin
        data_inA = 0;
        data_inB = 0;
        data_inC = 0;
        data_inD = 0;
        last_end = 0;
        ap_num2 = 0;
    end 
    else begin
        if(value && ap_num2 < 9)begin
            data_inA = dataA_array[ap_num2];
            data_inB = dataB_array[ap_num2];
            data_inC = dataC_array[ap_num2];
            data_inD = dataD_array[ap_num2];
            last_end = last_end_array[ap_num2];
            ap_num2 = ap_num2 + 1;
        end 
        else
        begin
            if(last_end)
            begin
                data_inA = data_inA;
                data_inB = data_inB;
                data_inC = data_inC;
                data_inD = data_inD;
                last_end = last_end;
            end
            else
            begin
                data_inA = 0;
                data_inB = 0;
                data_inC = 0;
                data_inD = 0;
                last_end = 0;
            end
        end
    end
end

integer non_read1,ap_num1;
always @(negedge clk ) begin
    if (!reset) begin
        ansA = 0;
        ansB = 0;
        ansC = 0;
        ansD = 0;
        ap_num1 = 0;
        non_read1 = 0;
        error = 0;
        conter = 0;
    end 
    else begin
        if(valid && conter <= 7)begin
            if(!non_read1)begin
                if (!$feof(fd_ans)) begin
                    charcount = $fgets (line, fd_ans);
                    if(charcount != 0) begin
                        while( line.substr(1, 2) == "//") charcount = $fgets (line, fd_ans);

                        if(ap_num1 == 8) begin
                            ap_num1 = ap_num1;
                        end 
                        else begin
                            ap_num1 = ap_num1+1;
                            charcount = $sscanf(line, "%d %d %d %d",ansA ,ansB ,ansC ,ansD );
                            if((ansA == data_outA) && (ansB == data_outB) && (ansC == data_outC) && (ansD == data_outD))begin
                                $display("pass%2d gold:%6d,%6d,%6d,%6d; ans:%6d,%6d,%6d,%6d",ap_num1, ansA ,ansB ,ansC ,ansD ,data_outA,data_outB,data_outC,data_outD);
                            end
                            else begin
                                $display("faill%2d gold:%6d,%6d,%6d,%6d; ans:%6d,%6d,%6d,%6d",ap_num1, ansA ,ansB ,ansC ,ansD ,data_outA,data_outB,data_outC,data_outD);
                                error = error + 1;
                            end
                        end
                    end
                end
                else begin
                    $fclose(fd_ans);
                    non_read1 = 1;
                end
            end 
            conter = conter + 1;
        end
    end
end
always @(negedge clk ) begin
    if(finish_out)
    begin
        if(error == 0 && conter != 0) begin
            $display ("-------------------------------------------------");
            $display ("------Simulation finish all pass-----------------");
            $display ("-------------------------------------------------");
        end
        else begin
            $display ("-------------------------------------------------");
            $display ("------Simulation finish faill--------------------");
            $display ("-------------------------------------------------");
        end
        $display ("-------------------------------------------------");
        $display ("cycle : %d",cycle);
        $display ("-------------------------------------------------");
        $fclose(fd);
        $fclose(fd_ans);
        $finish;
    end
end
endmodule
