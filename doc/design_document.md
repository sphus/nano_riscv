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
