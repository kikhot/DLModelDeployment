function [Y_result, Z_result] = Last_Random_Round_Algorithm(Y_relax,Z_relax, DLModelCap, storageCap)

remain = storageCap;
[J,K] = size(Y_relax);
[J,K,A] = size(Z_relax);
Y_result = zeros(J,K);
Z_result = zeros(J,K,A);

% 将var中为1或0的数直接赋值到result
for j = 1:J
    for k = 1:K
        probability = rand();   % 概率p
        if Y_relax(j,k)==1 || Y_relax(j,k)==0
            Y_result(j,k) = Y_relax(j,k);
            remain(j) = remain(j) - DLModelCap(k)*Y_relax(j,k);
        else
            if(remain(j) > DLModelCap(k))
                if probability <= Y_relax(j,k)
                    Y_result(j,k) = 1;
                    remain(j) = remain(j) - DLModelCap(k);
                else
                    Y_result(j,k) = 0;
                end
            else
                Y_result(j,k) = 0;
            end
        end
    end
end


for j = 1:J
    for k = 1:K
        if(Y_result(j,k)==1)
            probability = rand();
            otherZ_AOI = 0;
            for a = 2:A
                if(Z_relax(j,k,a)>0)
                    otherZ_AOI = a;
                end
            end
            if(otherZ_AOI==0)
                Z_result(j,k,1) = 1;
            else
                if(probability < Z_relax(j,k,otherZ_AOI)/(Z_relax(j,k,1)+Z_relax(j,k,otherZ_AOI)))
                    Z_result(j,k,otherZ_AOI) = 1;
                else
                    Z_result(j,k,1) = 1;
                end
            end
        else
            Z_result(j,k,:) = 0;
        end
    end
end


end