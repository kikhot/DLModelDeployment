function[X,Y,Z,resultQoE,resultProfit,providerProfit,placementCost,updateCost,runCost,taskAccRate,extime] = Last_Greedy_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta)
tic
A = DLModelMaxAOI;

X = zeros(I,J,A,T);
Y = zeros(J,K,T);
Z = zeros(J,K,A,T);
AOI = zeros(J,K,T); % 边缘服务器中服务的AOI

for t=1:T
    % 边缘服务器每个时隙放置DL服务
    % 对每个边缘服务器能够处理的推理任务按照服务类型进行从大到小排序
    server_to_service_num = zeros(J,K); % 每个边缘服务器能处理的每个服务类型的任务数
    for i=1:I
        for j=1:J
            k = K_It(i,t);
            if(taskNeedCompuCap(i,j,t) < 100)   % 边缘服务器能处理该任务，则对应服务类型计数加一
                server_to_service_num(j,k) = server_to_service_num(j,k) + 1;
            end
        end
    end

    % 通过每个边缘服务器的服务类型频率放置服务
    for j=1:J
        [~, index_temp] = sort(server_to_service_num(j,:),'descend');
        index_J(j,:) = index_temp;
    end
    remainCap = storageCap;
    for j=1:J
        for index_k=1:size(index_J(j,:),2)
            k = index_J(j,index_k);
            if(remainCap(j) > DLModelCap(k))
                Y(j,k,t) = 1;
                if(t==1) % 如果当前时隙是第一个时隙，将AOI置为1
                    AOI(j,k,t) = 1;
                    Z(j,k,1,t) = 1;
                elseif(AOI(j,k,t-1)==0)
                    Z(j,k,1,t) = 1;
                    AOI(j,k,t) = 1;
                elseif(AOI(j,k,t-1)~=0)
                    if(AOI(j,k,t-1)==A)
                        AOI(j,k,t) = 1;
                        Z(j,k,1,t) = 1;
                    else
                        AOI(j,k,t) = AOI(j,k,t-1) + 1;
                        Z(j,k,AOI(j,k,t),t) = 1;
                    end

                end
                remainCap(j) = remainCap(j) - DLModelCap(k);
            end
        end
    end

    % 对推理任务进行卸载
    % 首先排列出每个任务所能卸载的边缘服务器集合
    % 其次对每个任务根据推理任务卸载到边缘服务器的效用与任务所需的计算资源的比值大小进行排序，排列出每个任务对应边缘服务器的优先级
    % 然后，挑选出任务比值最大的那个边缘服务器，并将该任务卸载到相应的边缘服务器
    task_to_server = {};
    for i=1:I
        task_to_server{i} = [];
        for j=1:J
            k = K_It(i,t);
            if(taskNeedCompuCap(i,j,t)<100 && Y(j,k,t)==1)
                if(size(task_to_server{i},2) == 0)
                    task_to_server{i} = [task_to_server{i} j];
                else
                    for temp_j=1:size(task_to_server{i},2)
                        index_j = task_to_server{i}(temp_j);
                        unit_utility = calculateUnitUtility(taskNeedCompuRes(i,t),taskPay(i,t),taskNeedCompuCap(i,j,t),serverCompuCost(j,t),AOI(j,k,t),Beta);
                        unit_utility1 = calculateUnitUtility(taskNeedCompuRes(i,t),taskPay(i,t),taskNeedCompuCap(i,index_j,t),serverCompuCost(index_j,t),AOI(index_j,k,t),Beta);
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
    % 然后，挑选出任务比值最大的那个边缘服务器，并将该任务卸载到相应的边缘服务器
    task_to_max_utility = [];   % 存储每个任务中的比值最大的边缘服务器的比值
    task_to_max_server_index = [];    % 存储每个任务中的比值最大的边缘服务器索引
    task_index = [];    % 存储任务的索引
    for i=1:I
        if(~isempty(task_to_server{i}))
            j = task_to_server{i}(1);
            task_to_server{i}(1) = [];
            unit_utility = calculateUnitUtility(taskNeedCompuRes(i,t),taskPay(i,t),taskNeedCompuCap(i,j,t),serverCompuCost(j,t),AOI(j,k,t),Beta);
            task_to_max_utility = [task_to_max_utility unit_utility];
            task_to_max_server_index = [task_to_max_server_index j];
        else    % 如果任务没有边缘服务器对应，效用为0
            task_to_max_utility = [task_to_max_utility 0];
            task_to_max_server_index = [task_to_max_server_index 0];
        end
        task_index = [task_index i];
    end

    remainCompuCap = serverCompuCap;
    while(~all(task_to_max_server_index==0))
        % 将task_to_max_utility按照unit_utility大小进行降序
        [task_to_max_utility, temp_index] = sort(task_to_max_utility, 'descend');
        temp_task_to_max_server_index = task_to_max_server_index;
        temp_task_index = task_index;
        for i=1:I
            task_to_max_server_index(i) = temp_task_to_max_server_index(temp_index(i));
            task_index(i) = temp_task_index(temp_index(i));
        end

        for i=1:I
            index_i = task_index(i);
            index_j = task_to_max_server_index(i);
            k = K_It(index_i,t);
            if(task_to_max_utility(i)~=0)
                if(taskNeedCompuCap(index_i,index_j,t)<=remainCompuCap(index_j)) % 满足计算资源，分配任务给边缘服务器
                    remainCompuCap(index_j) = remainCompuCap(index_j) - taskNeedCompuCap(index_i,index_j,t);
                    AOI_temp = AOI(index_j,k,t);
                    X(index_i,index_j,AOI_temp,t) = 1;
                    task_to_max_utility(i) = 0;
                    task_to_max_server_index(i) = 0;
                else
                    if(isempty(task_to_server{index_i}))
                        task_to_max_utility(i) = 0;
                        task_to_max_server_index(i) = 0;
                    else
                        temp_j = task_to_server{index_i}(1);
                        task_to_server{index_i}(1) = [];
                        unit_utility = calculateUnitUtility(taskNeedCompuRes(index_i,t),taskPay(index_i,t),taskNeedCompuCap(index_i,temp_j,t),serverCompuCost(temp_j,t),AOI(temp_j,k,t),Beta);
                        task_to_max_utility(i) = unit_utility;
                        task_to_max_server_index(i) = temp_j;
                    end
                end
            end
        end
    end


    % 边缘服务器中DL模型更新
    % 如果更新成本小于模型的QoE更新后的变化值，则进行更新
    
    for j=1:J
        for k=1:K
            accumulate = 0;
            flag1 = 0;
            for i=1:I
                if(Y(j,k,t)==1 && AOI(j,k,t)~=1 && X(i,j,AOI(j,k,t),t)==1)
                    accumulate = accumulate + (Beta*exp(-1)-Beta*exp(-(AOI(j,k,t)-1)));
                    if(accumulate > DLUpdateCost(j,k))
                        flag1 = 1;
                        break;
                    end
                end
            end
            if(flag1==1)
                for i=1:I
                    if(X(i,j,AOI(j,k,t),t)==1)
                        X(i,j,AOI(j,k,t),t) = 0;
                        X(i,j,1,t) = 0;
                    end
                end
                Z(j,k,AOI(j,k,t),t) = 0;
                AOI(j,k,t) = 1;
                Z(j,k,1,t) = 1;
            end
        end
    end
end


C = zeros(J,K,F);
C(:,:,1) = Y(:,:,1);
C(:,:,2:end) = max(Y(:,:,2:end)-Y(:,:,1:end-1), zeros(J,K,F-1));

providerProfit = sum(X.*repmat(reshape(taskPay, [I,1,1,T]), [1,J,A,1]), 'all');  % 服务提供商收益
QoE = sum(X.*exp(-repmat(reshape(1:A,1,1,A,1), [I,J,1,T])), 'all');
placementCost = sum(C.*repmat(DLDeployCost, [1,1,F]), 'all');       % 放置成本
updateCost = sum(reshape(Z(:,:,1,:), [J,K,T]).*repmat(DLUpdateCost, [1,1,T]), 'all');       % 服务更新成本
runCost = sum(X.*(repmat(reshape(taskNeedCompuRes, [I,1,1,T]), [1,J,A,1]).*repmat(reshape(serverCompuCost, [1,J,1,T]), [I,1,A,1])), 'all');
resultQoE = QoE;        % 最终用户QoE
resultProfit = providerProfit - placementCost - runCost - updateCost;   % 最终服务提供商利润

count = sum(X, "all");
taskAccRate = count / (I*T);

extime = toc;
end

% 计算推理任务单位计算资源所能提供的效用
function[unit_utility] = calculateUnitUtility(taskNeedCompuRes1,taskPay1,taskNeedCompuCap1,serverCompuCost1,AOI1,Beta)

unit_utility = (taskPay1+Beta*exp(-AOI1)-taskNeedCompuRes1*serverCompuCost1)/taskNeedCompuCap1;
% unit_utility = taskPay1+Beta*exp(-AOI1)-taskNeedCompuRes1*serverCompuCost1;

end