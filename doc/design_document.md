# 开发文档

## 设计思路

### 状态图

| 状态  |                  CPU动作                   |
| :---: | :----------------------------------------: |
|  IF   |    jump_addr计算并输出至ROM,同时给入PC     |
|  EX   | 访存:result即mem_addr,根据wmem选择是否写入 |
|  EX   |   跳转:result计算,判断并存储跳转条件jump   |
|  MEM  |                写回mem_data                |

- IF
  - 必会跳转到EX
- EX
  - load指令:跳转到MEM
  - 其他指令:跳转回IF
- MEM
  - 必会跳转到MEM

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

### inst_dff设计思路

- IF阶段输出ROM地址
- EX阶段接收mem_rdata作为inst
  - 若不为访存指令,mem_rdata作为inst即可,不必存储
  - 若为访存指令,下一拍的mem_rdata将为data而非inst,此时需要让inst_dff存住inst
- MEM阶段读回data memory数据,此时mem_rdata为数据而非inst,inst选择inst_dff的输出信号

## 测试方法

### 自动化测试使用方法:

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