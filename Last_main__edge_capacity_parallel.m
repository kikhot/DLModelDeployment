clc;
clear;

% 并行计算

dirdate=datestr(now,29);
savePath=['.\Code\result\Data_',dirdate];%windows
savePath = [savePath,'\edge_capacity_change'];
% savePath=['./Code/result/Data_',dirdate];%linux
if ~exist(savePath,'dir')
    mkdir(savePath);
end
addpath algorithm\;
addpath benchmarks\;
addpath distributed_algorithm\

I = 300;   % 每个时隙推理任务数量
J = 4;      % 固定服务器数量为5
K = 8;    % DL模型类型数量
T = 30;    % 时隙
frame = 1;    % 每帧所占时隙
F = T/frame;    % 帧数
edge_capacity_change = [0.5, 1, 1.5, 2, 2.5, 3];
epsilon = 0.2;
seed_num = [1:1:100];
Beta = 30;


for i=1:size(edge_capacity_change,2)%任务数变化结果
    data = cell(1,size(seed_num,2));
    parfor se = 1:size(seed_num, 2)
        rng(seed_num(se));%随机种子固定
        [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
        serverCompuCap = serverCompuCap * edge_capacity_change(i);
%         % mine算法
%         [~,~,~,resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1,taskAccRate1,extime1] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
%             taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
%         data{se} = [data{se};[edge_capacity_change(i),resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1,taskAccRate1,extime1]];
%         disp(['DLModelPlacement算法完成']);
        % 贪心算法
        [X2,Y2,Z2,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,taskAccRate2,extime2] = Last_Greedy_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
        data{se} = [data{se};[edge_capacity_change(i),resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,taskAccRate2,extime2]];

        % PBA+OLSA
        [X3,Y3,Z3,resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3,taskAccRate3,extime3] = Last_OLSA2_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
        data{se} = [data{se};[edge_capacity_change(i),resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3,taskAccRate3,extime3]];

        [X4,Y4,Z4,resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4,taskAccRate4,extime4] =  Last_DMDTA_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
        disp(['DMDTA算法完成']);
        data{se} = [data{se};[edge_capacity_change(i),resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4,taskAccRate4,extime4]];

        disp([i,se]);

    end
    for se = 1:size(seed_num, 2)
%         y1=strcat(savePath,'\all_ours_beta_change-Profit_data.txt');
%         fid1=fopen(y1,'a');
%         fprintf(fid1,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(1,1),data{se}(1,2),data{se}(1,3),data{se}(1,4),data{se}(1,5),data{se}(1,6),data{se}(1,7),data{se}(1,8),data{se}(1,9));
%         fclose(fid1);
        y3=strcat(savePath,'\all_greedy_serverCompuCap_change-Profit_data.txt');
        fid3=fopen(y3,'a');
        fprintf(fid3,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(1,1),data{se}(1,2),data{se}(1,3),data{se}(1,4),data{se}(1,5),data{se}(1,6),data{se}(1,7),data{se}(1,8),data{se}(1,9));
        fclose(fid3);
        y4=strcat(savePath,'\all_OLSA_serverCompuCap_change-Profit_data.txt');
        fid4=fopen(y4,'a');
        fprintf(fid4,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(2,1),data{se}(2,2),data{se}(2,3),data{se}(2,4),data{se}(2,5),data{se}(2,6),data{se}(2,7),data{se}(2,8),data{se}(2,9));
        fclose(fid4);
        y5=strcat(savePath,'\all_DMDTA_serverCompuCap_change-Profit_data.txt');
        fid5=fopen(y5,'a');
        fprintf(fid5,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(3,1),data{se}(3,2),data{se}(3,3),data{se}(3,4),data{se}(3,5),data{se}(3,6),data{se}(3,7),data{se}(3,8),data{se}(3,9));
        fclose(fid5);
    end
end

for i=1:size(edge_capacity_change,2)%任务数变化结果
    data = cell(1,size(seed_num,2));
    parfor se = 1:size(seed_num, 2)
        rng(seed_num(se));%随机种子固定
        [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
        storageCap = storageCap * edge_capacity_change(i);
%         % mine算法
%         [~,~,~,resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1,taskAccRate1,extime1] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
%             taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
%         data{se} = [data{se};[edge_capacity_change(i),resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1,taskAccRate1,extime1]];
%         disp(['DLModelPlacement算法完成']);
        % 贪心算法
        [X2,Y2,Z2,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,taskAccRate2,extime2] = Last_Greedy_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
        data{se} = [data{se};[edge_capacity_change(i),resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,taskAccRate2,extime2]];

        % PBA+OLSA
        [X3,Y3,Z3,resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3,taskAccRate3,extime3] = Last_OLSA2_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
        data{se} = [data{se};[edge_capacity_change(i),resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3,taskAccRate3,extime3]];

        [X4,Y4,Z4,resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4,taskAccRate4,extime4] =  Last_DMDTA_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
        disp(['DMDTA算法完成']);
        data{se} = [data{se};[edge_capacity_change(i),resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4,taskAccRate4,extime4]];

        disp([i,se]);

    end
    for se = 1:size(seed_num, 2)
%         y1=strcat(savePath,'\all_ours_beta_change-Profit_data.txt');
%         fid1=fopen(y1,'a');
%         fprintf(fid1,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(1,1),data{se}(1,2),data{se}(1,3),data{se}(1,4),data{se}(1,5),data{se}(1,6),data{se}(1,7),data{se}(1,8),data{se}(1,9));
%         fclose(fid1);
        y3=strcat(savePath,'\all_greedy_storageCap_change-Profit_data.txt');
        fid3=fopen(y3,'a');
        fprintf(fid3,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(1,1),data{se}(1,2),data{se}(1,3),data{se}(1,4),data{se}(1,5),data{se}(1,6),data{se}(1,7),data{se}(1,8),data{se}(1,9));
        fclose(fid3);
        y4=strcat(savePath,'\all_OLSA_storageCap_change-Profit_data.txt');
        fid4=fopen(y4,'a');
        fprintf(fid4,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(2,1),data{se}(2,2),data{se}(2,3),data{se}(2,4),data{se}(2,5),data{se}(2,6),data{se}(2,7),data{se}(2,8),data{se}(2,9));
        fclose(fid4);
        y5=strcat(savePath,'\all_DMDTA_storageCap_change-Profit_data.txt');
        fid5=fopen(y5,'a');
        fprintf(fid5,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(3,1),data{se}(3,2),data{se}(3,3),data{se}(3,4),data{se}(3,5),data{se}(3,6),data{se}(3,7),data{se}(3,8),data{se}(3,9));
        fclose(fid5);
    end
end