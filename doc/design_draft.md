# 草稿

| ADDR  | INST  |
| :---: | :---: |
|   0   |  ADD  |
|   4   |  SUB  |

|       | IF  | EX  | IF  | EX  |     |
| ----- | --- | --- | --- | --- | --- |
| addr  | 0   | 0   | 4   | 4   |     |
| rdata | x   | ADD | ADD | SUB |     |
| inst  | x   | ADD | ADD | SUB |     |

| state    | IF  | EX  | IF  | EX  |     |     |     |
| -------- | --- | --- | --- | --- | --- | --- | --- |
| addr     | 0   | 0   | 4   | 4   |     |     |     |
| rdata    | x   | ADD | ADD | SUB | SUB |     |     |
| inst_dff | x   | x   | ADD | ADD | SUB | LW  |     |
| inst     | x   | ADD | ADD | SUB | SUB |     |     |
| inst_CE  | 0   | 0   | 0   | 0   | 0   | 0   |     |
| hold     | x   | 0   | 0   | 0   | 0   | 0   |     |
| inst_sel | x   | r   | r   | r   | r   | r   |     |

| ADDR  | INST  |
| :---: | :---: |
|   0   |  LW   |
|   4   |  ADD  |

| state    | IF  | EX  | EX   | EX   | IF   | EX  | IF  |
| -------- | --- | --- | ---- | ---- | ---- | --- | --- |
| addr     | 0   | 0   | 0    | 0    | 4    | 4   | 8   |
| rdata    | x   | LW  | data | data | data | ADD | ADD |
| inst_dff | x   | x   | LW   | LW   | LW   | LW  | ADD |
| inst     | x   | LW  | LW   | LW   | LW   | ADD | ADD |
| inst_CE  | 0   | 1   | 0    | 0    | 0    | 0   | 0   |
| hold     | x   | 1   | 1    | 0    | 0    | 0   | 0   |
| inst_sel | x   | R   | DFF  | DFF  | DFF  | R   | R   |

dff的值要持续到下一个IF

- inst_CE
  - IF阶段进入EX阶段,有load指令
- inst_sel
  - R
    - 有load指令
      - IF阶段进入EX阶段
    - 没load指令
  - DFF
    - 有load指令且上一阶段是EX
