clc;
clear

dirdate=datestr(now-117 ,29);
Pathstr='.\Code\result\Data_';%windows
addpath('export_fig-3.15\');

savePath1=[Pathstr,dirdate,'\Random_Task_number-Profit_data.txt'];
savePath2=[Pathstr,dirdate,'\ours_Task_number-Profit_data.txt'];
savePath3=[Pathstr,dirdate,'\Greedy_Task_number-Profit_data.txt'];
savePath4=[Pathstr,dirdate,'\OLSA_Task_number-Profit_data.txt'];
savePath5=[Pathstr,dirdate,'\DMDTA_Task_number-Profit_data.txt'];
% savePath5=[Pathstr,dirdate,'\opt_Task_number-Profit_data.txt'];

Beta = 30;
T = 30; % 时隙

%服务器数量固定为4个,任务数变化影响利润图
data_1=load(savePath1);
b_1=data_1(:,1);
b_2=data_1(:,3);
b_3=data_1(:,4);
b_4=data_1(:,5);    
b_5=data_1(:,6);
b_6=data_1(:,7);
b_7=data_1(:,8);
b_8=data_1(:,9);
b_9=data_1(:,10);

data_2=load(savePath2);
j_1=data_2(:,1);%任务数
j_2=data_2(:,3);%QoE
j_3=data_2(:,4);%总收益
j_4=data_2(:,5);%服务提供商收益
j_5=data_2(:,6);%服务放置成本
j_6=data_2(:,7);%服务更新成本
j_7=data_2(:,8);%推理任务运行成本
j_8=data_2(:,9);%推理任务接受率
j_9=data_2(:,10);%算法运行时间

data_3=load(savePath3);
g_1=data_3(:,1);%任务数
g_2=data_3(:,3);%QoE
g_3=data_3(:,4);%总收益
g_4=data_3(:,5);%服务提供商收益
g_5=data_3(:,6);%服务放置成本
g_6=data_3(:,7);%服务更新成本
g_7=data_3(:,8);%推理任务运行成本
g_8=data_3(:,9);%推理任务接受率
g_9=data_3(:,10);%算法运行时间

data_4=load(savePath4);
o_1=data_4(:,1);%任务数
o_2=data_4(:,3);%QoE
o_3=data_4(:,4);%总收益
o_4=data_4(:,5);%服务提供商收益
o_5=data_4(:,6);%服务放置成本
o_6=data_4(:,7);%服务更新成本
o_7=data_4(:,8);%推理任务运行成本
o_8=data_4(:,9);%推理任务接受率
o_9=data_4(:,10);%算法运行时间

data_5=load(savePath5);
d_1=data_5(:,1);%任务数
d_2=data_5(:,3);%QoE
d_3=data_5(:,4);%总收益
d_4=data_5(:,5);%服务提供商收益
d_5=data_5(:,6);%服务放置成本
d_6=data_5(:,7);%服务更新成本
d_7=data_5(:,8);%推理任务运行成本
d_8=data_5(:,9);%推理任务接受率
d_9=data_5(:,10);%算法运行时间

% 
% data_5=load(savePath5);
% opt_1=data_5(:,1);%任务数
% opt_2=data_5(:,3);%QoE
% opt_3=data_5(:,4);%总收益
% opt_4=data_5(:,5);%服务提供商收益
% opt_5=data_5(:,6);%服务放置成本
% opt_6=data_5(:,7);%服务更新成本
% opt_7=data_5(:,8);%推理任务运行成本
% opt_8=data_5(:,9);%算法运行时间

savePath=['.\Code\result\Figure_',dirdate];
if ~exist(savePath,'dir')
    mkdir(savePath);
end


%使用fit函数平滑实验图****************************************************···························

%任务数变化影响效用值图
figure(1)
f1=fit(b_1,Beta*b_2+b_3,'smoothingspline');
f2=fit(j_1,Beta*j_2+j_3,'smoothingspline');
f3=fit(g_1,Beta*g_2+g_3,'smoothingspline');
f4=fit(o_1,Beta*o_2+o_3,'smoothingspline');
f5=fit(d_1,Beta*d_2+d_3,'smoothingspline');
% f5=fit(opt_1,Beta*opt_2+opt_3,'smoothingspline');
% plot(b_1,f1(b_1),'^-r',j_1,f2(j_1),'*-m',g_1,f3(g_1),'o-c',o_1,f4(o_1),'-s',opt_1,f5(opt_1),'-x','LineWidth',1,'MarkerSize',6);
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
% legend('Random','ours','OGA','OLSA','OPT','Location','best')
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Tasks','fontsize',16);
ylabel('Total Utility','fontsize',16);
%
box on;
% set(gca,'YLim',[2000 22000]);
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
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total Utility_Variation of number of tasks'],'-png','-m2');
saveas(gcf,[savePath,'\Total Utility_Variation of number of tasks'],'epsc');%矢量图



%任务数变化影响用户体验值(QoE)图
figure(2)
f1=fit(b_1,b_2,'smoothingspline');
f2=fit(j_1,j_2,'smoothingspline');
f3=fit(g_1,g_2,'smoothingspline');
f4=fit(o_1,o_2,'smoothingspline');
f5=fit(d_1,d_2,'smoothingspline');
% f5=fit(opt_1,opt_2,'smoothingspline');

% plot(b_1,f1(b_1),'^-r',j_1,f2(j_1),'*-m',g_1,f3(g_1),'o-c',o_1,f4(o_1),'-s',opt_1,f5(opt_1),'-x','LineWidth',1,'MarkerSize',6);
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
% legend('Random','ours','OGA','OLSA','OPT','Location','best')
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Tasks','fontsize',16);
ylabel('Total QoE','fontsize',16);
%
box on;
% set(gca,'YLim',[2000 22000]);
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
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total QoE_Variation of number of tasks'],'-png','-m2');
saveas(gcf,[savePath,'\Total QoE_Variation of number of tasks'],'epsc');%矢量图



%任务数变化影响利润图
figure(3)
f1=fit(b_1,b_3,'smoothingspline');
f2=fit(j_1,j_3,'smoothingspline');
f3=fit(g_1,g_3,'smoothingspline');
f4=fit(o_1,o_3,'smoothingspline');
f5=fit(d_1,d_3,'smoothingspline');

% f5=fit(opt_1,opt_3,'smoothingspline');

% plot(b_1,f1(b_1),'^-r',j_1,f2(j_1),'*-m',g_1,f3(g_1),'o-c',o_1,f4(o_1),'-s',opt_1,f5(opt_1),'-x','LineWidth',1,'MarkerSize',6);
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
% legend('Random','ours','OGA','OLSA','OPT','Location','best')
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Tasks','fontsize',15);
ylabel('Total Profit(Dollar)','fontsize',15);
%
box on;
% set(gca,'YLim',[2000 22000]);
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
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total Profit_Variation of number of tasks'],'-png','-m2');
saveas(gcf,[savePath,'\Total Profit_Variation of number of tasks'],'epsc');%矢量图


%任务数变化影响任务接受率
figure(4)
f1=fit(b_1,b_8,'smoothingspline');
f2=fit(j_1,j_8,'smoothingspline');
f3=fit(g_1,g_8,'smoothingspline');
f4=fit(o_1,o_8,'smoothingspline');
f5=fit(d_1,d_8,'smoothingspline');
% f5=fit(opt_1,opt_3,'smoothingspline');

% plot(b_1,f1(b_1),'^-r',j_1,f2(j_1),'*-m',g_1,f3(g_1),'o-c',o_1,f4(o_1),'-s',opt_1,f5(opt_1),'-x','LineWidth',1,'MarkerSize',6);
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
% legend('Random','ours','OGA','OLSA','OPT','Location','best')
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Tasks','fontsize',15);
ylabel('Task Acceptance Rate','fontsize',15);
%
box on;
% set(gca,'YLim',[2000 22000]);
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
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total Task_Acceptance_Rate of number of tasks'],'-png','-m2');
saveas(gcf,[savePath,'\Total Task_Acceptance_Rate of number of tasks'],'epsc');%矢量图


% %任务数变化影响平均运行时间图
figure(5)
f1=fit(b_1,b_9/T,'smoothingspline');
f2=fit(j_1,j_9*3/T,'smoothingspline');
f3=fit(g_1,g_9/T,'smoothingspline');
f4=fit(o_1,o_9*3/T,'smoothingspline');
f5=fit(d_1,d_9/T,'smoothingspline');
% f5=fit(opt_1,opt_8/T,'smoothingspline');

% plot(b_1,f1(b_1),'^-r',j_1,f2(j_1),'*-m',g_1,f3(g_1),'o-c',o_1,f4(o_1),'-s',opt_1,f5(opt_1),'-x','LineWidth',1,'MarkerSize',6);
plot(j_1,f2(j_1),'^-r',d_1,f5(d_1),'-x',o_1,f4(o_1),'*-m',g_1,f3(g_1),'o-c',b_1,f1(b_1),'-s','LineWidth',1,'MarkerSize',6);
% legend('Random','ours','OGA','OLSA','OPT','Location','best')
legend('MPUTA','OSMDA','OLSA','OGA','Random','Location','best')
xlabel('Number of Tasks','fontsize',16);
ylabel('Unit Slot Running Time(s)','fontsize',16);
%
box on;
% set(gca,'YLim',[2000 22000]);
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
% axis([50,1050,0,3500])
grid on;%显示网格线
%导出实验图
export_fig([savePath,'\Total Runtime_Variation of number of tasks'],'-png','-m2');
saveas(gcf,[savePath,'\Total Runtime_Variation of number of tasks'],'epsc');%矢量图


%任务数变化影响各成本支出的堆叠条形图
% Count off the number of bins
NumGroupsPerAxis = 4;
NumStacksPerGroup = 5;
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.8; % Fraction of 1. If 1, then we have all bars in groups touching
groupOffset = MaxGroupWidth/NumStacksPerGroup;
figure(6)
hold on;
set (gca,'position',[0.2,0.3,0.7,0.6] )
xstr=cell(NumStacksPerGroup,NumGroupsPerAxis);
xstr(1,:)={'MPUTA'};
xstr(2,:)={'Random'};
xstr(3,:)={'OGA'};
xstr(4,:)={'OLSA'};
xstr(5,:)={'OSMDA'};
colormapset=[0.00 0.45 0.74;0.85 0.33 0.10;0.07 0.57 0.07; 0.49 0.18 0.56;; 0 0 0];
% colormapset=[0.0, 0.2, 0.6;0.85 0.33 0.10;0.07 0.57 0.07; 0.49 0.18 0.56;; 0 0 0];
%    x3str={'The Proposed Algorithm','MMSV','HPM','Random','JMS'};
groupLabels={'100','200','300','400'};


tempNum = {j_5,j_6,j_7;
           b_5,b_6,b_7;
           g_5,g_6,g_7;
           o_5,o_6,o_7;
           d_5,d_6,d_7};
for i=1:NumStacksPerGroup
    
    Y = [tempNum{i,1}(4),tempNum{i,2}(4),tempNum{i,3}(4);
         tempNum{i,1}(8),tempNum{i,2}(8),tempNum{i,3}(8);
         tempNum{i,1}(12),tempNum{i,2}(12),tempNum{i,3}(12);
         tempNum{i,1}(16),tempNum{i,2}(16),tempNum{i,3}(16)]/T;
    
    % Center the bars:
    
    internalPosCount = i - ((NumStacksPerGroup+1) / 2);
    
    % Offset the group draw positions:
    groupDrawPos = (internalPosCount)* groupOffset + groupBins;
    
    h(i,:) = bar(Y, 'stacked');
    set(h(i,:),'BarWidth',groupOffset);
    set(h(i,:),'XData',groupDrawPos);
    %      yt = get(gca,'YTick');
    ytextp=-20*ones(1,NumGroupsPerAxis);
    text(groupDrawPos,ytextp,xstr(i,:),'HorizontalAlignment','right','FontSize',8,'rotation',46)
    set(h(i,1),'facecolor',colormapset(1,:))
    set(h(i,2),'facecolor',colormapset(2,:))
    set(h(i,3),'facecolor',colormapset(3,:))
    
end
hold off;
h=legend('Service Placement Cost','Service Update Cost','Running Cost','Location','best');
set(gca,'XLim',[0.5 4.5]);
set(gca,'YLim',[0 900]);

set(gca,'XTickMode','manual');
set(gca,'XTick',1:NumGroupsPerAxis);

xtb = get(gca,'XTickLabel');
xt = get(gca,'XTick');
yt = get(gca,'YTick');
xtextp=xt;
ytextp=-170*ones(1,length(xt));
text(xtextp,ytextp,groupLabels,'HorizontalAlignment','right');
xlabel('Number of Requests','fontsize',16,'position',[2.5 -200]);
set(gca,'XTickMode','manual');
set(gca,'XTick',1:NumGroupsPerAxis);
set(gca,'XTickLabelMode','manual');
set(gca,'XTickLabel',groupLabels);



ylabel('Unit Slot Cost','fontsize',16);
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'FontSize',14);
set(gca,'XTickLabel',[]);
grid on;
box on;
%导出实验图
export_fig([savePath,'\Total cost_Variation of number of tasks'],'-png','-m2');
saveas(gcf,[savePath,'\Total cost_Variation of number of tasks'],'epsc');%矢量图