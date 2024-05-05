clc;
clear

dirdate=datestr(now+3,29);
Pathstr='.\Code\result\Data_';%windows
addpath('export_fig-3.15\');

savePath1=[Pathstr,dirdate,'\edge_capacity_change','\our_serverCompuCap_change_data.txt'];
savePath2=[Pathstr,dirdate,'\edge_capacity_change','\DMDTA_serverCompuCap_change_data.txt'];
savePath3=[Pathstr,dirdate,'\edge_capacity_change','\OLSA_serverCompuCap_change_data.txt'];
savePath4=[Pathstr,dirdate,'\edge_capacity_change','\greedy_serverCompuCap_change_data.txt'];


savePath11=[Pathstr,dirdate,'\edge_capacity_change','\our_storageCap_change_data.txt'];
savePath12=[Pathstr,dirdate,'\edge_capacity_change','\DMDTA_storageCap_change_data.txt'];
savePath13=[Pathstr,dirdate,'\edge_capacity_change','\OLSA_storageCap_change_data.txt'];
savePath14=[Pathstr,dirdate,'\edge_capacity_change','\greedy_storageCap_change_data.txt'];


Beta = 30;
T = 30; % 时隙

%服务器数量固定为4个,任务数为300，计算容量变化影响利润图
data_1=load(savePath1);
b_1=data_1(:,1);
b_2=data_1(:,2);
b_3=data_1(:,3);
b_4=data_1(:,4);    
b_5=data_1(:,5);
b_6=data_1(:,6);
b_7=data_1(:,7);
b_8=data_1(:,8);
b_9=data_1(:,9);


% data_2=load(savePath2);
% j_1=data_2(:,1);%容量倍数变化
% j_2=data_2(:,2);%QoE
% j_3=data_2(:,3);%总收益
% j_4=data_2(:,4);%服务提供商收益
% j_5=data_2(:,5);%服务放置成本
% j_6=data_2(:,6);%服务更新成本
% j_7=data_2(:,7);%推理任务运行成本
% j_8=data_2(:,8);%推理任务接收率
% j_9=data_2(:,9);%算法运行时间

data_2=load(savePath2);
d_1=data_2(:,1);
d_2=data_2(:,2);
d_3=data_2(:,3);
d_4=data_2(:,4);    
d_5=data_2(:,5);
d_6=data_2(:,6);
d_7=data_2(:,7);
d_8=data_2(:,8);
d_9=data_2(:,9);

data_3=load(savePath3);
o_1=data_3(:,1);
o_2=data_3(:,2);
o_3=data_3(:,3);
o_4=data_3(:,4);    
o_5=data_3(:,5);
o_6=data_3(:,6);
o_7=data_3(:,7);
o_8=data_3(:,8);
o_9=data_3(:,9);

data_4=load(savePath4);
g_1=data_4(:,1);
g_2=data_4(:,2);
g_3=data_4(:,3);
g_4=data_4(:,4);    
g_5=data_4(:,5);
g_6=data_4(:,6);
g_7=data_4(:,7);
g_8=data_4(:,8);
g_9=data_4(:,9);


savePath=['.\Code\result\Figure_',dirdate, '\epsilon_change'];
if ~exist(savePath,'dir')
    mkdir(savePath);
end


% 总效用影响
figure(1)
temp1 =  Beta*b_2 + b_3;
temp2 =  Beta*d_2 + d_3;
temp3 =  Beta*o_2 + o_3;
temp4 =  Beta*g_2 + g_3;
% bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]]);
bar([[temp1(1),temp2(1),temp3(1),temp4(1)]; [temp1(2),temp2(2),temp3(2),temp4(2)]; [temp1(3),temp2(3),temp3(3),temp4(3)]; [temp1(4),temp2(4),temp3(4),temp4(4)]; [temp1(5),temp2(5),temp3(5),temp4(5)]; [temp1(6),temp2(6),temp3(6),temp4(6)]]);


xlabel('edge computational capacity change','fontsize',16);
ylabel('Total Utility','fontsize',16);


legend('MPUTA','OSMDA','OLSA','OGA','location','northwest');
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
% axis([0,9,0,1150])
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
set(gca,'xticklabel',{'0.5', '1', '1.5', '2', '2.5', '3'});
% set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
grid on;
export_fig([savePath,'\edge_computational_capacity change for utility'],'-png','-m2');
saveas(gcf,[savePath,'\edge_computational_capacity change for utility'],'svg');%矢量图


% 总的任务成本影响
figure(2)
temp1 =  b_7;
temp2 =  d_7;
temp3 =  o_7;
temp4 =  g_7;
% bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]]);
bar([[temp1(1),temp2(1),temp3(1),temp4(1)]; [temp1(2),temp2(2),temp3(2),temp4(2)]; [temp1(3),temp2(3),temp3(3),temp4(3)]; [temp1(4),temp2(4),temp3(4),temp4(4)]; [temp1(5),temp2(5),temp3(5),temp4(5)]; [temp1(6),temp2(6),temp3(6),temp4(6)]]);


xlabel('edge computational capacity change','fontsize',16);
ylabel('Total Running Cost','fontsize',16);


legend('MPUTA','OSMDA','OLSA','OGA','location','northwest');
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
% axis([0,9,0,1150])
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
set(gca,'xticklabel',{'0.5', '1', '1.5', '2', '2.5', '3'});
% set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
grid on;
export_fig([savePath,'\edge_computational_capacity change for running cost'],'-png','-m2');
saveas(gcf,[savePath,'\edge_computational_capacity change for running cost'],'svg');%矢量图


% 总的服务放置和更新成本影响
figure(3)
temp1 =  b_5+b_6;
temp2 =  d_5+d_6;
temp3 =  o_5+o_6;
temp4 =  g_5+g_6;
% bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]]);
bar([[temp1(1),temp2(1),temp3(1),temp4(1)]; [temp1(2),temp2(2),temp3(2),temp4(2)]; [temp1(3),temp2(3),temp3(3),temp4(3)]; [temp1(4),temp2(4),temp3(4),temp4(4)]; [temp1(5),temp2(5),temp3(5),temp4(5)]; [temp1(6),temp2(6),temp3(6),temp4(6)]]);


xlabel('edge computational capacity change','fontsize',16);
ylabel('Total Deployment Cost','fontsize',16);


legend('MPUTA','OSMDA','OLSA','OGA','location','northwest');
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
% axis([0,9,0,1150])
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
set(gca,'xticklabel',{'0.5', '1', '1.5', '2', '2.5', '3'});
% set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
grid on;
export_fig([savePath,'\edge_computational_capacity change for deployment cost'],'-png','-m2');
saveas(gcf,[savePath,'\edge_computational_capacity change for deployment cost'],'svg');%矢量图



% % 总的推理任务接收率影响
% figure(4)
% temp1 =  b_8;
% temp2 =  d_8;
% temp3 =  o_8;
% temp4 =  g_8;
% % bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]]);
% bar([[temp1(1),temp2(1),temp3(1),temp4(1)]; [temp1(2),temp2(2),temp3(2),temp4(2)]; [temp1(3),temp2(3),temp3(3),temp4(3)]; [temp1(4),temp2(4),temp3(4),temp4(4)]; [temp1(5),temp2(5),temp3(5),temp4(5)]; [temp1(6),temp2(6),temp3(6),temp4(6)]]);
% 
% 
% xlabel('edge computational capacity change','fontsize',13);
% ylabel('Task Acceptance Rate','fontsize',13);
% 
% 
% legend('MPUTA','OSMDA','OLSA','OGA','location','northwest');
% box on;
% set(gcf,'color','white');
% set(gca,'LineWid',1.5);
% set(gca,'xminortick','on');
% set(gca,'yminortick','on');
% set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
% % axis([0,9,0,1150])
% if size(get(gca,'YTick'),2)<=5
%     gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
%     set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
% end
% %
% set(gca,'xticklabel',{'0.5', '1', '1.5', '2', '2.5', '3'});
% % set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% % set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
% grid on;
% export_fig([savePath,'\edge_computational_capacity change for Task Acceptance Rate'],'-png','-m2');
% saveas(gcf,[savePath,'\edge_computational_capacity change for Task Acceptance Rate'],'svg');%矢量图


%边缘服务器变化影响任务接受率图
figure(4)
f1=fit(b_1,b_8,'smoothingspline');
f2=fit(d_1,d_8,'smoothingspline');
f3=fit(o_1,o_8,'smoothingspline');
f4=fit(g_1,g_8,'smoothingspline');

plot(b_1,f1(b_1),'^-r',d_1,f2(d_1),'-x',o_1,f3(o_1),'*-m',g_1,f4(g_1),'o-c','LineWidth',1,'MarkerSize',6);
legend('MPUTA','OSMDA','OLSA','OGA','Location','northwest')
xlabel('edge computational capacity change','fontsize',16);
ylabel('Task Acceptance Rate','fontsize',16);
xlim([0.4,3.1]);
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
export_fig([savePath,'\edge_computational_capacity change for Task Acceptance Rate'],'-png','-m2');
saveas(gcf,[savePath,'\edge_computational_capacity change for Task Acceptance Rate'],'epsc');%矢量图










%服务器数量固定为4个,任务数为300，存储容量变化影响利润图
data_11=load(savePath11);
b_11=data_11(:,1);
b_12=data_11(:,2);
b_13=data_11(:,3);
b_14=data_11(:,4);    
b_15=data_11(:,5);
b_16=data_11(:,6);
b_17=data_11(:,7);
b_18=data_11(:,8);
b_19=data_11(:,9);


% data_2=load(savePath2);
% j_1=data_2(:,1);%容量倍数变化
% j_2=data_2(:,2);%QoE
% j_3=data_2(:,3);%总收益
% j_4=data_2(:,4);%服务提供商收益
% j_5=data_2(:,5);%服务放置成本
% j_6=data_2(:,6);%服务更新成本
% j_7=data_2(:,7);%推理任务运行成本
% j_8=data_2(:,8);%推理任务接收率
% j_9=data_2(:,9);%算法运行时间

data_12=load(savePath12);
d_11=data_12(:,1);
d_12=data_12(:,2);
d_13=data_12(:,3);
d_14=data_12(:,4);    
d_15=data_12(:,5);
d_16=data_12(:,6);
d_17=data_12(:,7);
d_18=data_12(:,8);
d_19=data_12(:,9);

data_13=load(savePath13);
o_11=data_13(:,1);
o_12=data_13(:,2);
o_13=data_13(:,3);
o_14=data_13(:,4);    
o_15=data_13(:,5);
o_16=data_13(:,6);
o_17=data_13(:,7);
o_18=data_13(:,8);
o_19=data_13(:,9);

data_14=load(savePath14);
g_11=data_14(:,1);
g_12=data_14(:,2);
g_13=data_14(:,3);
g_14=data_14(:,4);    
g_15=data_14(:,5);
g_16=data_14(:,6);
g_17=data_14(:,7);
g_18=data_14(:,8);
g_19=data_14(:,9);


savePath=['.\Code\result\Figure_',dirdate, '\epsilon_change'];
if ~exist(savePath,'dir')
    mkdir(savePath);
end


% 总效用影响
figure(5)
temp1 =  Beta*b_12 + b_13;
temp2 =  Beta*d_12 + d_13;
temp3 =  Beta*o_12 + o_13;
temp4 =  Beta*g_12 + g_13;
% bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]]);
bar([[temp1(1),temp2(1),temp3(1),temp4(1)]; [temp1(2),temp2(2),temp3(2),temp4(2)]; [temp1(3),temp2(3),temp3(3),temp4(3)]; [temp1(4),temp2(4),temp3(4),temp4(4)]; [temp1(5),temp2(5),temp3(5),temp4(5)]; [temp1(6),temp2(6),temp3(6),temp4(6)]]);


xlabel('edge storage capacity change','fontsize',16);
ylabel('Total Utility','fontsize',16);


legend('MPUTA','OSMDA','OLSA','OGA','location','northwest');
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
ylim([0,90000])
% axis([0,9,0,1150])
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
set(gca,'xticklabel',{'0.5', '1', '1.5', '2', '2.5', '3'});
% set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
grid on;
export_fig([savePath,'\edge_storage_capacity change for utility'],'-png','-m2');
saveas(gcf,[savePath,'\edge_storage_capacity change for utility'],'svg');%矢量图


% 总的任务成本影响
figure(6)
temp1 =  b_17;
temp2 =  d_17;
temp3 =  o_17;
temp4 =  g_17;
% bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]]);
bar([[temp1(1),temp2(1),temp3(1),temp4(1)]; [temp1(2),temp2(2),temp3(2),temp4(2)]; [temp1(3),temp2(3),temp3(3),temp4(3)]; [temp1(4),temp2(4),temp3(4),temp4(4)]; [temp1(5),temp2(5),temp3(5),temp4(5)]; [temp1(6),temp2(6),temp3(6),temp4(6)]]);


xlabel('edge storage capacity change','fontsize',16);
ylabel('Total Running Cost','fontsize',16);


legend('MPUTA','OSMDA','OLSA','OGA','location','northwest');
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
% axis([0,3,0,90000])
ylim([0,8000])

if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
set(gca,'xticklabel',{'0.5', '1', '1.5', '2', '2.5', '3'});
% set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
grid on;
export_fig([savePath,'\edge_storage_capacity change for running cost'],'-png','-m2');
saveas(gcf,[savePath,'\edge_storage_capacity change for running cost'],'svg');%矢量图


% 总的服务放置和更新成本影响
figure(7)
temp1 =  b_15+b_16;
temp2 =  d_15+d_16;
temp3 =  o_15+o_16;
temp4 =  g_15+g_16;
% bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]]);
bar([[temp1(1),temp2(1),temp3(1),temp4(1)]; [temp1(2),temp2(2),temp3(2),temp4(2)]; [temp1(3),temp2(3),temp3(3),temp4(3)]; [temp1(4),temp2(4),temp3(4),temp4(4)]; [temp1(5),temp2(5),temp3(5),temp4(5)]; [temp1(6),temp2(6),temp3(6),temp4(6)]]);


xlabel('edge storage capacity change','fontsize',16);
ylabel('Total Deployment Cost','fontsize',16);


legend('MPUTA','OSMDA','OLSA','OGA','location','northwest');
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
% axis([0,9,0,1150])
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
set(gca,'xticklabel',{'0.5', '1', '1.5', '2', '2.5', '3'});
% set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
grid on;
export_fig([savePath,'\edge_storage_capacity change for deployment cost'],'-png','-m2');
saveas(gcf,[savePath,'\edge_storage_capacity change for deployment cost'],'svg');%矢量图



% % 总的推理任务接收率影响
% figure(4)
% temp1 =  b_8;
% temp2 =  d_8;
% temp3 =  o_8;
% temp4 =  g_8;
% % bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]]);
% bar([[temp1(1),temp2(1),temp3(1),temp4(1)]; [temp1(2),temp2(2),temp3(2),temp4(2)]; [temp1(3),temp2(3),temp3(3),temp4(3)]; [temp1(4),temp2(4),temp3(4),temp4(4)]; [temp1(5),temp2(5),temp3(5),temp4(5)]; [temp1(6),temp2(6),temp3(6),temp4(6)]]);
% 
% 
% xlabel('edge computational capacity change','fontsize',13);
% ylabel('Task Acceptance Rate','fontsize',13);
% 
% 
% legend('MPUTA','OSMDA','OLSA','OGA','location','northwest');
% box on;
% set(gcf,'color','white');
% set(gca,'LineWid',1.5);
% set(gca,'xminortick','on');
% set(gca,'yminortick','on');
% set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
% % axis([0,9,0,1150])
% if size(get(gca,'YTick'),2)<=5
%     gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
%     set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
% end
% %
% set(gca,'xticklabel',{'0.5', '1', '1.5', '2', '2.5', '3'});
% % set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% % set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
% grid on;
% export_fig([savePath,'\edge_computational_capacity change for Task Acceptance Rate'],'-png','-m2');
% saveas(gcf,[savePath,'\edge_computational_capacity change for Task Acceptance Rate'],'svg');%矢量图


%边缘服务器变化影响任务接受率图
figure(8)
f1=fit(b_11,b_18,'smoothingspline');
f2=fit(d_11,d_18,'smoothingspline');
f3=fit(o_11,o_18,'smoothingspline');
f4=fit(g_11,g_18,'smoothingspline');

plot(b_1,f1(b_1),'^-r',d_1,f2(d_1),'-x',o_1,f3(o_1),'*-m',g_1,f4(g_1),'o-c','LineWidth',1,'MarkerSize',6);
legend('MPUTA','OSMDA','OLSA','OGA','Location','northwest')
xlabel('edge storage capacity change','fontsize',16);
ylabel('Task Acceptance Rate','fontsize',16);
xlim([0.4,3.1]);
%
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'FontSize',14);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
ylim([0.10,0.33])

if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\edge_storage_capacity change for Task Acceptance Rate'],'-png','-m2');
saveas(gcf,[savePath,'\edge_storage_capacity change for Task Acceptance Rate'],'epsc');%矢量图