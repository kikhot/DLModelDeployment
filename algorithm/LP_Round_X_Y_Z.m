function [x,y,z] = LP_Round_X_Y_Z(I,J,K,Y_Pre,Z_Pre,K_It,serverCompuCap,storageCap,serverCompuCost, ...
    taskPay,taskNeedCompuCap,taskNeedCompuRes,DLModelCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon)
% epsilon = 0.1;
yalmip('clear');
A = DLModelMaxAOI;
% 定义变量
% 创建任务卸载决策变量
X = sdpvar(I, J, A, 'full');
% 创建DL模型服务放置决策变量
Y = sdpvar(J, K, 'full');

% 创建DL模型服务放置的AOI决策变量(当Z_jk1=1时，为更新决策）
Z = sdpvar(J, K, A, 'full');
% 目标函数
obj = 0;
% 添加用户QoE和服务提供商的收益
QoE = Beta * sum(X.*repmat(exp(-permute(1:A,[1,3,2])),[I,J,1]), 'all');
providerProfit = sum(X.*repmat(taskPay,[1,J,A]), 'all');
obj = QoE + providerProfit;

% 添加DL服务放置成本
placementCost = 0;
updateCost = 0;

for j = 1:J
    for k = 1:K
%         placementCost = placementCost + DLDeployCost(j,k)/log(1+1/epsilon)*(kullbackleibler(Y(j,k)+epsilon,Y_Pre(j,k)+epsilon)+Y_Pre(j,k)-Y(j,k));
        placementCost = placementCost + DLDeployCost(j,k)/log(1+1/epsilon)*(kullbackleibler(Y(j,k)+epsilon,Y_Pre(j,k)+epsilon)-Y(j,k));
    end
end
obj = obj - placementCost;

% 添加DL模型更新成本
updateCost = updateCost + sum(Z(:,:,1).*DLUpdateCost, 'all');

obj = obj - updateCost;
% 添加运行成本
runCost = sum(ones(I,J,A).*taskNeedCompuRes.*reshape(serverCompuCost, [1,J]).*X, 'all');
obj = obj - runCost;
% 约束条件
constraint = [];
% constraint = [constraint 0<=X<=1 0<=Y<=1 0<=Z<=1];
constraint = [constraint 0<=X 0<=Z 0<=Y<=1];
% 约束C1
constraint = [constraint sum(X,[2,3]) <= 1];
% 约束C2
[I_idx, J_idx, A_idx] = ndgrid(1:I, 1:J, 1:A);
K_idx = K_It(sub2ind([I,1], I_idx(:)));
constraint = [constraint X(:) <= Z(sub2ind([J K A], J_idx(:), K_idx(:), A_idx(:)))];
% 约束C3
% 约束C4
constraint = [constraint Z(:,:,2:end)<=Z_Pre(:,:,1:end-1) reshape(sum(Z,3),[J,K])==Y];


% 约束C5
constraint = [constraint sum(Y.*repmat(DLModelCap,[J,1]), 2) <= storageCap'];
% 约束C6
constraint = [constraint sum(X.*repmat(taskNeedCompuCap,[1,1,A]), [1,3]) <= serverCompuCap];

ops = sdpsettings('solver','mosek', 'verbose', 0, 'mosek.MSK_IPAR_NUM_THREADS', 64);
% ops.mosek.MSK_DPAR_INTPNT_CO_TOL_REL_GAP = 1.0e-4;
% ops.mosek.MSK_DPAR_INTPNT_QO_TOL_REL_GAP = 1.0e-4;
% ops.mosek.MSK_DPAR_INTPNT_TOL_REL_GAP = 1.0e-4;

% yalmip('modelXYZ.lp', constraint, -obj, ops, 'write');
diagnostics=optimize(constraint,-obj,ops);
% if diagnostics.problem==0
%     disp('Solver thinks it is feasible')
% elseif diagnostics.problem == 1
%     disp('Solver thinks it is infeasible')
%     pause();
% else
%     disp('Timeout, Display the current optimal solution')
% end
% 显示求解结果
x = value(X);
y = value(Y);
z = value(Z);
end