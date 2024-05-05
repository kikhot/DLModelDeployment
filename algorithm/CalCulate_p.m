function[profit_p] = CalCulate_p(Z_temp,t,K_It,taskPay,taskNeedCompuRes,serverCompuCost,Beta)
[J,~,A] = size(Z_temp);
[I,~] = size(taskPay);

profit_p = zeros(I,J);
p = (Beta*exp(-repmat(reshape(1:A,1,1,A), [I,J,1])) - (repmat(reshape(taskNeedCompuRes(:,t), [I,1,1]), [1,J,A]).*repmat(reshape(serverCompuCost(:,t), [1,J,1]), [I,1,A])));
for i=1:I
    for j=1:J
        for a=1:A
            k = K_It(i,t);
            if(Z_temp(j,k,a)==1)
                profit_p(i,j) = Z_temp(j,k,a) * (taskPay(i,t) + p(i,j,a));
            end
        end
    end
end
profit_p(profit_p == 0) = -inf;
end