% 计算完成推理任务所需的CPU周期
function [taskNeedCompuRes] = CalculateTaskNeedCompuRes(taskSize, DLModelNeedComputeCap, K_It)

[I, T] = size(taskSize);
taskNeedCompuRes = zeros(I,T);
for i = 1:I
    for t = 1:T
        taskNeedCompuRes(i,t) = round(taskSize(i,t)*DLModelNeedComputeCap(K_It(i,t))*1024*1024,0);
    end
end

end