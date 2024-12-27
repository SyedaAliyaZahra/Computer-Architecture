module tb_processor();
    logic clk;
    logic rst;

    // Processor DUT instantiation
    processor dut
    (
        .clk(clk),
        .rst(rst)
    );

    // Clock Generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset Generator
    initial begin
        rst = 1;
        #10;
        rst = 0;
        #1000;
        $finish;
    end

    // Initializing Instruction, Register File, and Data Memories
    initial begin
        $readmemb("instruction_memory", dut.imem.mem);
        $readmemb("register_file", dut.reg_file_inst.reg_mem);
        $readmemb("data_memory", dut.data_mem_inst.mem); // Initialize data memory
        $display("Data stored at address %h: %h", dut.data_mem_inst.addr, dut.data_mem_inst.mem[dut.data_mem_inst.addr[31:2]]);
    end

    // Dumping the simulation results
    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, tb_processor);
    end

    // Monitor Data Memory after Store Operation
    initial begin
        #50; // Wait for some cycles, enough for a store operation to complete
        if (dut.data_mem_inst.wr_en) begin
            // Assuming a store operation is happening
            $display("Data stored at address %h: %h", dut.data_mem_inst.addr, dut.data_mem_inst.mem[dut.data_mem_inst.addr[31:2]]);
        end

        // Verify updated memory content
        #50; // Wait for the next cycle or further operations
        $display("Updated memory content at address %h: %h", dut.data_mem_inst.addr, dut.data_mem_inst.mem[dut.data_mem_inst.addr[31:2]]);
    end
endmodule
