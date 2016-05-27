load best_path;
K = 5;

for i = 1:K
    path2 = path{i};
    path2 = path2(2:end-1);
    if i == 1
        path1 = path{K};
        path1 = path1(2:end-1);
        path3 = path{i+1};
        path3 = path3(2:end-1);
        [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
        newpath1 = [0 newpath1 0];
        newpath2 = [0 newpath2 0];
        newpath3 = [0 newpath3 0];
        path{K} = newpath1;
        path{i} = newpath2;
        path{i+1} = newpath3;
    elseif i == K
        path1 = path{i-1};
        path1 = path1(2:end-1);
        path3 = path{1};
        path3 = path3(2:end-1);
        [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
        newpath1 = [0 newpath1 0];
        newpath2 = [0 newpath2 0];
        newpath3 = [0 newpath3 0];
        path{i-1} = newpath1;
        path{i} = newpath2;
        path{1} = newpath3;
    else
        path1 = path{i-1};
        path1 = path1(2:end-1);
        path3 = path{i+1};
        path3 = path3(2:end-1);
        [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
        newpath1 = [0 newpath1 0];
        newpath2 = [0 newpath2 0];
        newpath3 = [0 newpath3 0];
        path{i-1} = newpath1;
        path{i} = newpath2;
        path{i+1} = newpath3;
    end
end

% step2: interchange
for i = 1:K
    path2 = path{i};
    path2 = path2(2:end-1);
    if i == 1
        path1 = path{K};
        path1 = path1(2:end-1);
        path3 = path{i+1};
        path3 = path3(2:end-1);
        [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
        newpath1 = [0 newpath1 0];
        newpath2 = [0 newpath2 0];
        newpath3 = [0 newpath3 0];
        path{K} = newpath1;
        path{i} = newpath2;
        path{i+1} = newpath3;
    elseif i == K
        path1 = path{i-1};
        path1 = path1(2:end-1);
        path3 = path{1};
        path3 = path3(2:end-1);
        [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
        newpath1 = [0 newpath1 0];
        newpath2 = [0 newpath2 0];
        newpath3 = [0 newpath3 0];
        path{i-1} = newpath1;
        path{i} = newpath2;
        path{1} = newpath3;
    else
        path1 = path{i-1};
        path1 = path1(2:end-1);
        path3 = path{i+1};
        path3 = path3(2:end-1);
        [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
        newpath1 = [0 newpath1 0];
        newpath2 = [0 newpath2 0];
        newpath3 = [0 newpath3 0];
        path{i-1} = newpath1;
        path{i} = newpath2;
        path{i+1} = newpath3;
    end
end