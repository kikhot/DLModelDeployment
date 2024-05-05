clc;
clear;

% 并行计算

dirdate=datestr(now+1,29);
savePath=['.\Code\result\Data_',dirdate];%windows
savePath = [savePath,'\beta_change'];
% savePath=['./Code/result/Data_',dirdate];%linux
if ~exist(savePath,'dir')
    mkdir(savePath);
end
addpath algorithm\;
addpath benchmarks\;

I = 300;   % 每个时隙推理任务数量
J = 4;      % 固定服务器数量为5
K = 8;    % DL模型类型数量
T = 30;    % 时隙
frame = 1;    % 每帧所占时隙
F = T/frame;    % 帧数
Betas = [5:5:70];
epsilon = 0.2;
seed_num = [1:1:20];


for i=1:size(Betas,2)%任务数变化结果
    data = cell(1,size(seed_num,2));
    parfor se = 1:size(seed_num, 2)
        rng(seed_num(se));%随机种子固定
        [serverCompuCap,storageCap,serverJumpDelay,serverCompuCost,MecDistance,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,taskSize,taskDeadline,taskPay,taskToMec,taskAndMecDistance,K_It,taskNeedCompuCap,taskNeedCompuRes] = parameterGeneration(I,J,K,T);
        % 随机算法
        Beta = Betas(i);
        % mine算法
        [~,~,~,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,extime2] = Last_Round_Algorithm(I,J,K,T,frame,F,K_It,serverCompuCap,storageCap,serverCompuCost, ...
            taskSize,taskPay,taskNeedCompuRes,taskNeedCompuCap,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI,Beta,epsilon);
        data{se} = [data{se};[Beta,resultQoE2,resultProfit2,providerProfit2,placementCost2,updateCost2,runCost2,extime2]];
        disp(['DLModelPlacement算法完成']);
        disp([i,se]);

    end
    for se = 1:size(seed_num, 2)
        y2=strcat(savePath,'\all_ours_beta_change-Profit_data.txt');
        fid2=fopen(y2,'a');
        fprintf(fid2,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.4f\n',data{se}(1,1),data{se}(1,2),data{se}(1,3),data{se}(1,4),data{se}(1,5),data{se}(1,6),data{se}(1,7),data{se}(1,8));
        fclose(fid2);
    end
end