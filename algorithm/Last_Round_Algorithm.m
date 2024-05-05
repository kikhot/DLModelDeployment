
function [X_result,Y_result,Z_result,resultQoE,resultProfit,providerProfit,placementCost,updateCost,runCost,taskAccRate,extime] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon)

A = DLModelMaxAOI;
% 算法思路：在每个时隙开始时，首先求解(X,Y,Z)的在时隙t时的正则化松弛解(使用mosek求解器求解(单纯形法)),并用随机舍入算法求解 (Y,Z)，
%           在得到(Y,Z)解后，将其带入到目标函数中,并求得X的松弛解,使用GAP(二部图匹配+移除违约任务)方法得到最终X的可行解
Z_Pre = zeros(J, K, DLModelMaxAOI);
Y_Pre = zeros(J, K);
Y_result = zeros(J, K, T);  % 最终的DL服务放置决策
Z_result = zeros(J,K,DLModelMaxAOI,T);  % 最终的DL服务更新决策
X_result = zeros(I,J,DLModelMaxAOI,T);  % 最终的推理任务卸载决策
% 最终的推理任务卸载决策
tic
for t = 1:T
    % (1) 先对t时隙的(X,Y,Z)进行松弛，然后随机舍入Y,Z
    [~,Y_relax,Z_relax] = LP_Round_X_Y_Z(I,J,K,Y_Pre,Z_Pre,K_It(:,t),serverCompuCap,storageCap,serverCompuCost(:,t), ...
        taskPay(:,t),taskNeedCompuCap(:,:,t),taskNeedCompuRes(:,t),DLModelCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
    % 运行随机舍入算法求解DL服务放置决策（Y，Z）
    [Y_result(:,:,t), Z_result(:,:,:,t)] = Last_Random_Round_Algorithm(Y_relax, Z_relax, DLModelCap, storageCap);  
    % 求解(3)问题
    Z_temp = Z_result(:,:,:,t);
    profit_p = CalCulate_p(Z_temp,t,K_It,taskPay,taskNeedCompuRes,serverCompuCost,Beta);
    profit_p(:,end+1) = 0; % 假设有一个虚拟的MEC服务器，卸载到其中的收益为0
    max_profit_p = round(max(max(profit_p)) + 10,0);
    cost_c = max_profit_p - profit_p;
    [X_t] = Last_TaskOffloading_Algorithm(taskNeedCompuCap(:,:,t), cost_c,profit_p,serverCompuCap);
    X = zeros(I,J,A);
    for i=1:I
        for j=1:J
            if(X_t(i,j)==1)
                k1 = K_It(i,t);
                for a=1:A
                    if(Z_temp(j,k1,a)==1)
                        X(i,j,a) = X_t(i,j);
                    end
                end
            end
        end
    end
    X_result(:,:,:,t) = X;
    Z_Pre = Z_result(:,:,:,t);
    Y_Pre = Y_result(:,:,t);
end
extime = toc;
C = zeros(J,K,F);
C(:,:,1) = Y_result(:,:,1);
C(:,:,2:end) = max(Y_result(:,:,2:end)-Y_result(:,:,1:end-1), zeros(J,K,F-1));

providerProfit = sum(X_result.*repmat(reshape(taskPay, [I,1,1,T]), [1,J,A,1]), 'all');
QoE = sum(X_result.*exp(-repmat(reshape(1:A,1,1,A,1), [I,J,1,T])), 'all');
placementCost = sum(C.*repmat(DLDeployCost, [1,1,F]), 'all');
updateCost = sum(reshape(Z_result(:,:,1,:), [J,K,T]).*repmat(DLUpdateCost, [1,1,T]), 'all');
runCost = sum(X_result.*(repmat(reshape(taskNeedCompuRes, [I,1,1,T]), [1,J,A,1]).*repmat(reshape(serverCompuCost, [1,J,1,T]), [I,1,A,1])), 'all');
resultQoE = QoE;
resultProfit = providerProfit - placementCost - runCost - updateCost;

count = sum(X_result, "all");
taskAccRate = count / (I*T);

end

