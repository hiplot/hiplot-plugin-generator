#######################################################
# Copyright (C) 2020 by Hiplot Team                   #
# All rights reserved.                                #
#######################################################

pacman::p_load(PCAtools)

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
call_pcatools <- function(datTable, sampleInfo,
                          top_var,
                          screeplotComponents, screeplotColBar,
                          pairsplotComponents,
                          biplotShapeBy, biplotColBy,
                          plotloadingsComponents,
                          plotloadingsLowCol,
                          plotloadingsMidCol,
                          plotloadingsHighCol,
                          eigencorplotMetavars,
                          eigencorplotComponents) {
  row.names(datTable) <- datTable[,1]
  datTable <- datTable[,-1]
  row.names(sampleInfo) <- sampleInfo[,1]
  sampleInfo <- sampleInfo[,-1]
  data3 <- pca(datTable, metadata = sampleInfo, removeVar = (100 - top_var) / 100)

  p1 <- PCAtools::screeplot(
    data3, components = getComponents(data3, 1:screeplotComponents),
    axisLabSize = 14, titleLabSize = 20,
    colBar = screeplotColBar,
    gridlines.major = FALSE, gridlines.minor = FALSE,
    returnPlot = TRUE)

  p2 <- PCAtools::pairsplot(
    data3, components = getComponents(data3, c(1:pairsplotComponents)),
    triangle = TRUE, trianglelabSize = 12,
    hline = 0, vline = 0,
    pointSize = 0.8, gridlines.major = FALSE, gridlines.minor = FALSE,
    colby = 'Grade',
    title = '', plotaxes = FALSE,
    margingaps = unit(c(0.01, 0.01, 0.01, 0.01), 'cm'),
    returnPlot = TRUE,
    colkey = get_hiplot_color(conf$general$palette, -1,
                              conf$general$palette_custom)) #!!

  params_biplot <- list(data3,
                        showLoadings = TRUE,
                        lengthLoadingsArrowsFactor = 1.5,
                        sizeLoadingsNames = 4,
                        colLoadingsNames = 'red4',
                        # other parameters
                        lab = NULL,
                        hline = 0, vline = c(-25, 0, 25),
                        vlineType = c('dotdash', 'solid', 'dashed'),
                        gridlines.major = FALSE, gridlines.minor = FALSE,
                        pointSize = 5,
                        legendPosition = 'none', legendLabSize = 16, legendIconSize = 8.0,
                        drawConnectors = FALSE,
                        title = 'PCA bi-plot',
                        subtitle = 'PC1 versus PC2',
                        caption = '27 PCs ≈ 80%',
                        returnPlot = TRUE)
  if (!is.null(biplotShapeBy) &&  biplotShapeBy != "") {
    params_biplot$shape <- biplotShapeBy
  }
  if (!is.null(biplotColBy) && biplotColBy != "") {
    params_biplot$colby <- biplotColBy
    params_biplot$colkey <- get_hiplot_color(conf$general$palette, -1,
                                             conf$general$palette_custom) #!!
  }

  p3 <- do.call(PCAtools::biplot, params_biplot)

  p4 <- PCAtools::plotloadings(
    data3, rangeRetain = 0.01, labSize = 4,
    components = getComponents(data3, c(1:plotloadingsComponents)),
    title = 'Loadings plot', axisLabSize = 12,
    subtitle = 'PC1, PC2, PC3, PC4, PC5',
    caption = 'Top 1% variables',
    gridlines.major = FALSE, gridlines.minor = FALSE,
    shape = 24, shapeSizeRange = c(4, 8),
    col = c(plotloadingsLowCol, plotloadingsMidCol, plotloadingsHighCol),
    legendPosition = 'none',
    drawConnectors = FALSE,
    returnPlot = TRUE)

  eigencorplotMetavars <- unlist(eigencorplotMetavars)
  if (length(eigencorplotMetavars) > 0) {
    metavars <- eigencorplotMetavars
  } else {
    metavars <- colnames(sampleInfo)[2:ncol(sampleInfo)]
  }
  p5 <- PCAtools::eigencorplot(
    data3,
    components = getComponents(data3, 1:eigencorplotComponents),
    metavars = metavars,
    cexCorval = 1.0,
    fontCorval = 2,
    posLab = 'all',
    rotLabX = 45,
    scale = TRUE,
    main = "PC clinical correlates",
    cexMain = 1.5,
    plotRsquared = FALSE,
    corFUN = 'pearson',
    corUSE = 'pairwise.complete.obs',
    signifSymbols = c('****', '***', '**', '*', ''),
    signifCutpoints = c(0, 0.0001, 0.001, 0.01, 0.05, 1),
    returnPlot = TRUE)

  p6 <- plot_grid(
    p1, p2, p3,
    ncol = 3,
    labels = c('A', 'B  Pairs plot', 'C'),
    label_fontfamily = 'serif',
    label_fontface = 'bold',
    label_size = 22,
    align = 'h',
    rel_widths = c(1.10, 0.80, 1.10))

  p7 <- plot_grid(
    p4,
    as.grob(p5),
    ncol = 2,
    labels = c('D', 'E'),
    label_fontfamily = 'serif',
    label_fontface = 'bold',
    label_size = 22,
    align = 'h',
    rel_widths = c(0.8, 1.2))

  p <- plot_grid(
    p6, p7,
    ncol = 1,
    rel_heights = c(1.1, 0.9))

  out_xlsx <- paste(opt$outputFilePrefix, ".xlsx", sep = "")
  write.xlsx(as.data.frame(data3$rotated), out_xlsx, row.names = TRUE)

  return(p)
}
