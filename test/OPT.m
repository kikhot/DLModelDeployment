function [resultQoE, resultProfit] = OPT(J,K,T,frame,F,It_num,K_It,serverCompuRes,storageCap,serverCompuCost, ...
    taskSize,taskPay,taskNeedCompuRes,DLModelCap,DLModelNeedComputeCap,DLDeployCost,DLUpdateCost,DLModelMaxAOI)

% 定义变量
% 创建变量
% 创建任务卸载决策变量
% X_ija(t),i为推理任务，j为边缘服务器，a为具有该任务的边缘服务器DL服务类型的AOI为a
for t = 1:T
    for i = 1:It_num(t)
        X{t}{i} = binvar(J, min(t, DLModelMaxAOI(K_It{t}(i))), 'full');
    end
end
% 创建DL模型服务放置决策变量
% Y_jk(f),j为边缘服务器，k为DL服务类型，f为帧数
Y = binvar(J, K, F, 'full');
% 创建DL模型服务放置的AOI决策变量(当Z_jk1(t)=1时，为更新决策）
% Z_jka(t)，j为边缘服务器，k为DL服务类型，a为边缘服务器DL服务类型k的AOI，t为时隙
for t = 1:T
    for k = 1:K
        Z{t,k} = binvar(J, min(t, DLModelMaxAOI(k)), 'full');
    end
end
% 创建服务放置改变决策
C = binvar(J, K, F, 'full');


% 目标函数
obj = 0;
% 添加用户QoE和服务提供商的收益
QoE = 0;
providerProfit = 0;
for t = 1:T
    for i = 1:It_num(t)
        for j = 1:J
            for a = 1:min(t, DLModelMaxAOI(K_It{t}(i)))
                obj = obj + X{t}{i}(j,a)*exp(1)^double(-a) + X{t}{i}(j,a)*taskPay{t}(i);
                QoE = QoE + X{t}{i}(j,a)*exp(1)^double(-a);
                providerProfit = providerProfit + X{t}{i}(j,a)*taskPay{t}(i);
            end
        end
    end
end
% 添加DL服务放置成本
deployCost = 0;
for f = 1:F
    if f == 1
        obj = obj - sum(Y(:,:,1).*DLDeployCost, 'all');
        deployCost = deployCost + sum(Y(:,:,1).*DLDeployCost, 'all');
    else
        obj = obj - sum(C(:,:,f).*DLDeployCost, 'all');
        deployCost = deployCost + sum(C(:,:,f).*DLDeployCost, 'all');
    end

end
% 添加DL模型更新成本
updateCost = 0;
for t = 1:T
    for j = 1:J
        for k = 1:K
            obj = obj - Z{t,k}(j,1) * DLUpdateCost(j,k);
            updateCost = updateCost + Z{t,k}(j,1) * DLUpdateCost(j,k);
        end
    end
end
% 添加运行成本
runCost = 0;
for t = 1:T
   for i = 1:It_num(t)
       for j = 1:J
           for a = 1:min(t, DLModelMaxAOI(K_It{t}(i)))
               tempRunCost = taskSize{t}(i)*DLModelNeedComputeCap(K_It{t}(i))*serverCompuCost(j)/1000;
               runCost = runCost + X{t}{i}(j,a)*tempRunCost;
               obj = obj - X{t}{i}(j,a)*tempRunCost;
           end
       end
   end
end
disp(['目标函数构建完成']);


% 约束条件
constraint=[];
% 约束C1
for t = 1:T
    for i = 1:It_num(t)
        tempConstr = 0;
        for j = 1:J
            for a = 1:min(t, DLModelMaxAOI(K_It{t}(i)))
                tempConstr = tempConstr + X{t}{i}(j,a);
            end
        end
        constraint = [constraint, tempConstr <= 1];
    end
end
% 约束C2
for t = 1:T
    for i = 1:It_num(t)
        for j = 1:J
            for a = 1:min(t, DLModelMaxAOI(K_It{t}(i)))
                constraint = [constraint, X{t}{i}(j,a) <= Z{t,K_It{t}(i)}(j,a)];
            end
        end
    end
end
% 约束C3
for t = 1:T
    for j = 1:J
        for k = 1:K
            constraint = [constraint, sum(Z{t,k}(j,:),'all') == Y(j,k,floor((t-1)/frame)+1)];
        end
    end
end
% 约束C4
for t = 2:T
    for j = 1:J
        for k = 1:K
            for a = 2:min(t, DLModelMaxAOI(k))
                constraint = [constraint, Z{t,k}(j,a) <= Z{t-1,k}(j,a-1)];
            end
        end
    end
end
% 约束C5
for j = 1:J
    for f = 1:F
        constraint = [constraint, sum(Y(j,:,f).*DLModelCap, 'all') <= storageCap(j)];
    end

end
% 约束C6
for t = 1:T
    for j = 1:J
        tempConstr = 0;
        for i = 1:It_num(t)
            for a = 1:min(t, DLModelMaxAOI(K_It{t}(i)))
                tempConstr = tempConstr + X{t}{i}(j,a)*taskNeedCompuRes{t}(i,j);
            end
        end
        constraint = [constraint, tempConstr <= serverCompuRes(j)];
    end
end


% yt-(yt-1)约束
for f = 2:F
    for j = 1:J
        for k = 1:K
            constraint = [constraint, C(j,k,f) >= Y(j,k,f)-Y(j,k,f-1)];
        end
    end
end

% constraint=[constraint,x(1)+x(2)>350];
% constraint=[constraint,x(1)>100];
% constraint=[constraint,2*x(1)+x(2)<600];
% constraint=[constraint,x(2)>0];
% 求解
ops = sdpsettings('solver','cplex','verbose',1);
ops.cplex.display='on';
ops.cplex.timelimit=6000;
ops.cplex.mip.tolerances.mipgap=0.001;
% 输出模型
ops.cplex.exportmodel = 'model.lp';
% 诊断求解可行性
disp('开始求解')
diagnostics=optimize(constraint,-obj,ops);
% [model,recoverymodel,diagnostic,internalmodel] = export(constraint,-obj,ops);
if diagnostics.problem==0
    disp('Solver thinks it is feasible')
elseif diagnostics.problem == 1
    disp('Solver thinks it is infeasible')
    pause();
else
    disp('Timeout, Display the current optimal solution')
end


% 显示求解结果
for t = 1:T
    for i = 1:It_num(t)
        for j = 1:J
            for a = 1:min(t, DLModelMaxAOI(K_It{t}(i)))
                x{t}{i}(j,a) = value(X{t}{i}(j,a));
            end
        end
    end
end
QoE = value(QoE);
obj = value(obj);
resultQoE = QoE;
resultProfit = obj - QoE;
providerProfit = value(providerProfit);

deployCost = value(deployCost);
for f = 1:F
    for j = 1:J
        for k = 1:K
            y(j,k,f) = value(Y(j,k,f));
        end
    end
end
%end
disp("a")