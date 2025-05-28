############################## 基础配置#############################
#退出当前仿真
quit -sim
#清除命令和信息
.main clear

##############################编译和仿真文件#########################
vlib work

# 编译文件

vlog +incdir+"../rtl/" "../rtl/*.v"
vlog +incdir+"../rtl/" "../rtl/core/*.v"
vlog +incdir+"../rtl/" "../rtl/periph/*.v"
vlog +incdir+"../rtl/" "../rtl/soc/*.v"
vlog +incdir+"../rtl/" "../rtl/utils/*.v"
vlog +incdir+"../rtl/" "../rtl/debug/*.v"
vlog +incdir+"../rtl/" "../tb/tb_riscv.v"

# 进行设计优化,但又保证所有信号可见,速度较快
vsim -vopt work.tb_riscv -voptargs=+acc

# 添加虚拟类型
virtual    type {
{01 IF}
{02 EX}
} vir_new_signal
#添加波形区分说明
add wave -divider {complex_fsm_inst}
#添加波形
virtual    function {(vir_new_signal)tb_riscv/riscv_soc_inst/riscv_inst/control_inst/state} STATE
add wave  -color purple  -itemcolor blue  tb_riscv/riscv_soc_inst/riscv_inst/control_inst/STATE

add wave -divider {PC} 
add wave tb_riscv/riscv_soc_inst/riscv_inst/pc_inst/*
add wave -divider {REGISTER} 
# add wave -label "REGISTER" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem
add wave -label "ra" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[1]
add wave -label "sp" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[2]
add wave -label "gp" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[3]
add wave -label "tp" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[4]
for {set i 0} {$i < 3} {incr i} {add wave -label "t$i" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[[expr $i + 5]]}
add wave -label "s0/fp" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[8]
add wave -label "s1" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[9]
for {set i 0} {$i < 8} {incr i} {add wave -label "a$i" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[[expr $i + 10]]}
for {set i 2} {$i < 12} {incr i} {add wave -label "s$i" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[[expr $i + 16]]}
for {set i 3} {$i < 7} {incr i} {add wave -label "t$i" tb_riscv/riscv_soc_inst/riscv_inst/register_inst/reg_mem[[expr $i + 25]]}
# add wave -divider {MEM_WB} 
# add wave tb_riscv/riscv_soc_inst/riscv_inst/mem_wb_inst/*
# add wave -divider {IMM_GEN} 
# add wave tb_riscv/riscv_soc_inst/riscv_inst/id_unit_inst/imm_gen_inst/*
# add wave -divider {ID} 
# add wave tb_riscv/riscv_soc_inst/riscv_inst/id_unit_inst/control_inst/*
add wave  -color purple  -itemcolor blue  tb_riscv/riscv_soc_inst/riscv_inst/control_inst/STATE
add wave -divider {CONTROL} 
add wave tb_riscv/riscv_soc_inst/riscv_inst/control_inst/*
add wave -divider {IMM_GEN} 
add wave tb_riscv/riscv_soc_inst/riscv_inst/imm_gen_inst/*
add wave  -color purple  -itemcolor blue  tb_riscv/riscv_soc_inst/riscv_inst/control_inst/STATE
add wave -divider {IF} 
add wave tb_riscv/riscv_soc_inst/riscv_inst/IF_inst/*
add wave -divider {EX} 
add wave tb_riscv/riscv_soc_inst/riscv_inst/ex_inst/*
add wave -divider {ALU} 
add wave tb_riscv/riscv_soc_inst/riscv_inst/ex_inst/ALU_inst/*
# add wave -divider {HAZARD_DETECTION} 
# add wave tb_riscv/riscv_soc_inst/riscv_inst/hazard_detection_inst/*
# add wave -divider {ROM} 
# add wave tb_riscv/riscv_soc_inst/rom_inst/r_addr
# add wave tb_riscv/riscv_soc_inst/rom_inst/r_data
add wave  -color purple  -itemcolor blue  tb_riscv/riscv_soc_inst/riscv_inst/control_inst/STATE
add wave -divider {RISCV} 
add wave tb_riscv/riscv_soc_inst/riscv_inst/*


add wave -divider {RAM_INTERFACE} 
add wave tb_riscv/riscv_soc_inst/ram_interface_inst/*
add wave -divider {RAM} 
add wave tb_riscv/riscv_soc_inst/ram_inst/*
add wave  -color purple  -itemcolor blue  tb_riscv/riscv_soc_inst/riscv_inst/control_inst/STATE

# add wave -divider {RAM_BYTE0} 
# add wave tb_riscv/riscv_soc_inst/ram_inst/ram_byte0/*
# add wave -divider {RAM_BYTE1} 
# add wave tb_riscv/riscv_soc_inst/ram_inst/ram_byte1/*
# add wave -divider {RAM_BYTE2} 
# add wave tb_riscv/riscv_soc_inst/ram_inst/ram_byte2/*
# add wave -divider {RAM_BYTE3} 
# add wave tb_riscv/riscv_soc_inst/ram_inst/ram_byte3/*

configure wave -signalnamewidth 1

################################运行仿真#############################
# run 40ns
run 20us
# run -all
# quit -sim