#######################################################
# Easy cox analysis and visualization.                #
#-----------------------------------------------------#
# Author: Shixiang Wang                               #
#                                                     #
# Date: 2020-08-10                                    #
# Version: 0.1                                        #
#######################################################
#                    CAUTION                          #
#-----------------------------------------------------#
# Copyright (C) 2020 by Hiplot Team                   #
# All rights reserved.                                #
#######################################################

pacman::p_load(ezcox)

############# Section 1 ##########################
# input options, data and configuration section
##################################################
{
  # check data
  # check data columns
  if (ncol(data) < 3) {
    stop("Input data should have at least 3 columns!")
  }

  if (!all(c("time", "status") %in% colnames(data))) {
    cat("WARN: 'time' and 'status' colnames not exist in input data.",
        sep = "\n")
    cat("WARN: rename the first and the second column as 'time' and 'status'.",
        sep = "\n")
    colnames(data)[1:2] <- c("time", "status")
  }


  data$time <- as.numeric(data$time)
  data$status <- as.integer(data$status) # Can only be 0 or 1 here

  covariates <- unlist(conf$dataArg[[1]][[1]]$value)
  controls <- unlist(conf$dataArg[[1]][[2]]$value)
  vars_to_show <- unlist(conf$dataArg[[1]][[3]]$value)
  # 协变量
  if (covariates == "" || is.null(covariates)) {
    covariates <- setdiff(colnames(data), c("time", "status"))
  } else {
    covariates <- gsub(" ", "", unlist(strsplit(covariates, split = ",")))
  }

  # 控制变量
  if (controls == "" || is.null(controls)) {
    controls <- NULL
  } else {
    controls <- gsub(" ", "", unlist(strsplit(controls, split = ",")))
  }

  # 结果图显示变量
  if (vars_to_show == "" || is.null(vars_to_show)) {
    vars_to_show <- NULL
  } else {
    vars_to_show <- gsub(" ", "", unlist(strsplit(vars_to_show, split = ",")))
  }

  # logical values: TRUE or FALSE

  # 结果图合并模型：默认 FALSE
  merge_models <- conf$extra$merge_models
  # 结果图去除控制变量：默认 FALSE
  drop_controls <- conf$extra$drop_controls
  # 结果图添加 caption：默认 TRUE
  add_caption <- conf$extra$add_caption
}

############# Section 2 #############
#           plot section
#####################################

# https://shixiangwang.github.io/ezcox/reference/show_forest.html
p <- ezcox::show_forest(
  data = data,
  covariates = covariates,
  controls = controls,
  merge_models = merge_models,
  vars_to_show = vars_to_show,
  drop_controls = drop_controls,
  add_caption = add_caption
)

############# Section 3 #############
#          output section
#####################################
{
  export_single(p, opt, conf)
}

