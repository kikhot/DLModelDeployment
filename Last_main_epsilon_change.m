clc;
clear;

dirdate=datestr(now+1,29);
savePath=['.\Code\result\Data_',dirdate];%windows
% savePath=['./Code/result/Data_',dirdate];%linux
savePath = [savePath,'\epsilon_change'];
if ~exist(savePath,'dir')
    mkdir(savePath);
end
addpath algorithm\;
addpath benchmarks\;

requestCount = 300;   % 每个时隙推理任务数量
J = 4;      % 固定服务器数量为4
K = 8;    % DL模型类型数量
T = 30;    % 时隙
frame = 1;    % 每帧所占时隙
F = T/frame;    % 帧数
Beta = 30;
seed_num = [1:1:100];
epsilons = [0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000];

for e_index=1:size(epsilons,2)
    epsilon = epsilons(e_index);
    for se = 1:size(seed_num, 2)
        rng(seed_num(se));%随机种子固定
        I = requestCount;  % 每个时隙的任务数量
        [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
        % mine算法
        [~,~,~,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
        disp(['DLModelPlacement算法完成']);
    
        y2=strcat(savePath,['\all_mine_epsilon_change_data', '.txt']);
        fid2=fopen(y2,'a');
        fprintf(fid2,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',I,J,epsilon,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2);  % 写入数据到文件
        fclose(fid2);
        disp([se, e_index]);
    end
end