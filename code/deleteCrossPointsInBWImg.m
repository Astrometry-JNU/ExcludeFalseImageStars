function bwImgOut = deleteCrossPointsInBWImg( bwImgIn, crossPoints )
%DELETECROSSPOINTSINBWIMG 删除交叉点
%   输入阈值图像和交叉点位置，输出新的阈值图像

if size(crossPoints, 1) ~= 0                                        % 如果存在交叉点，将交叉点本身以及四邻域像素置为零
    for j = 1 : size(crossPoints, 1)
        bwImgIn(crossPoints(j, 1), crossPoints(j, 2)) = 0;
        bwImgIn(crossPoints(j, 1) + 1, crossPoints(j, 2)) = 0;
        bwImgIn(crossPoints(j, 1) - 1, crossPoints(j, 2)) = 0;
        bwImgIn(crossPoints(j, 1), crossPoints(j, 2) + 1) = 0;
        bwImgIn(crossPoints(j, 1), crossPoints(j, 2) - 1) = 0;
    end
end

bwImgOut = bwareaopen(bwImgIn, 20);                                 % 置零后进行区域开操作

end

