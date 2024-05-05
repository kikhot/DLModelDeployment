clc;
clear

dirdate=datestr(now + 1,29);
Pathstr='.\Code\result\Data_';%windows
% Pathstr='./Code/result/Data_';%linux
% dirdate=datestr(now,31);%‘yyyy-mm-dd HH:MM:SS’



% 任务变化
savePath12=[Pathstr,[dirdate,'\epsilon_change'],'\mine_epsilon_change_data.txt'];
savePath_12=[Pathstr,[dirdate,'\epsilon_change'],'\all_mine_epsilon_change_data.txt'];



%载入任务数变化数据
load(savePath_12);
f12=fopen(savePath12,'w');

Cycles=100;%循环次数
num_1=8*Cycles; % epsilon变化次数
i_1=1;
j_1=Cycles;
while num_1~=0
    % 计算epsilon变化数据平均值
    fprintf(f12,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_mine_epsilon_change_data(i_1:j_1,1)),ceil(mean(all_mine_epsilon_change_data(i_1:j_1,2))),mean(all_mine_epsilon_change_data(i_1:j_1,3)),mean(all_mine_epsilon_change_data(i_1:j_1,4)),mean(all_mine_epsilon_change_data(i_1:j_1,5)),mean(all_mine_epsilon_change_data(i_1:j_1,6)),mean(all_mine_epsilon_change_data(i_1:j_1,7)),mean(all_mine_epsilon_change_data(i_1:j_1,8)),mean(all_mine_epsilon_change_data(i_1:j_1,9)));
    i_1=i_1+Cycles;
    j_1=j_1+Cycles;
    num_1=num_1-Cycles;
end
