clc;
clear;

dirdate = datestr(now+2, 29);
Pathstr = '.\Code\result\Data_'; %windows
addpath('export_fig-3.15\');

savePath1 = [Pathstr, dirdate, '\beta_change\our_beta_change-Profit_data.txt'];

T = 30; % 时隙

% 加载数据
data_1 = load(savePath1);
b_1 = data_1(:,1);
b_2 = data_1(:,2);
b_3 = data_1(:,3);

savePath = ['.\Code\result\Figure_', dirdate];
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

% 绘制图形
figure(1);
yyaxis left;
f1 = fit(b_1, b_2, 'smoothingspline');
left_plot = plot(b_1, f1(b_1), '*-m', 'LineWidth', 1, 'MarkerSize', 6);
xlabel('beta 变化', 'fontsize', 16);
ylabel('Total QoE', 'fontsize', 16);

% 获取左侧y轴的颜色，并设置相应线条颜色
ax = gca; % 获取当前轴句柄
left_color = ax.YAxis(1).Color; % 获取左侧y轴颜色
left_plot.Color = left_color; % 设置线条颜色

yyaxis right;
f2 = fit(b_1, b_3, 'smoothingspline');
right_plot = plot(b_1, f2(b_1), '-s', 'LineWidth', 1, 'MarkerSize', 6);
ylabel('Total Profit', 'fontsize', 16);

% 获取右侧y轴的颜色，并设置相应线条颜色
right_color = ax.YAxis(2).Color; % 获取右侧y轴颜色
right_plot.Color = right_color; % 设置线条颜色

legend('QoE', 'Profit', 'location', 'best');

% 设置x轴的范围
xlim([min(b_1)-5 max(b_1)]);

set(gcf, 'color', 'white');
set(gca, 'LineWidth', 1.5, 'FontSize', 14, 'XMinorTick', 'on', 'YMinorTick', 'on', 'GridLineStyle', '-.', 'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.9);
grid on; % 显示网格线

% 导出图像
export_fig([savePath, '\Total Utility_Variation of beta_change'], '-png', '-m2');
saveas(gcf, [savePath, '\Total Utility_Variation of beta_change'], 'epsc'); % 矢量图