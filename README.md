# DLModelDeployment

Language: English | [中文](README.zh-CN.md)

MATLAB simulation code for **[Joint Optimization of Model Deployment for Freshness-Sensitive Task Assignment in Edge Intelligence](https://ieeexplore.ieee.org/document/10621314/)**.

Paper DOI: [10.1109/INFOCOM52122.2024.10621314](https://doi.org/10.1109/INFOCOM52122.2024.10621314)

This repository studies online deep learning (DL) model deployment and inference-task assignment in a multi-edge-server system. The experiments jointly decide:

- `Y`: which DL models are deployed on each edge server.
- `Z`: whether each deployed model is fresh or has a specific Age of Information (AoI).
- `X`: which inference tasks are accepted and assigned to which edge server/model-AoI state.

The objective combines user QoE, provider revenue, model deployment cost, model update cost, and inference running cost.

## Repository Layout

```text
.
├── algorithm/                       # Proposed centralized online algorithm
│   ├── Last_Round_Algorithm.m       # MPUTA / proposed rounded algorithm
│   ├── LP_Round_X_Y_Z.m             # YALMIP relaxation solved by MOSEK
│   ├── Last_Random_Round_Algorithm.m
│   ├── Last_TaskOffloading_Algorithm.m
│   └── CalCulate_p.m
├── distributed_algorithm/           # Distributed matching-based variant
│   ├── Last_DMDTA_Algorithm.m       # OSMDA / distributed algorithm
│   ├── Stable_Algorithm.m
│   └── ...
├── benchmarks/                      # Baseline algorithms
│   ├── Last_Random_Algorithm.m
│   ├── Last_Greedy_Algorithm.m      # OGA baseline
│   └── Last_OLSA2_Algorithm.m       # OLSA-style baseline
├── Code/result/                     # Saved experiment data and figures
├── export_fig-3.15/                 # Figure export utility
├── test/                            # Small tests and solver experiments
├── parameterGeneration.m            # Random system/task/model generator
├── CalculateTaskNeedCompuCap.m      # Required compute capacity per task/server
├── CalculateTaskNeedCompuRes.m      # Required CPU cycles per task
├── Last_main*.m                     # Experiment entry scripts
├── Last_load*.m                     # Average raw repeated runs
└── Last_Draw*.m                     # Plot figures from averaged data
```

## Requirements

The code is written for MATLAB and uses optimization solvers through YALMIP.

Required:

- MATLAB.
- YALMIP.
- MOSEK, used in `LP_Round_X_Y_Z.m` for the relaxed deployment/update/task problem.
- IBM CPLEX, used in `Last_TaskOffloading_Algorithm.m` and exact OPT experiments.
- Parallel Computing Toolbox, for scripts using `parfor`.

Recommended:

- Curve Fitting Toolbox, used by plotting scripts through `fit(..., 'smoothingspline')`.
- `export_fig`, already included under `export_fig-3.15/`.

Most scripts currently use Windows-style paths such as `.\Code\result\...` and `addpath algorithm\;`. On macOS/Linux, change these to `/` paths or uncomment the Linux path lines where available.

## Simulation Model

`parameterGeneration(I,J,K,T)` creates one random experiment instance:

- `I`: number of inference tasks per time slot.
- `J`: number of edge servers.
- `K`: number of DL model/service types.
- `T`: number of time slots.

Generated parameters include:

- Edge resources: compute capacity, storage capacity, inter-server hop delay, compute cost, and server distance matrix.
- DL model properties: storage size, required CPU cycles per bit, deployment cost, update cost, and maximum allowed AoI.
- Task properties: input size, deadline, payment, associated MEC server, wireless distance, requested model type, required CPU cycles, and required compute capacity.

Task model requests follow a Zipf-like distribution in `parameterGeneration.m`, making some DL services more popular than others.

## Algorithms

### MPUTA / Proposed Centralized Algorithm

Implemented in `algorithm/Last_Round_Algorithm.m`.

For each time slot:

1. Solve a regularized relaxed joint optimization problem for `X`, `Y`, and `Z` using `LP_Round_X_Y_Z.m`.
2. Randomly round relaxed model placement/update decisions with `Last_Random_Round_Algorithm.m`.
3. Compute task-server profit scores with `CalCulate_p.m`.
4. Assign tasks with `Last_TaskOffloading_Algorithm.m`, which solves a GAP-like LP and applies deterministic rounding.
5. Accumulate QoE, profit, deployment cost, update cost, running cost, task acceptance rate, and execution time.

### OSMDA / Distributed Algorithm

Implemented in `distributed_algorithm/Last_DMDTA_Algorithm.m`.

Each server solves a local relaxed problem, rounds its own model decisions, builds server/task preference lists, and then applies `Stable_Algorithm.m` for matching-based task assignment.

### Baselines

- `benchmarks/Last_Random_Algorithm.m`: random placement, random update, and random feasible assignment.
- `benchmarks/Last_Greedy_Algorithm.m`: greedy model placement by service popularity and task assignment by unit utility.
- `benchmarks/Last_OLSA2_Algorithm.m`: OLSA-style online service placement/update with stable matching.
- `Last_OPT.m` and `Last_OPT_2.m`: exact optimization variants for small-scale checks.

## Running Experiments

Run scripts from the repository root in MATLAB.

### 1. Main Task/Server Scaling Experiment

```matlab
Last_main_parallel
```

This script runs repeated seeded trials and writes raw results under:

```text
Code/result/Data_yyyy-mm-dd/
```

Main settings in the script:

- Task scaling: `requestCount = 25:25:400`, fixed `J = 4`, `K = 8`, `T = 30`.
- Server scaling section: fixed `I = 300`.
- Seeds: `seed_num = 1:100`.
- Default `Beta = 30`, `epsilon = 0.2`.

### 2. Distributed Experiment

```matlab
Last_distributed_main
```

This includes the distributed DMDTA/OSMDA algorithm together with random, greedy, and OLSA baselines.

### 3. Epsilon Sensitivity

```matlab
Last_main_epsilon_change
Last_load_epsilon_change
Last_Draw_epsilon_change
```

The epsilon values are:

```matlab
epsilons = [0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000];
```

### 4. Beta Sensitivity

```matlab
Last_main_beta_change_parallel
Last_load_beta_change
Last_Draw_beta_change
```

The beta values are:

```matlab
Betas = 5:5:70;
```

### 5. Edge Resource Capacity Sensitivity

```matlab
Last_main__edge_capacity_parallel
Last_load__edge_capacity_parallel
Last_Draw_edge_capacity_change
```

This varies compute and storage capacities by:

```matlab
edge_capacity_change = [0.5, 1, 1.5, 2, 2.5, 3];
```

## Result Processing Workflow

The expected workflow is:

1. Run a `Last_main*.m` experiment script.
2. Run the corresponding `Last_load*.m` script to average repeated seeded runs.
3. Run the corresponding `Last_Draw*.m` script to generate PNG/EPS/SVG figures.

Raw files use the prefix `all_`, for example:

```text
all_ours_Task_number-Profit_data.txt
all_Random_Task_number-Profit_data.txt
all_Greedy_Task_number-Profit_data.txt
all_OLSA_Task_number-Profit_data.txt
all_DMDTA_Task_number-Profit_data.txt
```

Averaged files remove the `all_` prefix, for example:

```text
ours_Task_number-Profit_data.txt
```

Many load/draw scripts hard-code date offsets such as `datestr(now+3,29)` or `datestr(now-117,29)`. Before plotting, update `dirdate` so it points to the generated `Data_yyyy-mm-dd` directory you want to process.

## Output Columns

For task-count and server-count experiments, each row generally follows:

| Column | Meaning |
| --- | --- |
| 1 | Number of tasks `I` |
| 2 | Number of servers `J` |
| 3 | Total QoE |
| 4 | Total profit |
| 5 | Provider revenue before costs |
| 6 | Model placement cost |
| 7 | Model update cost |
| 8 | Inference running cost |
| 9 | Task acceptance rate |
| 10 | Execution time |

For sensitivity experiments, column 1 is the changed parameter, such as `epsilon`, `Beta`, compute-capacity multiplier, or storage-capacity multiplier.

## Existing Results

The repository already contains saved data and figures in `Code/result/`, including:

- Task-number variation.
- Server-number variation.
- Epsilon sensitivity.
- Beta sensitivity.
- Edge compute/storage capacity sensitivity.

Figures are stored under directories such as:

```text
Code/result/Figure_2024-03-30/
Code/result/Figure_2024-03-30/epsilon_change/
```

## Notes and Known Caveats

- Some scripts are experiment snapshots and contain date offsets or commented alternative paths. Check `dirdate` and `savePath` before running.
- Parallel scripts can be expensive: the default main experiments use up to 100 seeds and repeated solver calls.
- `Last_main_parallel.m` and related scripts append to result files. Delete or move old output files if you want a clean rerun.
- Solver availability is essential. The proposed algorithm depends on YALMIP plus MOSEK, while task-offloading rounding uses CPLEX.
- `benchmarks/Last_OLSA2_Algorithm.m` contains the OLSA-style baseline used by the main scripts.

## License

This project is released under the Apache License 2.0. See `LICENSE`.
