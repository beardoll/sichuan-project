% �÷�֧���編�������·��
function [path] = branchbound(N, n, dist_spot, dist_repo)
    % n��linehaul�ĸ���
    % N�ǽڵ��ܵĸ���
    % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
    % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
    m = N - n;    % backhaul�ĸ���
    pq = [];   % priority queue
    treeroot = 0;   % ��ʼ�����Ӳֿ⿪ʼ
    impose = 1:m; %��ʼ�������ӽڵ�Ϊ���е�Linehaul
    pq = mincost(impose);  % �ӿ��е��ӽڵ���Ѱ�Ҵ�����С��
end

function [min_spot] = mincost(impose)
    % ��impose���ҳ�������С���ӽڵ�
    
    
    