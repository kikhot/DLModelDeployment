clc;
clear

dirdate=datestr(now-1,29);
Pathstr='.\Code\result\Data_';%windows
% Pathstr='./Code/result/Data_';%linux
% dirdate=datestr(now,31);%‘yyyy-mm-dd HH:MM:SS’



% 边缘服务器计算容量变化
savePath11=[Pathstr,[dirdate,'\edge_capacity_change'],'\our_serverCompuCap_change_data.txt'];
savePath_11=[Pathstr,[dirdate,'\edge_capacity_change'],'\all_ours_serverCompuCap_change_data.txt'];
savePath21=[Pathstr,[dirdate,'\edge_capacity_change'],'\DMDTA_serverCompuCap_change_data.txt'];
savePath_21=[Pathstr,[dirdate,'\edge_capacity_change'],'\all_DMDTA_serverCompuCap_change_data.txt'];
savePath31=[Pathstr,[dirdate,'\edge_capacity_change'],'\OLSA_serverCompuCap_change_data.txt'];
savePath_31=[Pathstr,[dirdate,'\edge_capacity_change'],'\all_OLSA_serverCompuCap_change_data.txt'];
savePath41=[Pathstr,[dirdate,'\edge_capacity_change'],'\greedy_serverCompuCap_change_data.txt'];
savePath_41=[Pathstr,[dirdate,'\edge_capacity_change'],'\all_greedy_serverCompuCap_change_data.txt'];

% 边缘服务器存储容量变化
savePath12=[Pathstr,[dirdate,'\edge_capacity_change'],'\our_storageCap_change_data.txt'];
savePath_12=[Pathstr,[dirdate,'\edge_capacity_change'],'\all_ours_storageCap_change_data.txt'];
savePath22=[Pathstr,[dirdate,'\edge_capacity_change'],'\DMDTA_storageCap_change_data.txt'];
savePath_22=[Pathstr,[dirdate,'\edge_capacity_change'],'\all_DMDTA_storageCap_change_data.txt'];
savePath32=[Pathstr,[dirdate,'\edge_capacity_change'],'\OLSA_storageCap_change_data.txt'];
savePath_32=[Pathstr,[dirdate,'\edge_capacity_change'],'\all_OLSA_storageCap_change_data.txt'];
savePath42=[Pathstr,[dirdate,'\edge_capacity_change'],'\greedy_storageCap_change_data.txt'];
savePath_42=[Pathstr,[dirdate,'\edge_capacity_change'],'\all_greedy_storageCap_change_data.txt'];



%载入边缘服务器计算容量变化数据
load(savePath_11);
f11=fopen(savePath11,'w');
load(savePath_21);
f21=fopen(savePath21,'w');
load(savePath_31);
f31=fopen(savePath31,'w');
load(savePath_41);
f41=fopen(savePath41,'w');

%载入边缘服务器存储容量变化数据
load(savePath_12);
f12=fopen(savePath12,'w');
load(savePath_22);
f22=fopen(savePath22,'w');
load(savePath_32);
f32=fopen(savePath32,'w');
load(savePath_42);
f42=fopen(savePath42,'w');

Cycles=100;%循环次数
num_1=6*Cycles; % 容量变化次数
i_1=1;
j_1=Cycles;
while num_1~=0
    % 计算epsilon变化数据平均值
    fprintf(f11,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_ours_serverCompuCap_change_data(i_1:j_1,1)),ceil(mean(all_ours_serverCompuCap_change_data(i_1:j_1,2))),mean(all_ours_serverCompuCap_change_data(i_1:j_1,3)),mean(all_ours_serverCompuCap_change_data(i_1:j_1,4)),mean(all_ours_serverCompuCap_change_data(i_1:j_1,5)),mean(all_ours_serverCompuCap_change_data(i_1:j_1,6)),mean(all_ours_serverCompuCap_change_data(i_1:j_1,7)),mean(all_ours_serverCompuCap_change_data(i_1:j_1,8)),mean(all_ours_serverCompuCap_change_data(i_1:j_1,9)));
    fprintf(f21,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,1)),ceil(mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,2))),mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,3)),mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,4)),mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,5)),mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,6)),mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,7)),mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,8)),mean(all_DMDTA_serverCompuCap_change_data(i_1:j_1,9)));
    fprintf(f31,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,1)),ceil(mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,2))),mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,3)),mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,4)),mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,5)),mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,6)),mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,7)),mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,8)),mean(all_OLSA_serverCompuCap_change_data(i_1:j_1,9)));
    fprintf(f41,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_greedy_serverCompuCap_change_data(i_1:j_1,1)),ceil(mean(all_greedy_serverCompuCap_change_data(i_1:j_1,2))),mean(all_greedy_serverCompuCap_change_data(i_1:j_1,3)),mean(all_greedy_serverCompuCap_change_data(i_1:j_1,4)),mean(all_greedy_serverCompuCap_change_data(i_1:j_1,5)),mean(all_greedy_serverCompuCap_change_data(i_1:j_1,6)),mean(all_greedy_serverCompuCap_change_data(i_1:j_1,7)),mean(all_greedy_serverCompuCap_change_data(i_1:j_1,8)),mean(all_greedy_serverCompuCap_change_data(i_1:j_1,9)));
    fprintf(f12,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_ours_storageCap_change_data(i_1:j_1,1)),ceil(mean(all_ours_storageCap_change_data(i_1:j_1,2))),mean(all_ours_storageCap_change_data(i_1:j_1,3)),mean(all_ours_storageCap_change_data(i_1:j_1,4)),mean(all_ours_storageCap_change_data(i_1:j_1,5)),mean(all_ours_storageCap_change_data(i_1:j_1,6)),mean(all_ours_storageCap_change_data(i_1:j_1,7)),mean(all_ours_storageCap_change_data(i_1:j_1,8)),mean(all_ours_storageCap_change_data(i_1:j_1,9)));
    fprintf(f22,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_DMDTA_storageCap_change_data(i_1:j_1,1)),ceil(mean(all_DMDTA_storageCap_change_data(i_1:j_1,2))),mean(all_DMDTA_storageCap_change_data(i_1:j_1,3)),mean(all_DMDTA_storageCap_change_data(i_1:j_1,4)),mean(all_DMDTA_storageCap_change_data(i_1:j_1,5)),mean(all_DMDTA_storageCap_change_data(i_1:j_1,6)),mean(all_DMDTA_storageCap_change_data(i_1:j_1,7)),mean(all_DMDTA_storageCap_change_data(i_1:j_1,8)),mean(all_DMDTA_storageCap_change_data(i_1:j_1,9)));
    fprintf(f32,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_OLSA_storageCap_change_data(i_1:j_1,1)),ceil(mean(all_OLSA_storageCap_change_data(i_1:j_1,2))),mean(all_OLSA_storageCap_change_data(i_1:j_1,3)),mean(all_OLSA_storageCap_change_data(i_1:j_1,4)),mean(all_OLSA_storageCap_change_data(i_1:j_1,5)),mean(all_OLSA_storageCap_change_data(i_1:j_1,6)),mean(all_OLSA_storageCap_change_data(i_1:j_1,7)),mean(all_OLSA_storageCap_change_data(i_1:j_1,8)),mean(all_OLSA_storageCap_change_data(i_1:j_1,9)));
    fprintf(f42,'%d,%d,%.4f,%.2f,%.2f,%.2f,%.2f,%2f,%2f\n',mean(all_greedy_storageCap_change_data(i_1:j_1,1)),ceil(mean(all_greedy_storageCap_change_data(i_1:j_1,2))),mean(all_greedy_storageCap_change_data(i_1:j_1,3)),mean(all_greedy_storageCap_change_data(i_1:j_1,4)),mean(all_greedy_storageCap_change_data(i_1:j_1,5)),mean(all_greedy_storageCap_change_data(i_1:j_1,6)),mean(all_greedy_storageCap_change_data(i_1:j_1,7)),mean(all_greedy_storageCap_change_data(i_1:j_1,8)),mean(all_greedy_storageCap_change_data(i_1:j_1,9)));
    i_1=i_1+Cycles;
    j_1=j_1+Cycles;
    num_1=num_1-Cycles;
end
