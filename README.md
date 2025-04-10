自动化测试使用方法:
- 打开Anaconda Prompt
  ```
  :: 进入sim\pytest\文件夹
  :: 其中$PATH为工程的绝对路径
  cd $PATH\sim\pytest

  :: 单条指令测试:执行auipc指令测试
  python test_one_inst.py auipc
  :: 全测试:执行generated/所有bin文件
  python test_all.py
  ```
- 结果
  - print到cmd上了
  - 也可以打开[fail.txt](sim/output/fail.txt)和[pass.txt](sim/output/pass.txt)查看



笔记:
- 大小端模式:
  - 大端模式:高字节放在低地址,低字节放在高地址
    > 高对低,低对高
  - 小端模式:低字节放在低地址,高字节放在高地址
    > 高对高,低对低

if取指令
instruction fetch

 
流水线冲刷
跳转指令执行时,将前面取指,译码模块的内容用nop冲刷掉


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


R-Type ：为寄存器操作数指令，含2个源寄存器rs1,rs2和一个目的寄存器rd。
I-Type ：为立即数操作指令，含一个源寄存器和一个目的寄存器和一个12bit立即数操作数
S-Type ：为存储器写指令，含两个源寄存器和一个12bit立即数。
B-Type：为跳转指令，实际是S-Type的变种。与S-Type主要的区别是立即数编码。S-Type中的imm[11:5]变为{immm[12], imm[10:5]}，imm[4:0]变为{imm[4:1], imm[11]}。
U-Type ：为长立即数指令，含一个目的寄存器和20bit立即数操作数。
J-Type：为长跳转指令，实际是U-Type的变种。与U-Type主要的区别是立即数编码。U-Type中的imm[31:12]变为{imm[20], imm[10:1], imm[11], imm[19:12]}。




如果nop和busy同时来
hold[1] = 1
nop_reg = 1
等busy=0
nop_reg = 0


| data_busy | should_nop | nop_reg |  nop  | nop_reg |
| :-------: | :--------: | :-----: | :---: | :-----: |
|     0     |     0      |    0    |   0   |    0    |
|     0     |     1      |    x    |   1   |    0    |
|     1     |     0      |    0    |   1   |    0    |
|     1     |     0      |    1    |   1   |    1    |
|     1     |     1      |    0    |   1   |    1    |
|     0     |     0      |    1    |   1   |    0    |




|          |   冲刷   |                 暂停                 |
| :------: | :------: | :----------------------------------: |
|   条件   | 出现跳转 | $出现严重数据冒险\\访存接收busy信号$ |
| 控制信号 |   无效   |                 无效                 |
| 数据信号 |   无效   |                 保持                 |


|       |               [1]               |          [0]           |
| :---: | :-----------------------------: | :--------------------: |
| hold  |    全部pipe_dff停滞,对应busy    | 仅pc,IF_ID停滞,对应nop |
| flush | IF_ID,ID_EX,EX_MEM冲刷,对应jump |   ID_EX冲刷,对应nop    |






- 连续访存指令时
  - 第一次busy高电平无视,其他时候与单次访存行为一致
  - 给信号
    - 第一次给出去,第二次无视busy给出去,第三次若busy为高,暂停
  - 取数据
    - 第一次busy无视,第二次MEM_WB保留rd_addr,等到busy为低,取数据


- 单次访存指令
  - 给信号
    - 地址给出去,若busy为高,暂停
  - 取数据
    - 若busy为高,暂停

hold控制下一拍不动


访存:出现busy全部停一拍
