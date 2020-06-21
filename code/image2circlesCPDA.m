function [circles, edgeOut] = image2circlesCPDA( img )
% ����fitsͼ��image�����ͼ���м�⵽��Բ�������ʽ������ΪԲ���������зֱ�Ϊ:x, y, R

% Ԥ����
[graMedImg, bwImg] = preProcessing(img);
edgeOut = bwImg;

% ��鼫��
% bwRange = checkRange(bwImg);
% �жϼ�������ж��Ƿ�ֻ��һ��Ŀ������

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


% if bwRange > 0.0923                                     % ֮ǰ��0.1085

%     figure;
%     imshow(bwImg);
    
    % ȡ�Ǽ�
    skel = bwmorph(bwImg, 'skel', Inf);
    
%     figure;
%     imshow(skel);

%     output = newFindVPoints( graMedImg, bwImg );
    
    % ��Y�ͽ����
    crossPoints = getCrossPoints(skel);
%     figure;
%     imshow(skel);
%     hold on;
%     if crossPoints
%     plot(crossPoints(:, 2), crossPoints(:, 1), 'ro');
%     end
%     hold off;
    % ɾ���Ǽ��е�Y�ͽ���㲢���򿪲���
    skel = deleteCrossPointsInSkel(skel, crossPoints);
    
    
%     [cout,marked_img,cd] = cpdaTest(skel);
    cout = cpdaSimp(skel);      % ���Լ򻯵�CPDAʵ��
%     figure;
%     imshow(skel);
%     hold on;
%     for j = 1 : size(cout, 1)
%         plot(cout(j, 2), cout(j, 1), 'ro')
%     end    
%     hold off;

    % ɾ��Ԥ�����ͼ���еĽ����
    bwImg = deleteCrossPointsInBWImg(bwImg, crossPoints);
%     figure;
%     imshow(bwImg);
    
    % �и�յ�
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
    
    % ��ͨ�� - ��� - �Ƚ� - �ϲ�
    circles = getCirclesFromBWImg(bwImg);
    
% else
%     % ֱ�����
%     circles = circleFitting(bwImg);
% end

end

