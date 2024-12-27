module PC_MUX
(
    input  logic [31:0] pc_out,        
    input  logic [31:0] opr_res,    
    input  logic        br_taken,     
    output logic [31:0] pc_in 
);

    always_comb
    begin
        automatic logic [31:0] pc_plus_4 = pc_out + 32'd4;
        if (br_taken) 
            pc_in = opr_res;      // If branch is taken, use ALU output (branch target)
        else 
            pc_in = pc_plus_4;   // If branch is not taken, use PC + 4
    end

endmodule
