function [circles, edgeOut] = image2circlesCPDA( img )
% 输入fits图像image，输出图像中检测到的圆。输出格式：行数为圆的数量，列分别为:x, y, R

% 预处理
[graMedImg, bwImg] = preProcessing(img);
edgeOut = bwImg;

% 检查极差
% bwRange = checkRange(bwImg);
% 判断极差，用以判断是否只有一个目标天体

% figure;
% imshow(bwImg);
% [row, col] = find(bwImg == 1);
% a = fitellipse(col', row');
% t = linspace(0,pi*2);
% x = a(3) * cos(t);
% y = a(4) * sin(t);
% nx = x*cos(a(5))-y*sin(a(5)) + a(1); 
% ny = x*sin(a(5))+y*cos(a(5)) + a(2);
% hold on
% plot(nx,ny,'r-');


% if bwRange > 0.0923                                     % 之前是0.1085

%     figure;
%     imshow(bwImg);
    
    % 取骨架
    skel = bwmorph(bwImg, 'skel', Inf);
    
%     figure;
%     imshow(skel);

%     output = newFindVPoints( graMedImg, bwImg );
    
    % 找Y型交叉点
    crossPoints = getCrossPoints(skel);
%     figure;
%     imshow(skel);
%     hold on;
%     if crossPoints
%     plot(crossPoints(:, 2), crossPoints(:, 1), 'ro');
%     end
%     hold off;
    % 删除骨架中的Y型交叉点并区域开操作
    skel = deleteCrossPointsInSkel(skel, crossPoints);
    
    
%     [cout,marked_img,cd] = cpdaTest(skel);
    cout = cpdaSimp(skel);      % 测试简化的CPDA实现
%     figure;
%     imshow(skel);
%     hold on;
%     for j = 1 : size(cout, 1)
%         plot(cout(j, 2), cout(j, 1), 'ro')
%     end    
%     hold off;

    % 删除预处理后图像中的交叉点
    bwImg = deleteCrossPointsInBWImg(bwImg, crossPoints);
%     figure;
%     imshow(bwImg);
    
    % 切割拐点
    for j = 1 : size(cout, 1)
        bwImg(cout(j, 1)-2:cout(j, 1)+2, cout(j, 2)-2:cout(j, 2)+2) = 0;
    end
    
%     figure, imshow(bwImg)
%     hold on
%     plot(cout(:, 2), cout(:, 1), 'ro')
%     
%     plot(cout(:, 2), cout(:, 1)+1, 'ro')
%     plot(cout(:, 2)+1, cout(:, 1), 'ro')
%     plot(cout(:, 2)+1, cout(:, 1)+1, 'ro')
%     
%     plot(cout(:, 2), cout(:, 1)-1, 'ro')
%     plot(cout(:, 2)-1, cout(:, 1), 'ro')
%     plot(cout(:, 2)-1, cout(:, 1)-1, 'ro')
%     
%     plot(cout(:, 2)+1, cout(:, 1)-1, 'ro')
%     plot(cout(:, 2)-1, cout(:, 1)+1, 'ro')
%     hold off
    
    
%     figure;
%     imshow(bwImg);
    
    % 连通集 - 拟合 - 比较 - 合并
    circles = getCirclesFromBWImg(bwImg);
    
% else
%     % 直接拟合
%     circles = circleFitting(bwImg);
% end

end

