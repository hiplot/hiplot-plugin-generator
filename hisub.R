#!/usr/bin/env Rscript
# Hiplot 插件提交器
# Copyright @ 2021 Hiplot team
# 工作原理：
# 1. 读入文件
# 2. 移除无关行
# 3. 为每一个 tag 创建一个对应的解析函数
# 4. 解析所有内容并整理输出，为生成 .json 配置提供内容
# 5. 生成 .json (data.json, meta.json, ui.json)
# 6. 基于配置和输入文件生成 plot.R
#
# Test: ./hisub.R test_ezcox.R ezcox

suppressMessages(library(readr))
suppressMessages(library(dplyr))
suppressMessages(library(purrr))
suppressMessages(library(jsonlite))
suppressMessages(library(styler))

Args <- commandArgs(trailingOnly = TRUE)
# Args <- c("test.R", "test-plugin2")

# 如果传入的不是 2 个参数，中间的文件原样拷贝到插件目录以支持
# 已准备好的数据文件或其他所需脚本
fc <- file_content <- read_lines(Args[1])
if (length(Args) > 2) {
  outdir <- Args[length(Args)]
  flag <- TRUE
} else {
  outdir <- Args[2]
  flag <- FALSE
}

dir.create(outdir, recursive = TRUE)
if (flag) {
  file.copy(Args[2:(length(Args) - 1)], outdir)
}
# Preprocessing -----------------------------------------------------------

# 过滤无关行
file_content <- file_content[startsWith(file_content, "#")]
file_content <- file_content[
  (grep("# *@hiplot +start", file_content) + 1):(grep("# *@hiplot +end", file_content) - 1)
]

# 分隔标签内容
# src: https://stackoverflow.com/questions/16357962/r-split-numeric-vector-at-position
splitAt <- function(x, pos) unname(split(x, cumsum(seq_along(x) %in% pos)))

tag_list <- splitAt(file_content, grep("# *@", file_content))

# Parsing content ---------------------------------------------------------

# 针对每一个元素解析标签和内容
tag_name <- map_chr(tag_list, ~ sub("# *@([^ ]+).*", "\\1", .[1]))

parse_tag_value <- function(x) sub("# *@[^ ]+ +([^ ]+).*", "\\1", x[1])
parse_tag_header <- function(x) sub("# *@[^ ]+ +", "", x[1])
parse_tag_appname <- function(x) {
  list(type = "appname", value = parse_tag_value(x))
}
parse_tag_apptitle <- function(x) {
  list(
    type = "apptitle",
    value = list(
      en = trimws(sub("^# *", "", x[2])),
      zh = trimws(sub("^# *", "", x[3]))
    )
  )
}
parse_tag_target <- function(x) {
  list(type = "target", value = parse_tag_value(x))
}

parse_tag_release <- function(x) {
  list(type = "release", value = parse_tag_value(x))
}

parse_tag_tag <- function(x) {
  list(type = "tag", value = unlist(strsplit(parse_tag_header(x), split = " ")))
}
parse_tag_author <- function(x) {
  list(type = "author", value = parse_tag_header(x))
}
parse_tag_email <- function(x) {
  list(type = "email", value = parse_tag_header(x))
}
parse_tag_url <- function(x) {
  value <- parse_tag_header(x)
  if (sub(" ", "", value) == "NULL") {
    value <- NULL
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
  x <- paste(x[x != ""], collapse = "\n")
  message("\nCitation info parsed.")
  cat(x)
  list(type = "citation", value = x)
}

parse_doc <- function(x) {
  if (length(x) > 1) {
    x <- sub("^# *$", "\n", x)
    x <- sub("^# *", "", x)
  }
  x <- x[x != ""]
  idx_en <- grep("^en:", x)
  idx_zh <- grep("^zh:", x)

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
      x_en <- gsub("en: *", "", paste(x[1:(idx_zh - 1)], collapse = " "))
      x_zh <- gsub("zh: *", "", paste(x[idx_zh:length(x)], collapse = " "))
    } else {
      x_zh <- gsub("zh: *", "", paste(x[1:(idx_en - 1)], collapse = " "))
      x_en <- gsub("en: *", "", paste(x[idx_en:length(x)], collapse = " "))
    }
  } else {
    # Only Chinese available
    x <- gsub("zh: *", "", x)
    x_zh <- paste(x, collapse = " ")
    x_en <- ""
  }
  list(
    en = trimws(x_en, "right"),
    zh = trimws(x_zh, "right")
  )
}

parse_tag_description <- function(x) {
  x[1] <- parse_tag_header(x[1])
  if (startsWith(x[1], "#")) x[1] <- ""

  doc_list <- parse_doc(x)
  x_en <- doc_list$en
  x_zh <- doc_list$zh

  message("\nDescription info parsed.")
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
  message("\nRequired packages parsed.")
  cat(x)
  list(type = "library", value = x)
}

parse_tag_param <- function(x) {
  param_name <- parse_tag_value(x[1])
  if (!grepl("export::", x[1])) {
    message("\nNo export detected.")
    return(NULL) # No returns
  }

  header <- trimws(parse_tag_header(x[1]))
  header <- sub("^.*export::", "", header)
  header <- unlist(strsplit(header, "::"))

  doc_list <- parse_doc(x[-1])
  doc_list <- map(doc_list, ~ sub("  ", "", sub("\n", "", .)))

  list(
    type = "param",
    value = list(
      param_type = header[1],
      param_name = param_name,
      widget_type = header[2],
      default_value = jsonlite::fromJSON(header[3]),
      en = doc_list$en,
      zh = doc_list$zh
    )
  )
}

parse_tag_return <- function(x) {
  if (!grepl("::", x[1])) {
    return(list(
      type = "return",
      value = NULL
    ))
  }
  header <- trimws(parse_tag_header(x[1]))
  header <- unlist(strsplit(header, "::"))
  outfmt <- jsonlite::fromJSON(header[2])

  doc_list <- parse_doc(x[-1])
  list(
    type = "return",
    value = list(
      outtype = header[1],
      outfmt = outfmt,
      outsetting = jsonlite::fromJSON(header[3]),
      en = doc_list$en,
      zh = doc_list$zh
    )
  )
}

parse_tag_data <- function(x) {
  x <- sub("^# *", "", x)
  x <- x[!grepl("^@|#", x)]
  x <- paste(x, collapse = "\n")
  message("\nCode to generate data parsed.")
  cat(x)
  list(type = "data", value = x)
}

parse_tag <- function(x, name) {
  switch(
    name,
    appname = parse_tag_appname(x),
    apptitle = parse_tag_apptitle(x),
    target = parse_tag_target(x),
    tag = parse_tag_tag(x),
    author = parse_tag_author(x),
    email = parse_tag_email(x),
    url = parse_tag_url(x),
    citation = parse_tag_citation(x),
    version = parse_tag_version(x),
    release = parse_tag_release(x),
    description = parse_tag_description(x),
    main = parse_tag_main(x),
    library = parse_tag_library(x),
    param = parse_tag_param(x),
    return = parse_tag_return(x),
    data = parse_tag_data(x)
  )
}

a <- map2(tag_list, tag_name, parse_tag)
names(a) <- tag_name
a <- compact(a)

# 注意有多个参数在 names 中同名
# print(jsonlite::toJSON(a, auto_unbox = TRUE, pretty = TRUE))


# Generate data files -----------------------------------------------------

if ("data" %in% names(a)) {
  message("Generating data file...")
  old_wd <- getwd()
  setwd(outdir)
  eval(parse(text = a$data$value))
  setwd(old_wd)
}

# Generate plugin files ---------------------------------------------------
# 标签、参数、控件的设定匹配和设定有难度

message("Generating plugin files...")
# 参数的收集！参数对应的 ui 控件！
set_widget <- function(w) {
  c(list(
    type = w$widget_type,
    label = list(
      en = w$en,
      zh_cn = w$zh
    )
  ), w$default_value[!names(w$default_value) %in% "default"])
}

set_widget_dataArg <- function(w) {
  c(list(
    label = list(
      en = w$en,
      zh_cn = w$zh
    )
  ), w$default_value[!names(w$default_value) %in% "default"])
}

drop_names <- function(x) {
  for (i in seq_along(x)) {
    names(x[[i]]) <- NULL
  }
  x
}

collect_params <- function(x) {
  all_args <- x[names(x) == "param"]
  # 根据参数类型和控件类型生成 data.json 和 ui.json 所需数据
  # 参数类型：data, dataArg(暂时不实现),
  # general(通过return实现，以避免设置函数参数，只设定主题和图片大小), extra
  # 这里实现 data 和 extra 即可
  # 控件类型：hiplot-textarea, select, switch, slider, text-field, ...

  # data.json 需要生成的是默认参数值
  # 一处在 params 里，一处在 exampleData 里
  #
  # ui.json 需要生成的是参数的 ui 配置信息

  params_textarea <- list()
  params_dataArg <- list()
  params_extra <- list()
  example_textarea <- list()
  example_dataArg <- list()
  # example_extra <- list()
  ui_data <- list()
  ui_dataArg <- list()
  ui_extra <- list()

  # 为数据表添加前缀，对应的 dataArg 也需要更改
  j <- 1
  for (i in seq_along(all_args)) {
    if (all_args[[i]]$value$param_type == "data") {
      for (k in seq_along(all_args)) {
        # widget_type
        if (all_args[[k]]$value$param_type == "dataArg") {
          if (all_args[[k]]$value$widget_type == all_args[[i]]$value$param_name) {
            all_args[[k]]$value$widget_type <- paste0(j, "-", all_args[[i]]$value$param_name)
          }
        }
      }
      all_args[[i]]$value$param_name <- paste0(j, "-", all_args[[i]]$value$param_name)
      j <- j + 1
    }
  }

  map(all_args, function(y) {
    y <- y$value
    if (y$param_type == "data") {
      params_textarea[[y$param_name]] <<- ""
      if (!is.null(y$default_value$default)) {
        example_textarea[[y$param_name]] <<- paste(read_lines(file.path(outdir, y$default_value$default)), collapse = "\n")
      }
      ui_data[[y$param_name]] <<- set_widget(y)
    } else if (y$param_type == "extra") {
      params_extra[[y$param_name]] <<- y$default_value$default
      ui_extra[[y$param_name]] <<- set_widget(y)
    } else if (y$param_type == "dataArg") {
      params_dataArg[[y$widget_type]][[y$param_name]][["value"]] <<- list()
      example_dataArg[[y$widget_type]][[y$param_name]][["value"]] <<- if (is.null(y$default_value$default)) {
        list()
      } else {
        y$default_value$default
      }
      ui_dataArg[[y$widget_type]][[y$param_name]] <<- set_widget_dataArg(y)
    }
    NULL
  })

  # example_dataArg 和 ui_dataArg 可能需要排序
  for (i in names(ui_dataArg)) {
    iord <- order(map_int(ui_dataArg[[i]], "index"))
    ui_dataArg[[i]] <- ui_dataArg[[i]][iord]
    for (j in seq_along(ui_dataArg[[i]])) {
      ui_dataArg[[i]][[j]]$index <- NULL
    }

    if (i %in% names(example_dataArg)) {
      example_dataArg[[i]] <- example_dataArg[[i]][iord]
    }
  }

  list(
    params_textarea = params_textarea,
    params_dataArg = drop_names(params_dataArg),
    params_extra = params_extra,
    example_textarea = example_textarea,
    example_dataArg = drop_names(example_dataArg),
    ui_data = ui_data,
    ui_dataArg = drop_names(ui_dataArg),
    ui_extra = ui_extra
  )
}

a$params <- collect_params(a)
# toJSON(list(list(value= list()), list(value=list())), auto_unbox = T)

# meta.json
# Metadata for the plugin
json_meta <- list(
  name = list(zh_cn = a$apptitle$value$zh, en = a$apptitle$value$en),
  intro = list(zh_cn = a$description$value$zh, en = a$description$value$en),
  src = "",
  href = paste0("/", a$target$value, "/", a$appname$value),
  tag = c("vue", a$tag$value),
  meta = list(
    score = 3, # default score, change by team member after accept
    author = a$author$value,
    email = a$email$value,
    issues = a$url$value,
    releaseDate = if ("release" %in% names(a)) {
      a$release$value
    } else {
      as.character(Sys.Date())
    },
    updateDate = as.character(Sys.Date()),
    citation = a$citation$value
  )
)

message("  meta.json")
# jsonlite::toJSON(json_meta, auto_unbox = TRUE, pretty = TRUE)
write_json(json_meta, file.path(outdir, "meta.json"), auto_unbox = TRUE, pretty = TRUE)

# data.json
json_data <- list(
  module = a$target$value,
  tool = a$appname$value,
  params = list(
    # Multiple dataTable assigned to data, data2, data3, ... in plot.R
    textarea = a$params$params_textarea,
    config = list(
      dataArg = a$params$params_dataArg,
      # data = list(),
      general = c(
        list(
          cmd = "",
          imageExportType = a$return$value$outfmt,
          size = list(
            width = a$return$value$outsetting$width,
            height = a$return$value$outsetting$height
          ),
          theme = if (!is.null(a$return$value$outsetting$theme_support)) {
            if (a$return$value$outsetting$theme_support) {
              a$return$value$outsetting$theme_default
            } else {
              NULL
            }
          } else {
            NULL
          }
        ),
        a$return$value$outsetting[!names(a$return$value$outsetting) %in% c("width", "height", "theme_support", "theme_default")]
      ),
      # Common extra parameter setting
      extra = a$params$params_extra
    )
  ),
  exampleData = list(
    config = list(
      # data = list(),
      # general = list(),
      # extra = list()
      dataArg = a$params$example_dataArg
    ),
    textarea = a$params$example_textarea
  )
)

message("  data.json")
# jsonlite::toJSON(json_data, auto_unbox = TRUE, pretty = TRUE)
write_json(json_data, file.path(outdir, "data.json"),
  null = "list", auto_unbox = TRUE, pretty = TRUE
)

# ui.json

json_ui <- list(
  data = a$params$ui_data,
  dataArg = a$params$ui_dataArg,
  # general = list(
  #
  # ),
  extra = a$params$ui_extra
)

message("  ui.json")
# json_ui <- jsonlite::toJSON(json_ui, auto_unbox = TRUE, pretty = TRUE)
write_json(json_ui, file.path(outdir, "ui.json"),
  null = "list", auto_unbox = TRUE, pretty = TRUE
)

# plot.R
# 保留输入脚本
message("  source.R")
write_lines(fc, file.path(outdir, "source.R"))
# 生成 plot.R 进行调用
args_pairs <- map(
  a[names(a) == "param"],
  ~ c(
    .$value$param_type,
    .$value$param_name,
    .$value$widget_type,
    .$value$default_value$index
  )
)

# 确定 data 的匹配
# 如果开发时数据表使用 data, data2, data3 没有问题
# 但如果用户自定义数据表名，这里只能
# 按顺序生成给 data, data2, ...
# !!后续文档要描述该情况，推荐按函数设定顺序写参数说明
data_idx <- 1
args_pairs2 <- c()
for (i in seq_along(args_pairs)) {
  if (args_pairs[[i]][1] == "data") {
    if (data_idx == 1) {
      z <- paste(args_pairs[[i]][1], "= data, ")
    } else {
      z <- paste(args_pairs[[i]][1], "=", paste0("data", data_idx, ","))
    }

    # 补充对应的 dataArg
    idx <- map_chr(args_pairs, 1) == "dataArg" & map_chr(args_pairs, 3) == args_pairs[[i]][2]
    if (any(idx)) {
      z2 <- paste(
        map_chr(args_pairs[idx], 2), "=",
        paste0(
          "conf$dataArg[[",
          data_idx, "]][[",
          map_chr(args_pairs[idx], 4),
          "]]$value,"
        )
      )
      z <- c(z, z2)
    }

    data_idx <- data_idx + 1
  } else if (args_pairs[[i]][1] == "extra") {
    z <- paste(args_pairs[[i]][2], "=", paste0("conf$extra$", args_pairs[[i]][2], ","))
  } else {
    z <- c()
  }
  args_pairs2 <- c(args_pairs2, z)
}
args_pairs2[length(args_pairs2)] <- sub(",", "", args_pairs2[length(args_pairs2)])

plot_r <- c(
  'source("source.R")\n',
  paste(
    paste0(a$main$value, "("),
    paste(args_pairs2, collapse = "\n"),
    ")",
    sep = "\n"
  )
)

# 处理非 ggplot 图
if (a$return$value$outtype %in% c("plot", "basic", "grid")) {
  plot_r[2] <- paste(
    "as.ggplot(~",
    plot_r[2],
    ")",
    sep = ""
  )
}

# 增加对图片的配置
if (a$return$value$outtype %in% c("ggplot", "plot", "basic", "grid")) {
  plot_r <- c(
    plot_r,
    "\nexport_single(p, opt, conf)"
  )
}

message("  plot.R")
write_lines(plot_r, file.path(outdir, "plot.R"))
style_file(file.path(outdir, "plot.R"))

# Rscript /Users/wsx/Documents/GitHub/scripts-basic/r/run_debug.R -c test-plugin/data.json -i test-plugin/data.txt -o test-plugin/test -t test-plugin --enableExample
