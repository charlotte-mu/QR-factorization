`timescale 1ns/10ps
`define CYCLE      10 
`define End_CYCLE  100
`define SDFFILE    "./QR_top_syn.sdf"
`define PAT        "./HDL/testdata.txt"
`define ANS        "./HDL/ans.txt"

module testbench();
integer fd,fd_ans;
integer charcount;
string line;
reg signed [12:0]ansA, ansB, ansC ,ansD;
integer conter;
integer error;
//=========IO define
reg clk = 0;
reg reset =0;

reg signed [12:0]data_inA, data_inB, data_inC, data_inD;
reg last_end;
wire signed [12:0]data_outA, data_outB, data_outC, data_outD;
wire finish_out;
// wire validA, validB, validC, validD;
wire valid;

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
    .valid(valid)
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

always @(negedge clk ) begin
    if (!reset) begin
        data_inA = 0;
        data_inB = 0;
        data_inC = 0;
        data_inD = 0;
        last_end = 0;
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
                        ap_num = ap_num+1;
                        charcount = $sscanf(line, "%d %d %d %d %d",last_end ,data_inA ,data_inB ,data_inC ,data_inD );
                        $display("index %d:  %d, %d, %d, %d, %d",ap_num ,last_end ,data_inA ,data_inB ,data_inC ,data_inD );
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
