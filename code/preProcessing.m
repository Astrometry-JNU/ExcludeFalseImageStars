function [graMedImg, bwImg] = preProcessing( img )
%PREPROCESSING ͼ��Ԥ����
%   ����ԭͼ��double�������������ֵ�˲������ݶȡ�����ֵ�������ıߡ������������ͼ��logical��

% ���Զ�ԭͼ����ѹ��
% img = log(img+1);
% figure;
% imshow(img, []);

medImg = medfilt2(img, [3 3]);                      % ��ֵ�˲�
% graMedImg = magnitudeOfGradient(medImg);            % ��ȡ�ݶ�ͼ��

% ���������ݶ�����
% graMedImg = edgeEdit(medImg, 'sobel');
graMedImg = edgeEdit(medImg, 'roberts');
graMedImg = sqrt(graMedImg);

graMedImg = graMedImg / max(graMedImg(:));          % ʹ���ֵΪ1

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
bwGraMedImg = im2bw(graMedImg, thresh*gra99percent);             % ��ֵ����

% ����ֱ��ͼ��ӳ��
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

% ���ܿ��10������Ϊ0������ͼ���Եȱ��Ӱ��
bwGraMedImg(1:10, :) = 0;
bwGraMedImg(end - 10:end, :) = 0;
bwGraMedImg(:, 1:10) = 0;
bwGraMedImg(:, end - 10:end) = 0;

% figure;
% imshow(bwGraMedImg);


% ���Ե�����ȡ�Ǽܺ������������˳���������ֻ��ϸ����ı�Ե���Բ��ʧ�ܣ�ԭ�������ڱ�Ե��һ����Ȳ��������ݶȽϵͣ����������п��ĵ������������ϸ�����ͼ���Ͽ��ܻ����
% ˫��ı�Ե�������к�ȵı�ԵֻҪ��Ⱦ������Ч�����������в�𣨵���ͼ��һ���м�����߱���������Ϻ�����ƫ�ƣ�������к�ȵı�Ե���ܿ��Ը��õض�λ��Ե���ģ���Ϊϸ�����
% Ե���ܻ����ƫ�ơ�������ܿ���������������Ժ���һ�αղ����Է�տ׶���ϸ����Ȼ��ʹ��ϸ����ı�Ե�����ǿ����ֻ�̫�����ˡ�
% skel = bwmorph(bwGraMedImg, 'skel', Inf);
% figure;
% imshow(skel)
% figure;
% imshow(bwGraMedImg)



cc = bwconncomp(bwGraMedImg);                       % �ҳ���ͨ��
ccNum = cc.NumObjects;                              % ��ͨ������
ccCell = cc.PixelIdxList;                           % ÿ����ͨ�����������������λ��
ccSizes = ones(1, ccNum + 1);                       % �洢ÿ����ͨ��������������1Ϊ�˺���ȷ����ֵʱ�����Ե���
for j = 1 : ccNum                                   % ��¼ÿ����ͨ��������
    ccSizes(j) = size(ccCell{j}, 1);
end
ccSizes = sort(ccSizes, 'descend');                 % ����ͨ����������������

thresSet = 0;
for j = 1 : ccNum                                   % �ɴ�С����
    if ccSizes(j) / ccSizes(j + 1) > 6              % ������X���ļ����Ϊ��ֵ�жϱ�׼���˴���Ϊ6��
        thresSet = ccSizes(j);
        break;
    end
end
if thresSet ~= 0
    bwGraMedImg = bwareaopen(bwGraMedImg, thresSet);    % ���õ�����ֵ�������򿪲���������С����
end
% ������������
bwImg = bwGraMedImg;

% figure;
% imshow(bwImg);
% imwrite(bwImg, 'roberts.png');

% ��ӱղ����������Ե�ڵĺڵ㣬�����У�������Щ������������ʧЧ��
% SE = strel('square',3);
% bwImg = imclose(bwImg, SE);

% figure;
% imshow(bwImg);
% skel = bwmorph(bwImg, 'skel', Inf);
% figure;
% imshow(skel);

% ��Ӹ�˹ģ�����������Ե�ڵĺڵ�
% ���ۣ�Ч�����ã�ֻ�����ӹ۸У��Է���û�а���
% h = fspecial('gaussian', 7, 1);
% bwImg = double(bwImg);
% bwImg = imfilter(bwImg, h);
% figure;
% imshow(bwImg);
% skel = bwmorph(bwImg, 'skel', Inf);
% figure;
% imshow(skel);









end

