# 开发文档

## 测试方法

### 自动化测试使用方法:

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

### 寄存器表

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

## 设计思路


### 状态图

| 状态  |                    CPU动作                    |
| :---: | :-------------------------------------------: |
|  IF   |      jump_addr计算并输出至ROM,同时给入PC      |
|  MEM  |  访存:result即mem_addr,根据wmem选择是否写入   |
|  MEM  |    跳转:result计算,判断并存储跳转条件jump     |
|  WB   | result计算,根据rmem选择写回mem_data还是result |

### 控制信号

|       |   指令    |  SEL  | 输入1 | 输入2 | CTRL  |
| :---: | :-------: | :---: | :---: | :---: | :---: |
|  IF   |   jalr    |   1   |  rs1  |  imm  |   0   |
|  IF   | cjump/jal |   3   |  PC   |  imm  |   0   |
|  IF   |   ~jump   |   4   |  PC   |   4   |   0   |
| ----- |   -----   | ----- | ----- | ----- | ----- |
|  MEM  |    R/B    |   0   |  rs1  |  rs2  |   1   |
|  MEM  |   I/L/S   |   1   |  rs1  |  imm  |   1   |
|  MEM  |    lui    |   2   |   0   |  imm  |   1   |
|  MEM  |   auipc   |   3   |  PC   |  imm  |   1   |
|  MEM  | jalr/jal  |   4   |  PC   |   4   |   1   |
| ----- |   -----   | ----- | ----- | ----- | ----- |
|  WB   |   同MEM   | 同MEM | 同MEM | 同MEM | 同MEM |

### inst_dff设计原因

IF阶段输出ROM地址
MEM/EX阶段接收inst并访存,此时IF存住
WB阶段读回数据,此时inst会被冲刷成RAM的data,所以上一拍就要存住inst

## 优化计划
修改state逻辑:变为IF,EX,MEM
非load指令只用两排,且不用inst_dff寄存器,降低功耗
load指令与以前相同
大概思路
非LOAD:EX写回,跳转到IF,inst_dff不用EN,inst选择mem_rdata
LOAD:EX访存,此时不写回,跳转到MEM写回,再跳转到IF,inst沿用之前的电路


### 状态图

| 状态  |                        CPU动作                        |
| :---: | :---------------------------------------------------: |
|  IF   |          jump_addr计算并输出至ROM,同时给入PC          |
|  EX   | 访存:result即mem_addr,若为load指令,跳入MEM,否则回到IF |
|  EX   |         跳转:判断并存储跳转条件,供IF阶段使用          |
|  MEM  |                     写回mem_data                      |


### 控制信号

|       |   指令    |  SEL  | 输入1 | 输入2 | CTRL  |
| :---: | :-------: | :---: | :---: | :---: | :---: |
|  IF   |   jalr    |   1   |  rs1  |  imm  |   0   |
|  IF   | cjump/jal |   3   |  PC   |  imm  |   0   |
|  IF   |   ~jump   |   4   |  PC   |   4   |   0   |
| ----- |   -----   | ----- | ----- | ----- | ----- |
|  EX   |    R/B    |   0   |  rs1  |  rs2  |   1   |
|  EX   |   I/L/S   |   1   |  rs1  |  imm  |   1   |
|  EX   |    lui    |   2   |   0   |  imm  |   1   |
|  EX   |   auipc   |   3   |  PC   |  imm  |   1   |
|  EX   | jalr/jal  |   4   |  PC   |   4   |   1   |
| ----- |   -----   | ----- | ----- | ----- | ----- |
|  MEM  |   均可    | 均可  | 均可  | 均可  | 均可  |