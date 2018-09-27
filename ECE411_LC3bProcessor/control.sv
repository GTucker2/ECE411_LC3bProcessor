import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module control
(
    input clk,
	 
	 /* Datapath controls */
	 input rv32i_opcode opcode,
	 output logic load_pc,
	 output logic load_ir,
	 output logic load_regfile,
	 output logic load_mar,
	 output logic load_mdr,
	 output logic load_data_out,
	 output logic pcmux_sel,
	 output branch_funct3_t cmpop,
	 output logic alumux1_sel,
	 output logic [1:0] alumux2_sel,
	 output logic [1:0] regfilemux_sel,
	 output logic marmux_sel,
	 output logic cmpmux_sel,
	 output alu_ops aluop,
	 
	 /* Memory signals */
	 input [2:0] funct3,
	 input [6:0] funct7,
	 input mem_resp,
	 input br_en,
	 output logic mem_read,
	 output logic mem_write,
	 output rv32i_mem_wmask mem_byte_enable 
);

enum int unsigned {
    fetch1,
	 fetch2,
	 fetch3,
	 decode,
	 s_auipc,
	 s_imm,
	 s_jal,
	 s_jalr,
	 s_lui,
	 s_br,
	 s_reg,
	 calc_addr,
	 ld1,
	 ld2,
	 st1,
	 st2
} state, next_states;

always_comb
begin : state_actions
    /* Default output assignments */
	 load_pc = 1'b0;
	 load_ir = 1'b0;
	 load_regfile = 1'b0;
	 load_mar = 1'b0;
	 load_mdr = 1'b0;
	 load_data_out = 1'b0;https://courses.engr.illinois.edu/ece411/fa2018/mp/riscv-spec-v2.2.pdf
	 pcmux_sel = 1'b0;
	 cmpop = branch_funct3_t'(funct3);
	 alumux1_sel = 1'b0; 
	 alumux2_sel = 2'b0;
	 regfilemux_sel = 2'b0;
	 marmux_sel = 1'b0;
	 cmpmux_sel = 1'b0;
	 aluop = alu_ops'(funct3);
	 mem_read = 1'b0;
	 mem_write = 1'b0;
	 mem_byte_enable = 4'b1111;
	 
    /* Actions for each state */
	 case(state)
		fetch1: begin
			/* MAR <= PC */
			load_mar = 1;
		end
		
		fetch2: begin
			/* Read memory */
			mem_read = 1;
			load_mdr = 1;
		end
		
		fetch3: begin
			/* Load IR */
			load_ir = 1;
		end
		
		decode: /* Do Nothing */;
		
		s_auipc: begin
			/* DC <= PC + u_imm */
			load_regfile = 1;
			
			// PC is the first input to the ALU
			alumux1_sel = 1;
			
			// The u-type immediate is the second input to the ALU
			alumux2_sel = 1;
			
			// In the case of auipc, funct3 is some random bits so we
			// must explicitly set the aluop
			aluop = alu_add;
			
			/* PC <= PC + 4 */
			load_pc = 1;
		end
		
		s_imm: begin
			if (funct3 == 3'b010) begin
				/* SLTI */
				/* rd <= (rs1 ^ i_imm) */
				load_regfile = 1;
				
				// set necessary muxes
				regfilemux_sel = 1;
				cmpmux_sel = 1;
				
				// set the op for the cmp
				cmpop = blt; 
				
				/* PC <= PC + 4 */
				load_pc = 1;
			end else if (funct3 == 3'b011) begin
				/* SLTIU */
				/* rd <= (rs1 ^ i_imm) */
				load_regfile = 1;
				
				// set necessary muxes
				regfilemux_sel = 1;
				cmpmux_sel = 1;
				
				// set the op for the cmp
				cmpop = bltu; 
				
				/* PC <= PC + 4 */
				load_pc = 1;
			end else if (funct3 == 3'b101) begin
				if (funct7[5] == 1) begin
					/* SRAI */
					/* rd <= (rs1 ^ i_imm) */
					load_regfile = 1;
					
					/* alu_op <= alu_sra */
					aluop = alu_sra;
					
					/* PC <= PC + 4 */
					load_pc = 1;
				end
				else begin
					/* SRLI */
					/* rd <= (rs1 ^ i_imm) */
					load_regfile = 1;
				
					/* alu_op <= funct3 */
					aluop = alu_ops'(funct3);
				
					/* PC <= PC + 4 */
					load_pc = 1;
				end
			end else begin
				/* other */
				/* rd <= (rs1 ^ i_imm) */
				load_regfile = 1;
				
				aluop = alu_ops'(funct3);
				
				/* PC <= PC = 4 */
				load_pc = 1;
			end
		end
		
		s_reg: begin
			if (funct3 == 3'b010) begin
				/* SLT */
				/* rd <= (rs1 ^ i_imm) */
				load_regfile = 1;
				
				// set necessary muxes
				regfilemux_sel = 1;
				cmpmux_sel = 0;
				
				// set the op for the cmp
				cmpop = blt; 
				
				/* PC <= PC + 4 */
				load_pc = 1;
			end else if (funct3 == 3'b011) begin
				/* SLTU */
				/* rd <= (rs1 ^ i_imm) */
				load_regfile = 1;
				
				// set necessary muxes
				regfilemux_sel = 1;
				cmpmux_sel = 0;
				
				// set the op for the cmp
				cmpop = bltu; 
				
				/* PC <= PC + 4 */
				load_pc = 1;
			end else if (funct3 == 3'b101) begin
				if (funct7[5] == 1) begin
					/* SRA */
					/* rd <= (rs1 ^ i_imm) */
					load_regfile = 1;
					
					/* alu_op <= alu_sra */
					aluop = alu_sra;
					
					/* PC <= PC + 4 */
					load_pc = 1;
				end
				else begin
					/* SRL */
					/* rd <= (rs1 ^ i_imm) */
					load_regfile = 1;
				
					/* alu_op <= funct3 */
					aluop = alu_ops'(funct3);
				
					/* PC <= PC + 4 */
					load_pc = 1;
				end
			end else begin
				/* other */
				/* rd <= (rs1 ^ i_imm) */
				load_regfile = 1;
				
				if (funct3 == 3'b000) begin 
					if (funct7[5] == 1) begin 
						/* alu_op <= alu_sub */
						aluop = alu_sub; 
					end else begin 
						/* alu_op <= alu_add */
						aluop = alu_add; 
					end
				end else begin 
					/* alu_op <= funct3 */
					aluop = alu_ops'(funct3);
				end
				
				/* PC <= PC = 4 */
				load_pc = 1;
			end
		end
		
		s_lui: begin
			load_regfile = 1;
			regfilemux_sel = 2;
			load_pc = 1;
		end 
		
		s_br: begin
			alumux1_sel = 1;
			alumux2_sel = 2;
			aluop = alu_add;
			pcmux_sel = br_en;
			load_pc = 1;
		end
		
		s_jal: begin
			load_regfile = 1;
			regfilemux_sel = 3;
			alumux1_sel = 1;
			alumux2_sel = 1;
			aluop = alu_add;
			pcmux_sel = 1;
			load_pc = 1;
		end
		
		s_jalr: begin
		   load_regfile = 1;
			regfilemux_sel = 3;
			alumux1_sel = 0;
			alumux2_sel = 0;
			aluop = alu_add;
			pcmux_sel = 1;
			load_pc = 1;
		end 
		
		calc_addr: begin
		/* If we are to store the data... */
			if (opcode == op_store) begin 
				load_data_out = 1;
				alumux2_sel = 3;
			end 

			aluop = alu_add;
			marmux_sel = 1;
			load_mar = 1;
		end
		
		ld1: begin
		/* Byte */
			if (funct3 == 3'b000) begin 
				mem_byte_enable = 4'b0001;
			end 
		/* H */
			else if (funct3 == 3'b001) begin 
				mem_byte_enable = 4'b0011;
			end
		/* Word */
			else if (funct3 == 3'b010) begin 
				mem_byte_enable = 4'b1111;
			end
		/* Byte unsigned */
			else if (funct3 == 3'b100) begin 
				mem_byte_enable = 4'b0001;
			end
		/* H unsigned */ 
			else if (funct3 == 3'b101) begin
				mem_byte_enable = 4'b0011;
			end
			load_mdr = 1;
			mem_read = 1;
		end
		
		ld2: begin 
			regfilemux_sel = 3;
			load_regfile = 1;
			load_pc = 1;
		end
		
		st1: begin
		/* Byte */
			if (funct3 == 3'b000) begin 
				mem_byte_enable = 4'b0001;
			end 
		/* H */
			else if (funct3 == 3'b001) begin 
				mem_byte_enable = 4'b0011;
			end
		/* Word */
			else if (funct3 == 3'b010) begin 
				mem_byte_enable = 4'b1111;
			end
		/* Byte unsigned */
			else if (funct3 == 3'b100) begin 
				mem_byte_enable = 4'b0001;
			end
		/* H unsigned */ 
			else if (funct3 == 3'b101) begin
				mem_byte_enable = 4'b0011;
			end
			mem_write = 1;
		end
		
		st2: begin
			load_pc = 1;
		end
		
		default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	  next_states = state;
	  case(state)
			fetch1: next_states = fetch2;
			fetch2: if (mem_resp) next_states = fetch3;
			fetch3: next_states = decode; 
			decode: begin
				case(opcode)
					op_auipc: next_states = s_auipc;
					op_lui: next_states = s_lui;
					op_imm: next_states = s_imm;
					op_load: next_states = calc_addr;
					op_store: next_states = calc_addr;
					op_br: next_states = s_br;
					op_reg: next_states = s_reg;
					op_jal: next_states = s_jal;
					op_jalr: next_states = s_jalr;
					default: $display("Unknown opcode");
				endcase
			end
			calc_addr: begin
				case(opcode)
					op_load: next_states = ld1;
					op_store: next_states = st1;
					default: $display("Unknown opcode");
				endcase
			end
			ld1: if (mem_resp) next_states = ld2;
			st1: if (mem_resp) next_states = st2;
			default: next_states = fetch1;
		endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state = next_states;
end

endmodule : control
