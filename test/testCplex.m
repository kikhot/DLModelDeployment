a = [3,1,2,1,3,5];
[~, ans] = sort(a, 'descend');
ans

for i=ans
    disp(i)
    disp('a')
end