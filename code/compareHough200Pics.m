% 比较本文算法与圆霍夫变换算法
% 200张图像中既包含fits格式也包含由原始IMG格式转换而来的mat格式
% timeRecorder变量用于记录每张图像的运行时间，可以保存变量再生成最终的对比运行时间的折线图，对比运行时间时注释掉显示部分的代码


clear;clc;

fits = ls('..\data\*.fits');                                % 搜索文件夹内fits格式文件
mats = ls('..\data\*.mat');                                 % 搜索文件夹内mat格式文件
mats = [mats, repmat(' ', size(mats, 1), 1)];               % 补齐mat字符串，使之与fits格式文件长度一致
pics = [fits; mats];                                        % 拼接文件列表
pics = [repmat('..\data\', size(pics, 1), 1), pics];        % 生成带有完整路径的文件列表

timeRecorder = zeros(200, 1);                               % 预先初始化的记录时间的变量
tic;                                                        % 开始计时
for k = 1:size(pics, 1)                                     % 遍历图像
    [pathstr,name,ext] = fileparts(pics(k, :));             % 拆分文件名
    if strcmp(ext, '.fits')                                 % fits格式
        img = fitsread(pics(k, :));
    else                                                    % mat格式
        load(pics(k, :));
        img = imgPixels;
    end
    
    figure;                                                 % 显示原图
    imshow(img, []);
    
    % Circular Hough Transform
    [centers,radii] = imfindcircles(img, [20, 400],  'Sensitivity', 0.957,'EdgeThreshold', 0.2);    % 找圆，CHT算法
    viscircles(centers,radii, 'LineStyle', '--', 'EnhanceVisibility', 0);                           % 绘制圆
    
    % The CPDA method
    [circles, edgeOut] = image2circlesCPDA(img);                                                    % 找圆，本文算法
    viscircles([circles(:, 1), circles(:, 2)],circles(:, 3), ...
        'color', [0/255, 113/255, 189/255], 'EnhanceVisibility', 0);                                % 绘制圆
    
    timeRecorder(k) = toc;                                                                          % 记录时间
end
toc;
