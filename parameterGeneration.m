

function[serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T)

% 服务器参数
serverCompuCap = randi([20 40], 1, J);     % 每个边缘服务器所能处理的最大计算资源(Giga CPU cycles/s)GHZ
storageCap = randi([100 200], 1, J);       % 每个服务器的存储资源总量（GB）
serverJumpDelay = 100;    % 边缘服务器每跳所用时间（ms）
serverCompuCost = 0.6 + 0.3*rand(J, T);   % 每个服务器在时隙t的单位计算成本($/GHZ)
% 基站之间的跳数
A = randi([1,J],J);
MecDistance = triu(A,0) + tril(A',-1);
for ll=1:J
    MecDistance(ll,ll)=0;
end
% DL模型参数
DLModelCap = randi([20 50], 1, K);            % 每个DL模型的存储容量，单位GB
DLModelNeedComputeCap = randi([500 1500], 1, K);    % 不同类型DL模型单位大小任务所需计算资源，单位cycles/bit
DLDeployCost = roundn(20+10*rand(J, K),-4);      % 模型动态放置成本($)
DLUpdateCost = roundn(5+5*rand(J, K),-4);      % 模型动态更新成本($)
DLModelMaxAOI = 4;     % DL模型所需最大AOI

% 推理任务参数
taskSize = 2+8*rand(I,T);     % 每个任务的输入大小（MB）
taskDeadline = randi([1000 3000], I, T);      % 每个推理任务所能容忍的最大延迟（ms）
taskPay = roundn(10+20*rand(I, T),-4);    % 每个推理任务所能支付的价格（$）
taskToMec = randi([1,J], I, T);     % 任务所关联的MEC
taskAndMecDistance = randi([20, 200], I, T);    % 任务与所关联的MEC之间的距离(m)

% 任务与深度学习服务类型之间的关系
K_It = zeros(I,T);
for t = 1:T
    % 服从zipf分布
    s = 0.56; % Zipf分布参数 0.56
    r = 1:K;
    p = r.^(-s) / sum(r.^(-s));
%     idx = randperm(length(p));
%     p = p(idx);
    K_It(:,t) = randsample(K, I, true, p)';
end
% 完成推理任务所需的CPU周期(cycle)
taskNeedCompuRes = CalculateTaskNeedCompuRes(taskSize, DLModelNeedComputeCap, K_It);
% 推理任务所需分配的计算资源，暂时进行固定
taskNeedCompuCap = CalculateTaskNeedCompuCap(MecDistance,taskDeadline,taskNeedCompuRes,taskToMec,taskAndMecDistance,taskSize,serverJumpDelay,serverCompuCap);
taskNeedCompuRes = taskNeedCompuRes/1e9;
end