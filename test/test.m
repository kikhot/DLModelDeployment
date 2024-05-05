% clc;
% clear;
% dirdate = datestr(now, 29);
% savePath = ['.\Code\result\Data_', dirdate];
%
% %
% if ~exist(savePath, 'dir')
%     mkdir(savePath);
% end
%
% n = 100:100:1000; % 终端设备数量
% m = 10:10:100; % 服务器数量


% matlab中调用python

% 更新python模块
% clear classes
% obj = py.importlib.import_module('test1');
% py.importlib.reload(obj)
%
% py.test1.testFun()

% 定义参数
% N = 100; % 元素个数
% s = 0.56; % Zipf分布参数
%
% % 计算概率分布
% r = 1:N;
% p = r.^(-s) / sum(r.^(-s));
%
% % 生成随机样本
% sample = randsample(N, 1000, true, p);
%
% % 绘制直方图
% histogram(sample, 'Normalization', 'probability');
clear;
clc;
% J = 3;
% K = 8;
% A = 5;
% T = 10;
% I = 100;
% t = 1;
% Z = randi([0 1], J,K,A);
% ma = load("matlab.mat");
% K_It = ma.K_It;
% % [I_idx, J_idx, A_idx, T_idx] = ndgrid(1:I, 1:J, 1:A, 1:T)
% % K_idx = K_It(sub2ind([I T], I_idx(:), T_idx(:)));
% % result = Z(sub2ind([J K A T], J_idx(:), K_idx(:), A_idx(:), T_idx(:)));
% K_It1 = K_It(:,t);
% [I_idx, J_idx, A_idx] = ndgrid(1:I, 1:J, 1:A);
% K_idx = K_It1(sub2ind([I 1], I_idx(:), ones(numel(I_idx), 1)));
% result = Z(sub2ind([J K A], J_idx(:), K_idx(:), A_idx(:)));
% 
% 
% for i = 1:I
%     for j = 1:J
%         for a = 1:A
%             result_2(i,j,a) = Z(j,K_It(i,t),a);
%         end
%     end
% end
% 
% result_3 = result_2(:);
% if(result_3 == result)
%     disp('hello')
% end

J = 3;
K = 8;
m1 = load("test1.mat");
m2 = load("test2.mat");
m3 = load("test3.mat");
% Y1 = m1.y;
Y = m1.y;
% Y_Pre = m2.Y_Pre;
Y_Pre = zeros(J,K);
DLDeployCost = m2.DLDeployCost;
epsilon = 1 ;

placementCost = 0;
for j = 1:J
    for k=1:K
        placementCost = placementCost + DLDeployCost(j,k)/log(1+1/epsilon)*(kullbackleibler(Y(j,k)+epsilon,Y_Pre(j,k)+epsilon)+Y_Pre(j,k)-Y(j,k));
    end
end

