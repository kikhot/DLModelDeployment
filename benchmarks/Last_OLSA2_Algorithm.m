function[X,Y,Z,resultQoE,resultProfit,providerProfit,placementCost,updateCost,runCost,taskAccRate,extime] = Last_PBAandStableMatching_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta)
tic
A = DLModelMaxAOI;
% OLSA：具有许多请求的内容具有更高的被缓存和更新的优先级，并且当其用户对于该DL服务所损失QOE累加和达到其更新成本时，缓存的内容将被更新（An Online Framework for Joint Network Selection and Service Placement in Mobile Edge Computing）
% StableMatching：稳定匹配算法，多对多匹配，


X = zeros(I,J,A,T);
Y = zeros(J,K,F);
Z = zeros(J,K,A,T);
AOI = zeros(J,K,T); % 边缘服务器中服务的AOI

OLSA_Sum = zeros(J,K);  % 用户对于DL服务所损失QOE累加和达到其更新成本时
for t=1:T
    f = floor((t-1)/frame)+1;  % 计算当前帧数
    gap_cost = 0;

    % OLSA：具有许多请求的内容具有更高的被缓存和更新的优先级，并且当其用户对于该DL服务所损失QOE累加和达到其更新成本时，缓存的内容将被更新
    % 计算稳定匹配后的DL模型放置和任务卸载决策
    if(t==1)
        [taskStatus,serverStatus] = StableMatching_XY(I,J,K,K_It,t,taskNeedCompuRes,taskPay,taskNeedCompuCap,serverCompuCost,serverCompuCap,DLModelCap,storageCap);
        t_pre = t;
        switchCost = 0;
        for i=1:I
            if(taskStatus(i)~=0)
                X(i,taskStatus(i),1,t) = 1;
            end
        end
        for j=1:J
            for k_index=1:size(serverStatus{j},2)
                k = serverStatus{j}(k_index);
                Y(j,k,f) = 1;
                Z(j,k,1,t) = 1;
                AOI(j,k,t) = 1;
                switchCost = switchCost + DLDeployCost(j,k);
            end
        end
    else
        for t_gap=t_pre:t
            profit_XY = 0;
            profit_X = 0;
            [taskStatus1,serverStatus] = StableMatching_XY(I,J,K,K_It,t_gap,taskNeedCompuRes,taskPay,taskNeedCompuCap,serverCompuCost,serverCompuCap,DLModelCap,storageCap);
            for i=1:I
                if(taskStatus1(i)~=0)
                    profit_XY = profit_XY + taskPay(i,t_gap)-taskNeedCompuRes(i,t_gap)*serverCompuCost(taskStatus1(i),t_gap);
                end
            end
            [taskStatus2] = StableMatching_X(Y,I,J,K,K_It,t,t_pre,taskNeedCompuRes,taskPay,taskNeedCompuCap,serverCompuCost,serverCompuCap);
            profit_X = 0;
            for i=1:I
                if(taskStatus2(i)~=0)
                    profit_X = profit_X + taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(taskStatus2(i),t);
                end
            end
            gap_cost = profit_XY - profit_X;
        end


    end

    if(t~=1)
        if(switchCost < 1.5*gap_cost)
            [taskStatus,serverStatus] = StableMatching_XY(I,J,K,K_It,t,taskNeedCompuRes,taskPay,taskNeedCompuCap,serverCompuCost,serverCompuCap,DLModelCap,storageCap);
            for j=1:J
                for k_index=1:size(serverStatus{j},2)
                    k = serverStatus{j}(k_index);
                    Y(j,k,f) = 1;
                end
            end
            t_pre = f;
            gap_cost = 0;
        else
            for j=1:J
                for k=1:K
                    Y(j,k,f) = Y(j,k,t_pre);
                end
            end
            [taskStatus] = StableMatching_X(Y,I,J,K,K_It,t,t_pre,taskNeedCompuRes,taskPay,taskNeedCompuCap,serverCompuCost,serverCompuCap);
        end
    end


    if(t~=1)
        for j=1:J
            for k=1:K
                if(Y(j,k,t)==1)
                    if(AOI(j,k,t-1)==0)
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
                end
            end
        end
    end
    % 将OLSA思想应用到模型更新上，即当模型的更新成本小于不更新所带来的QoE消耗时，则更新
    for j=1:J
        for k=1:K
            if(AOI(j,k,t)==1)
                OLSA_Sum(j,k) = 0;
            elseif(AOI(j,k,t)==0)
                OLSA_Sum(j,k) = 0;
            end
        end
    end
    for j=1:J
        if(AOI(j,k,t)~=1)
            for i=1:I
                k = K_It(i,t);
                if(taskStatus(i)==j)
                    OLSA_Sum(j,k) = OLSA_Sum(j,k) + Beta*(exp(-1)-exp(-AOI(j,k,t)));
                end
            end
        end
    end
    for j=1:J
        for k=1:K
            if(OLSA_Sum(j,k)>=DLUpdateCost(j,k))
                OLSA_Sum(j,k) = 0;
                Z(j,k,AOI(j,k,t),t) = 0;
                AOI(j,k,t) = 1;
                Z(j,k,1,t) = 1;
            end
        end
    end
    % 计算决策变量X
    for i=1:I
        for j=1:J
            k = K_It(i,t);
            if(taskStatus(i)==j)
                X(i,j,AOI(j,k,t),t) = 1;
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



function[taskStatus] = StableMatching_X(Y,I,J,K,K_It,t,t_pre,taskNeedCompuRes,taskPay,taskNeedCompuCap,serverCompuCost,serverCompuCap)
% StableMatching：稳定匹配算法，多对多匹配
% 计算出每个推理任务的偏好列表，推理任务对边缘服务器的偏好值为（任务对边缘服务器的效用）
task_to_server = {};
for i=1:I
    task_to_server{i} = [];
    for j=1:J
        k = K_It(i,t);
        if(taskNeedCompuCap(i,j,t)<100 && Y(j,k,t_pre)==1)
            if(size(task_to_server{i},2) == 0)
                task_to_server{i} = [task_to_server{i} j];
            else
                for temp_j=1:size(task_to_server{i},2)
                    index_j = task_to_server{i}(temp_j);
                    if(taskNeedCompuCap(i,j,t)<=taskNeedCompuCap(i,index_j,t))
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
% 计算出每个边缘服务器的偏好列表，边缘服务器对推理任务的偏好值为（任务卸载到边缘服务所需的计算资源）
for j=1:J
    server_to_task{j} = [];
    for i=1:I
        k = K_It(i,t);
        if(taskNeedCompuCap(i,j,t)<100 && Y(j,k,t_pre)==1)
            if(size(server_to_task{j},2)==0)
                server_to_task{j} = [server_to_task{j} i];
            else
                for temp_i=1:size(server_to_task{j},2)
                    index_i = server_to_task{j}(temp_i);
                    unit_utility = calculateUnitUtility(taskNeedCompuRes(i,t),taskPay(i,t),taskNeedCompuCap(i,j,t),serverCompuCost(j,t));
                    unit_utility1 = calculateUnitUtility(taskNeedCompuRes(index_i,t),taskPay(index_i,t),taskNeedCompuCap(index_i,j,t),serverCompuCost(j,t));
                    if(unit_utility>=unit_utility1)
                        if(temp_i == 1)
                            server_to_task{j} = [i, server_to_task{j}];
                            break;
                        else
                            server_to_task{j} = [server_to_task{j}(1:temp_i-1), i, server_to_task{j}(temp_i:end)];
                            break;
                        end
                    else
                        if(temp_i == size(server_to_task{j},2))
                            server_to_task{j} = [server_to_task{j}, i];
                            break;
                        end
                    end
                end
            end
        end
    end
end
% 初始化任务和边缘服务器的状态
taskStatus = zeros(1,I);
serverStatus = cell(1,J);
remainCompuCap = serverCompuCap;
while(1)
    % 从每个边缘服务器的偏好列表中依次选择推理任务
    for j=1:J
        if(isempty(server_to_task{j}))
            continue;
        end
        index_i = server_to_task{j}(1);
        server_to_task{j}(1) = [];
        % 如果满足计算资源要求，并且推理任务没有卸载，则暂时匹配
        if(remainCompuCap(j)>taskNeedCompuCap(index_i,j,t) && taskStatus(index_i)==0)
            remainCompuCap(j) = remainCompuCap(j) - taskNeedCompuCap(index_i,j,t);
            taskStatus(index_i) = j;
            % 如果满足计算资源要求，然而已经匹配，则任务通过偏好列表选择更好的边缘服务器
        elseif(remainCompuCap(j)>taskNeedCompuCap(index_i,j,t) && taskStatus(index_i)~=0)
            for j1=1:size(task_to_server{index_i},2)
                if(task_to_server{index_i}(j1)==j)
                    remainCompuCap(j) = remainCompuCap(j) - taskNeedCompuCap(index_i,j,t);
                    remainCompuCap(taskStatus(index_i)) = remainCompuCap(taskStatus(index_i)) + taskNeedCompuCap(index_i,taskStatus(index_i),t);
                    taskStatus(index_i) = j;
                    break;
                elseif(task_to_server{index_i}(j1)==taskStatus(index_i))
                    break;
                end
            end
        end
    end
    flag = true;
    for j=1:J
        if(~isempty(server_to_task{j}))
            flag = false;
        end
    end
    if(flag)
        break;
    end
end

max_Iter = 1;
while(max_Iter<400)
    %每个移动用户计算其最喜欢的传输规则；
    max_Iter = max_Iter + 1;
    %每个移动用户计算其最喜欢的传输规则；
    pair = cell(1,I);
    for i=1:I
        % 初始转移对（s，a，b）
        if(taskStatus(i)~=0)
            k = K_It(i,t);
            curr_pair_PV = (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(taskStatus(i),t))/taskNeedCompuCap(i,j,t);
        else
            curr_pair_PV = 0;
        end

        for j=1:J
            if(j~=taskStatus(i))
                k = K_It(i,t);
                if(ismember(k,serverStatus{j}))
                    jj = taskStatus(i);
                    tran_pair_PV = (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(j,t))/taskNeedCompuCap(i,j,t);
                    if(tran_pair_PV > curr_pair_PV && remainCompuCap(j)>taskNeedCompuCap(i,j,t))
                        pair{i} = [i,taskStatus(i),j];
                        curr_pair_PV = tran_pair_PV;
                    end
                end
            end
        end
    end
    flag = true;
    for i=1:I
        if(~isempty(pair{i}))
            flag = false;
        end
    end
    if(flag)
        break;
    end
    max_transfer = [];
    max_pair_PV = 0;
    for j=1:J
        for i=1:I
            if(~isempty(pair{i}) && pair{i}(3)==j)
                jj = pair{i}(2);
                if(jj == 0)
                    tran_pair_PV =  (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(j,t))/taskNeedCompuCap(i,t);
                else
                    tran_pair_PV = (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(j,t))/taskNeedCompuCap(i,t) - (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(jj,t))/taskNeedCompuCap(i,t);
                end
                if((isempty(max_transfer) && tran_pair_PV>0) || max_pair_PV<tran_pair_PV)
                    max_transfer = [i,taskStatus(i),j];
                    max_pair_PV = tran_pair_PV;
                end
            end
        end
    end

    if(isempty(max_transfer))
        break;
    end
    if(max_transfer(2) == 0)
        taskStatus(max_transfer(1)) = max_transfer(3);
        remainCompuCap(max_transfer(3)) = remainCompuCap(max_transfer(3)) - taskNeedCompuCap(max_transfer(1),max_transfer(3),t);
    else
        i1 = max_transfer(1);
        j1 = max_transfer(2);
        j2 = max_transfer(3);
        remainCompuCap(j1) = remainCompuCap(j1) + taskNeedCompuCap(i1,j1,t);
        remainCompuCap(j2) = remainCompuCap(j2) - taskNeedCompuRes(i1,j2,t);
        taskStatus(i1) = j2;
    end
end


end


function[taskStatus,serverStatus] = StableMatching_XY(I,J,K,K_It,t,taskNeedCompuRes,taskPay,taskNeedCompuCap,serverCompuCost,serverCompuCap,DLModelCap,storageCap)
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
% 计算出每个边缘服务器的偏好列表，边缘服务器对推理任务的偏好值为（任务卸载到边缘服务所需的计算资源）
for j=1:J
    server_to_task{j} = [];
    for i=1:I
        k = K_It(i,t);
        if(taskNeedCompuCap(i,j,t)<100)
            if(size(server_to_task{j},2)==0)
                server_to_task{j} = [server_to_task{j} i];
            else
                for temp_i=1:size(server_to_task{j},2)
                    index_i = server_to_task{j}(temp_i);
                    if(taskNeedCompuCap(i,j,t)<=taskNeedCompuCap(index_i,j,t))
                        if(temp_i == 1)
                            server_to_task{j} = [i, server_to_task{j}];
                            break;
                        else
                            server_to_task{j} = [server_to_task{j}(1:temp_i-1), i, server_to_task{j}(temp_i:end)];
                            break;
                        end
                    else
                        if(temp_i == size(server_to_task{j},2))
                            server_to_task{j} = [server_to_task{j}, i];
                            break;
                        end
                    end
                end
            end
        end
    end
end
% 初始化任务和边缘服务器的状态
taskStatus = zeros(1,I);
serverStatus = cell(1,J);
remainCompuCap = serverCompuCap;
while(1)
    serverStatus = cell(1,J);
    % 从每个任务的偏好列表中依次选择边缘服务器
    one_round_server_to_task = cell(1,J);
    for i=1:I
        if(isempty(task_to_server{i}))
            continue;
        end

        % 如果满足计算资源要求，并且推理任务没有卸载，则暂时匹配
        if(taskStatus(i)==0)
            index_j = task_to_server{i}(1);
            task_to_server{i}(1) = [];
            one_round_server_to_task{index_j} = [one_round_server_to_task{index_j} i];
        else
            one_round_server_to_task{taskStatus(i)} = [one_round_server_to_task{taskStatus(i)} i];
        end
    end
    one_round_server_to_task2 = cell(1,J);
    for j=1:J
        for i=1:size(server_to_task{j},2)
            if(ismember(server_to_task{j}(i),one_round_server_to_task{j}))
                one_round_server_to_task2{j} = [one_round_server_to_task2{j} server_to_task{j}(i)];
            end
        end
    end


    % 服务放置决策,对匹配的任务进行放置决策挑选
    taskStatus = zeros(1,I);
    for j=1:J
        k_flag = zeros(1,K);
        k_profit = zeros(1,K);
        k_CompuCap = zeros(1,K);
        k_taskindex = cell(1,K);
        for i=1:size(one_round_server_to_task2{j},2)
            index_i = one_round_server_to_task2{j}(i);
            remainStorageCap = storageCap(j);
            k = K_It(index_i,t);
            if((sum(k_CompuCap.*k_flag,'all')+taskNeedCompuCap(index_i,j,t))>serverCompuCap(j)) % 如果加入该任务导致计算资源超载，则输出结果
                for kl=1:K
                    if(k_flag(kl)==1)
                        serverStatus{j} = [serverStatus{j} kl];
                        for l=1:size(k_taskindex{kl},2)
                            ii = k_taskindex{kl}(l);
                            taskStatus(ii) = j;
                        end
                    end

                end
                break;
            end
            k_flag = zeros(1,K);
            k_profit(k) = k_profit(k) + taskPay(index_i,t) - taskNeedCompuRes(index_i,t)*serverCompuCost(j,t);
            k_CompuCap(k) = k_CompuCap(k) + taskNeedCompuCap(index_i,j,t);
            k_taskindex{k} = [k_taskindex{k} index_i];
            [B,ind] = sort(k_profit./(k_CompuCap+0.0000000001), 'descend');
            for k1=1:size(ind,2)
                k_ind = ind(k1);
                if(remainStorageCap > DLModelCap(k_ind))
                    remainStorageCap = remainStorageCap - DLModelCap(k_ind);
                    k_flag(k_ind) = 1;
                end
            end
            if(i==size(one_round_server_to_task2{j},2))
                for kl=1:K
                    if(k_flag(kl)==1)
                        serverStatus{j} = [serverStatus{j} kl];
                        for l=1:size(k_taskindex{kl},2)
                            ii = k_taskindex{kl}(l);
                            taskStatus(ii) = j;
                        end
                    end
                end
            end
        end
    end

    flag = true;
    for i=1:I
        if(~isempty(task_to_server{i}) && taskStatus(i)==0)
            flag = false;
        end
    end
    if(flag)
        break;
    end
end

remainCompuCap = serverCompuCap;
for i=1:I
    if(taskStatus(i)~=0)
        j = taskStatus(i);
        remainCompuCap(j) = remainCompuCap(j) - taskNeedCompuCap(i,j,t);
    end
end

% 合作博弈
% 联合博弈阶段算法
max_Iter = 1;
while(max_Iter<400)
    %每个移动用户计算其最喜欢的传输规则；
    max_Iter = max_Iter + 1;
    pair = cell(1,I);
    for i=1:I
        % 初始转移对（s，a，b）
        if(taskStatus(i)~=0)
            for k=1:K
                if(k==K_It(i,t))
                    k = K_It(i,t);
                    curr_pair_PV = (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(taskStatus(i),t))/taskNeedCompuCap(i,j,t);
                end
            end
        else
            curr_pair_PV = 0;
        end

        for j=1:J
            if(j~=taskStatus(i))
                for k=1:K
                    if(k==K_It(i,t))
                        if(ismember(k,serverStatus{j}))
                            jj = taskStatus(i);
                            tran_pair_PV = (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(j,t))/taskNeedCompuCap(i,j,t);
                            if(tran_pair_PV > curr_pair_PV && remainCompuCap(j)>taskNeedCompuCap(i,j,t))
                                pair{i} = [i,taskStatus(i),j];
                                curr_pair_PV = tran_pair_PV;
                            end
                        end
                    end
                end
            end
        end
    end
    flag = true;
    for i=1:I
        if(~isempty(pair{i}))
            flag = false;
        end
    end
    %     if(flag)
    %         break;
    %     end
    max_transfer = [];
    max_pair_PV = 0;
    for j=1:J
        for i=1:I
            if(~isempty(pair{i}) && pair{i}(3)==j)
                jj = pair{i}(2);
                if(jj == 0)
                    tran_pair_PV =  (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(j,t))/taskNeedCompuCap(i,t);
                else
                    tran_pair_PV = (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(j,t))/taskNeedCompuCap(i,t) - (taskPay(i,t)-taskNeedCompuRes(i,t)*serverCompuCost(jj,t))/taskNeedCompuCap(i,t);
                end
                if((isempty(max_transfer) && tran_pair_PV>0) || max_pair_PV<tran_pair_PV)
                    max_transfer = [i,taskStatus(i),j];
                    max_pair_PV = tran_pair_PV;
                end
            end
        end
    end

    if(isempty(max_transfer))
        continue;
%         break;
    end
    if(max_transfer(2) == 0)
        taskStatus(max_transfer(1)) = max_transfer(3);
        remainCompuCap(max_transfer(3)) = remainCompuCap(max_transfer(3)) - taskNeedCompuCap(max_transfer(1),max_transfer(3),t);
    else
        i1 = max_transfer(1);
        j1 = max_transfer(2);
        j2 = max_transfer(3);
        remainCompuCap(j1) = remainCompuCap(j1) + taskNeedCompuCap(i1,j1,t);
        remainCompuCap(j2) = remainCompuCap(j2) - taskNeedCompuCap(i1,j2,t);
        taskStatus(i1) = j2;
    end

end



end



% 计算推理任务单位计算资源所能提供的效用
function[unit_utility] = calculateUnitUtility(taskNeedCompuRes1,taskPay1,taskNeedCompuCap1,serverCompuCost1)
% unit_utility = (taskPay1-taskNeedCompuRes1*serverCompuCost1)/taskNeedCompuCap1;
unit_utility = taskPay1-taskNeedCompuRes1*serverCompuCost1;
end
