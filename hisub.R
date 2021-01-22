# Hiplot 插件提交器
# @Copyright 2021 Hiplot team
# 工作原理：
# 1. 读入文件
# 2. 移除无关行
# 3. 为每一个 tag 创建一个对应的解析函数
# 4. 解析所有内容并整理输出，为生成 .json 配置提供内容
# 5. 生成 .json (data.json, meta.json, ui.json)
# 6. 基于配置和输入文件生成 plot.R

library(readr)
library(dplyr)

file_content <- read_lines("test_parser.R")

# 过滤无关行
file_content <- file_content[startsWith(file_content, "#")]
file_content <- file_content[
  (grep("# *@hiplot +start", file_content)+1):(grep("# *@hiplot +end", file_content)-1)]

# 分隔标签内容
# src: https://stackoverflow.com/questions/16357962/r-split-numeric-vector-at-position
splitAt <- function(x, pos) unname(split(x, cumsum(seq_along(x) %in% pos)))

tag_list <- splitAt(file_content, grep("# *@", file_content))

# 针对每一个元素解析标签和内容
