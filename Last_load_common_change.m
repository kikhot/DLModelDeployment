clc;
clear

dirdate=datestr(now+6,29);
Pathstr='.\Code\result\Data_';%windows
% Pathstr='./Code/result/Data_';%linux
% dirdate=datestr(now,31);%‘yyyy-mm-dd HH:MM:SS’




% % 任务变化
% savePath11=[Pathstr,dirdate,'\Random_Task_number-Profit_data.txt'];
% savePath12=[Pathstr,dirdate,'\ours_Task_number-Profit_data.txt'];
% savePath13=[Pathstr,dirdate,'\Greedy_Task_number-Profit_data.txt'];
% savePath14=[Pathstr,dirdate,'\OLSA_Task_number-Profit_data.txt'];
% savePath15=[Pathstr,dirdate,'\DMDTA_Task_number-Profit_data.txt'];
% % savePath15=[Pathstr,dirdate,'\opt_Task_number-Profit_data.txt'];
% savePath_11=[Pathstr,dirdate,'\all_Random_Task_number-Profit_data.txt'];
% savePath_12=[Pathstr,dirdate,'\all_ours_Task_number-Profit_data.txt'];
% savePath_13=[Pathstr,dirdate,'\all_Greedy_Task_number-Profit_data.txt'];
% savePath_14=[Pathstr,dirdate,'\all_OLSA_Task_number-Profit_data.txt'];
% savePath_15=[Pathstr,dirdate,'\all_DMDTA_Task_number-Profit_data.txt'];
% % savePath_15=[Pathstr,dirdate,'\all_OPT_Task_number-Profit_data.txt'];

% 边缘服务器变化
savePath21=[Pathstr,dirdate,'\Random_Server_number-Profit_data.txt'];
savePath22=[Pathstr,dirdate,'\ours_Server_number-Profit_data.txt'];
savePath23=[Pathstr,dirdate,'\Greedy_Server_number-Profit_data.txt'];
savePath24=[Pathstr,dirdate,'\OLSA_Server_number-Profit_data.txt'];
savePath25=[Pathstr,dirdate,'\DMDTA_Server_number-Profit_data.txt'];
savePath_21=[Pathstr,dirdate,'\all_Random_Server_number-Profit_data.txt'];
savePath_22=[Pathstr,dirdate,'\all_ours_Server_number-Profit_data.txt'];
savePath_23=[Pathstr,dirdate,'\all_Greedy_Server_number-Profit_data.txt'];
savePath_24=[Pathstr,dirdate,'\all_OLSA_Server_number-Profit_data.txt'];
savePath_25=[Pathstr,dirdate,'\all_DMDTA_Server_number-Profit_data.txt'];


% %载入任务数变化数据
% load(savePath_11);
% load(savePath_12);
% load(savePath_13);
% load(savePath_14);
% load(savePath_15);


%载入边缘服务器变化数据
load(savePath_21);
load(savePath_22);
load(savePath_23);
load(savePath_24);
load(savePath_25);

% f11=fopen(savePath11,'w');
% f12=fopen(savePath12,'w');
% f13=fopen(savePath13,'w');
% f14=fopen(savePath14,'w');
% f15=fopen(savePath15,'w');

f21=fopen(savePath21,'w');
f22=fopen(savePath22,'w');
f23=fopen(savePath23,'w');
f24=fopen(savePath24,'w');
f25=fopen(savePath25,'w');

% Cycles=100;%循环次数
% num_1=16*Cycles; % 任务变化次数
% i_1=1;
% j_1=Cycles;
% while num_1~=0
%     % 计算任务数变化数据平均值
%     fprintf(f11,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_Random_Task_number_Profit_data(i_1:j_1,1)),ceil(mean(all_Random_Task_number_Profit_data(i_1:j_1,2))),mean(all_Random_Task_number_Profit_data(i_1:j_1,3)),mean(all_Random_Task_number_Profit_data(i_1:j_1,4)),mean(all_Random_Task_number_Profit_data(i_1:j_1,5)),mean(all_Random_Task_number_Profit_data(i_1:j_1,6)),mean(all_Random_Task_number_Profit_data(i_1:j_1,7)),mean(all_Random_Task_number_Profit_data(i_1:j_1,8)),mean(all_Random_Task_number_Profit_data(i_1:j_1,9)),mean(all_Random_Task_number_Profit_data(i_1:j_1,10)));
%     fprintf(f12,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_ours_Task_number_Profit_data(i_1:j_1,1)),ceil(mean(all_ours_Task_number_Profit_data(i_1:j_1,2))),mean(all_ours_Task_number_Profit_data(i_1:j_1,3)),mean(all_ours_Task_number_Profit_data(i_1:j_1,4)),mean(all_ours_Task_number_Profit_data(i_1:j_1,5)),mean(all_ours_Task_number_Profit_data(i_1:j_1,6)),mean(all_ours_Task_number_Profit_data(i_1:j_1,7)),mean(all_ours_Task_number_Profit_data(i_1:j_1,8)),mean(all_ours_Task_number_Profit_data(i_1:j_1,9)),mean(all_ours_Task_number_Profit_data(i_1:j_1,10)));
%     fprintf(f13,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_Greedy_Task_number_Profit_data(i_1:j_1,1)),ceil(mean(all_Greedy_Task_number_Profit_data(i_1:j_1,2))),mean(all_Greedy_Task_number_Profit_data(i_1:j_1,3)),mean(all_Greedy_Task_number_Profit_data(i_1:j_1,4)),mean(all_Greedy_Task_number_Profit_data(i_1:j_1,5)),mean(all_Greedy_Task_number_Profit_data(i_1:j_1,6)),mean(all_Greedy_Task_number_Profit_data(i_1:j_1,7)),mean(all_Greedy_Task_number_Profit_data(i_1:j_1,8)),mean(all_Greedy_Task_number_Profit_data(i_1:j_1,9)),mean(all_Greedy_Task_number_Profit_data(i_1:j_1,10)));
%     fprintf(f14,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_OLSA_Task_number_Profit_data(i_1:j_1,1)),ceil(mean(all_OLSA_Task_number_Profit_data(i_1:j_1,2))),mean(all_OLSA_Task_number_Profit_data(i_1:j_1,3)),mean(all_OLSA_Task_number_Profit_data(i_1:j_1,4)),mean(all_OLSA_Task_number_Profit_data(i_1:j_1,5)),mean(all_OLSA_Task_number_Profit_data(i_1:j_1,6)),mean(all_OLSA_Task_number_Profit_data(i_1:j_1,7)),mean(all_OLSA_Task_number_Profit_data(i_1:j_1,8)),mean(all_OLSA_Task_number_Profit_data(i_1:j_1,9)),mean(all_OLSA_Task_number_Profit_data(i_1:j_1,10)));
%     fprintf(f15,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,1)),ceil(mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,2))),mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,3)),mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,4)),mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,5)),mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,6)),mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,7)),mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,8)),mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,9)),mean(all_DMDTA_Task_number_Profit_data(i_1:j_1,10)));
%     %     fprintf(f15,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%4f\n',mean(all_OPT_Task_number_Profit_data(i_1:j_1,1)),ceil(mean(all_OPT_Task_number_Profit_data(i_1:j_1,2))),mean(all_OPT_Task_number_Profit_data(i_1:j_1,3)),mean(all_OPT_Task_number_Profit_data(i_1:j_1,4)),mean(all_OPT_Task_number_Profit_data(i_1:j_1,5)),mean(all_OPT_Task_number_Profit_data(i_1:j_1,6)),mean(all_OPT_Task_number_Profit_data(i_1:j_1,7)),mean(all_OPT_Task_number_Profit_data(i_1:j_1,8)),mean(all_OPT_Task_number_Profit_data(i_1:j_1,9)));
% 
%     i_1=i_1+Cycles;
%     j_1=j_1+Cycles;
%     num_1=num_1-Cycles;
% end

Cycles=100;%循环次数
% num_1=14*Cycles;    % 边缘服务器变化次数
num_1=7*Cycles;    % 边缘服务器变化次数
i_1=1;
j_1=Cycles;
while num_1~=0
    % 计算边缘服务器数变化数据平均值
    fprintf(f21,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_Random_Server_number_Profit_data(i_1:j_1,1)),ceil(mean(all_Random_Server_number_Profit_data(i_1:j_1,2))),mean(all_Random_Server_number_Profit_data(i_1:j_1,3)),mean(all_Random_Server_number_Profit_data(i_1:j_1,4)),mean(all_Random_Server_number_Profit_data(i_1:j_1,5)),mean(all_Random_Server_number_Profit_data(i_1:j_1,6)),mean(all_Random_Server_number_Profit_data(i_1:j_1,7)),mean(all_Random_Server_number_Profit_data(i_1:j_1,8)), mean(all_Random_Server_number_Profit_data(i_1:j_1,9)),mean(all_Random_Server_number_Profit_data(i_1:j_1,10)));
    fprintf(f22,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_ours_Server_number_Profit_data(i_1:j_1,1)),ceil(mean(all_ours_Server_number_Profit_data(i_1:j_1,2))),mean(all_ours_Server_number_Profit_data(i_1:j_1,3)),mean(all_ours_Server_number_Profit_data(i_1:j_1,4)),mean(all_ours_Server_number_Profit_data(i_1:j_1,5)),mean(all_ours_Server_number_Profit_data(i_1:j_1,6)),mean(all_ours_Server_number_Profit_data(i_1:j_1,7)),mean(all_ours_Server_number_Profit_data(i_1:j_1,8)), mean(all_ours_Server_number_Profit_data(i_1:j_1,9)),mean(all_ours_Server_number_Profit_data(i_1:j_1,10)));
    fprintf(f23,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_Greedy_Server_number_Profit_data(i_1:j_1,1)),ceil(mean(all_Greedy_Server_number_Profit_data(i_1:j_1,2))),mean(all_Greedy_Server_number_Profit_data(i_1:j_1,3)),mean(all_Greedy_Server_number_Profit_data(i_1:j_1,4)),mean(all_Greedy_Server_number_Profit_data(i_1:j_1,5)),mean(all_Greedy_Server_number_Profit_data(i_1:j_1,6)),mean(all_Greedy_Server_number_Profit_data(i_1:j_1,7)),mean(all_Greedy_Server_number_Profit_data(i_1:j_1,8)), mean(all_Greedy_Server_number_Profit_data(i_1:j_1,9)),mean(all_Greedy_Server_number_Profit_data(i_1:j_1,10)));
    fprintf(f24,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_OLSA_Server_number_Profit_data(i_1:j_1,1)),ceil(mean(all_OLSA_Server_number_Profit_data(i_1:j_1,2))),mean(all_OLSA_Server_number_Profit_data(i_1:j_1,3)),mean(all_OLSA_Server_number_Profit_data(i_1:j_1,4)),mean(all_OLSA_Server_number_Profit_data(i_1:j_1,5)),mean(all_OLSA_Server_number_Profit_data(i_1:j_1,6)),mean(all_OLSA_Server_number_Profit_data(i_1:j_1,7)),mean(all_OLSA_Server_number_Profit_data(i_1:j_1,8)), mean(all_OLSA_Server_number_Profit_data(i_1:j_1,9)),mean(all_OLSA_Server_number_Profit_data(i_1:j_1,10)));
    fprintf(f25,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%2f,%2f,%4f\n',mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,1)),ceil(mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,2))),mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,3)),mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,4)),mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,5)),mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,6)),mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,7)),mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,8)),mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,9)),mean(all_DMDTA_Server_number_Profit_data(i_1:j_1,10)));

    i_1=i_1+Cycles;
    j_1=j_1+Cycles;
    num_1=num_1-Cycles;
end