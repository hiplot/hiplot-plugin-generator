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
# @citation This is a
# Markdown paragraph to describe
# the reference #1.
#
# Another reference #2.
# @version 0.1.0
# @description
# en: A detail description for this plugin,
# markdown should be supported.
# zh: 插件中文描述。
# 这个插件用于测试。
#
# @main helloworld
# @library ggplot2 tidyverse/dplyr https://gitee.com/ShixiangWang/sigminer
#
# @param data [export::<param-type>::<widget-type>::[<default-value>]]
# en: a table with at least two numeric columns.
# zh: 至少两列的数值的表格。
#
# @param y [export::extra::text-field::[mpg]]
# en: a string represent the column mapping to y axis.
# zh: 一个指示映射到 y 轴的列名
#
# @param zzz 没有采用方括号标记的参数不被解析导出
#
# @return [<result-type>::[<output-format>]]
# en: Result descript in English.
# zh: 结果的中文描述
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
