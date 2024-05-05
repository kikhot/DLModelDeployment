function [placementCost] = CalculatePlacementCost(Y, DLDeployCost)


placementCost = 0;
for f = 1:size(Y,3)
    if(f==1)
        placementCost = placementCost + sum(Y(:,:,f).*DLDeployCost, 'all');
    else
        temp = Y(:,:,f-1);
        temp = Y(:,:,f) - temp;
        temp3 = temp;
        temp = temp>0;
        placementCost = placementCost + sum(temp.*DLDeployCost, 'all');
    end
    
end

end