function skelOut = deleteCrossPointsInSkel( skelIn, crossPoints )
%DELETECROSSPOINTSINSKEL ɾ�������еĽ����
%   ��������ͽ�������꣬���ȥ������㲢�������򿪲�����Ĺ���

if crossPoints                          % ����н��������������
    skelIn(crossPoints(:, 1), crossPoints(:, 2)) = 0;
end

skelIn = bwareaopen(skelIn, 20);        % ����������������򿪲�����ȥ����С������
skelOut = skelIn;

end

