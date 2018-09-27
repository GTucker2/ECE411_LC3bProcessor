import rv32i_types::*;

module datapath
(
    input clk,

    /* control signals */
	 input load_mar,
	 input load_mdr,
	 input alu_ops aluop,
    input pcmux_sel,
	 input load_ir,
    input load_pc,
	 input load_regfile,
	 input load_data_out,
	 input cmpmux_sel,
	 input marmux_sel,
	 input alumux1_sel,
	 input [1:0] alumux2_sel,
	 input [1:0] regfilemux_sel,

    /* declare more ports here */
	 input branch_funct3_t cmpop,
	 input rv32i_word mem_rdata,
	 output rv32i_word mem_wdata,
	 output rv32i_word mem_address,
	 output rv32i_opcode opcode,
	 output [2:0] funct3,
	 output [6:0] funct7,
	 output logic br_en
);

/* declare internal signals */
rv32i_word pcmux_out;
rv32i_word postalumux_out;
rv32i_word alumux1_out;
rv32i_word alumux2_out;
rv32i_word alumux2_2_out;
rv32i_word pc_out;
rv32i_word alu_out;
rv32i_word pc_plus4_out;
rv32i_word rs1_out, rs2_out;
rv32i_word i_imm, u_imm, b_imm, s_imm, j_imm;
rv32i_word cmpmux_out;
rv32i_word marmux_out;
rv32i_word regfilemux_out;
rv32i_word mdr_out;
rv32i_word cmp_out;
rv32i_reg rs1, rs2, rd;

/*
 * IR
 */
ir IR
(
	.clk(clk),
   .load(load_ir),
   .in(mdr_out),
   .funct3(funct3),
   .funct7(funct7),
   .opcode(opcode),
   .i_imm(i_imm),
   .s_imm(s_imm),
   .b_imm(b_imm),
   .u_imm(u_imm),
   .j_imm(j_imm),
   .rs1(rs1),
   .rs2(rs2),
   .rd(rd)
);

/*
 * CMP
 */
mux2 cmpmux
(
	.sel(cmpmux_sel),
	.a(rs2_out),
	.b(i_imm),
	.f(cmpmux_out)
);

cmp cmp
(
	.cmpop(cmpop),
	.a(rs1_out),
	.b(cmpmux_out),
	.f(cmp_out)
);

always_comb begin
	br_en = cmp_out[0];
end

/*
 * MAR
 */
mux2 marmux
(
	.sel(marmux_sel),
	.a(pc_out),
	.b(postalumux_out),
	.f(marmux_out)
);
 
register mar
(
	.clk(clk),
   .load(load_mar),
   .in(marmux_out),
   .out(mem_address)
); 
 
/*
 * MDR
 */ 
register mdr
(
	.clk(clk),
	.load(load_mdr),
	.in(mem_rdata),
	.out(mdr_out)
);
 
/*
 * REG_FILE
 */
 
mux8 regfilemux
(
	.sel({opcode[3],regfilemux_sel}),
	.a(postalumux_out),
	.b(cmp_out),
	.c(u_imm),
	.d(mdr_out),
	.e(u_imm),
	.f(pc_plus4_out),
	.g(u_imm),
	.h(pc_plus4_out),
	.i(regfilemux_out)
);

regfile regfile
(
	.clk(clk),
	.load(load_regfile),
	.in(regfilemux_out),
	.src_a(rs1), 
	.src_b(rs2), 
	.dest(rd),
   .reg_a(rs1_out), 
	.reg_b(rs2_out)
);

/*
 * PC
 */
mux2 pcmux
(
    .sel(pcmux_sel),
    .a(pc_plus4_out),
    .b(postalumux_out),
    .f(pcmux_out)
);

pc_register pc
(
    .clk,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);

always_comb begin
	pc_plus4_out = pc_out + 4;
end

/*
 * MEM_DATA_OUT
 */
 
register memdataout
(
	.clk(clk),
   .load(load_data_out),
   .in(rs2_out),
   .out(mem_wdata)
); 

/*
 * ALU
 */
 
mux2 alumux1
(
	.sel(alumux1_sel),
   .a(rs1_out),
   .b(pc_out),
   .f(alumux1_out)
);

mux8 alumux2_1
(
	.sel({opcode[3],alumux2_sel}),
	.a(i_imm),
	.b(u_imm),
	.c(b_imm),
	.d(s_imm),
	.e(j_imm),
	.f(j_imm),
	.g(j_imm),
	.h(j_imm),
	.i(alumux2_out)
);

mux2 alumux2_2
(
	.sel((opcode[6] ^ opcode[5]) & opcode[4]),
	.a(alumux2_out),
	.b(rs2_out),
	.f(alumux2_2_out)
);
 
alu alu
(
	.aluop(aluop),
   .a(alumux1_out), 
	.b(alumux2_2_out),
   .f(alu_out)
);

mux2 postalumux
(
	.sel(opcode[6]),
	.a(alu_out),
	.b({alu_out[31:1],1'b0}),
	.f(postalumux_out)
);

endmodule : datapath
