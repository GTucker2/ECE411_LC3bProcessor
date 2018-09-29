import rv32i_types::*;

module cache_control
(
	 input mem_read,
	 input mem_write,
	 input pmem_resp,
	 input hit,
	 input dirty,
	 output set_dirty,
	 output set_valid,
	 output load_mem,
	 output mem_resp,
	 output load_tag,
	 output pmem_read,
	 output pmem_write,
	 output set_clean
);

enum int unsigned {
    idle,
	 tag_compare_1,
	 tag_compare_2,
	 allocate,
	 write_back
} state, next_states;

always_comb
begin : state_actions
	/* Default output assignments */
	set_dirty = 1'b0;
	set_valid = 1'b0;
	load_mem = 1'b0;
	mem_resp = 1'b0;
	load_tag = 1'b0;
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	set_clean = 1'b0;
end

case(state):
	idle: begin end
	tag_compare_1:
	begin
		if (valid && hit)
		begin
			load_tag = 1
			mem_resp = 1
		end
	end
	tag_compare_2:
	begin
		if (mem_write == 1)
		begin
			set_dirty = 1
			set_valid = 1
			load_mem = 1
		end
	end
	allocate:
	begin
		pmem_read = 1
		load_mem = 1
	end
	write_back:
	begin
		pmem_write = 1
		set_clean = 1
	end
endcase

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	  next_states = state;
	  case(state)
			idle:
			begin
				if (mem_read || mem_write)
					next_states = tag_compare_1;
			end
			tag_compare_1:
			begin
				if (mem_resp) next_states = idle;
				else next_states = tag_compare_2;
			end
			tag_compare_2:
			begin
				if (~hit && dirty) begin
					next_states = write_back;
				end else if (~hit && ~dirty) begin
					next_states = allocate;
				end
			end
			allocate:
			begin
				if (pmem_resp) begin
					next_states = tag_compare_1;
				end
			end
			write_back:
			begin
				if (pmem_resp_1) begin
					next_states = allocate;
				end
			end
			default: next_states = idle;
		endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state = next_states;
end

endmodule : cache_control
