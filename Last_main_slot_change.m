clc;
clear;

dirdate=datestr(now,29);
savePath=['.\Code\result\Data_',dirdate];%windows
% savePath=['./Code/result/Data_',dirdate];%linux
savePath = [savePath,'\epsilon_change'];
if ~exist(savePath,'dir')
    mkdir(savePath);
end
addpath algorithm\;
addpath benchmarks\;

requestCount = [25:25:400];   % 每个时隙推理任务数量
I = 300;
J = 4;      % 固定服务器数量为4
K = 8;    % DL模型类型数量
T = 10;    % 时隙
frame = 1;    % 每帧所占时隙
F = T/frame;    % 帧数
Beta = 8;
seed_num = [1:1:3];
slots = [10,30,50,70];
epsilon = 0.2;

for slot = 1:size(slots, 2)
%     rng(seed_num(se));%随机种子固定
    T = slots(slot);
    F = T;
    [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
    % mine算法
    [~,~,~,resultQoE1,resultProfit1,providerProfit1,placementCost1,updateCost1,runCost1] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
        taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
    disp(['10DLModelPlacement算法完成']);
    y2=strcat(savePath,['\all_min_slot_change_data', '.txt']);
    fid2=fopen(y2,'a');
    fprintf(fid2,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',I,J,T,resultQoE1/T,resultProfit1/T,providerProfit1/T,placementCost1/T,updateCost1/T,runCost1/T);  % 写入数据到文件
    fclose(fid2);
end