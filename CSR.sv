module CSR 
(   input logic clk,
    input logic rst,
    input logic [31:0] wdata3,
    input logic [31:0] inst,
    input logic csr_rd,
    input logic csr_wr,
    output logic [31:0] rdata4
    
);
    logic [31:0] csr_mem [0:5];

    always_comb begin
        if (csr_rd) begin
            case (inst[31:20])    
                12'h300: rdata4 = csr_mem[0]; // mstatus
                12'h304: rdata4 = csr_mem[1]; // mie
                12'h305: rdata4 = csr_mem[2]; // mtvec
                12'h341: rdata4 = csr_mem[3]; // mepc
                12'h342: rdata4 = csr_mem[4]; // mcause
                12'h344: rdata4 = csr_mem[5]; // mip
            endcase
        end else begin
            rdata4 = 32'b0;        
        end
    end


   always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            csr_mem[0] <= 32'b0; // mstatus
            csr_mem[1] <= 32'b0; // mie
            csr_mem[2] <= 32'b0; // mtvec
            csr_mem[3] <= 32'b0; // mepc
            csr_mem[4] <= 32'b0; // mcause
            csr_mem[5] <= 32'b0; // mip
        end else if (csr_wr) begin
            case (inst[31:20])
                12'h300: csr_mem[0] <= wdata3; // mstatus
                12'h304: csr_mem[1] <= wdata3; // mie
                12'h305: csr_mem[2] <= wdata3; // mtvec
                12'h341: csr_mem[3] <= wdata3; // mepc
                12'h342: csr_mem[4] <= wdata3; // mcause
                12'h344: csr_mem[5] <= wdata3; // mip
                default: ; 
            endcase
        end
    end

endmodule