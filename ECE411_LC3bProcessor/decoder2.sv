import rv32i_types::*;

module decoder2
(
    input sel,
    input a,
    input b,
    output f,
    output g,
);

always_comb begin
    if (sel == a) begin
        f = 1;
        g = 0;
    end else if (sel == b) begin
        f = 0;
        g = 1;
    end else begin
        f = 0;
        g = 0;
    end
end

endmodule : decoder2
