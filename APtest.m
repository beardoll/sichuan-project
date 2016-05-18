% costMat = [12 7 9 7 9;
%            8 9 6 6 6;
%            7 17 12 14 9;
%            15 14 6 6 10;
%            4 10 7 10 9];
costMat = [85 92 73 90;
           95 87 78 95;
           82 83 79 90;
           86 90 80 88];
maxval = max(max(costMat));
costMat = maxval - costMat;
results = AP(costMat)