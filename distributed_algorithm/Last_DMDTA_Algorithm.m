
function [X_result,Y_result,Z_result,resultQoE,resultProfit,providerProfit,placementCost,updateCost,runCost,taskAccRate,extime] = Last_DMDTA_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon)

A = DLModelMaxAOI;
% 算法思路：在每个时隙开始时，首先求解(X,Y,Z)的在时隙t时的正则化松弛解(使用mosek求解器求解(单纯形法)),并用随机舍入算法求解 (Y,Z)，
%           在得到(Y,Z)解后，将其带入到目标函数中,并求得X的松弛解,使用GAP(二部图匹配+移除违约任务)方法得到最终X的可行解
Z_Pre = zeros(J, K, DLModelMaxAOI);
Y_Pre = zeros(J, K);
Y_result = zeros(J, K, T);  % 最终的DL服务放置决策
Z_result = zeros(J,K,DLModelMaxAOI,T);  % 最终的DL服务更新决策
X_result = zeros(I,J,DLModelMaxAOI,T);  % 最终的推理任务卸载决策
X_relax = zeros(I,J,DLModelMaxAOI,T);  % 最终的推理任务卸载决策


% 最终的推理任务卸载决策
extime = 0;
for t = 1:T
    x_flag = zeros(1,I);
    total_extime_t = 0;
    for j = 1:J
        tic
        [X_relax_t,Y_relax,Z_relax] = LP_Round_X_Y_Z(I,1,K,Y_Pre(j,:),Z_Pre(j,:,:),K_It(:,t),serverCompuCap(j),storageCap(j),serverCompuCost(j,t), ...
            taskPay(:,t),taskNeedCompuCap(:,j,t),taskNeedCompuRes(:,t),DLModelCap,DLDeployCost(j,:),DLUpdateCost(j,:),DLModelMaxAOI,Beta,epsilon);     
        [Y_result(j,:,t), Z_result(j,:,:,t)] = Last_Random_Round_Algorithm(Y_relax, Z_relax, DLModelCap, storageCap(j));  
        X_temp = sum(X_relax_t, 3);
        for i = 1:I
            if(Y_result(j,K_It(i,t),t) ~= 1)
                for a = 1:DLModelMaxAOI
                    X_relax_t(i,1,a) = 0;
                end
            end
        end
        X_relax(:,j,:,t) = X_relax_t;
        [a, idx] = sort(X_temp, 'descend');
        temp_BS_CompCap = serverCompuCap(j);
        server_to_task{j} = idx;
        task_to_server = {};
        for i=1:I
            task_to_server{i} = [];
            for j=1:J
                k = K_It(i,t);
                if(taskNeedCompuCap(i,j,t)<100)
                    if(size(task_to_server{i},2) == 0)
                        task_to_server{i} = [task_to_server{i} j];
                    else
                        for temp_j=1:size(task_to_server{i},2)
                            index_j = task_to_server{i}(temp_j);
                            unit_utility = calculateUnitUtility(taskNeedCompuRes(i,t),taskPay(i,t),taskNeedCompuCap(i,j,t),serverCompuCost(j,t))/taskNeedCompuCap(i,j,t);
                            unit_utility1 = calculateUnitUtility(taskNeedCompuRes(i,t),taskPay(i,t),taskNeedCompuCap(i,index_j,t),serverCompuCost(index_j,t))/taskNeedCompuCap(i,index_j,t);
                            if(unit_utility>=unit_utility1)
                                if(temp_j == 1)
                                    task_to_server{i} = [j, task_to_server{i}];
                                    break;
                                else
                                    task_to_server{i} = [task_to_server{i}(1:temp_j-1), j, task_to_server{i}(temp_j:end)];
                                    break;
                                end
                            else
                                if(temp_j == size(task_to_server{i},2))
                                    task_to_server{i} = [task_to_server{i}, j];
                                    break;
                                end
                            end
                        end
                    end
                end
            end
        end
        total_extime_t = total_extime_t+toc;

    end
    total_extime_t = total_extime_t/J;
    extime = extime + total_extime_t;
    
    [taskStatus] = Stable_Algorithm(task_to_server,server_to_task,I,J,K,K_It,t,taskNeedCompuCap,serverCompuCost,serverCompuCap);

    for i=1:I
        for a=1:DLModelMaxAOI
            if(taskStatus(i) ~= 0 && Z_result(taskStatus(i), K_It(i,t), a,t) == 1)
                X_result(i,taskStatus(i),a,t) = 1;
            end
        end
    end

%     X_result(:,:,:,t) = X_relax(:,:,:,t);
    Z_Pre = Z_result(:,:,:,t);
    Y_Pre = Y_result(:,:,t);
end
% extime = toc;
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


% 计算推理任务单位计算资源所能提供的效用
function[unit_utility] = calculateUnitUtility(taskNeedCompuRes1,taskPay1,taskNeedCompuCap1,serverCompuCost1)
% unit_utility = (taskPay1-taskNeedCompuRes1*serverCompuCost1)/taskNeedCompuCap1;
unit_utility = taskPay1-taskNeedCompuRes1*serverCompuCost1;
end


