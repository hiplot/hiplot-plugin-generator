# Title     : A template served for parser
#             converting comments to hiplot plugin
#             interfaces (ui.json, meta.json, data.json (may be also plot.R))
# Created by: wsx
# Created on: 2021/1/14

# @hiplot start
# @appname test-plugin (the name is converted to plugin slug, only the fisrt word included)
# @apptype vue one of vue and shiny. Shiny 的 main, param, return 等标签都会忽略
# @target basic (where the plugin should be deployed to, only the first word included)
# @status new one of new or a link to the hiplot plugin, e.g., https://hiplot.com.cn/basic/heatmap 用来加速审查
# @author a, b, c
# @maintainer a <a.email>, b, c
# @url xxx.com
# @citation This is a
# Markdown paragraph to describe citation info.
# @version 0.1.0 (a semantic version)
# @description A detail description for this plugin,
# markdown should be supported.
# @description-cn 插件中文描述。
# 支持多行和 Markdown 语法。
#
# @main helloworld the entry of program, only the first world is used.
# @library ggplot2 tidyverse/dplyr https://gitee.com/ShixiangWang/sigminer
#
# @param data [export::<param-type>::<widget-type>::[<default-value>]]
# Pay attention:
#   参数名后接参数接口设定，下一行才开始描述参数。
#   Valid <widget-type> includes select, switch, slider, text-field,
#   (需要补充，特别是数据表以及自动选择表格列名的控件类型（例子：https://hiplot.com.cn/basic/ezcox）)
#   Valid <param-type> includes general, extra, （数据表和其列名选择是否作为一个新的参数类型？）
#   Valid <default-value> depends one the <widget-type>:
#     - for type 'select': string/numeric options separated by comma, e.g., str:a, b, c, num: 1, 1.5, 2
#         example: [export::extra::select::[int: 1, 1.5, 2]]
#     - for type 'switch': TRUE/true or FALSE/false
#     - for type 'slider': start:end:step, e.g., 2:10:1
#     - for type 'text-field': any string, even void, i.e., [export::extra::text-field::[]]
#
# 上面的介绍包括本行都会被纳入参数英文介绍，即 zh: 未出现在行首前的所有内容一同被纳入 en:。
# en: a table with at least two numeric columns.
# zh: 至少两列的数值的表格。（转换为中文参数介绍）
#
# @param y [export::extra::text-field::[mpg]]
# en: a string represent the column mapping to y axis.
# zh: 一个指示映射到 y 轴的列名
#
# @param zzz 没有采用方括号标记的参数不被解析导出
#
# @return [<result-type>::[<output-format>]]
# Pay attention:
#   Valid <result-type> includes ggplot, basic, other (more?)
#   Valid <output-format> includes general, pdf, png, tiff, zip, file, directory.
#         Multiple options are valid.
#         'general' 包含目前 hiplot 插件常见输出选项
#         'file'（单个结果文件）和 'directory'（多个结果文件）用于支持一些工具的输出，像 gistic2 这种
#         使用它们时，主函数需要支持一个结果文件/目录路径设定，使用 hiplot_file/hiplot_outdir
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
helloworld <- function(data, x, y = "mpg") {
  p <- ggplot(data, aes_string(x = x, y = mpg))
  p <- p + geom_point()
  # Here export a ggplot object
  return(p)
}
