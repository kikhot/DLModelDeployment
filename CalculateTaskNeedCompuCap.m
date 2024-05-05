function[taskNeedCompuCap] = CalculateTaskNeedCompuCap(MecDistance,taskDeadline,taskNeedCompuRes,taskToMec,taskAndMecDistance,taskSize,serverJumpDelay,serverCompuCap)

[I,T] = size(taskNeedCompuRes);
[J,~] = size(MecDistance);
taskNeedCompuCap = zeros(I,J,T);
power = 0.1;    % W
noise = 10^(-13); % W
B = 2000000; % HZ
g = 127 + 30*log10(taskAndMecDistance/1000);   % 信道增益
r = B*log2(1+power*g/(noise));  % 传输速率

for t = 1:T
    for i = 1:I
        for j = 1:J
            commtime = ((taskSize(i,t)*1024*1024)/r(i,t)*1000 + serverJumpDelay*MecDistance(taskToMec(i,t),j));   % ms
            if taskDeadline(i,t) > commtime
                taskNeedCompuCap(i,j,t) = taskNeedCompuRes(i,t)*r(i,t)/((taskDeadline(i,t)*r(i,t)/1000) - (taskSize(i,t)*1024*1024 + 0.1*MecDistance(taskToMec(i,t),j)*r(i,t)))/1e9;
                if(taskNeedCompuCap(i,j,t) > serverCompuCap(j))
                    taskNeedCompuCap(i,j,t) = 100;
                end
            else
                taskNeedCompuCap(i,j,t) = 100;
            end
        end
    end
end

end