import rv32i_types::*;

module cache_datapath
(
    input clk,
    input set_valid,
    input [15:0] mem_address,
    input set_clean,
    input set_dirty,
    input load_tag,
    input load_mem,
    input mem_write,
    input pmem_read,
    input [3:0] mem_byte_enable,
    input [31:0] mem_wdata,
    input [255:0] pmem_rdata,
    output [255:0] pmem_rdata,
    output [31:0] pmem_address,
    output [31:0] mem_rdata,
    output hit,
    output valid,
    output dirty,
);

/* Addressing connections */
logic [2:0] set = mem_address[7:5];
logic [4:0] offset = mem_address[4:0];
logic [23:0] tag = mem_address[31:8];

/* LRU connections */
logic lru_dataout;
logic lru_decoder_out_0;
logic lru_decoder_out_1;
logic [127:0] lru_mux_out;

/* Firstvalid connections */
logic firstvalid_write = (set_valid & lru_decoder_out_0);
logic [127:0] firstvalid_out;

/* Firstdirty connections */
logic firstdirty_write = ((set_clean | set_dirty) & lru_decoder_out_0);
logic firstdirty_datain = (~set_clean & sit_dirty);
logic [127:0] firstdirty_out;

/* Firsttag connections */
logic firsttag_write = (load_tag & lru_decoder_out_0);
logic [127:0] firsttag_out;

/* Firstdata connections */
logic firstdata_write = (load_mem & lru_decoder_out_0);
logic [255:0] firstdata_out;

/* Othervalid connections */
logic othervalid_write = (set_valid & lru_decoder_out_1);
logic [127:0] othervalid_out;

/* Otherdirty connections */
logic otherdirty_write = ((set_clean | set_dirty) & lru_decoder_out_1);
logic otherdirty_datain = (~set_clean & sit_dirty);
logic [127:0] otherdirty_out;

/* Othertag connections */
logic othertag_write = (load_tag & lru_decoder_out_1);
logic [127:0] othertag_out;

/* Otherdata connections */
logic otherdata_write = (load_mem & lru_decoder_out_1);
logic [255:0] otherdata_out;

/* tagcmp connections */
logic firsttagcmp_out;
logic othertagcmp_out;

/* Output connections */
logic [255:0] dataoutmux_out;
logic validoutmux_out;
logic dirtyoutmux_out;

/* Dataload system connections */
logic dataloadoutmux_sel = (pmem_read & ~mem_write);
logic [255:0] dataloadsys_out;
logic [255:0] readmux_out;
logic [255:0] writemux_out;
logic offsetdecoder_out[31:0];

/* Pmem addressing connections */
logic [31:0] offsetaddrmux_out;
logic [31:0] setaddrmux_out;

/*
 * LRU
 */

mux2 lru_mux
(
    .sel(),
    .a(0),
    .b(1),
    .f(lru_mux_out)
);

array lru_array
(
    .clk,
    .write(load_mem),
    .index(set),
    .datain(lru_mux_out),
    .dataout(lru_dataout)
);

decoder2 lru_decoder
(
    .sel(lru_dataout)
    .a(0),
    .b(1),
    .f(lru_decoder_out_0),
    .g(lru_decoder_out_1)
);

/*
 * DATALOAD SYSTEM
 */

decoder32 offset_decoder
(
    .sel(offset),
    .out(offsetdecoder_out)
);

mux2 readmux_0 ( .sel(offsetdecoder_out[0]), .a(dataoutmux_out[7:0]), .b(pmem_rdata[7:0]), .f(readmux_out[7:0]) );
mux2 readmux_1 ( .sel(offsetdecoder_out[1]), .a(dataoutmux_out[15:8]), .b(pmem_rdata[15:8]), .f(readmux_out[15:8]) );
mux2 readmux_2 ( .sel(offsetdecoder_out[2]), .a(dataoutmux_out[23:16]), .b(pmem_rdata[23:16]), .f(readmux_out[23:16]) );
mux2 readmux_3 ( .sel(offsetdecoder_out[3]), .a(dataoutmux_out[31:24]), .b(pmem_rdata[31:24]), .f(readmux_out[31:24]) );
mux2 readmux_4 ( .sel(offsetdecoder_out[4]), .a(dataoutmux_out[39:32]), .b(pmem_rdata[39:32]), .f(readmux_out[39:32]) );
mux2 readmux_5 ( .sel(offsetdecoder_out[5]), .a(dataoutmux_out[47:40]), .b(pmem_rdata[47:40]), .f(readmux_out[47:40]) );
mux2 readmux_6 ( .sel(offsetdecoder_out[6]), .a(dataoutmux_out[55:48]), .b(pmem_rdata[55:48]), .f(readmux_out[55:48]) );
mux2 readmux_7 ( .sel(offsetdecoder_out[7]), .a(dataoutmux_out[63:56]), .b(pmem_rdata[63:56]), .f(readmux_out[63:56]) );
mux2 readmux_8 ( .sel(offsetdecoder_out[8]), .a(dataoutmux_out[71:64]), .b(pmem_rdata[71:64]), .f(readmux_out[71:64]) );
mux2 readmux_9 ( .sel(offsetdecoder_out[9]), .a(dataoutmux_out[79:72]), .b(pmem_rdata[79:72]), .f(readmux_out[79:72]) );
mux2 readmux_10 ( .sel(offsetdecoder_out[10]), .a(dataoutmux_out[87:80]), .b(pmem_rdata[87:80]), .f(readmux_out[87:80]) );
mux2 readmux_11 ( .sel(offsetdecoder_out[11]), .a(dataoutmux_out[95:88]), .b(pmem_rdata[95:88]), .f(readmux_out[95:88]) );
mux2 readmux_12 ( .sel(offsetdecoder_out[12]), .a(dataoutmux_out[103:96]), .b(pmem_rdata[103:96]), .f(readmux_out[103:96]) );
mux2 readmux_13 ( .sel(offsetdecoder_out[13]), .a(dataoutmux_out[111:104]), .b(pmem_rdata[111:104]), .f(readmux_out[111:104]) );
mux2 readmux_14 ( .sel(offsetdecoder_out[14]), .a(dataoutmux_out[119:112]), .b(pmem_rdata[119:112]), .f(readmux_out[119:112]) );
mux2 readmux_15 ( .sel(offsetdecoder_out[15]), .a(dataoutmux_out[127:120]), .b(pmem_rdata[127:120]), .f(readmux_out[127:120]) );
mux2 readmux_16 ( .sel(offsetdecoder_out[16]), .a(dataoutmux_out[135:128]), .b(pmem_rdata[135:128]), .f(readmux_out[135:128]) );
mux2 readmux_17 ( .sel(offsetdecoder_out[17]), .a(dataoutmux_out[143:136]), .b(pmem_rdata[143:136]), .f(readmux_out[143:136]) );
mux2 readmux_18 ( .sel(offsetdecoder_out[18]), .a(dataoutmux_out[151:144]), .b(pmem_rdata[151:144]), .f(readmux_out[151:144]) );
mux2 readmux_19 ( .sel(offsetdecoder_out[19]), .a(dataoutmux_out[159:152]), .b(pmem_rdata[159:152]), .f(readmux_out[159:152]) );
mux2 readmux_20 ( .sel(offsetdecoder_out[20]), .a(dataoutmux_out[167:160]), .b(pmem_rdata[167:160]), .f(readmux_out[167:160]) );
mux2 readmux_21 ( .sel(offsetdecoder_out[21]), .a(dataoutmux_out[175:168]), .b(pmem_rdata[175:168]), .f(readmux_out[175:168]) );
mux2 readmux_22 ( .sel(offsetdecoder_out[22]), .a(dataoutmux_out[183:176]), .b(pmem_rdata[183:176]), .f(readmux_out[183:176]) );
mux2 readmux_23 ( .sel(offsetdecoder_out[23]), .a(dataoutmux_out[191:184]), .b(pmem_rdata[191:184]), .f(readmux_out[191:184]) );
mux2 readmux_24 ( .sel(offsetdecoder_out[24]), .a(dataoutmux_out[199:192]), .b(pmem_rdata[199:192]), .f(readmux_out[199:192]) );
mux2 readmux_25 ( .sel(offsetdecoder_out[25]), .a(dataoutmux_out[207:200]), .b(pmem_rdata[207:200]), .f(readmux_out[207:200]) );
mux2 readmux_26 ( .sel(offsetdecoder_out[26]), .a(dataoutmux_out[215:208]), .b(pmem_rdata[215:208]), .f(readmux_out[215:208]) );
mux2 readmux_27 ( .sel(offsetdecoder_out[27]), .a(dataoutmux_out[223:216]), .b(pmem_rdata[223:216]), .f(readmux_out[223:216]) );
mux2 readmux_28 ( .sel(offsetdecoder_out[28]), .a(dataoutmux_out[231:224]), .b(pmem_rdata[231:224]), .f(readmux_out[231:224]) );
mux2 readmux_29 ( .sel(offsetdecoder_out[29]), .a(dataoutmux_out[239:232]), .b(pmem_rdata[239:232]), .f(readmux_out[239:232]) );
mux2 readmux_30 ( .sel(offsetdecoder_out[30]), .a(dataoutmux_out[247:240]), .b(pmem_rdata[247:240]), .f(readmux_out[247:240]) );
mux2 readmux_31 ( .sel(offsetdecoder_out[31]), .a(dataoutmux_out[255:248]), .b(pmem_rdata[255:248]), .f(readmux_out[255:248]) );

mux2 dataloadoutput_mux
(
    .sel(dataloadoutmux_sel),
    .a(writemux_out),
    .b(readmux_out),
    .f(dataloadsys_out)
);*/

/*
 * WAY 1
 */

array firstvalid
(
    .clk,
    .write(firstvalid_write),
    .index(set),
    .datain(set_valid),
    .dataout(firstvalid_out)
);

array firstdirty
(
    .clk,
    .write(firstdirty_write),
    .index(set),
    .datain(firstdirty_datain),
    .dataout(firstdirty_out)
);

array firsttag
(
    .clk,
    .write(firsttag_write),
    .index(set),
    .datain(tag),
    .dataout(firsttag_out)
);

array firstdata_UH
(
    .clk,
    .write(firstdata_write),
    .index(set),
    .datain(dataloadsys_out[255:128]),
    .dataout(firstdata_out[255:128])
);

array firstdata_LH
(
    .clk,
    .write(firstdata_write),
    .index(set),
    .datain(dataloadsys_out[127:0]),
    .dataout(firstdata_out[127:0])
);

cache_cmp firsttagcmp
(
    .a(tag),
    .b(firsttag_out),
    .f(firsttagcmp_out)
);

/*
 * WAY 2
 */

array othervalid
(
    .clk,
    .write(othervalid_write),
    .index(set),
    .datain(set_valid),
    .dataout(othervalid_out)
);

array otherdirty
(
    .clk,
    .write(otherdirty_write),
    .index(set),
    .datain(otherdirty_datain),
    .dataout(otherdirty_out)
);

array othertag
(
    .clk,
    .write(othertag_write),
    .index(set),
    .datain(tag),
    .dataout(othertag_out)
);

array otherdata_UH
(
    .clk,
    .write(otherdata_write),
    .index(set),
    .datain(dataloadsys_out[255:128]),
    .dataout(otherdata_out[255:128])
);

array otherdata_LH
(
    .clk,
    .write(otherdata_write),
    .index(set),
    .datain(dataloadsys_out[127:0]),
    .dataout(otherdata_out[127:0])
);

cache_cmp othertagcmp
(
    .a(tag),
    .b(othertag_out),
    .f(othertagcmp_out)
);

/* OUTPUT PATHS */

mux2 dataout_mux
(
    .sel(lru_decoder_out_1),
    .a(firstdata_out),
    .b(otherdata_out),
    .f(dataoutmux_out)
);

mux2 dirtyout_mux
(
    .sel(lru_decoder_out_1),
    .a(firstdirty_out),
    .b(otherdirty_out),
    .f(dirtyoutmux_out)
);

mux2 validout_mux
(
    .sel(lru_decoder_out_1),
    .a(firstvalid_out),
    .b(othervalid_out),
    .f(validoutmux_out)
);

always_comb begin
    hit = (othertagcmp_out | firsttagcmp_out);
    pmem_wdata = dataoutmux_out;
    valid = validoutmux_out;
    dirty = dirtyoutmux_out;
end

/* PMEM ADDRESS CALCULATOR */

mux32 offsetaddr_mux
(
     .sel(offset),
     .a(0),
     .b(8),
     .c(16),
     .d(24),
     .e(32),
     .f(40),
     .g(48),
     .h(56),
     .i(64),
     .j(72),
     .k(80),
     .l(88),
     .m(96),
     .n(104),
     .o(112),
     .p(120),
     .q(128),
     .r(136),
     .s(144),
     .t(152),
     .u(160),
     .v(168),
     .w(176),
     .x(184),
     .y(192),
     .z(200),
     .aa(208),
     .bb(216),
     .cc(224),
     .dd(232),
     .ee(240),
     .ff(248),
     .out(offsetaddrmux_out)
);

mux8 setaddr_mux
(
    .sel(set),
    .a(0),
    .b(256),
    .c(512),
    .d(768),
    .e(1024),
    .f(1280),
    .g(1536),
    .h(1792),
    .i(setaddrmux_out)
);

always_comb begin
    pmem_address = (offsetaddrmux_out | setaddrmux_out);
end

endmodule : cache_datapath
