function bwImgOut = deleteCrossPointsInBWImg( bwImgIn, crossPoints )
%DELETECROSSPOINTSINBWIMG ɾ�������
%   ������ֵͼ��ͽ����λ�ã�����µ���ֵͼ��

if size(crossPoints, 1) ~= 0                                        % ������ڽ���㣬������㱾���Լ�������������Ϊ��
    for j = 1 : size(crossPoints, 1)
        bwImgIn(crossPoints(j, 1), crossPoints(j, 2)) = 0;
        bwImgIn(crossPoints(j, 1) + 1, crossPoints(j, 2)) = 0;
        bwImgIn(crossPoints(j, 1) - 1, crossPoints(j, 2)) = 0;
        bwImgIn(crossPoints(j, 1), crossPoints(j, 2) + 1) = 0;
        bwImgIn(crossPoints(j, 1), crossPoints(j, 2) - 1) = 0;
    end
end

bwImgOut = bwareaopen(bwImgIn, 20);                                 % �����������򿪲���

end

