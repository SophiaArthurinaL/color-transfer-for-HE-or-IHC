library(imager)

# 设置工作目录
setwd("D:\\demo")


# 读取图像A
img_A <- load.image("已调色.png")

# 定义缩放比例
scale_factor <- 1

# 调整图像A的大小
img_A_resized <- resize(img_A, round(dim(img_A)[1] * scale_factor), round(dim(img_A)[2] * scale_factor))

# 转换至LAB色彩空间
img_A_lab <- RGBtoLab(img_A_resized)

# 提取LAB通道
L_A <- img_A_lab[,,1]
A_A <- img_A_lab[,,2]
B_A <- img_A_lab[,,3]

# 计算图像A的均值和标准差
mean_L_A <- mean(L_A)
mean_A_A <- mean(A_A)
mean_B_A <- mean(B_A)

sd_L_A <- sd(L_A)
sd_A_A <- sd(A_A)
sd_B_A <- sd(B_A)

# 获取文件夹中所有图像文件的列表，且是png格式
file_list <- list.files(pattern = "\\.png$")

# 遍历每个图像文件并处理
for (file in file_list) {
  
  # 读取图像B (imager)
  img_B <- load.image(file)
  
  # 调整图像B的大小到与A相同的尺寸
  img_B_resized <- resize(img_B, round(dim(img_A)[1] * scale_factor), round(dim(img_A)[2] * scale_factor))
  
  # 转换至LAB色彩空间
  img_B_lab <- RGBtoLab(img_B_resized)
  
  # 提取LAB通道
  L_B <- img_B_lab[,,1]
  A_B <- img_B_lab[,,2]
  B_B <- img_B_lab[,,3]
  
  # 计算图像B的均值和标准差
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
  
  # 合并新的LAB通道S
  img_B_lab_new <- imager::as.cimg(c(L_B_new, A_B_new, B_B_new), x = dim(img_B_lab)[1], y = dim(img_B_lab)[2], cc = 3)
  
  # 将LAB转换回RGB
  img_B_modified <- LabtoRGB(img_B_lab_new)
  
  img_B_modified <- resize(img_B_modified, round(dim(img_B)[1] * scale_factor), round(dim(img_B)[2] * scale_factor))
  
  # 保存修改后的图像
  save.image(img_B_modified, paste0(sub(".png$", "", file), "_modified.png"))
}


#以下是一个简易的修改偏色的代码，可以把修改后产生偏色的图像背景改成白色

library(magick)
library(ggplotify)
# 获取文件夹中所有图像文件的列表
file_list <- list.files(pattern = "\\_modified.png$")

# 遍历每个图像文件并处理
for (file in file_list) {
  # 读取图像C
  img_C <- image_read(file)

  # 填充背景颜色为白色，fuzz 参数调整为适当的值（0-100）
  img_C_modified <- image_fill(img_C, 'white', fuzz = 2)

  # 将处理后的图像转换为 ggplot 对象
  gg_img <- as.ggplot(img_C_modified)

  # 保存修改后的图像
  image_write(img_C_modified, paste0(sub(".png$", "", file), "_modified.png"))
}

