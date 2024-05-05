clc;
clear

dirdate=datestr(now,29);
Pathstr='.\Code\result\Data_';%windows
% Pathstr='./Code/result/Data_';%linux
% dirdate=datestr(now,31);%‘yyyy-mm-dd HH:MM:SS’




% slot变化
savePath11=[Pathstr,dirdate,'\ours_slot_number_Profit_data.txt'];
savePath_11=[Pathstr,dirdate,'\all_ours_10_slot_number-Profit_data.txt'];
savePath_12=[Pathstr,dirdate,'\all_ours_30_slot_number-Profit_data.txt'];
savePath_13=[Pathstr,dirdate,'\all_ours_50_slot_number-Profit_data.txt'];
savePath_14=[Pathstr,dirdate,'\all_ours_70_slot_number-Profit_data.txt'];



%载入slot数变化数据
load(savePath_11);
load(savePath_12);
load(savePath_13);
load(savePath_14);


f11=fopen(savePath11,'w');


Cycles=100;%循环次数
i_1=1;
j_1=Cycles;

% 计算任务数变化数据平均值
fprintf(f11,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',mean(all_ours_10_slot_number_Profit_data(i_1:j_1,1)),ceil(mean(all_ours_10_slot_number_Profit_data(i_1:j_1,2))),mean(all_ours_10_slot_number_Profit_data(i_1:j_1,3)),mean(all_ours_10_slot_number_Profit_data(i_1:j_1,4)),mean(all_ours_10_slot_number_Profit_data(i_1:j_1,5)),mean(all_ours_10_slot_number_Profit_data(i_1:j_1,6)),mean(all_ours_10_slot_number_Profit_data(i_1:j_1,7)),mean(all_ours_10_slot_number_Profit_data(i_1:j_1,8)));
fprintf(f11,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',mean(all_ours_30_slot_number_Profit_data(i_1:j_1,1)),ceil(mean(all_ours_30_slot_number_Profit_data(i_1:j_1,2))),mean(all_ours_30_slot_number_Profit_data(i_1:j_1,3)),mean(all_ours_30_slot_number_Profit_data(i_1:j_1,4)),mean(all_ours_30_slot_number_Profit_data(i_1:j_1,5)),mean(all_ours_30_slot_number_Profit_data(i_1:j_1,6)),mean(all_ours_30_slot_number_Profit_data(i_1:j_1,7)),mean(all_ours_30_slot_number_Profit_data(i_1:j_1,8)));
fprintf(f11,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',mean(all_ours_50_slot_number_Profit_data(i_1:j_1,1)),ceil(mean(all_ours_50_slot_number_Profit_data(i_1:j_1,2))),mean(all_ours_50_slot_number_Profit_data(i_1:j_1,3)),mean(all_ours_50_slot_number_Profit_data(i_1:j_1,4)),mean(all_ours_50_slot_number_Profit_data(i_1:j_1,5)),mean(all_ours_50_slot_number_Profit_data(i_1:j_1,6)),mean(all_ours_50_slot_number_Profit_data(i_1:j_1,7)),mean(all_ours_50_slot_number_Profit_data(i_1:j_1,8)));
fprintf(f11,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f\n',mean(all_ours_70_slot_number_Profit_data(i_1:j_1,1)),ceil(mean(all_ours_70_slot_number_Profit_data(i_1:j_1,2))),mean(all_ours_70_slot_number_Profit_data(i_1:j_1,3)),mean(all_ours_70_slot_number_Profit_data(i_1:j_1,4)),mean(all_ours_70_slot_number_Profit_data(i_1:j_1,5)),mean(all_ours_70_slot_number_Profit_data(i_1:j_1,6)),mean(all_ours_70_slot_number_Profit_data(i_1:j_1,7)),mean(all_ours_70_slot_number_Profit_data(i_1:j_1,8)));

i_1=i_1+Cycles;
j_1=j_1+Cycles;