clc;
clear

dirdate=datestr(now+2,29);
Pathstr=['.\Code\result\Data_',dirdate];%windows
Pathstr = [Pathstr,'\beta_change'];
% Pathstr='./Code/result/Data_';%linux
% dirdate=datestr(now,31);%‘yyyy-mm-dd HH:MM:SS’

% beta变化(任务固定为300，边缘服务器固定为5）
savePath1=[Pathstr,'\our_beta_change-Profit_data.txt'];
savePath_1=[Pathstr,'\all_ours_beta_change-Profit_data.txt'];

%载入beta变化数据
load(savePath_1);

f1=fopen(savePath1,'w');

Cycles=20;%循环次数
num_1=14*Cycles; % beta变化次数
i_1=1;
j_1=Cycles;
while num_1~=0
    % 计算任务数变化数据平均值
    fprintf(f1,'%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%4f\n',mean(all_ours_beta_change_Profit_data(i_1:j_1,1)),ceil(mean(all_ours_beta_change_Profit_data(i_1:j_1,2))),mean(all_ours_beta_change_Profit_data(i_1:j_1,3)),mean(all_ours_beta_change_Profit_data(i_1:j_1,4)),mean(all_ours_beta_change_Profit_data(i_1:j_1,5)),mean(all_ours_beta_change_Profit_data(i_1:j_1,6)),mean(all_ours_beta_change_Profit_data(i_1:j_1,7)),mean(all_ours_beta_change_Profit_data(i_1:j_1,8)));

    i_1=i_1+Cycles;
    j_1=j_1+Cycles;
    num_1=num_1-Cycles;
end
