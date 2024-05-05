function[X] = Last_TaskOffloading_Algorithm(taskNeedCompuCap, cost_c,profit_p, serverCompuCap)
taskNeedCompuCap(:,end+1) = 0;    % 假设有一个虚拟的MEC服务器，卸载到该MEC需要的计算资源为0
serverCompuCap(end+1) = 0;  % 假设有一个虚拟的MEC服务器，其计算资源为0
eps = 1e-6;
cost_c(isinf(cost_c)) = 1000;

[x] = getLPsol(taskNeedCompuCap,cost_c,serverCompuCap);
B = buildGraph(x,taskNeedCompuCap);

res = detRound(B,cost_c,eps);
[I,J] = size(cost_c);
totalCap = zeros(1,J);
totalProfit = zeros(1,J);
X = zeros(I,J);
for i=1:I
    j = res(i);
    X(i,j) = 1;
    totalCap(j) = totalCap(j) + taskNeedCompuCap(i,j);
    totalProfit(j) = totalProfit(j) + profit_p(i,j);
end
% 如果卸载任务的总计算资源容量小于MEC所能承受的最大容量，则直接输出即可
% 否则：查找卸载到每个MEC中满足论文定理的任务，如果所包含的价值大于MECj的其他所有的总价值，则将其他所有任务卸载置为0，
%       否则，将该任务卸载置为零，以满足资源约束
flag = totalCap>serverCompuCap;    % 判断每个MEC是否满足最大计算容量
remove_index = zeros(1,J);      % 需要删除的任务
max_index = ones(1,J);
flag1 = false;

for j = 1:J-1
    if(flag(j))
        for i=1:I
            if(taskNeedCompuCap(i,j)>taskNeedCompuCap(max_index(j),j))
                max_index(j) = i;
            end
            if((res(i)==j) && (totalCap(j)-taskNeedCompuCap(i,j))<=serverCompuCap(j))
                if(2*profit_p(i,j)>totalProfit(j))
                    X(:,j) = 0;
                    X(i,j) = 1;
                    flag1 = true;
                    break;
                else
                    if(remove_index(j)~=0)
                        ll = remove_index(j);
                        if(profit_p(ll,j)>profit_p(i,j))
                            remove_index(j) = i;
                        end
                    else
                        remove_index(j) = i;
                    end
                end
            end
        end
        if(remove_index(j)==0&&flag1)
            flag1 = false;
            continue;
        end
        X(remove_index(j),j) = 0;
    end
end

totalCap1 = zeros(1,J);
totalProfit1 = zeros(1,J);
for i=1:I
    for j=1:J-1
        if(X(i,j)==1)
            totalCap1(j) = totalCap1(j) + X(i,j)*taskNeedCompuCap(i,j);
            totalProfit1(j) = totalProfit1(j) + X(i,j)*profit_p(i,j);
        end
    end
end
X(:,end) = [];
end


% 获得LP的解决方案，有I个推理任务，J个MEC
% 输入：
%   taskNeedCompuCap: IXJ
%   profit_p: IXJ
%   serverCompuCap: 1XJ
% 输出： IXJ 松弛决策变量
function[x] = getLPsol(taskNeedCompuCap,cost_c,serverCompuCap)
[I,J] = size(cost_c);
X = sdpvar(I, J, 'full');
obj = 0;
obj = obj + sum(X.*cost_c, 'all');
constraint = [0 <= X <= 1];
constraint = [constraint sum(X,2)==1];
constraint = [constraint sum(X.*taskNeedCompuCap, 1) <= serverCompuCap];
ops = sdpsettings('solver','cplex','verbose',0);
optimize(constraint,obj,ops);
% diagnostics=optimize(constraint,obj,ops);
% if diagnostics.problem==0
%     disp('Solver thinks it is feasible')
% elseif diagnostics.problem == 1
%     disp('Solver thinks it is infeasible')
%     pause();
% else
%     disp('Timeout, Display the current optimal solution')
% end
x = value(X);
end


% 将LP解转换为具有分数边权重的二分图，其中一侧表示任务，另一侧表示槽：
% 输入:
%   x: IXJ
%   taskNeedCompuCap: IXJ
% 输出：一个nxmxn数组B，其中B[i，j，s]表示从任务i到MECj的插槽s的边缘上的权重。
function[B] = buildGraph(x,taskNeedCompuCap)
[I,J] = size(taskNeedCompuCap);
B = zeros(I,J,I);
for j=1:J
    s = 1;  % MEC j中的当前插槽
    space = 1; % 当前插槽中剩余的空间
    [~, x_indices] = sort(taskNeedCompuCap(:,j), 'descend');
    for ii=1:length(x_indices)
        i = x_indices(ii);
        y = x(i,j);
        if(y<=space)
            % 我们可以把这个任务塞进槽s里
            B(i,j,s) = y;
            space = space - y;
        else
            % 我们要把这个任务分成两个插槽
            B(i,j,s) = space;    % 填满当前插槽
            s = s + 1;  % 下一槽
            B(i,j,s) = y - space;    % 将剩余重量放入新插槽
            space = 1 - y + space;    % 更新新插槽中的剩余空间
        end
    end
end
end


% 确定性舍入算法
% 将输入的分数最小代价完全匹配确定地四舍五入为整数并输出。
% 输入：
%   B：用邻接矩阵表示的分数完全匹配
%   C：成本矩阵
% 输出：最终分配结果
function[res] = detRound(X, cost_c, eps)
[I,J,K] = size(X);
res = ones(1,I)*(-1);
B_temp = permute(X,[1,3,2]);
B = reshape(B_temp, [I,J*K]);
% 预处理-去除所有边缘w/weight 1
for i=1:I
    for j=1:J*K
        if(B(i,j)>1-eps)
            res(i) = floor((j-1)/K) + 1;
            B(i,j) = 0;
        end
    end
end
% 并非所有作业都已分配
while(sum(res(:)==-1) ~= 0)
    % 寻找循环或增广路径
    cyc = cycle_bipartite(B);
    [pairs, B, cyc] = round_cycle(B, cyc,K,cost_c,eps);
    % 记录所有已完成的边
    if(size(pairs,1) ~= 0)
        for j=1:size(pairs,1)
            res(pairs(j,1)) = floor((pairs(j,2)-1)/K) + 1;
            B(pairs(j,1),pairs(j,2)) = 0;
        end
    end
end
end


% 在二部图中找到一个循环或增广路径。
function[res] = cycle_bipartite(x)
cl = []; 
cr = [];
st = find(sum(x,1)>1e-6);
x_temp = x;
eps = 1e-6;
[x_temp, res] = dfs_right(x_temp,cl,cr,st,eps);
if(isempty(res{1}) && isempty(res{2}))
    [r,c] = find(x_temp>0)
    disp(x_temp);
end
end

function [x,cyc] = dfs_left(x, cl, cr, l, eps)
cl(end+1)=-1;
for i=1:length(l)
    cl(end)=l(i);
    s = cl(end);
    t = cr(end);
    x(s,t)=0;
    llist = find(x(cl(end),:) > eps);
    if(ismember(cr(1), llist))
        cr(end+1)=cr(1);
        cyc = {cl, cr};
        return;
    end
    [x,cyc] = dfs_right(x, cl, cr, llist, eps);
    if(~isempty(cyc{1}))
        return;
    end
    if(~isempty(cr))
        x(s,t)=1;
    end
end
cl(end)=[];
cyc = cell(1,2);
end

function [x,cyc] = dfs_right(x, cl, cr, l, eps)
cr(end+1)=-1;
for i=1:length(l)
    cr(end)=l(i);
    s = -1;
    t = cr(end);
    if(~isempty(cl))
        s = cl(end);
        x(s, t) = 0;
    end
    rlist = find(x(:,t) > eps);
    if(isempty(rlist))
        if(isempty(find(x(:,cr(1))>eps)))
            cyc = {cl, cr};
            return;
        end
    end
    [x,cyc] = dfs_left(x, cl, cr, rlist, eps);
    if(~isempty(cyc{1}))
        return;
    end
    if(~isempty(cl))
        x(s,t)=1;
    end
end
cr(end)=[];
cyc = cell(1,2);
end


function [pairs, B, cyc] = round_cycle(B, cyc, k, C, eps)
% Input:
% B: an adjacency matrix
% cyc: a cycle in B
% k: the number of slots for each machine
% C: the cost matrix
% eps: a small positive value to handle numerical errors
%
% Output:
% pairs: lists of edges with weight 1
% B is rounded such that at least one edge in the cycle in the graph is saturated
% determine which direction to round
slope = 0;
l = length(cyc{1});
for i=1:l
    slope = slope + C(cyc{1}(i), floor((cyc{2}(i)-1)/k)+1) - C(cyc{1}(i), floor((cyc{2}(i+1)-1)/k)+1);
end
if(slope > eps) % flip the cycle to ensure the LP value is not increased
    cyc{1} = fliplr(cyc{1});
    cyc{2} = fliplr(cyc{2});
end

if(~isempty(cyc{1}))
    w = min(1 - B(sub2ind(size(B), cyc{1}, cyc{2}(1:end-1))));
    d = min(B(sub2ind(size(B), cyc{1}, cyc{2}(2:end))));
    c = min(w, d);
else
    w = min(1 - B(sub2ind(size(B), cyc{1}, cyc{2})));
    d = min(B(sub2ind(size(B), cyc{1}, cyc{2})));
    c = min(w, d);
end


pairs = [];
curr = cyc{2}(1);
for i=1:l

    % increase the weights of red edges
    curl = cyc{1}(i);
    B(curl,curr) = B(curl,curr) + c;
    if(B(curl,curr) > 1-eps) % new integral edge found
        pairs(end+1,:) = [curl,curr];
    end

    % decrease the weights of blue edges
    curr = cyc{2}(i+1);
    B(curl,curr) = B(curl,curr) - c;
    if(B(curl,curr) < eps)
        B(curl,curr) = 0;
    end
end
end
