function[taskStatus] = Stable_Algorithm(task_to_server,server_to_task,I,J,K,K_It,t,taskNeedCompuCap,serverCompuCost,serverCompuCap)
% StableMatching：稳定匹配算法，多对多匹配
% 计算出每个推理任务的偏好列表，推理任务对边缘服务器的偏好值为（任务对边缘服务器的效用）
% task_to_server = {};
% 
% % 计算出每个边缘服务器的偏好列表，边缘服务器对推理任务的偏好值为（任务卸载到边缘服务所需的计算资源）
% server_to_task{} = [];

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