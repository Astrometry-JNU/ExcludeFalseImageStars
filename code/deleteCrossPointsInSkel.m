function skelOut = deleteCrossPointsInSkel( skelIn, crossPoints )
%DELETECROSSPOINTSINSKEL 删除骨骼中的交叉点
%   输入骨骼和交叉点坐标，输出去除交叉点并进行区域开操作后的骨骼

if crossPoints                          % 如果有交叉点就消除交叉点
    skelIn(crossPoints(:, 1), crossPoints(:, 2)) = 0;
end

skelIn = bwareaopen(skelIn, 20);        % 消除交叉点后进行区域开操作，去除过小的轮廓
skelOut = skelIn;

end

