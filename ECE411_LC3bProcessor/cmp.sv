import rv32i_types::*;

module cmp #(parameter width = 32)
(
	input branch_funct3_t cmpop,
	input [width-1:0] a, b,
	output logic [width-1:0] f
);

rv32i_word mux_out;
logic beq_r, bne_r, blt_r, bge_r;	

/* computes possible signals to send */
always_comb
	begin
		if (a == b)
		begin
			beq_r = 1;
			bne_r = 0;
		end
		else
		begin
			beq_r = 0;
			bne_r = 1;
		end
		if (cmpop[1] == 1)
		begin
			if (a < b)
			begin
				blt_r = 1;
				bge_r = 0;
			end
			else
			begin
				blt_r = 0;
				bge_r = 1;
			end
		end
		else
		begin
			if ($signed(a) < $signed(b))
			begin
				blt_r = 1;
				bge_r = 0;
			end
			else
			begin
				blt_r = 0;
				bge_r = 1;
			end
		end
	end
	
/* designates an output value based on the cmpop */
mux4 internalmux
(
	.sel({cmpop[2],cmpop[0]}),
	.a({31'h0, beq_r}),
	.b({31'h0, bne_r}),
	.c({31'h0, blt_r}),
	.d({31'h0, bge_r}),
	.f(mux_out)
);

/* picks the final output based on the cmpop */
always_comb
	begin
		if(cmpop == 3'b010)
			f = $signed(a) ^ $signed(b);
		else if(cmpop == 3'b011)
			f = a ^ b;
		else
			f = mux_out;
	end

endmodule : cmp