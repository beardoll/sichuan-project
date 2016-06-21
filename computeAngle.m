function [theta] = computeAngle(x,y,repox,repoy)
% 计算顾客节点的幅角
% x,y为顾客节点的横纵坐标
% repox,repoy为仓库节点的横纵坐标
    tanvalue = (y-repoy)./(x-repox);
    theta = zeros(1,length(x));
    for i = 1:length(x)
        temp = atan(tanvalue);
        if x(i)==0  % 正切值为无穷大的位置上
            if y(i) > repoy  % 在90度的位置
                theta(i) = pi/2;
            else
                theta(i) = 3/2*pi;
            end
        else
            if x(i)>repox && y(i)>=repoy  % 锐角位置
                theta(i) = temp(i);
            elseif x(i)<repox && y(i)>=repoy % 第二象限
                theta(i) = temp(i) + pi; 
            elseif x(i)<repox && y(i)<repoy  % 第三象限
                theta(i) = temp(i) + pi;
            elseif x(i)>repox && y(i)<repoy  % 第四象限
                theta(i) = temp(i) + 2*pi;
            end
        end
    end
end