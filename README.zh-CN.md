# DLModelDeployment

语言：[English](README.md) | 中文

本项目是论文 **[Joint Optimization of Model Deployment for Freshness-Sensitive Task Assignment in Edge Intelligence](https://ieeexplore.ieee.org/document/10621314/)** 的 MATLAB 仿真实验代码。

论文 DOI：[10.1109/INFOCOM52122.2024.10621314](https://doi.org/10.1109/INFOCOM52122.2024.10621314)

该项目研究边缘智能场景中，对新鲜度敏感的深度学习模型部署与推理任务分配联合优化问题。实验同时决定：

- `Y`：每个边缘服务器部署哪些 DL 模型。
- `Z`：每个已部署模型是否更新，以及模型当前对应的 Age of Information (AoI) 状态。
- `X`：每个推理任务是否被接收，并分配到哪个边缘服务器和模型 AoI 状态。

优化目标综合考虑用户 QoE、服务提供商收益、模型部署成本、模型更新成本和推理运行成本。

## 项目结构

```text
.
├── algorithm/                       # 论文中的集中式在线算法
│   ├── Last_Round_Algorithm.m       # MPUTA / 本文舍入算法
│   ├── LP_Round_X_Y_Z.m             # 通过 YALMIP + MOSEK 求解松弛问题
│   ├── Last_Random_Round_Algorithm.m
│   ├── Last_TaskOffloading_Algorithm.m
│   └── CalCulate_p.m
├── distributed_algorithm/           # 分布式匹配算法
│   ├── Last_DMDTA_Algorithm.m       # OSMDA / 分布式算法
│   ├── Stable_Algorithm.m
│   └── ...
├── benchmarks/                      # 对比算法
│   ├── Last_Random_Algorithm.m
│   ├── Last_Greedy_Algorithm.m      # OGA 贪心算法
│   └── Last_OLSA2_Algorithm.m       # OLSA 风格基线
├── Code/result/                     # 已保存的实验数据和图片
├── export_fig-3.15/                 # 图片导出工具
├── test/                            # 小规模测试和求解器实验
├── parameterGeneration.m            # 随机生成系统、任务和模型参数
├── CalculateTaskNeedCompuCap.m      # 计算任务在不同服务器上的所需计算能力
├── CalculateTaskNeedCompuRes.m      # 计算任务所需 CPU 周期数
├── Last_main*.m                     # 实验入口脚本
├── Last_load*.m                     # 对多次随机种子结果求平均
└── Last_Draw*.m                     # 根据平均结果绘图
```

## 环境依赖

代码基于 MATLAB 编写，并通过 YALMIP 调用优化求解器。

必要依赖：

- MATLAB。
- YALMIP。
- MOSEK：`LP_Round_X_Y_Z.m` 中用于求解联合部署、更新和任务分配的松弛优化问题。
- IBM CPLEX：`Last_TaskOffloading_Algorithm.m` 和部分精确最优解实验中使用。
- Parallel Computing Toolbox：带 `parfor` 的并行实验脚本需要。

推荐依赖：

- Curve Fitting Toolbox：绘图脚本中使用 `fit(..., 'smoothingspline')` 平滑曲线。
- `export_fig`：已包含在 `export_fig-3.15/` 目录中。

多数脚本使用 Windows 风格路径，例如 `.\Code\result\...` 和 `addpath algorithm\;`。如果在 macOS/Linux 上运行，需要把路径改成 `/`，或使用脚本中已注释的 Linux 路径。

## 仿真模型

`parameterGeneration(I,J,K,T)` 生成一次随机实验实例：

- `I`：每个时隙的推理任务数量。
- `J`：边缘服务器数量。
- `K`：DL 模型或服务类型数量。
- `T`：时隙数量。

生成的参数包括：

- 边缘服务器资源：计算能力、存储容量、服务器间跳时延、计算成本、服务器距离矩阵。
- DL 模型属性：模型存储大小、单位 bit 任务所需 CPU 周期、部署成本、更新成本、最大允许 AoI。
- 推理任务属性：输入大小、截止时间、支付价格、关联 MEC、无线距离、请求模型类型、所需 CPU 周期和所需计算能力。

任务请求的模型类型在 `parameterGeneration.m` 中按照 Zipf-like 分布生成，因此不同 DL 服务具有不同流行度。

## 算法说明

### MPUTA / 本文集中式算法

实现文件：`algorithm/Last_Round_Algorithm.m`。

每个时隙执行以下步骤：

1. 通过 `LP_Round_X_Y_Z.m` 求解 `X`、`Y` 和 `Z` 的正则化松弛问题。
2. 使用 `Last_Random_Round_Algorithm.m` 对模型部署和更新决策进行随机舍入。
3. 使用 `CalCulate_p.m` 计算任务到服务器的收益分数。
4. 使用 `Last_TaskOffloading_Algorithm.m` 完成任务卸载分配，该模块先解 GAP-like LP，再进行确定性舍入。
5. 累计 QoE、利润、部署成本、更新成本、运行成本、任务接受率和算法运行时间。

### OSMDA / 分布式算法

实现文件：`distributed_algorithm/Last_DMDTA_Algorithm.m`。

每个服务器分别求解本地松弛问题并舍入自己的模型部署决策，随后构造服务器和任务的偏好列表，最后通过 `Stable_Algorithm.m` 进行稳定匹配式任务分配。

### 对比算法

- `benchmarks/Last_Random_Algorithm.m`：随机模型放置、随机更新和随机可行任务分配。
- `benchmarks/Last_Greedy_Algorithm.m`：根据服务流行度进行贪心模型放置，并按单位效用进行任务分配。
- `benchmarks/Last_OLSA2_Algorithm.m`：结合 OLSA 思想和稳定匹配的在线服务放置/更新基线。
- `Last_OPT.m` 和 `Last_OPT_2.m`：用于小规模验证的精确优化版本。

## 运行实验

请在 MATLAB 中从项目根目录运行脚本。

### 1. 任务数和服务器数变化实验

```matlab
Last_main_parallel
```

该脚本会运行多组固定随机种子实验，并将原始结果写入：

```text
Code/result/Data_yyyy-mm-dd/
```

主要设置：

- 任务数变化：`requestCount = 25:25:400`，固定 `J = 4`、`K = 8`、`T = 30`。
- 服务器数变化：固定 `I = 300`。
- 随机种子：`seed_num = 1:100`。
- 默认参数：`Beta = 30`，`epsilon = 0.2`。

### 2. 分布式算法实验

```matlab
Last_distributed_main
```

该脚本包含分布式 DMDTA/OSMDA 算法，以及 Random、Greedy 和 OLSA 对比算法。

### 3. epsilon 参数敏感性实验

```matlab
Last_main_epsilon_change
Last_load_epsilon_change
Last_Draw_epsilon_change
```

epsilon 取值为：

```matlab
epsilons = [0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000];
```

### 4. Beta 参数敏感性实验

```matlab
Last_main_beta_change_parallel
Last_load_beta_change
Last_Draw_beta_change
```

Beta 取值为：

```matlab
Betas = 5:5:70;
```

### 5. 边缘资源容量敏感性实验

```matlab
Last_main__edge_capacity_parallel
Last_load__edge_capacity_parallel
Last_Draw_edge_capacity_change
```

该实验分别改变服务器计算能力和存储容量，变化倍数为：

```matlab
edge_capacity_change = [0.5, 1, 1.5, 2, 2.5, 3];
```

## 结果处理流程

推荐流程如下：

1. 运行某个 `Last_main*.m` 实验脚本。
2. 运行对应的 `Last_load*.m` 脚本，对多次随机种子结果求平均。
3. 运行对应的 `Last_Draw*.m` 脚本，生成 PNG/EPS/SVG 图片。

原始结果文件通常带有 `all_` 前缀，例如：

```text
all_ours_Task_number-Profit_data.txt
all_Random_Task_number-Profit_data.txt
all_Greedy_Task_number-Profit_data.txt
all_OLSA_Task_number-Profit_data.txt
all_DMDTA_Task_number-Profit_data.txt
```

平均后的结果文件会去掉 `all_` 前缀，例如：

```text
ours_Task_number-Profit_data.txt
```

注意：许多 `Last_load*.m` 和 `Last_Draw*.m` 脚本中写死了日期偏移，例如 `datestr(now+3,29)` 或 `datestr(now-117,29)`。绘图前请修改 `dirdate`，使其指向你实际生成的 `Data_yyyy-mm-dd` 目录。

## 输出列含义

任务数变化和服务器数变化实验的结果文件通常每行包含：

| 列 | 含义 |
| --- | --- |
| 1 | 任务数量 `I` |
| 2 | 服务器数量 `J` |
| 3 | 总 QoE |
| 4 | 总利润 |
| 5 | 扣除成本前的服务提供商收益 |
| 6 | 模型部署成本 |
| 7 | 模型更新成本 |
| 8 | 推理运行成本 |
| 9 | 任务接受率 |
| 10 | 算法运行时间 |

对于敏感性实验，第 1 列通常是变化参数，例如 `epsilon`、`Beta`、计算能力倍数或存储容量倍数。

## 已保存结果

仓库中已经包含部分实验数据和图片，位于 `Code/result/`，包括：

- 任务数变化实验。
- 服务器数变化实验。
- epsilon 敏感性实验。
- Beta 敏感性实验。
- 边缘计算能力和存储容量敏感性实验。

图片目录示例：

```text
Code/result/Figure_2024-03-30/
Code/result/Figure_2024-03-30/epsilon_change/
```

## 注意事项

- 部分脚本是实验快照，包含固定日期偏移和注释掉的替代路径。运行前请检查 `dirdate` 和 `savePath`。
- 默认实验计算量较大：主实验通常使用 100 个随机种子，并会多次调用优化求解器。
- `Last_main_parallel.m` 等脚本会向结果文件追加内容。如果需要干净复现实验，请先删除或移动旧输出文件。
- 求解器是关键依赖。本文算法依赖 YALMIP + MOSEK，任务卸载舍入部分依赖 CPLEX。
- `benchmarks/Last_OLSA2_Algorithm.m` 是主实验中使用的 OLSA 风格基线。

## 许可证

本项目使用 Apache License 2.0。详见 `LICENSE`。
