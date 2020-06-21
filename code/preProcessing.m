function [graMedImg, bwImg] = preProcessing( img )
%PREPROCESSING 图像预处理
%   输入原图（double），输出经过中值滤波、求梯度、做阈值、处理四边、面积开操作的图像（logical）

% 尝试对原图对数压缩
% img = log(img+1);
% figure;
% imshow(img, []);

medImg = medfilt2(img, [3 3]);                      % 中值滤波
% graMedImg = magnitudeOfGradient(medImg);            % 获取梯度图像

% 尝试其他梯度算子
% graMedImg = edgeEdit(medImg, 'sobel');
graMedImg = edgeEdit(medImg, 'roberts');
graMedImg = sqrt(graMedImg);

graMedImg = graMedImg / max(graMedImg(:));          % 使最大值为1

% figure;
% imshow(graMedImg, []);

% w=fspecial('gaussian',[5 5],5);
% graMedImg=imfilter(graMedImg,w);
% corners = detectMinEigenFeatures(graMedImg);
% figure;
% imshow(graMedImg, []);
% hold on;
% plot(corners.selectStrongest(5));
% hold off;

thresh = 0.3;                                       % Roberts 0.3, Sobel 0.4
graList = sort(graMedImg(:));
graList(graList == 0) = [];
gra99percent = graList(round(0.9999*size(graList, 1)));

% graMedImg(graMedImg > gra99percent) = 0;
% thresh = sqrt(6 * mean2(graMedImg .* graMedImg));
bwGraMedImg = im2bw(graMedImg, thresh*gra99percent);             % 阈值处理

% 尝试直方图反映射
% graList = sort(graMedImg(:));
% for j = 1:100
%     graMedImg(logical((graMedImg>=graList(round(size(graList, 1)*(j-1)/100 + 1))) .* (graMedImg<= graList(round(size(graList, 1)*j/100))))) = j;
% end


% figure;
% imshow(bwGraMedImg);

% bwGraMedImg = edge(medImg, 'Canny');
% [H,T,R] = hough(bwGraMedImg);
% figure;
% imshow(bwGraMedImg);
% figure;
% imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,...
%       'InitialMagnification','fit');
% title('Hough transform of gantrycrane.png');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
% colormap(hot);

% 四周宽度10像素设为0，消除图像边缘缺陷影响
bwGraMedImg(1:10, :) = 0;
bwGraMedImg(end - 10:end, :) = 0;
bwGraMedImg(:, 1:10) = 0;
bwGraMedImg(:, end - 10:end) = 0;

% figure;
% imshow(bwGraMedImg);


% 尝试调换提取骨架和面积开操作的顺序，以在最后只用细化后的边缘拟合圆。失败，原因是由于边缘有一定厚度并且中心梯度较低，导致中央有空心的情况，最终在细化后的图像上可能会出现
% 双层的边缘。另外有厚度的边缘只要厚度均匀拟合效果几乎不会有差别（但是图上一般中间厚两边薄，导致拟合后重心偏移），其次有厚度的边缘可能可以更好地定位边缘中心，因为细化后边
% 缘可能会产生偏移。后面可能可以在面积开操作以后做一次闭操作以封闭孔洞再细化，然后使用细化后的边缘，但是可能又会太繁琐了。
% skel = bwmorph(bwGraMedImg, 'skel', Inf);
% figure;
% imshow(skel)
% figure;
% imshow(bwGraMedImg)



cc = bwconncomp(bwGraMedImg);                       % 找出连通集
ccNum = cc.NumObjects;                              % 连通集数量
ccCell = cc.PixelIdxList;                           % 每个连通集包含的像素坐标的位置
ccSizes = ones(1, ccNum + 1);                       % 存储每个连通集的像素数，加1为了后面确定阈值时处理边缘情况
for j = 1 : ccNum                                   % 记录每个连通集像素数
    ccSizes(j) = size(ccCell{j}, 1);
end
ccSizes = sort(ccSizes, 'descend');                 % 将连通集像素数逆序排序

thresSet = 0;
for j = 1 : ccNum                                   % 由大到小遍历
    if ccSizes(j) / ccSizes(j + 1) > 6              % 将大于X倍的间隔作为阈值判断标准，此处设为6倍
        thresSet = ccSizes(j);
        break;
    end
end
if thresSet ~= 0
    bwGraMedImg = bwareaopen(bwGraMedImg, thresSet);    % 将得到的阈值用于区域开操作以消除小轮廓
end
% 最初方法的输出
bwImg = bwGraMedImg;

% figure;
% imshow(bwImg);
% imwrite(bwImg, 'roberts.png');

% 添加闭操作消除大边缘内的黑点，好像还行，但是有些两个天体的情况失效了
% SE = strel('square',3);
% bwImg = imclose(bwImg, SE);

% figure;
% imshow(bwImg);
% skel = bwmorph(bwImg, 'skel', Inf);
% figure;
% imshow(skel);

% 添加高斯模糊，消除大边缘内的黑点
% 结论：效果不好，只能增加观感，对分析没有帮助
% h = fspecial('gaussian', 7, 1);
% bwImg = double(bwImg);
% bwImg = imfilter(bwImg, h);
% figure;
% imshow(bwImg);
% skel = bwmorph(bwImg, 'skel', Inf);
% figure;
% imshow(skel);









end

