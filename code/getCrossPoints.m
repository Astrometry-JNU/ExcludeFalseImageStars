function crossPoints = getCrossPoints( skel )
%FINDCROSSPOINTS 从骨骼图像找出交叉点
%   输入骨骼图像，输出交叉点位置。格式：2列，分别为行号r、列号c，行数为交叉点个数


h = ones(3, 3);                         % 全1的相关模版
filted = imfilter(uint8(skel), h);      % 相关操作，默认：结果大小与原图一致，边缘为0填充
[r, c] = find(filted > 3);              % 交叉点大于3（包含自身、至少3个邻接点）
crossPoints = [];
for j = 1 : size(r, 1)                  % 遍历所有检测出的点，该点位于骨架中才为交叉点（应该直接与骨架相乘更快）
    if skel(r(j), c(j)) == 1
        crossPoints = [crossPoints; r(j), c(j)];
    end
end

end

