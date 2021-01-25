# Hiplot 插件提交器
# Copyright @ 2021 Hiplot team
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

parse_tag_value <- function(x) sub("# *@[^ ]+ +([^ ]+).*", "\\1", x[1])
parse_tag_header <- function(x) sub("# *@[^ ]+ +", "", x[1])
parse_tag_appname <- function(x) {
  list(type = "appname", value = parse_tag_value(x))
}
parse_tag_apptype <- function(x) {
  list(type = "apptype", value = parse_tag_value(x))
}
parse_tag_target <- function(x) {
  list(type = "target", value = parse_tag_value(x))
}
parse_tag_status <- function(x) {
  list(type = "status", value = parse_tag_value(x))
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

parse_tag_version <- function(x) {
  list(type = "version", value = parse_tag_value(x))
}
parse_tag_citation <- function(x) {
  x[1] <- parse_tag_header(x[1])
  if (startsWith(x[1], "#")) x[1] <- ""
  if (length(x) > 1) {
    x[-1] <- sub("^# *$", "\n", x[-1])
    x[-1] <- sub("^# *", "", x[-1])
  }
  x <- paste(x[x != ""], collapse = " ")
  message("Citation info parsed.")
  cat(x)
  list(type = "citation", value = x)
}

parse_tag_description <- function(x) {
  x[1] <- parse_tag_header(x[1])
  if (startsWith(x[1], "#")) x[1] <- ""
  if (length(x) > 1) {
    x[-1] <- sub("^# *$", "\n", x[-1])
    x[-1] <- sub("^# *", "", x[-1])
  }
  x <- x[x != ""]
  idx_en <- grep("en:", x)
  idx_zh <- grep("zh:", x)

  if (length(idx_zh) == 0) {
    # ALL records are in English
    if (length(idx_en) > 0) {
      x <- gsub("en: *", "", x)
    }
    x_en <- paste(x, collapse = " ")
    x_zh <- ""
  } else if (length(idx_en) > 0) {
    # Both English and Chinese available
    if (idx_en < idx_zh) {
      x_en <- gsub("en: *", "", paste(x[1:(idx_zh-1)], collapse = " "))
      x_zh <- gsub("zh: *", "", paste(x[idx_zh:length(x)], collapse = " "))
    } else {
      x_zh <- gsub("zh: *", "", paste(x[1:(idx_en-1)], collapse = " "))
      x_en <- gsub("en: *", "", paste(x[idx_en:length(x)], collapse = " "))
    }

  } else {
    # Only Chinese available
    x <- gsub("zh: *", "", x)
    x_zh <- paste(x, collapse = " ")
    x_en <- ""
  }

  message("Description info parsed.")
  message("en:")
  cat(x_en)
  message("\nzh:")
  cat(x_zh)
  list(type = "description", value = list(
    en = x_en,
    zh = x_zh
  ))
}

parse_tag_main <- function(x) {
  list(type = "main", value = parse_tag_value(x))
}
parse_tag_library <- function(x) {
  x[1] <- parse_tag_header(x[1])
  if (length(x) > 1) {
    x[-1] <- sub("^#", "", x[-1])
  }
  x <- paste(x, collapse = " ")
  x <- unlist(strsplit(x, split = " "))
  message("Required packages parsed.")
  cat(x)
  list(type = "library", value = x)
}

parse_tag_param <- function(x) {}
parse_tag_return <- function(x) {}
parse_tag_data <- function(x) {
  x <- sub("^# *", "", x)
  x <- x[!grepl("^@|#", x)]
  x <- paste(x, collapse = "\n")
  message("Code to generate data parsed.")
  cat(x)
  list(type = "data", value = x)
}

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


