function [x,y,z,resultQoE,resultProfit,providerProfit,placementCost,updateCost,runCost,extime] = Last_OPT(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta)
yalmip('clear');
tic
A = DLModelMaxAOI;
% 定义变量
% 创建任务卸载决策变量
X = binvar(I, J, A, T, 'full');
% 创建DL模型服务放置决策变量
Y = binvar(J, K, T, 'full');

% 创建DL模型服务放置的AOI决策变量(当Z_jk1=1时，为更新决策）
Z = binvar(J, K, A, T,'full');
C = binvar(J, K, T, 'full');

% 目标函数
obj = 0;
% 添加用户QoE和服务提供商的收益
providerProfit = sum(X.*repmat(reshape(taskPay, [I,1,1,T]), [1,J,A,1]), 'all');
QoE = sum(X.*exp(-repmat(reshape(1:A,1,1,A,1), [I,J,1,T])), 'all');
obj = obj + providerProfit + Beta*QoE;


% 添加DL服务放置成本
placementCost = sum(C.*repmat(DLDeployCost, [1,1,T]), 'all');
obj = obj - placementCost;

% 添加DL模型更新成本
updateCost = sum(reshape(Z(:,:,1,:), [J,K,T]).*repmat(DLUpdateCost, [1,1,T]), 'all');
obj = obj - updateCost;

% 添加运行成本
runCost = sum(X.*(repmat(reshape(taskNeedCompuRes, [I,1,1,T]), [1,J,A,1]).*repmat(reshape(serverCompuCost, [1,J,1,T]), [I,1,A,1])), 'all');
obj = obj - runCost;
disp(['OPT目标函数构建完成']);

% 约束条件
% 约束C1
constraint = [];
constraint = [sum(X,[2,3]) <= 1];
% 约束C2
% for i = 1:I
%     for t = 1:T
%         size(reshape(X(i,:,:,t),[J,A]))
%         reshape(X(i,:,:,t),[J,A])
%         size(reshape(Z(:,K_It(i,t),:,t),[J,A]))
%         reshape(Z(:,K_It(i,t),:,t),[J,A])
%         constraint = [constraint  reshape(X(i,:,:,t),[J,A]) <= reshape(Z(:,K_It(i,t),:,t),[J,A])];
%     end
% end
[I_idx, J_idx, A_idx, T_idx] = ndgrid(1:I, 1:J, 1:A, 1:T);
K_idx = K_It(sub2ind([I T], I_idx(:), T_idx(:)));
constraint = [constraint X(:) <= Z(sub2ind([J K A T], J_idx(:), K_idx(:), A_idx(:), T_idx(:)))];
% 约束C3
temp = reshape(sum(Z, 3), [J,K,T]);
constraint = [constraint temp == Y];
% 约束C4
constraint = [constraint Z(:,:,2:end,2:end) <= Z(:,:,1:end-1,1:end-1)];
% constraint = [constraint Z(:,:,2:end,1) == 0 Z(:,:,1,1) == Y(:,:,1)];
constraint = [constraint Z(:,:,2:end,1) == 0];
% 约束C5
constraint = [constraint reshape(sum(Y.*repmat(DLModelCap,[J,1,T]), 2), [J,T]) <= repmat(storageCap',[1,F])];
% 约束C6
constraint = [constraint reshape(sum(X.*repmat(reshape(taskNeedCompuCap, [I,J,1,T]), [1,1,A,1]), [1,3]), [J,T]) <= repmat(serverCompuCap', [1, T])];

% 其他约束
% constraint = [constraint C(:,:,2:end)>=Y(:,:,2:end)-Y(:,:,1:end-1)  C(:,:,1)==Y(:,:,1)];
for j=1:J
    for k=1:K
        for t=2:T
            constraint = [constraint implies([Y(j,k,t)==1, Y(j,k,t-1)==0], C(j,k,t)==1)];
        end
    end
end
disp(['OPT约束条件构建完成']);

ops = sdpsettings('solver','gurobi','debug',1);
% ops.cplex.display='on';
% ops.cplex.timelimit=1000;
% ops.cplex.mip.tolerances.mipgap=0.025;
% 输出模型
% ops.cplex.exportmodel = 'model.lp';
ops.gurobi.Threads = 5;
ops.gurobi.MIPGap = 0.02;
diagnostics=optimize(constraint,-obj,ops);
if diagnostics.problem==0
    disp('Solver thinks it is feasible')
elseif diagnostics.problem == 1
    disp('Solver thinks it is infeasible')
    pause();
else
    disp('Timeout, Display the current optimal solution')
end

resultQoE = value(QoE);
resultProfit = value(obj) - Beta*value(QoE);
providerProfit = value(providerProfit);
placementCost = value(placementCost);
updateCost = value(updateCost);
runCost = value(runCost);

% 显示求解结果
x = round(value(X), 4);
y = round(value(Y), 4);
z = round(value(Z), 4);
extime = toc;
end