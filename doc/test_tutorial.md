# 测试教程

## 注意事项

在[defines.v](../rtl/defines.v)文件中,通过注释/取消注释前几行可以调整仿真参数

- PYTHON
  - 使用python自动化测试
  - 注释后使用Questa/modelsim测试
- SIM_TIME
  - 仿真时间,超时后打印`time out`并停止仿真
- ONE_INST_TEST
  - PC每变化一次便打印一次寄存器信息,便于仔细观察问题
  - 注释后每过一级测试输出一次信息
- PRINT_REGISTER
  - 运行过程中打印寄存器信息
  - 注释后不在运行过程中打印寄存器信息,只在指令测试失败时打印
- TEST_FILE
  - 使用Questa/modelsim测试时的测试指令

## Questa/modelsim测试方法

请先注释PYTHON

- modelsim
  - 修改[tcl](../sim/tcl/riscv.tcl)文件中21行
    - `vsim -vopt work.tb_riscv -voptargs=+acc`
    - 改为modelsim可以执行的仿真命令
  - 随后与Questa操作一致
- Questa
  - 打开测试工程[tb_riscv.mpf](../sim/tb_riscv.mpf),在transcript窗口中输入 `do tcl/riscv.tcl`
  - 随后便可以观察波形与transcript打印的指令测试信息了
- 注意事项
  - 可以自己修改add wave的内容,改变想看的波形
  - 仿真完关闭Questa/modelsim后,可以双击执行[killExtra.bat](../killExtra.bat)快速删除仿真中间文件与波形,减小存储消耗

## python自动化测试使用方法:

请先取消注释PYTHON

- 测试环境配置
  - 教程:B站搜索 BV1pZ4y1h7og
  - 另外感谢tiny RISCV的开源
- 打开命令行
  ```
  :: 进入sim\pytest\文件夹
  :: 其中$PATH为工程的绝对路径
  cd $PATH\sim\pytest

  :: 单条指令测试:执行auipc指令测试
  python test_one_inst.py auipc
  :: 单条指令测试:执行addi指令测试
  python test_one_inst.py addi
  :: 全测试:执行generated/所有bin文件
  python test_all.py
  ```
- 结果
  - print到cmd上了
    - 出现下图即测试成功
  - 也可以打开[fail.txt](sim/output/fail.txt)和[pass.txt](sim/output/pass.txt)查看具体指令测试结果

```
############################
#####  ALL INST PASS  ######
############################
```

## 寄存器表

| Register | Name   | Use                          | Saver  |
| :------- | :----- | :--------------------------- | :----- |
| x0       | zero   | Constant 0                   | -      |
| x1       | ra     | Return Address               | Caller |
| x2       | sp     | Stack Pointer                | Callee |
| x3       | gp     | Global Pointer               | -      |
| x4       | tp     | Thread Pointer               | -      |
| x5~x7    | t0~t2  | Temp                         | Caller |
| x8       | s0/fp  | Saved/Frame pointer          | Callee |
| x9       | s1     | Saved                        | Callee |
| x10~x11  | a0~a1  | Arguments/ <br> Return Value | Caller |
| x12~x17  | a2~a7  | Arguments                    | Caller |
| x18~x27  | s2~s11 | Saved                        | Callee |
| x28~x31  | t3~t6  | Temp                         | Caller |