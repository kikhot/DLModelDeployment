function[X,Y,Z] = test_check_True_XYZ(X,Y,Z,K_It,DLModelCap,storageCap,serverCompuCap,taskNeedCompuCap)

[I,J,A,T] = size(X);
[~,K,F] = size(Y);
frame = T/F;

flag = true;
% C1
for t=1:T
    for i=1:I
        temp = 0;
        for j=1:J
            for a=1:A
                temp = temp + X(i,j,a,t);
            end
        end
        if temp > 1
            disp(temp);
            disp('C1:')
            disp([i,j,a,t])
            flag = false;
        end
    end
end

if flag
    disp("C1没问题")
else
    disp("C1有问题")
end
flag = true;

% C2
for t=1:T
    for i=1:I
        for j=1:J
            for a=1:A
                if X(i,j,a,t)>Z(j,K_It(i,t),a,t)

                    disp([i,j,a,t]);
                    disp([j,K_It(i,t),a,t]);
                    disp(X(i,j,a,t));
                    disp(Z(j,K_It(i,t),a,t));
                    flag = false;
                end
            end
        end
    end
end

if flag
    disp("C2没问题")
else
    disp("C2有问题")
end

flag = true;

% C3
for t=1:T
    f = floor((t-1)/frame)+1;
    for j=1:J
        for k=1:K
            temp = 0;
            for a=1:A
                temp = temp + Z(j,k,a,t);
            end
            if(temp ~= Y(j,k,f))
                flag = false;
                disp([j,k,f]);
                disp([j,k,t])
                disp([temp,Y(j,k,f)])
            end
        end
    end
end
if flag
    disp("C3没问题")
else
    disp("C3有问题")
end


% C4
flag = true;
for t=2:T
    f = floor((t-1)/frame)+1;
    for j=1:J
        for k=1:K
            for a=2:A
                if Z(j,k,a,t)>Z(j,k,a-1,t-1)
                    disp([j,k,a,t]);
                    flag = false;
                end
            end
        end
    end
end
if flag
    disp("C4没问题")
else
    disp("C4有问题")
end


% C5
flag = true;
for f = 1:F
    for j=1:J
        temp = 0;
        for k=1:K
            temp = temp + Y(j,k,f)*DLModelCap(k);
        end
        if temp > storageCap(j)
            disp(j);
            disp([temp,storageCap(j)])
            flag = false;
        end
    end
end
if flag
    disp("C5没问题")
else
    disp("C5有问题")
end

% C6
flag = true;
for t=1:T
    for j=1:J
        temp = 0;
        for i=1:I
            for a=1:A
                temp = temp + X(i,j,a,t)*taskNeedCompuCap(i,j,t);
            end
        end
        if temp>serverCompuCap(j)
            disp([j,temp,serverCompuCap(j)])
            flag = false;
        end
    end
end

if flag
    disp("C6没问题")
else
    disp("C6有问题")
end

end