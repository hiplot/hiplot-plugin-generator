# @hiplot start
# @appname test-plugin
# @apptitle
# a test plugin
# 一个测试插件
# @target basic
# @status new
# @author a, b, c
# @maintainer a <a@163.com>
# @url xxx.com
# @citation
# - reference #1.
# - reference #2.
# @version 0.1.0
# @description
# en: A detail description for this plugin,
# markdown should be supported.
# zh: 插件中文描述。
# 这个插件用于测试。
#
# @main helloworld
# @library ggplot2 tidyverse/dplyr https://gitee.com/ShixiangWang/ezcox
#
# @param data export::data::hiplot-textarea::{"required": true, "example": "data.txt"}
# en: a table with at least two numeric columns, one column name should be 'mpg'.
# zh: 至少两列的数值的表格，至少有一列名为 mpg。
#
# @param x export::extra::text-field::{"default":"wt", "class":"col-12"}
# en: a string represent the column mapping to x axis.
# zh: 一个指示映射到 x 轴的列名。
# @param y export::extra::select::{"all": ["mpg", "wt", "vs"], "default": ["mpg"], "multiple": false, "class":"col-12"}
# en: a string represent the column mapping to x axis.
# zh: 一个指示映射到 y 轴的列名。
# @param size export::extra::slider::{"default":2, "min":0.5, "max":5, "step":0.5, "class":"col-12"}
# en: a number specifying dot size.
# zh: 一个指定点大小的数值。
#
# @param zzz 没有采用方括号标记的参数不被解析导出，可以仅用于注释。
#
# @return ggplot::["pdf", "png", "tiff"]::{"width": 6, "height": 4, "theme_support": true, "theme_default": "theme_bw"}
# en: Generate a dot plot.
# zh: 生成一幅点图。
# @data
# # 此处可以编写生成示例数据的代码
# # 示例数据文件需要跟数据表格参数对应起来
# # 或者忽略该标签，手动提交示例数据
# library(readr)
# data("mtcars")
# write_tsv(mtcars, "data.txt")
# @hiplot end

library(ggplot2)
helloworld <- function(data, x, y = "mpg", size = 2) {
  p <- ggplot(data, aes_string(x = x, y = y))
  p <- p + geom_point(size = size)
  # Here export a ggplot object
  return(p)
}
