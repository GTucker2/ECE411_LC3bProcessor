import rv32i_types::*;

module cpu
(
    input clk,

    /* Memory signals */
    input mem_resp,
    input [31:0] mem_rdata,
    output mem_read,
    output mem_write,
    output [3:0] mem_byte_enable,
    output [31:0] mem_address,
    output [31:0] mem_wdata
);

rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic bit30;
logic br_en;
logic load_pc;
logic load_ir;
logic load_regfile;
logic load_mar;
logic load_mdr;
logic pcmux_sel;
logic [1:0] regfilemux_sel;
logic marmux_sel;
alu_ops aluop;
logic alumux1_sel;
logic [1:0] alumux2_sel;
branch_funct3_t cmpop;
logic cmpmux_sel;
logic load_data_out;
logic jalr;


/* Instantiate MP 0 top level blocks here */

cpu_control cpu_control
(
    .clk,
	 .opcode,
	 .load_pc,
	 .load_ir,
	 .load_regfile,
	 .load_mar,
	 .load_mdr,
	 .load_data_out,
	 .pcmux_sel,
	 .cmpop,
	 .alumux1_sel,
	 .alumux2_sel,
	 .regfilemux_sel,
	 .marmux_sel,
	 .cmpmux_sel,
	 .aluop,
	 .funct3,
	 .funct7,
	 .mem_resp,
	 .br_en,
	 .mem_read,
	 .mem_write,
	 .mem_byte_enable 
);

cpu_datapath cpu_datapath
(
    .clk,
	 .load_mar,
	 .load_mdr,
	 .aluop,
    .pcmux_sel,
	 .load_ir,
    .load_pc,
	 .load_regfile,
	 .load_data_out,
	 .cmpmux_sel,
	 .marmux_sel,
	 .alumux1_sel,
	 .alumux2_sel,
	 .regfilemux_sel,
	 .cmpop,
	 .mem_rdata,
	 .mem_wdata,
	 .mem_address,
	 .opcode,
	 .funct3,
	 .funct7,
	 .br_en
);

endmodule : cpu
