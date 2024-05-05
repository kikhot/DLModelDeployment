clc;
clear;

dirdate=datestr(now-1,29);
savePath=['.\Code\result\Data_',dirdate];%windows
% savePath=['./Code/result/Data_',dirdate];%linux
if ~exist(savePath,'dir')
    mkdir(savePath);
end
addpath algorithm\;
addpath benchmarks\;
addpath test\

requestCount = [25:25:400];   % 每个时隙推理任务数量
J = 4;      % 固定服务器数量为5
K = 8;    % DL模型类型数量
T = 30;    % 时隙
frame = 1;    % 每帧所占时隙
F = T/frame;    % 帧数
Beta = 30;
epsilon = 0.2;
seed_num = [1:1:100];


for i=1:size(requestCount,2)%任务数变化结果
    for se = 1:size(seed_num, 2)
        rng(seed_num(se));%随机种子固定
        I = requestCount(i);  % 每个时隙的任务数量
        [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
        % 随机算法
        [X1,Y1,Z1,resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1,taskAccRate1,extime1] = Last_Random_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
        disp(['随机算法完成']);
        % mine算法
        [X2,Y2,Z2,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,taskAccRate2,extime2] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
        disp(['DLModelPlacement算法完成']);
        test_check_True_XYZ(X2,Y2,Z2,K_It,DLModelCap,storageCap,serverCompuCap,taskNeedCompuCap);

        % 贪心算法
        [X3,Y3,Z3,resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3,taskAccRate3,extime3] = Last_Greedy_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);

        % PBA+OLSA
        [X4,Y4,Z4,resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4,taskAccRate4,extime4] = Last_OLSA2_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
%         test_check_True_XYZ(X4,Y4,Z4,K_It,DLModelCap,storageCap,serverCompuCap,taskNeedCompuCap);
         % OPT最优解
%         [X5,Y5,Z5,resultQoE5,resultProfit5,providerProfit5,placementCost5,updateCost5,runCost5,extime5] = Last_OPT_2(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
%             taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
%         disp(['OPT算法完成']);
%         test_check_True_XYZ(X5,Y5,Z5,K_It,DLModelCap,storageCap,serverCompuCap,taskNeedCompuCap);
        % 结果输出
        y1=strcat(savePath,'\all_Random_Task_number-Profit_data.txt');
        fid1=fopen(y1,'a');
        fprintf(fid1,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',I,J,resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1,taskAccRate1,extime1);
        fclose(fid1);
        y2=strcat(savePath,'\all_ours_Task_number-Profit_data.txt');
        fid2=fopen(y2,'a');
        fprintf(fid2,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',I,J,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,taskAccRate2,extime2);
        fclose(fid2);
        y3=strcat(savePath,'\all_Greedy_Task_number-Profit_data.txt');
        fid3=fopen(y3,'a');
        fprintf(fid3,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',I,J,resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3,taskAccRate3,extime3);
        fclose(fid3);
        y4=strcat(savePath,'\all_OLSA_Task_number-Profit_data.txt');
        fid4=fopen(y4,'a');
        fprintf(fid4,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',I,J,resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4,taskAccRate4,extime4);
        fclose(fid4);
%         y5=strcat(savePath,'\all_OPT_Task_number-Profit_data.txt');
%         fid5=fopen(y5,'a');
%         fprintf(fid5,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',I,J,resultQoE5,resultProfit5,providerProfit5,placementCost5,updateCost5,runCost5,extime5);
%         fclose(fid5);
        disp([i,se]);
    end
end

I = 300;
serverCount = [1:1:14];    % 每个时隙服务器数量
for i=1:size(serverCount,2)%任务数变化结果
    for se = 1:size(seed_num, 2)
        rng(seed_num(se));%随机种子固定
        J = serverCount(i);    % 边缘服务器数量
        [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
        % 随机算法
        [~,~,~,resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1,taskAccRate1,extime1] = Last_Random_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
        disp(['随机算法完成']);
        % mine算法
        [~,~,~,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,taskAccRate2,extime2] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
        disp(['DLModelPlacement算法完成']);

        % 贪心算法
        [~,~,~,resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3,taskAccRate3,extime3] = Last_Greedy_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
%         test_check_True_XYZ(X,Y,Z,K_It,DLModelCap,storageCap,serverCompuCap,taskNeedCompuCap);

        % PBA+OLSA
        [~,~,~,resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4,taskAccRate4,extime4] = Last_OLSA2_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);

         % OPT最优解
%         if i<=3
%             [~,~,~,resultQoE5,resultProfit5,providerProfit5,placementCost5,updateCost5,runCost5] = Last_OPT(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
%                 taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta);
%             disp(['OPT算法完成']);
%         end

        % 将size(seed_num,2)次结果求均值
        % 结果输出
        y1=strcat(savePath,'\all_Random_Server_number-Profit_data.txt');
        fid1=fopen(y1,'a');
        fprintf(fid1,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',I,J,resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1,taskAccRate1,extime1);
        fclose(fid1);
        y2=strcat(savePath,'\all_ours_Server_number-Profit_data.txt');
        fid2=fopen(y2,'a');
        fprintf(fid2,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',I,J,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,taskAccRate2,extime2);
        fclose(fid2);
        y3=strcat(savePath,'\all_Greedy_Server_number-Profit_data.txt');
        fid3=fopen(y3,'a');
        fprintf(fid3,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',I,J,resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3,taskAccRate3,extime3);
        fclose(fid3);
        y4=strcat(savePath,'\all_OLSA_Server_number-Profit_data.txt');
        fid4=fopen(y4,'a');
        fprintf(fid4,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',I,J,resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4,taskAccRate4,extime4);
        fclose(fid4);
%         y5=strcat(savePath,'\all_OPT_Server_number-Profit_data.txt');
%         fid5=fopen(y5,'a');
%         fprintf(fid5,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',I,J,resultQoE5,resultProfit5,providerProfit5,placementCost5,updateCost5,runCost5);
%         fclose(fid5);
        disp([i,se]);
    end
end