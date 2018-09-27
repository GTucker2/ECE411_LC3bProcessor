import rv32i_types::*;

module mp2
(
	input clk,
	input pmem_rdata,
	input pmem_resp,
	output pmem_address,
	output pmem_wdata,
	output pmem_read,
	output pmem_write
);

/* 
 * CPU
 */  
 
cpu cpu
(
    .clk,
    .mem_resp,
    .mem_rdata,
    .mem_read,
    .mem_write,
    .mem_byte_enable,
    .mem_address,
    .mem_wdata
);

/*
 * CACHE
 */
cache cache 
(
	.clk,
	.mem_address,
	.mem_rdata,
	.mem_wdata,
	.mem_read,
	.mem_write,
	.mem_byte_enable,
	.mem_resp
); 

endmodule : mp2
