# 函数参数除了 default，其他直接转换 hiplot 前端支持的所有选项
#
# @hiplot start
# @appname test-plugin
# @apptitle
# a test plugin
# 一个测试插件
# @target basic
# @tag test dotplot
# @author a, b, c
# @email a@163.com
# @url xxx.com
# @citation
# - reference #1.
# - reference #2.
# @version 0.1.0
# @release 2020-09-10
# @description
# en: A detail description for this plugin,
# markdown should be supported.
# zh: 插件中文描述。
# 这个插件用于测试。
#
# @main helloworld
# @library ggplot2 tidyverse/dplyr https://gitee.com/ShixiangWang/ezcox
#
# @param data export::data::hiplot-textarea::{"default": "data.txt", "required": true}
# en: a table with at least two numeric columns, one column name should be 'mpg'.
# zh: 至少两列的数值的表格，至少有一列名为 mpg。
# @param x export::dataArg::data::{"index":2, "default": ["sex", "ecog"], "blackItems":["aaa","bbb"], "required": true}
# en: a string represent the column mapping to x axis.
# zh: 一个指示映射到 x 轴的列名。
# @param y export::dataArg::data::{"index":1, "blackItems":["time","status"], "required": false}
# en: a string represent the column mapping to y axis.
# zh: 一个指示映射到 y 轴的列名。
# @param size export::extra::slider::{"default":2, "min":0.5, "max":5, "step":0.5, "class":"col-12"}
# en: a number specifying dot size.
# zh: 一个指定点大小的数值。
# @param add_line export::extra::switch::{"default": true, "class":"col-12"}
# en: a bool to add line.
# zh: 添加线图。
# @param zzz 没有采用方括号标记的参数不被解析导出，可以仅用于注释。
#
# @return plot::["pdf", "png", "tiff"]::{"title": "A test plot", "width": 6, "height": 4, "theme_support": true, "theme_default": "theme_bw"}
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

# param x export::extra::text-field::{"default":"wt", "class":"col-12"}
# param y export::extra::select::{"default": ["mpg"], "default": "age", "items": ["mpg", "wt", "vs"], "class":"col-12"}


library(ggplot2)
helloworld <- function(data, x, y = "mpg", size = 2, add_line = TRUE) {
  p <- ggplot(data, aes_string(x = x, y = y))
  p <- p + geom_point(size = size)
  if (add_line) {
    p <- p + geom_line()
  }
  # Here export a ggplot object
  return(p)
}
