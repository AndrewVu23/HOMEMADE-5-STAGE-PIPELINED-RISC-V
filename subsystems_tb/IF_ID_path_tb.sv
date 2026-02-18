module IF_ID_path_tb();

    logic clk, reset, stall;
    
    logic w_RegWrite;
    logic [4:0] address_data;
    logic [31:0] w_Result;
    logic [31:0] captured_pc;

    IF_ID_path #(32) dut (
        .clk(clk), 
        .reset(reset), 
        .stall(stall),
        .w_RegWrite(w_RegWrite),
        .address_data(address_data),
        .w_Result(w_Result)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; stall = 0;
        w_RegWrite = 0; address_data = 0; w_Result = 0;
        
        #10 reset = 0; 
        $display("[Time %0t] Reset released.", $time);
        
        // Run for 3 cycles to let instructions flow from Fetch -> Decode
        repeat(3) @(posedge clk);
        #1;

        // PC Counter Check
        if (dut.f_PC !== 32'h0) 
            $display("PASSED. Current PC: %h", dut.f_PC);
        else 
            $error("FAILED. PC is stuck at 0");
        
        // Updating Register File Test
        @(negedge clk); 
        address_data = 5'd1;        
        w_Result = 32'hDEADBEEF;  
        w_RegWrite = 1;       
        
        @(negedge clk); 
        w_RegWrite = 0; 

        if (dut.Reg_File_module.Registers[1] === 32'hDEADBEEF) begin
            $display("PASSED. Register File updated correctly. Got: %h", dut.Reg_File_module.Registers[1]));
        end else begin
            $error("FAILED. Got: %h expected DEADBEEF", dut.Reg_File_module.Registers[1]);
        end

        // Stall Test
        @(negedge clk);
        stall = 1; 

        repeat(2) @(posedge clk);
        
        // PC Movement Check (should stop)
        captured_pc = dut.f_PC;
        @(posedge clk);
        
        if (dut.f_PC == captured_pc) begin
            $display("PASSED. PC stayed at %h", dut.f_PC);
        end else begin
            $error("FAILED. PC moved from %h to %h", captured_pc, dut.f_PC);
        end

        // Release Stall
        stall = 0;
        repeat(2) @(posedge clk);

        $finish;
    end

endmodule