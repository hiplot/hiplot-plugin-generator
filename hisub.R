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
library(purrr)

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
tag_name <- map_chr(tag_list, ~sub("# *@([^ ]+).*", "\\1", .[1]))

parse_tag_name <- function(x) sub("# *@[^ ]+ +([^ ]+).*", "\\1", x[1])
parse_tag_header <- function(x) sub("# *@[^ ]+ +", "", x[1])
parse_tag_appname <- function(x) {
  list(type = "appname", value = parse_tag_name(x))
}
parse_tag_apptype <- function(x) {
  list(type = "apptype", value = parse_tag_name(x))
}
parse_tag_target <- function(x) {
  list(type = "target", value = parse_tag_name(x))
}
parse_tag_status <- function(x) {
  list(type = "status", value = parse_tag_name(x))
}
parse_tag_author <- function(x) {
  list(type = "author", value = parse_tag_header(x))
}
parse_tag_maintainer <- function(x) {
  list(type = "author", value = parse_tag_header(x))
}
parse_tag_url <- function(x) {
  value = parse_tag_header(x)
  if (sub(" ", "", value) == "NULL") {
    value = NULL
  }
  list(type = "url", value = value)
}
parse_tag_citation <- function(x) {

}
parse_tag_version <- function(x) {
  list(type = "version", value = parse_tag_name(x))
}
parse_tag_description <- function(x) {}
parse_tag_main <- function(x) {
  list(type = "main", value = parse_tag_name(x))
}
parse_tag_library <- function(x) {}
parse_tag_param <- function(x) {}
parse_tag_return <- function(x) {}
parse_tag_data <- function(x) {}

parse_tag <- function(x, name) {
  switch(
    name,
    appname = parse_tag_appname(x),
    apptype = parse_tag_apptype(x),
    target = parse_tag_target(x),
    status = parse_tag_status(x),
    author = parse_tag_author(x),
    maintainer = parse_tag_maintainer(x),
    url = parse_tag_url(x),
    citation = parse_tag_citation(x),
    version = parse_tag_version(x),
    description = parse_tag_description(x),
    main = parse_tag_main(x),
    library = parse_tag_library(x),
    param = parse_tag_param(x),
    return = parse_tag_return(x),
    data = parse_tag_data(x))
}

content_list <- map2(tag_list, tag_name, parse_tag)
