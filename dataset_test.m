spotnum = 20;

% xrange = 100;
% yrange = 100;

% 
% dataset = zeros(spotnum,2);
% 
% for i=1:spotnum
%     dataset(i,1) = rand * xrange;
%     dataset(i,2) = rand * yrange;
%     while dataset(i,2)<30
%         dataset(i,2) = rand * yrange;
%     end
% end
% 
% for i=1:spotnum
%     plot(dataset(i,1),dataset(i,2),'o');
%     axis([0 100 0 100]);
%     hold on;
% end
% hold off;
% 
% save dataset;

weight = 3:0.5:6;
demand = zeros(spotnum, 1);
for i=1:spotnum
    demand(i) = weight(randi([1 length(weight)]));
end

save demand