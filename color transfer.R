library(imager)

# 设置工作目录
setwd("D:\\demo")#设置路径

# 读取图像A和图像B
img_A <- load.image("已调色.png")#这个是调色好的图像
img_B <- load.image("待调色.png")#这个是要调整的图像
filename <- "待调色"     #这个还是手动改一下，关系到最后的命名

# 定义缩放比例（如果你的图像是10000*10000像素的，建议把这个值改成1/4，以免卡死）
scale_factor <- 1

# 调整图像A和图像B的大小到相同的尺寸
img_A_resized <- resize(img_A, round(dim(img_A)[1] * scale_factor), round(dim(img_A)[2] * scale_factor))
img_B_resized <- resize(img_B, round(dim(img_A)[1] * scale_factor), round(dim(img_A)[2] * scale_factor))


# 转换至LAB色彩空间
img_A_lab <- RGBtoLab(img_A_resized)
img_B_lab <- RGBtoLab(img_B_resized)

# 提取LAB通道
L_A <- img_A_lab[,,1]
A_A <- img_A_lab[,,2]
B_A <- img_A_lab[,,3]

L_B <- img_B_lab[,,1]
A_B <- img_B_lab[,,2]
B_B <- img_B_lab[,,3]

# 计算图像A和图像B的均值和标准差
mean_L_A <- mean(L_A)
mean_A_A <- mean(A_A)
mean_B_A <- mean(B_A)

sd_L_A <- sd(L_A)
sd_A_A <- sd(A_A)
sd_B_A <- sd(B_A)

mean_L_B <- mean(L_B)
mean_A_B <- mean(A_B)
mean_B_B <- mean(B_B)

sd_L_B <- sd(L_B)
sd_A_B <- sd(A_B)
sd_B_B <- sd(B_B)

# 匹配B图的颜色到A图的颜色
L_B_new <- (L_B - mean_L_B) * (sd_L_A / sd_L_B) + mean_L_A
A_B_new <- (A_B - mean_A_B) * (sd_A_A / sd_A_B) + mean_A_A
B_B_new <- (B_B - mean_B_B) * (sd_B_A / sd_B_B) + mean_B_A

# 合并新的LAB通道
img_B_lab_new <- imager::as.cimg(c(L_B_new, A_B_new, B_B_new), x = dim(img_B_lab)[1], y = dim(img_B_lab)[2], cc = 3)

# 将LAB转换回RGB
img_B_modified <- LabtoRGB(img_B_lab_new)
img_B_modified <- resize(img_B_modified, round(dim(img_B)[1] * scale_factor), round(dim(img_B)[2] * scale_factor))


# 显示修改后的图像
plot(img_B_modified)

# 保存修改后的图像（如果需要保存）
save.image(img_B_modified, paste0(sub(".png$", "", filename), "_modified.png"))

