% dist_repo = [30 6 4 5 6];
% dist_spot = zeros(5,5);
% dist_spot(1,2) = 4;
% dist_spot(1,3) = 5;
% dist_spot(1,4) = 2;
% dist_spot(1,5) = 1;
% dist_spot(2,1) = 4;
% dist_spot(2,3) = 7;
% dist_spot(2,4) = 8;
% dist_spot(2,5) = 9;
% dist_spot(3,1) = 5;
% dist_spot(3,2) = 7;
% dist_spot(3,4) = 10;
% dist_spot(3,5) = 20;
% dist_spot(4,1) = 2;
% dist_spot(4,2) = 8;
% dist_spot(4,3) = 10;
% dist_spot(4,5) = 3;
% dist_spot(5,1) = 1;
% dist_spot(5,2) = 9;
% dist_spot(5,3) = 20;
% dist_spot(5,4) = 3;
% 
% for i = 1:5
%     dist_spot(i,i) = inf;
% end
% 
% [path, cost] = branchboundtight(5, 3, dist_spot, dist_repo)
% [path, cost] = branchbound(5, 5, dist_spot, dist_repo);

% dist_repo = [3 3 2 6];
% dist_spot = zeros(4,4);
% dist_spot(1,1) = inf;
% dist_spot(1,2) = 7;
% dist_spot(1,3) = 3;
% dist_spot(1,4) = 2;
% dist_spot(2,1) = 7;
% dist_spot(2,2) = inf;
% dist_spot(2,3) = 2;
% dist_spot(2,4) = 5;
% dist_spot(3,1) = 3;
% dist_spot(3,2) = 2;
% dist_spot(3,3) = inf;
% dist_spot(3,4) = 3;
% dist_spot(4,1) = 2;
% dist_spot(4,2) = 5;
% dist_spot(4,3) = 3;
% dist_spot(4,4) = inf;

dist_repo = [3 1 5 8];
dist_spot = zeros(4,4);
dist_spot(1,1) = inf;
dist_spot(1,2) = 6;
dist_spot(1,3) = 7;
dist_spot(1,4) = 9;
dist_spot(2,1) = 6;
dist_spot(2,2) = inf;
dist_spot(2,3) = 4;
dist_spot(2,4) = 2;
dist_spot(3,1) = 7;
dist_spot(3,2) = 4;
dist_spot(3,3) = inf;
dist_spot(3,4) = 3;
dist_spot(4,1) = 9;
dist_spot(4,2) = 2;
dist_spot(4,3) = 3;
dist_spot(4,4) = inf;

% dist_spot = rand(12,12);
% dist_repo = rand(1,12);

[path, cost] = branchboundtight(4, 4, dist_spot, dist_repo)