clc;
clear;

% 并行计算

dirdate=datestr(now+1,29);
savePath=['.\Code\result\Data_',dirdate];%windows
% savePath=['./Code/result/Data_',dirdate];%linux
if ~exist(savePath,'dir')
    mkdir(savePath);
end
addpath algorithm\;
addpath benchmarks\;

requestCount = [25:25:400];   % 每个时隙推理任务数量
J = 4;      % 固定服务器数量为5
K = 8;    % DL模型类型数量
T = 30;    % 时隙
frame = 1;    % 每帧所占时隙
F = T/frame;    % 帧数
Beta = 8;
epsilon = 0.2;
seed_num = [1:1:100];

I=300


data = cell(1,size(seed_num,2));
parfor se = 1:size(seed_num, 2)
    rng(seed_num(se));%随机种子固定
    T = 30;
    F = 30;
    [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
    % mine算法
    [~,~,~,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
        taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
    data{se} = [data{se};[I,J,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2]];
    disp(['DLModelPlacement算法完成']);
    T = 50;
    F = 50;
    [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
    % mine算法
    [~,~,~,resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
        taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
    data{se} = [data{se};[I,J,resultQoE3,resultProfit3,providerProfit3,placementCost3,updateCost3,runCost3]];
    disp(['DLModelPlacement算法完成']);
    T = 70;
    F = 70;
    [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
    % mine算法
    [~,~,~,resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
        taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
    data{se} = [data{se};[I,J,resultQoE4,resultProfit4,providerProfit4,placementCost4,updateCost4,runCost4]];
    disp(['DLModelPlacement算法完成']);
    disp([se]);

end
for se = 1:size(seed_num, 2)
    y1=strcat(savePath,'\all_ours_30_Task_number-Profit_data.txt');
    fid1=fopen(y1,'a');
    fprintf(fid1,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',data{se}(1,1),data{se}(1,2),data{se}(1,3),data{se}(1,4),data{se}(1,5),data{se}(1,6),data{se}(1,7),data{se}(1,8));
    fclose(fid1);
    y2=strcat(savePath,'\all_ours_50_Task_number-Profit_data.txt');
    fid2=fopen(y2,'a');
    fprintf(fid2,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',data{se}(2,1),data{se}(2,2),data{se}(2,3),data{se}(2,4),data{se}(2,5),data{se}(2,6),data{se}(2,7),data{se}(2,8));
    fclose(fid2);
    y3=strcat(savePath,'\all_ours_70_Task_number-Profit_data.txt');
    fid3=fopen(y3,'a');
    fprintf(fid3,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',data{se}(3,1),data{se}(3,2),data{se}(3,3),data{se}(3,4),data{se}(3,5),data{se}(3,6),data{se}(3,7),data{se}(3,8));
    fclose(fid3);
end
