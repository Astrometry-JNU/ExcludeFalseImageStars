% �Ƚϱ����㷨��Բ����任�㷨
% 200��ͼ���мȰ���fits��ʽҲ������ԭʼIMG��ʽת��������mat��ʽ
% timeRecorder�������ڼ�¼ÿ��ͼ�������ʱ�䣬���Ա���������������յĶԱ�����ʱ�������ͼ���Ա�����ʱ��ʱע�͵���ʾ���ֵĴ���


clear;clc;

fits = ls('..\data\*.fits');                                % �����ļ�����fits��ʽ�ļ�
mats = ls('..\data\*.mat');                                 % �����ļ�����mat��ʽ�ļ�
mats = [mats, repmat(' ', size(mats, 1), 1)];               % ����mat�ַ�����ʹ֮��fits��ʽ�ļ�����һ��
pics = [fits; mats];                                        % ƴ���ļ��б�
pics = [repmat('..\data\', size(pics, 1), 1), pics];        % ���ɴ�������·�����ļ��б�

timeRecorder = zeros(200, 1);                               % Ԥ�ȳ�ʼ���ļ�¼ʱ��ı���
tic;                                                        % ��ʼ��ʱ
for k = 1:size(pics, 1)                                     % ����ͼ��
    [pathstr,name,ext] = fileparts(pics(k, :));             % ����ļ���
    if strcmp(ext, '.fits')                                 % fits��ʽ
        img = fitsread(pics(k, :));
    else                                                    % mat��ʽ
        load(pics(k, :));
        img = imgPixels;
    end
    
    figure;                                                 % ��ʾԭͼ
    imshow(img, []);
    
    % Circular Hough Transform
    [centers,radii] = imfindcircles(img, [20, 400],  'Sensitivity', 0.957,'EdgeThreshold', 0.2);    % ��Բ��CHT�㷨
    viscircles(centers,radii, 'LineStyle', '--', 'EnhanceVisibility', 0);                           % ����Բ
    
    % The CPDA method
    [circles, edgeOut] = image2circlesCPDA(img);                                                    % ��Բ�������㷨
    viscircles([circles(:, 1), circles(:, 2)],circles(:, 3), ...
        'color', [0/255, 113/255, 189/255], 'EnhanceVisibility', 0);                                % ����Բ
    
    timeRecorder(k) = toc;                                                                          % ��¼ʱ��
end
toc;
