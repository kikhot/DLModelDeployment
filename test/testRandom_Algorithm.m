% 随机算法 
% 边缘-随机：每次，在每个服务器上随机选择几个DL模型，并部署在边缘侧，随机分配处理器数量。
% 在确保每个服务在服务器集群中至少有一个副本的情况下，每个服务器随机选择服务在自己身上进行缓存，直到服务器的容量达到或接近服务器的最大容量。

function[resultQoE, resultProfit] = Random_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI);

resultQoE = 0;      % 最终用户QoE
resultProfit = 0;   % 最终服务提供商利润
providerProfit = 0; % 服务提供商收益
runCost = 0;
placementCost = 0;  % 放置成本
updateCost = 0;     % 服务更新成本

rng('shuffle')  % 取消随机种子

tic;    % 运行时间
% 服务放置，边缘服务器每帧随机放置服务
Y = zeros(J,K,F);     % DL服务放置决策
for f = 1:F
    for j = 1:J
        while 1
            Y(j,:,f) = randi([0,1], 1, K);
            if(sum(Y(j,:,f).*DLModelCap) <= storageCap(j))
                break;
            end
        end
    end
end
C = zeros(J,K,F);
C(:,:,1) = Y(:,:,1);
C(:,:,2:end) = max(Y(:,:,2:end)-Y(:,:,1:end-1), zeros(J,K,F-1));
placementCost = sum(C.*repmat(DLDeployCost, [1,1,F]), 'all');


% 服务更新，每个时隙，随机更新放置在边缘服务器的DL服务
update = zeros(J,K,T);   % DL服务更新决策
AOI = zeros(J,K,T);     % DL服务的AOI年龄
for t = 1:T
    for j = 1:J
        for k = 1:K
            f = floor((t-1)/frame)+1;
            if(Y(j,k,f)==1)    % 边缘服务器j在时隙t中放置了模型k
                 % 如果当前时隙为初始时隙，或者当前时隙为DL服务最新放置时隙，则更新决策为1
                if((mod(t-1,frame)==0) && (f==1 || Y(j,k,f-1)==0)) 
                    % 直接进行更新
                    update(j,k,t)=1;
                    updateCost = updateCost + DLUpdateCost(j,k);
                    AOI(j,k,t) = 1;
                % 如果当前时隙放置了模型k，则随机进行更新决策
                else
                    % 随机更新
                    if(randi(2)==1)
                        update(j,k,t)=1;
                        updateCost = updateCost + DLUpdateCost(j,k);
                        AOI(j,k,t) = 1;
                    else
                        disp([j, k, t])
                        AOI(j,k,t) = AOI(j,k,t-1) + 1;
                    end
                end
            end
        end
    end
end


% 任务分配,在保证约束的情况下，随机分配到缓存了相应DL服务的边缘服务器中，
for t = 1:T
    X{t} = zeros(I, J); % 任务分配决策
end
for t = 1:T
    singleSlotToN = [1:1:I];  % 单个时隙所请求的任务数量
    % 获取每个DL服务类型在当前时隙所能提供的边缘服务器有哪些
    slotServiceToServer = {};    % 每个DL服务所能提供的边缘服务器集合
    f = floor((t-1)/frame)+1;
    for k = 1:K
        temp = [];
        for j = 1:J
            if(Y(j,k,f)==1)
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
        slot_index_i = randi([1 size(singleSlotToN,2)]);
        temp_i = singleSlotToN(slot_index_i);
        temp_k = K_It(temp_i,t);
        serviceToServerSlotArr = slotServiceToServer{temp_k};   % 缓存了相应服务的边缘服务器数组
        temp_n = size(serviceToServerSlotArr,2);
        while 1
            % 随机选择缓存了相应DL服务的边缘服务器
            if(temp_n == 0)
                break;  % 所有服务器遍历完成，拒绝该任务
            end
            slot_index_j = randi([1 size(serviceToServerSlotArr,2)]);
            temp_j = serviceToServerSlotArr(slot_index_j);
            if(taskNeedCompuRes(temp_i,t) <= remainComput_Cap(temp_j))
                remainComput_Cap(temp_j) = remainComput_Cap(temp_j) - taskNeedCompuRes(temp_i,t);
                X{t}(temp_i, temp_j) = 1;
                break;  % 随机选出对应的边缘服务器，跳过循环
            end
            temp_n = temp_n - 1;
            serviceToServerSlotArr(slot_index_j) = [];
        end
        singleSlotToN(slot_index_i) = [];
    end

end
for t = 1:T
    for i = 1:I
        for j = 1:J
            providerProfit = providerProfit + X{t}(i,j)*taskPay(i,t);
            resultQoE = resultQoE + X{t}(i,j)*AOI(j,K_It(i,t));
            runCost = X{t}(i,j)*taskNeedCompuRes(i,t)*serverCompuCost(j)/1000;
        end
    end

end


resultProfit = providerProfit - runCost - updateCost - placementCost;

result = resultProfit + resultQoE;

toc;    % 运行时间
disp(['运行时间', num2str(toc)]);
