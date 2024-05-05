clc;
clear

dirdate=datestr(now+3,29);
% dirdate=datestr(now,31);
Pathstr='.\Code\result\Data_';%windows
% Pathstr='./Code/result/Data_';%linux
addpath('export_fig-3.15\');

Beta = 30;

savePath1=[Pathstr,dirdate,'\Random_Server_number-Profit_data.txt'];
savePath2=[Pathstr,dirdate,'\ours_Server_number-Profit_data.txt'];
savePath3=[Pathstr,dirdate,'\Greedy_Server_number-Profit_data.txt'];
savePath4=[Pathstr,dirdate,'\OLSA_Server_number-Profit_data.txt'];
savePath5=[Pathstr,dirdate,'\DMDTA_Server_number-Profit_data.txt'];


%任务数量固定为300个,边缘服务器数变化影响效用图
data_1=load(savePath1);
b_1=data_1(:,2);
b_2=data_1(:,3);
b_3=data_1(:,4);
b_4=data_1(:,5);
b_5=data_1(:,6);
b_6=data_1(:,7);
b_7=data_1(:,8);
b_8=data_1(:,9);
data_2=load(savePath2);
j_1=data_2(:,2);%边缘服务器数量
j_2=data_2(:,3);%QoE
j_3=data_2(:,4);%总收益
j_4=data_2(:,5);%服务提供商收益
j_5=data_2(:,6);%服务放置成本
j_6=data_2(:,7);%服务更新成本
j_7=data_2(:,8);%推理任务运行成本
j_8=data_2(:,9);%推理任务运行成本
data_3=load(savePath3);
g_1=data_3(:,2);%任务数
g_2=data_3(:,3);%QoE
g_3=data_3(:,4);%总收益
g_4=data_3(:,5);%服务提供商收益
g_5=data_3(:,6);%服务放置成本
g_6=data_3(:,7);%服务更新成本
g_7=data_3(:,8);%推理任务运行成本
g_8=data_3(:,9);%推理任务运行成本
data_4=load(savePath4);
o_1=data_4(:,2);%任务数
o_2=data_4(:,3);%QoE
o_3=data_4(:,4);%总收益
o_4=data_4(:,5);%服务提供商收益
o_5=data_4(:,6);%服务放置成本
o_6=data_4(:,7);%服务更新成本
o_7=data_4(:,8);%推理任务运行成本
o_8=data_4(:,9);%推理任务运行成本
data_5=load(savePath5);
d_1=data_5(:,2);%任务数
d_2=data_5(:,3);%QoE
d_3=data_5(:,4);%总收益
d_4=data_5(:,5);%服务提供商收益
d_5=data_5(:,6);%服务放置成本
d_6=data_5(:,7);%服务更新成本
d_7=data_5(:,8);%推理任务运行成本
d_8=data_5(:,9);%推理任务运行成本


savePath=['.\Code\result\Figure_',dirdate];
if ~exist(savePath,'dir')
    mkdir(savePath);
end

%边缘服务器变化影响效用图
figure(1)
f1=fit(b_1,Beta*b_2+b_3,'smoothingspline');
f2=fit(j_1,Beta*j_2+j_3,'smoothingspline');
f3=fit(g_1,Beta*g_2+g_3,'smoothingspline');
f4=fit(o_1,Beta*o_2+o_3,'smoothingspline');
f5=fit(d_1,Beta*d_2+d_3,'smoothingspline');
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Servers','fontsize',16);
ylabel('Total Utility','fontsize',16);
xlim([0,14]);
%
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'xminortick','on');
set(gca,'FontSize',14);
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total Utility_Variation of number of servers'],'-png','-m2');
saveas(gcf,[savePath,'\Total Utility_Variation of number of servers'],'epsc');%矢量图




%边缘服务器变化影响QoE图
figure(2)
f1=fit(b_1,b_2,'smoothingspline');
f2=fit(j_1,j_2,'smoothingspline');
f3=fit(g_1,g_2,'smoothingspline');
f4=fit(o_1,o_2,'smoothingspline');
f5=fit(d_1,d_2,'smoothingspline');
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Servers','fontsize',16);
ylabel('Total QoE','fontsize',16);
xlim([0,14]);
%
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'FontSize',14);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total QoE_Variation of number of servers'],'-png','-m2');
saveas(gcf,[savePath,'\Total QoE_Variation of number of servers'],'epsc');%矢量图



%边缘服务器变化影响利润图
figure(3)
f1=fit(b_1,b_3,'smoothingspline');
f2=fit(j_1,j_3,'smoothingspline');
f3=fit(g_1,g_3,'smoothingspline');
f4=fit(o_1,o_3,'smoothingspline');
f5=fit(d_1,d_3,'smoothingspline');
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Servers','fontsize',16);
ylabel('Total Profit(Dollar)','fontsize',16);
xlim([0,14]);
%
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'FontSize',14);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total Profit_Variation of number of servers'],'-png','-m2');
saveas(gcf,[savePath,'\Total Profit_Variation of number of servers'],'epsc');%矢量图


%边缘服务器变化影响任务接受率图
figure(4)
f1=fit(b_1,b_8,'smoothingspline');
f2=fit(j_1,j_8,'smoothingspline');
f3=fit(g_1,g_8,'smoothingspline');
f4=fit(o_1,o_8,'smoothingspline');
f5=fit(d_1,d_8,'smoothingspline');
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Servers','fontsize',16);
ylabel('Task Acceptance Rate','fontsize',16);
xlim([0,14]);
%
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'FontSize',14);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total Task_Acceptance_Rate of number of servers'],'-png','-m2');
saveas(gcf,[savePath,'\Total Task_Acceptance_Rate of number of servers'],'epsc');%矢量图

