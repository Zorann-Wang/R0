`include "defines.v"

module alu(

    input   wire [`REG_DATA_BUS]    alu_data1_i, 
    input   wire [`REG_DATA_BUS]    alu_data2_i,
    input   wire [3:0]              alu_op_i,
    output  reg [`REG_DATA_BUS]     alu_data_o   // alu algorithm result output
    //output  reg                     alu_zero_o,     // zero flag
    //output  reg                     alu_sign_o      // sign flag, 1: negative, 0: zero or positive
);

/*
always_comb begin
    alu_zero_o = (alu_data_o == 32'b0) ? 1'b1:1'b0;
    alu_sign_o = alu_data_o[31];
end
*/

always_comb begin
    priority case (alu_op_i)
        // arithmetic
        `ALU_ADD: begin
            alu_data_o = $signed(alu_data1_i) + $signed(alu_data2_i);
        end

        `ALU_SUB: begin
            alu_data_o = $signed(alu_data1_i) - $signed(alu_data2_i);
        end

        // logical
        `ALU_AND: begin
            alu_data_o = alu_data1_i & alu_data2_i;
        end

        `ALU_OR: begin
            alu_data_o = alu_data1_i | alu_data2_i;
        end

        `ALU_XOR: begin
            alu_data_o = alu_data1_i ^ alu_data2_i;
        end

        // logic shift
        `ALU_SLL: begin
            alu_data_o = alu_data1_i << alu_data2_i;
        end
        
        `ALU_SRL: begin
                alu_data_o = alu_data1_i >> alu_data2_i; 
        end

        // arithmetic shift
        `ALU_SRA: begin
                alu_data_o = $signed(alu_data1_i) >>> alu_data2_i;
        end

        // signed comparison
        `ALU_SLT: begin
                alu_data_o = ($signed(alu_data1_i) < $signed(alu_data2_i)) ? 32'b1 : 32'b0; 
        end

        // unsigned comparison
        `ALU_SLTU: begin
                alu_data_o = (alu_data1_i < alu_data2_i) ? 32'b1 : 32'b0; 
        end
        
        default: begin
            alu_data_o = alu_data1_i; 
        end
    endcase
end  

endmodule