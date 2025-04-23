import os
import subprocess
import sys
import shutil


def list_binfiles(path):
    files = []
    list_dir = os.walk(path)
    for maindir, subdir, all_file in list_dir:
        for filename in all_file:
            apath = os.path.join(maindir, filename)
            if apath.endswith('.bin'):
                files.append(apath)

    return files

def list_txtfiles(path):
    files = []
    list_dir = os.walk(path)
    for maindir, subdir, all_file in list_dir:
        for filename in all_file:
            apath = os.path.join(maindir, filename)
            if apath.endswith('.txt'):
                files.append(apath)

    return files

def bin_to_mem(infile, outfile):
    binfile = open(infile, 'rb')
    binfile_content = binfile.read(os.path.getsize(infile))
    datafile = open(outfile, 'w')

    index = 0
    b0 = 0
    b1 = 0
    b2 = 0
    b3 = 0

    for b in  binfile_content:
        if index == 0:
            b0 = b
            index = index + 1
        elif index == 1:
            b1 = b
            index = index + 1
        elif index == 2:
            b2 = b
            index = index + 1
        elif index == 3:
            b3 = b
            index = 0
            array = []
            array.append(b3)
            array.append(b2)
            array.append(b1)
            array.append(b0)
            datafile.write(bytearray(array).hex() + '\n')

    binfile.close()
    datafile.close()


def copy_file(input_file, output_file):
    try:
        shutil.copyfile(input_file, output_file)
        print(f"File {input_file} copied to {output_file} successfully.")
    except FileNotFoundError:
        print(f"Error: {input_file} not found.")
    except PermissionError:
        print(f"Error: Permission denied to copy {input_file} to {output_file}.")
    except Exception as e:
        print(f"Error: {e}")

# 调用函数
# copy_file("input.txt", "output.txt")


def compile():
    #获取上一级目录
    rtl_dir = os.path.abspath(os.path.join(os.getcwd(), "..",".."))
    # iverilog程序
    iverilog_cmd = ['iverilog']
    # 编译生成文件
    iverilog_cmd += ['-o', r'out.vvp']
    # 头文件(defines.v)路径
    # iverilog_cmd += ['-I', rtl_dir + r'/rtl']
    iverilog_cmd += ['-I', rtl_dir + r'/rtl/core']
    iverilog_cmd += ['-I', rtl_dir + r'/rtl/periph']
    iverilog_cmd += ['-I', rtl_dir + r'/rtl/soc']
    iverilog_cmd += ['-I', rtl_dir + r'/rtl/utils']
    iverilog_cmd += ['-I', rtl_dir + r'/tb']

    # testbench文件
    iverilog_cmd.append(rtl_dir + r'/tb/tb_riscv.v')

    # 内核core
    iverilog_cmd.append(rtl_dir + r'/rtl/core/ALU.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/control.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/imm_gen.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/core/ctrl.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/IF.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/ex.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/core/hazard_detection.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/core/id_unit.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/core/if_id.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/core/pc.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/register.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/riscv.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/wb.v')

    # 外设periph
    iverilog_cmd.append(rtl_dir + r'/rtl/periph/ram_interface.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/periph/ram.v')
    # iverilog_cmd.append(rtl_dir + r'/rtl/periph/rom.v')
    # 通用utils
    iverilog_cmd.append(rtl_dir + r'/rtl/utils/DFF.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/utils/dual_ram.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/utils/full_handshake_rx.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/utils/full_handshake_tx.v')

    # debug 工具
    
    iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_dm.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_driver.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_top.v')

    # 顶层soc
    iverilog_cmd.append(rtl_dir + r'/rtl/soc/riscv_soc.v')

    # 编译
    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=10)

def sim():
    # 1.编译rtl文件
    compile()
    # 2.运行
    vvp_cmd = [r'vvp']
    vvp_cmd.append(r'out.vvp')
    process = subprocess.Popen(vvp_cmd)
    # try:
    #     process.wait(timeout=3)
    # except subprocess.TimeoutExpired:
    #     print('!!!Fail, vvp exec timeout!!!')

def run(test_txtfile):
    # 获取上一级路径
    rtl_dir = os.path.abspath(os.path.join(os.getcwd(), "..",".."))
    # 文件名字
    out_mem = rtl_dir + r'/sim/generated/inst_data.txt'
    # bin 转 mem
    # bin_to_mem(test_binfile, out_mem)
    copy_file(test_txtfile, out_mem)
    # 运行仿真
    sim()

if __name__ == '__main__':
    sys.exit(run(sys.argv[1]))