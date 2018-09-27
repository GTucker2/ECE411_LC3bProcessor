import rv32i_types::*;

module cache
(
	input clk,
	input [15:0] mem_address,
	output [15:0] mem_rdata,
	input [15:0] mem_wdata,
	input mem_read,
	input mem_write,
	input [3:0] mem_byte_enable,
	output mem_resp
);

/* 
 * DATAPATH
 */  
 
cache_datapath
(
);

/*
 * CONTROL
 */
cache_control
(
	.mem_read,
	.mem_write,
	.pmem_resp,
	.hit,
	.dirty,
	.set_dirty,
	.set_valid,
	.load_mem,
	.mem_resp,
	.load_tag,
	.pmem_read,
	.pmem_write,
	.set_clean
); 

endmodule : cache
