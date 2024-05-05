% OPT最优解
% 使用python3.9 + gurobi10.0.1 对问题进行求解

% function[resultQoE, resultProfit, Y, z, AOI, update] = randomAlgorithm(m,n,K,T,frame,mk,mt,processorNumber,signleProcessComputCap,storageCap,serverJumpDelay,taskSize,taskDeadline,taskPay,DLModelCap,DLModleNeedComputeCap,DLComputeRes,DLDeployCost,DLUpdateCost,singleProcessorRunCost,DLModelMaxAOI);


% matlab中调用python
% 更新python模块
clear classes
obj = py.importlib.import_module('OPT');
py.importlib.reload(obj)


m = 1000;    % 任务数量
n = 2;    % 边缘服务器数量
K = 10;    % DL模型类型数量
rng(5);    % 随机种子固定
T = 10;    % 时隙
frame = 1;    % 每帧所占时隙

mk = randi([1 K], 1, m, 'int16');    % 任务与深度学习服务类型之间的关系
mt = randi([1 T], 1, m, 'int16');    % 每个任务生成的时隙

% 服务器参数
processorNumber = randi([20 30], 1, n);    % 每个服务器的处理器量（个）
singleProcessComputCap = randi([200 400], 1, n);     % 每个边缘服务器处理器所能处理的计算资源（MHZ）
storageCap = randi([20000 40000], 1, n);       % 每个服务器的存储资源总量（MB）
serverJumpDelay = randi([4 10]);    % 边缘服务器每跳所用时间（ms）

% 推理任务参数
taskSize = randi([1 10], 1, m);    % 每个任务的输入大小（MB）
taskDeadline = randi([100, 600], 1, m);     % 每个推理任务所能容忍的最大延迟（ms）
taskPay = 2+2*rand(1,m);             % 每个推理任务所能支付的价格（$）


% DL模型参数
DLModelCap = randi([2000 3000], 1, K);            % 每个DL模型的存储容量，单位MB
DLModleNeedComputeCap = randi([500 1500], 1, K);    % 不同类型DL模型完成所需计算资源，单位cycles
DLComputeRes = randi([40 60], 1, K);   % DL模型所需分配的计算资源
DLDeployCost = zeros(n, K);%randi([1 2], n, K);      % 模型动态放置成本($)
DLUpdateCost = randi([5 10], n, K);      % 模型动态更新成本($)
singleProcessorRunCost = 0.1 + 0.2*rand(1, n);   % 服务器中单个处理器在每个时隙的运行成本($)
DLModelMaxAOI = randi([2 5], 1, K);     % DL模型所需最大AOI







% 调用python3.9 + gurobi10.0.1编写的python文件，求得最优解
py.OPT.optFun(m,n,K,T,frame,mk,mt,processorNumber,singleProcessComputCap,storageCap,serverJumpDelay,taskSize,taskDeadline,taskPay,DLModelCap,DLModleNeedComputeCap,DLComputeRes,DLDeployCost,DLUpdateCost,singleProcessorRunCost,DLModelMaxAOI);
















% end