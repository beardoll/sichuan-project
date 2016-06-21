function [theta] = computeAngle(x,y,repox,repoy)
% ����˿ͽڵ�ķ���
% x,yΪ�˿ͽڵ�ĺ�������
% repox,repoyΪ�ֿ�ڵ�ĺ�������
    tanvalue = (y-repoy)./(x-repox);
    theta = zeros(1,length(x));
    for i = 1:length(x)
        temp = atan(tanvalue);
        if x(i)==0  % ����ֵΪ������λ����
            if y(i) > repoy  % ��90�ȵ�λ��
                theta(i) = pi/2;
            else
                theta(i) = 3/2*pi;
            end
        else
            if x(i)>repox && y(i)>=repoy  % ���λ��
                theta(i) = temp(i);
            elseif x(i)<repox && y(i)>=repoy % �ڶ�����
                theta(i) = temp(i) + pi; 
            elseif x(i)<repox && y(i)<repoy  % ��������
                theta(i) = temp(i) + pi;
            elseif x(i)>repox && y(i)<repoy  % ��������
                theta(i) = temp(i) + 2*pi;
            end
        end
    end
end