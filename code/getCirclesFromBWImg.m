function circles = getCirclesFromBWImg( bwImg )
%GETCIRCLESFROMBWIMG ����ֵͼ��õ�Բ
%   ������ֵͼ�����Բ����ʽ��3�У�x��y��R

% figure;
% imshow(bwImg);

cc = bwconncomp(bwImg);                             % ��ͨ��������Ե
ccNum = cc.NumObjects;                              % ��Ե����������������
ccCell = cc.PixelIdxList;                           % ��Ե����λ�ã�cell��ÿ��Ԫ��Ϊÿ�������Ե��λ��
matchEdge = zeros((ccNum*ccNum-ccNum)/2, 3);

count = 1;
for j = 1 : ccNum - 1                               % �и������б�Ե��������ϡ������ϵõ������в�С����ֵ����Ϊ��ͬһ������ı�Ե��
    for k = j + 1 : ccNum
        
        x1 = floor((ccCell{j} - 1) / 1024) + 1;
        y1 = mod((ccCell{j} - 1), 1024) + 1;
        x2 = floor((ccCell{k} - 1) / 1024) + 1;
        y2 = mod((ccCell{k} - 1), 1024) + 1;

        x = [x1; x2];
        y = [y1; y2];

        N=length(x);
        xx=x.*x;
        yy=y.*y;
        xy=x.*y;
        A=[sum(x) sum(y) N;sum(xy) sum(yy) sum(y);sum(xx) sum(xy) sum(x)];
        B=[-sum(xx+yy);-sum(xx.*y+yy.*y);-sum(xx.*x+xy.*y)];
        a=A\B;
        xC = -0.5*a(1);
        yC = -0.5*a(2);
        R = sqrt(-(a(3)-xC^2-yC^2));


        Diff = zeros(size(x, 1), 1);                        % �洢ÿһ��������ֵ����{�õ���Բ��֮��ľ���}��뾶֮��
        for l = 1 : size(x, 1)
            Diff(l) = norm([x(l) - xC, y(l) - yC]) - R;
        end

        % ʹ�òв����ֵ
        Diff = abs(Diff);                                   % ȡ����ֵ����������
        Diff = sort(Diff, 'descend');
        bwRange = mean(Diff(1 : 5));                        % ������������5���ƽ��ֵ���԰뾶������԰뾶�İٷֱ�
        bwRange = bwRange / R;

        if bwRange < 0.0923                                 % �ж���ͬһ���������ϱ��Ϊ1
            bwRange = 1;
        else
            bwRange = 0;
        end
        
        % ʹ�ñ�׼��(0.5067~0.8276)�������Գ��԰뾶�����������֣��������԰뾶Ҳ���У����ص������ˣ�
%         bwRange = std(Diff);
%         if bwRange < 0.66715                                 % �ж���ͬһ���������ϱ��Ϊ1
%             bwRange = 1;
%         else
%             bwRange = 0;
%         end


        matchEdge(count, :) = [j, k, bwRange];
        count = count + 1;
    end
end

% matchEdge

for j = 1 : ccNum - 1                                   % ��ϱ��Ϊͬһ����ı�Ե����ͨ��
    for k = j + 1 : ccNum
        if matchEdge(matchEdge(:, 1) == j & matchEdge(:, 2) == k, 3) == 1
            ccCell{k} = [ccCell{k}; ccCell{j}];
            ccCell{j} = [];
            break;
        end
    end
end

count = 0;
for j = 1 : ccNum
    if size(ccCell{j}, 1) ~= 0
        count = count + 1;
    end
end

circles = zeros(count, 3);
count = 1;
for j = 1 : ccNum                                       % ��Ϻ�ı�Ե�������
    if ccCell{j} ~= 0
        x = floor((ccCell{j} - 1) / 1024) + 1;
        y = mod((ccCell{j} - 1), 1024) + 1;
        N=length(x);
        xx=x.*x;
        yy=y.*y;
        xy=x.*y;
        A=[sum(x) sum(y) N;sum(xy) sum(yy) sum(y);sum(xx) sum(xy) sum(x)];
        B=[-sum(xx+yy);-sum(xx.*y+yy.*y);-sum(xx.*x+xy.*y)];
        a=A\B;
        xC = -0.5*a(1);
        yC = -0.5*a(2);
        R = sqrt(-(a(3)-xC^2-yC^2));
        
        circles(count, :) = [xC, yC, R];
        count = count + 1;
    end
end

% figure;
% imshow(bwImg);
% hold on;
% for j = 1 : size(circles, 1)
%     theta = linspace(0, 2*pi);
%     x = circles(j, 3) * cos(theta) + circles(j, 1);
%     y = circles(j, 3) * sin(theta) + circles(j, 2);
%     plot(x, y);
% end
% hold off;

end


