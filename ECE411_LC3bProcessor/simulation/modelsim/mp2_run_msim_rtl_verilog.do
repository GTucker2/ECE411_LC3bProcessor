transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/rv32i_types.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/register.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/regfile.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/pc_reg.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/mux2.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/mux4.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/mux8.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/ir.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/datapath.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/control.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/alu.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/cmp.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/mp2.sv}

vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/mp2_tb.sv}
vlog -sv -work work +incdir+/home/gtucker2/ece411/mp2 {/home/gtucker2/ece411/mp2/memory.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixiv_hssi_ver -L stratixiv_pcie_hip_ver -L stratixiv_ver -L rtl_work -L work -voptargs="+acc"  mp2_tb

add wave *
view structure
view signals
run 200 ns
