# ExcludeFalseImageStars
exclude false image stars using CPDA and compare with CHT

排除假图像星中的圆拟合算法，使用200张图像比较两种算法的准确率和运行时间

## 组织结构

code文件夹存放的是代码

data文件夹存放的文件是用于比较的200张图像文件

## 使用方法
运行 compareHough200Pics.m 可以逐张输出标记了拟合圆的图像，其中蓝色实线为本算法结果，红色虚线为CHT算法结果。

运行结束后，变量 timeRecorder 记录的是每张图像了运行时间，绘制运行时间对比折线图时需要注释显示图像部分的代码，两种算法分别运行一次，分别保存记录运行时间的 timeRecorder  变量。

## 算法流程
本算法的实现在 image2circlesCPDA.m 文件中。

预处理 -> 提取骨架 -> 找Y型交点 -> 删除骨架中的Y型交点 -> 用CPDA算法检测V型交点 -> 删除原边缘中的两种交点 -> 合并连通集、拟合圆

取消每一步操作后的注释可以查看中间过程的处理结果

作者： 卢志聪，暨南大学硕士，指导老师：张庆丰
参考文献： 
Qingfeng Zhang, Zhicong Lu, Xiaomei Zhou, Yang Zheng, Zhan Li, Qing-Yu Peng, Shun Long and Weiheng Zhu. Automatic removal of false image stars in disk-resolved images of the Cassini Imaging Science Subsystem, Research in Astronomy and Astrophysics, 2020，20（7）:100
