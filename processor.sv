module processor
(
    input  logic clk,
    input  logic rst
);
    logic [31:0] pc_out;
    logic [31:0] pc_in;
    logic [31:0] inst;

    logic [ 6:0] opcode;
    logic [ 2:0] func3;
    logic [ 6:0] func7;
    logic [ 4:0] rs1;
    logic [ 4:0] rs2;
    logic [ 4:0] rd;

    logic [31:0] rdata1;
    logic [31:0] rdata2;
    logic [31:0] wdata;

    logic [31:0] MUX_output;
    logic [31:0] mux_out_a;
    logic [31:0] opr_res;

    logic [31:0] rdata3;
    logic rd_en,wr_en;
    logic [31:0] wdata2;
    
    logic [2:0] br_type;
    logic        br_taken;
    logic        rf_en;
    logic [3:0] aluop;
    logic [1:0] wb_sel;
    logic        is_I_type;
    logic        is_AUIPC;
    logic        is_LUI;
    logic        is_R_type;
    logic        is_S_type;
    logic        is_Iload_type;
    logic        is_B_type;
    logic        is_JAL;
    logic        is_JALR;
    logic        is_CSR;

    logic [31:0] imm_to_mux;

    logic [31:0] rdata4;
    
    
    // Program Counter instance
    pc pc_inst
    (
        .clk   (clk),
        .rst   (rst),
        .pc_in (pc_in),
        .pc_out (pc_out)
    );

    CSR csr
    (
        .clk   (clk),
        .rst   (rst),
        .inst(inst),
        .rdata4(rdata4),
        .wdata3(rdata1),
        .csr_rd(csr_rd),
        .csr_wr(csr_wr)

    );

    // Instruction Memory Instance
    inst_mem imem
    (
        .addr(pc_out),
        .data(inst)
    );

    // Instruction Decoder
    inst_dec inst_instance
    (
        .inst    (inst),
        .rs1     (rs1),
        .rs2     (rs2),
        .rd      (rd),
        .opcode  (opcode),
        .func3   (func3),
        .func7   (func7)
     //   .csr_addr (csr_addr)
    );

    // Immediate Generator
    immediate_gen imm_gen
    (
        .inst(inst),
        .imm_to_mux(imm_to_mux),
        .is_AUIPC(is_AUIPC),
        .is_LUI(is_LUI),
        .is_S_type(is_S_type),
        .is_Iload_type(is_Iload_type),
        .is_I_type(is_I_type),
        .is_B_type(is_B_type),
        .is_JAL(is_JAL),
        .is_JALR(is_JALR)
    );

    

    //Register File
    reg_file reg_file_inst
    (
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rf_en(rf_en),
        .clk(clk),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .wdata(wdata)
    );

    //Controller
    controller contr_inst
    (
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .rf_en(rf_en),
        .aluop(aluop),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .wb_sel(wb_sel),
        .is_AUIPC(is_AUIPC),
        .is_LUI(is_LUI),
        .is_R_type(is_R_type),
        .is_S_type(is_S_type),
        .is_Iload_type(is_Iload_type),
        .is_I_type(is_I_type),
        .is_B_type(is_B_type),
        .is_JAL(is_JAL),
        .is_JALR(is_JALR),
        .br_type(br_type),
        .csr_rd(csr_rd),
        .csr_wr(csr_wr),
        .rd(rd),
        .is_CSR(is_CSR)
    );

    // ALU Mux (for selecting between rdata2 and imm_to_mux)
    MUX_to_ALU alu_mux
    (
        .rdata2(rdata2),
        .imm_to_mux(imm_to_mux),
        .is_R_type(is_R_type),
        .MUX_output(MUX_output)
    );
     MUX_to_ALUa alu_mux_a
    (
        .rdata1(rdata1),      // Register file data 1
        .pc_out(pc_out),      // Program Counter output
        .is_LUI(is_LUI),
        .is_AUIPC(is_AUIPC),  
        .is_B_type(is_B_type),
        .is_JAL(is_JAL),   
        .mux_out_a(mux_out_a)  
    );

     PC_MUX pc_mux
    (
        .pc_out   (pc_out),
        .opr_res  (opr_res),
        .br_taken (br_taken),
        .pc_in (pc_in)
    );

    //ALU
    alu alu_inst
    (
        .opr_a(mux_out_a),
        .opr_b(MUX_output),
        .aluop(aluop),
        .opr_res(opr_res)
    );

    branch_condition br_cndtn
    (
        .rdata1(rdata1),
        .rdata2(rdata2),
        .br_type(br_type),
        .br_taken(br_taken)

    );

    // Data Memory
    data_mem data_mem_inst (
        .clk(clk),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .addr(opr_res),
        .wdata2(rdata2),
        .rdata3(rdata3),
        .func3(func3) 
    );

    // Write-Back MUX
    MUX_write_back wb_mux (
        .opr_res(opr_res),
        .rdata3(rdata3),
        .wb_sel(wb_sel),
        .wdata(wdata),
        .pc_out(pc_out),
        .rdata4(rdata4)
    );
//     initial begin
//     $monitor("PC: %b, Inst: %b, Opcode: %b, Func3: %b, Func7: %b, rs1: %d, rs2: %d, rd: %d,rdata1: %b, rdata2: %b, wdata: %b",
//              pc_out, inst, opcode, func3, func7, rs1, rs2, rd, rdata1, rdata2, wdata);
// end

endmodule
