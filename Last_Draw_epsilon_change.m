clc;
clear

dirdate=datestr(now+2,29);
Pathstr='.\Code\result\Data_';%windows
addpath('export_fig-3.15\');

savePath1=[Pathstr,dirdate,'\epsilon_change','\mine_epsilon_change_data.txt'];


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

% data_2=load(savePath2);
% j_1=data_2(:,1);%任务数
% j_2=data_2(:,3);%epsilon值
% j_3=data_2(:,4);%QoE
% j_4=data_2(:,5);%总收益
% j_5=data_2(:,6);%服务提供商收益
% j_6=data_2(:,7);%服务放置成本
% j_7=data_2(:,8);%服务更新成本
% j_8=data_2(:,9);%推理任务运行成本


savePath=['.\Code\result\Figure_',dirdate, '\epsilon_change'];
if ~exist(savePath,'dir')
    mkdir(savePath);
end


figure(1)
yyaxis left;
temp = Beta*b_3 + b_4;
% bar([temp(1,:); temp(2,:); temp(3,:); temp(4,:); temp(5,:); temp(6,:); temp(7,:); temp(8,:)]);
% bar([temp(1), temp(2), temp(3), temp(4), temp(5), temp(6), temp(7), temp(8)]);
bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]; [temp(7),0]; [temp(8),0]]);

xlabel('epsilon change','fontsize',13);
ylabel('Total Utility','fontsize',13);
axis([0,9,60000,66000])
%
set(gca,'xticklabel',{'0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000'});
% set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet

yyaxis right;
temp = b_6;
% bar([temp(1,:); temp(2,:); temp(3,:); temp(4,:); temp(5,:); temp(6,:); temp(7,:); temp(8,:)]);
% bar([temp(1), temp(2), temp(3), temp(4), temp(5), temp(6), temp(7), temp(8)]);
bar([[0,temp(1)]; [0,temp(2)]; [0,temp(3)]; [0,temp(4)]; [0,temp(5)]; [0,temp(6)]; [0,temp(7)]; [0,temp(8)]]);
ylabel('Total Placement Cost($)','fontsize',13);
legend('Total Utility', '', 'DL Placement Cost','location','northeast');
box on;
set(gcf,'color','white');
set(gca,'LineWid',1.5);
set(gca,'xminortick','on');
set(gca,'yminortick','on');
set(gca,'GridLineStyle','-.','GridColor',[0.8 0.8 0.8],'GridAlpha',0.9);
axis([0,9,0,1150])
if size(get(gca,'YTick'),2)<=5
    gap=(max(get(gca,'YTick'))-min(get(gca,'YTick')))./10;
    set(gca, 'YTick',min(get(gca,'YTick')):gap:max(get(gca,'YTick')));
end
%
set(gca,'xticklabel',{'0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000'});
% set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
grid on;
export_fig([savePath,'\epsilon_change of MPUTA for placement_cost'],'-png','-m2');
saveas(gcf,[savePath,'\epsilon_change of MPUTA for placement_cost'],'svg');%矢量图



% figure(2)
% temp =  b_6;
% % bar([temp(1,:); temp(2,:); temp(3,:); temp(4,:); temp(5,:); temp(6,:); temp(7,:); temp(8,:)]);
% % bar([temp(1), temp(2), temp(3), temp(4), temp(5), temp(6), temp(7), temp(8)]);
% bar([[temp(1),0]; [temp(2),0]; [temp(3),0]; [temp(4),0]; [temp(5),0]; [temp(6),0]; [temp(7),0]; [temp(8),0]]);
% 
% xlabel('epsilon change','fontsize',13);
% ylabel('Total Utility','fontsize',13);
% %
% set(gca,'xticklabel',{'0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000'});
% 
% 
% legend('Total Utility', '', 'DL Placement Cost','location','northeast');
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
% set(gca,'xticklabel',{'0.0001', '0.001', '0.01', '0.1', '1', '10', '100', '1000'});
% % set(gca,'xticklabel',{'50','100','150','200','250'});%50-250cloudlet
% % set(gca,'xticklabel',{'40','80','120','160','200'});%20-200cloudlet
% grid on;
% export_fig([savePath,'\epsilon_change of MPUTA for placement_cost'],'-png','-m2');
% saveas(gcf,[savePath,'\epsilon_change of MPUTA for placement_cost'],'svg');%矢量图


