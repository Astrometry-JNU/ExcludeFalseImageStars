function crossPoints = getCrossPoints( skel )
%FINDCROSSPOINTS �ӹ���ͼ���ҳ������
%   �������ͼ����������λ�á���ʽ��2�У��ֱ�Ϊ�к�r���к�c������Ϊ��������


h = ones(3, 3);                         % ȫ1�����ģ��
filted = imfilter(uint8(skel), h);      % ��ز�����Ĭ�ϣ������С��ԭͼһ�£���ԵΪ0���
[r, c] = find(filted > 3);              % ��������3��������������3���ڽӵ㣩
crossPoints = [];
for j = 1 : size(r, 1)                  % �������м����ĵ㣬�õ�λ�ڹǼ��в�Ϊ����㣨Ӧ��ֱ����Ǽ���˸��죩
    if skel(r(j), c(j)) == 1
        crossPoints = [crossPoints; r(j), c(j)];
    end
end

end

