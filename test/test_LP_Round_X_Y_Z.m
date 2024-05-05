function [x,y,z] = test_LP_Round_X_Y_Z(f,frame,J,K,Y_Pre,Z_Pre,It_num,K_It,serverCompuRes,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI)
epsilon = 0.00001
yalmip('clear');
% 定义变量
% 创建任务卸载决策变量
% X_ija,i为推理任务，j为边缘服务器，a为具有该任务的边缘服务器DL服务类型的AOI为a
tic;    % 运行时间
constraint = [];
for t = 1:frame
    t_real = (f-1)*frame+t;
    for i = 1:It_num(t_real)
        X{t}{i} = sdpvar(J, min(t, DLModelMaxAOI(K_It{t_real}(i))), 'full');
        constraint = [constraint, 0<= X{t}{i} <= 1];
    end
end
% 创建DL模型服务放置决策变量
% Y_jk,j为边缘服务器，k为DL服务类型
Y = sdpvar(J, K, 'full');
constraint = [constraint 0<= Y <= 1];
% 创建DL模型服务放置的AOI决策变量(当Z_jk1=1时，为更新决策）
% Z_jka，j为边缘服务器，k为DL服务类型，a为边缘服务器DL服务类型k的AOI
for t = 1:frame
    t_real = (f-1)*frame+t;
    for k = 1:K
        Z{t,k} = sdpvar(J, min(t_real, DLModelMaxAOI(k)), 'full');
        constraint = [constraint 0<= Z{t,k} <=1];
    end
end


% 目标函数
obj = 0;
% 添加用户QoE和服务提供商的收益
for t = 1:frame
    t_real = (f-1)*frame+t;
    for i = 1:It_num(t_real)
        for j = 1:J
            for a = 1:min(t_real, DLModelMaxAOI(K_It{t_real}(i)))
                obj = obj + X{t}{i}(j,a)*exp(1)^double(-a) + X{t}{i}(j,a)*taskPay{t_real}(i);
            end
        end
    end
end

placementCost = 0;
% 添加DL服务放置成本
for j = 1:J
    for k = 1:K
        obj = obj - DLDeployCost(j,k)/log(1+1/epsilon)*(kullbackleibler(Y(j,k)+epsilon,Y_Pre(j,k)+epsilon)+Y_Pre(j,k)-Y(j,k));
        placementCost = placementCost + DLDeployCost(j,k)/log(1+1/epsilon)*(kullbackleibler(Y(j,k)+epsilon,Y_Pre(j,k)+epsilon)+Y_Pre(j,k)-Y(j,k));
    end
end

% 添加DL模型更新成本
for t = 1:frame
    for j = 1:J
        for k = 1:K
            obj = obj - Z{t,k}(j,1) * DLUpdateCost(j,k);
        end
    end
end

% 添加运行成本
runCost = 0;
for t = 1:frame
    t_real = (f-1)*frame+t;
    for i = 1:It_num(t_real)
        for j = 1:J
            for a = 1:min(t_real, DLModelMaxAOI(K_It{t_real}(i)))
                tempRunCost = taskSize{t_real}(i)*DLModelNeedComputeCap(K_It{t_real}(i))*serverCompuCost(j)/1000;
                obj = obj - X{t}{i}(j,a)*tempRunCost;
                runCost = runCost + X{t}{i}(j,a)*tempRunCost;
            end
        end
    end
end

% disp(['目标函数构建完成']);


% 约束条件
% 约束C1
for t = 1:frame
    t_real = (f-1)*frame+t;
    for i = 1:It_num(t_real)
        tempConstr = 0;
        for j = 1:J
            for a = 1:min(t_real, DLModelMaxAOI(K_It{t_real}(i)))
                tempConstr = tempConstr + X{t}{i}(j,a);
            end
        end
        constraint = [constraint, tempConstr <= 1];
    end
end

% 约束C2
for t = 1:frame
    t_real = (f-1)*frame+t;
    for i = 1:It_num(t_real)
        for j = 1:J
            for a = 1:min(t_real, DLModelMaxAOI(K_It{t_real}(i)))
                constraint = [constraint, X{t}{i}(j,a) <= Z{t,K_It{t_real}(i)}(j,a)];
            end
        end
    end
end

% 约束C3
for t = 1:frame
    for j = 1:J
        for k = 1:K
            constraint = [constraint, sum(Z{t,k}(j,:),'all') == Y(j,k)];
        end
    end
end

% 约束C4
for t = 1:frame
    t_real = (f-1)*frame+t;
    for j = 1:J
        for k = 1:K
            for a = 2:min(t_real, DLModelMaxAOI(k))
                if t == 1
                    constraint = [constraint, Z{t,k}(j,a) <= Z_Pre{k}(j,a-1)];
                else
                    constraint = [constraint, Z{t,k}(j,a) <= Z{t-1,k}(j,a-1)];
                end
            end
        end
    end
end

% 约束C5
for j = 1:J
    constraint = [constraint, sum(Y(j,:).*DLModelCap, 'all') <= storageCap(j)];
end

% 约束C6
for t = 1:frame
    t_real = (f-1)*frame+t;
    for j = 1:J
        tempConstr = 0;
        for i = 1:It_num(t_real)
            for a = 1:min(t_real, DLModelMaxAOI(K_It{t_real}(i)))
                tempConstr = tempConstr + X{t}{i}(j,a)*taskNeedCompuRes{t_real}(i,j);
            end
        end
        constraint = [constraint, tempConstr <= serverCompuRes(j)];
    end

end



ops = sdpsettings('solver','mosek', 'verbos', 0);
ops.mosek.MSK_DPAR_INTPNT_TOL_REL_GAP = 1e-4;   % 保留解小数点后四位
diagnostics=optimize(constraint,-obj,ops);


% 显示求解结果
for t = 1:frame
    t_real = (f-1)*frame+t;
    for i = 1:It_num(t_real)
        for j = 1:J
            for a = 1:min(t_real, DLModelMaxAOI(K_It{t_real}(i)))
                x{t}{i}(j,a) = round(value(X{t}{i}(j,a)), 4);
            end
        end
    end
end


for j = 1:J
    for k = 1:K
        y(j,k) = round(value(Y(j,k)), 4);
    end
end

for t = 1:frame
    t_real = (f-1)*frame+t;
    for j = 1:J
        for k = 1:K
            for a = 1:min(t_real,DLModelMaxAOI(k))
                z{t,k}(j,a) = round(value(Z{t,k}(j,a)), 4);
            end
        end
    end
end
toc;    % 运行时间
disp(['运行时间', num2str(toc)]);
disp('hello')

%end