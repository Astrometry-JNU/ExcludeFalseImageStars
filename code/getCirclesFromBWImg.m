function circles = getCirclesFromBWImg( bwImg )
%GETCIRCLESFROMBWIMG 从阈值图像得到圆
%   输入阈值图像，输出圆。格式：3列，x，y，R

% figure;
% imshow(bwImg);

cc = bwconncomp(bwImg);                             % 连通集，即边缘
ccNum = cc.NumObjects;                              % 边缘数量，即天体数量
ccCell = cc.PixelIdxList;                           % 边缘具体位置，cell中每个元素为每个天体边缘的位置
matchEdge = zeros((ccNum*ccNum-ccNum)/2, 3);

count = 1;
for j = 1 : ccNum - 1                               % 切割后的所有边缘，两两组合。如果拟合得到的最大残差小于阈值，认为是同一个天体的边缘。
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


        Diff = zeros(size(x, 1), 1);                        % 存储每一个点的误差值，即{该点与圆心之间的距离}与半径之差
        for l = 1 : size(x, 1)
            Diff(l) = norm([x(l) - xC, y(l) - yC]) - R;
        end

        % 使用残差最大值
        Diff = abs(Diff);                                   % 取绝对值并逆序排序
        Diff = sort(Diff, 'descend');
        bwRange = mean(Diff(1 : 5));                        % 输出：误差最大的5项的平均值除以半径，即相对半径的百分比
        bwRange = bwRange / R;

        if bwRange < 0.0923                                 % 判定，同一个天体的组合标记为1
            bwRange = 1;
        else
            bwRange = 0;
        end
        
        % 使用标准差(0.5067~0.8276)（不可以除以半径，否则不能区分）（不除以半径也不行，有重叠，完了）
%         bwRange = std(Diff);
%         if bwRange < 0.66715                                 % 判定，同一个天体的组合标记为1
%             bwRange = 1;
%         else
%             bwRange = 0;
%         end


        matchEdge(count, :) = [j, k, bwRange];
        count = count + 1;
    end
end

% matchEdge

for j = 1 : ccNum - 1                                   % 组合标记为同一天体的边缘的连通集
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
for j = 1 : ccNum                                       % 组合后的边缘重新拟合
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


