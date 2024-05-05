% 随机算法 
% 边缘-随机：每次，在每个服务器上随机选择几个DL模型，并部署在边缘侧，随机分配处理器数量。
% 在确保每个服务在服务器集群中至少有一个副本的情况下，每个服务器随机选择服务在自己身上进行缓存，直到服务器的容量达到或接近服务器的最大容量。

function[X,Y,Z,resultQoE,resultProfit,providerProfit,placementCost,updateCost,runCost,taskAccRate,extime] = Last_Random_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta)

A = DLModelMaxAOI;  

tic;    % 运行时间
% 服务放置，边缘服务器每帧随机放置服务
Y = zeros(J,K,F);   % DL服务放置决策
Z = zeros(J,K,A,T);     % DL服务更新决策
X = zeros(I,J,A,T);     % 推理任务卸载决策
for t = 1:T
    f = floor((t-1)/frame)+1;  % 计算当前帧数
    % 边缘服务器每帧随机放置服务
    if mod(t,frame)==1 || frame==1   % 如果当前时隙是在当前帧的第一个时隙
        for j = 1:J
            while 1
                Y(j,:,f) = randi([0,1], 1, K);
                if(sum(Y(j,:,f).*DLModelCap) <= storageCap(j))
                    break;
                end
            end
        end
    end

    % 服务更新，每个时隙，随机更新放置在边缘服务器的DL服务
    for j = 1:J
        for k = 1:K
            if Y(j,k,f)==1      % 边缘服务器j在时隙t中放置了模型k
                % 如果当前时隙为初始时隙，或者当前时隙为DL服务最新放置时隙，则更新决策Z_jk1t为1
                if((t==1) ||  (f==1 || Y(j,k,f-1)==0))
                    % 直接进行更新
                    Z(j,k,1,t)  = 1;
                    % 如果当前时隙放置了模型k，则随机进行更新决策
                else
                    % 随机更新，如果随机到1，或者当前模型AOI已经达到最高限度
                    if(randi(2) == 1 || Z(j,k,A,t-1) == 1)
                        Z(j,k,1,t) = 1;
                    else
                        Z(j,k,2:end,t) = Z(j,k,1:end-1,t-1);
                    end
                end
            end
        end
    end
    % 任务分配,在保证约束的情况下，随机分配到缓存了相应DL服务的边缘服务器中，
    singleSlotToN = [1:1:I];  % 单个时隙所请求的任务数量
    % 获取每个DL服务类型在当前时隙所能提供的边缘服务器有哪些
    slotServiceToServer = {};    % 每个DL服务所能提供的边缘服务器集合
    for k = 1:K
        temp = [];
        for j = 1:J
            if Y(j,k,f)==1
                temp = [temp j];
            end
        end
        slotServiceToServer{k} = temp;
    end
    % 随机选取任务，并将任务卸载到缓存了相应DL服务的边缘服务器中
    % 边缘服务器的剩余计算容量
    remainComput_Cap = serverCompuCap;   % 服务器j的剩余计算资源（矩阵）
    while 1
        % 随机选择任务
        if(size(singleSlotToN,2)==0)
            break;  % 所有任务遍历完成
        end
        temp_i = randi([1 size(singleSlotToN,2)]);
        index_i = singleSlotToN(temp_i);
        index_k = K_It(index_i, t);
        serviceToServerSlotArr = slotServiceToServer{index_k};   % 缓存了相应服务的边缘服务器数组
        count_n = size(serviceToServerSlotArr, 2);
        while 1
            % 随机选择缓存了相应DL服务的边缘服务器
            if count_n==0
                break;  % 所有服务器遍历完成，拒绝该任务
            end
            temp_j = randi([1 size(serviceToServerSlotArr,2)]);
            index_j = serviceToServerSlotArr(temp_j);
            if(taskNeedCompuCap(index_i,index_j,t) <= remainComput_Cap(index_j))
                remainComput_Cap(index_j) = remainComput_Cap(index_j) - taskNeedCompuCap(index_i,index_j,t);
                a_temp = 0;
                for a=1:A
                    if(Z(index_j,K_It(index_i,t),a,t)==1)
                        a_temp = a;
                    end
                end
                if(a_temp==0)
                    disp('hello')
                end
                X(index_i,index_j,a_temp,t) = 1;
                break;  % 随机选出对应的边缘服务器，跳过循环
            end
            count_n = count_n - 1;
            serviceToServerSlotArr(temp_j) = [];

        end
        singleSlotToN(temp_i) = [];
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
