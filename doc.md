# Hiplot Vue 插件生成器文档

## 介绍

## 标签列表

标签以 `@` 开始，后面紧接着标签名，空格后的内容为标签参数。

- `@hiplot` - 1 行，后面接 `start` 和 `end` 用来表示插件注释的起始和结束位置。
- `@appname` - 1 行，你的插件名字，显示为 Hiplot 网站 URL 最后一栏名字，例如 `diy-gsea` 对应到 <https://hiplot.com.cn/basic/diy-gsea>。插件名使用小写字母和数字的组合，如果要组合不同的单词请使用短斜线`-`。
- `@alias` - 1行，你的插件的别名，显示在插件右侧边栏，**一般**使用首字母大写英文词，词中间使用短杠连接，例如：`Area-Chart`。当没有指定时，默认使用`@appname`指定的名字。
- `@apptitle` - 3 行，你的插件标题，一句话介绍你的插件。 输入 `@apptitle` 后重新起始一行开始输入文字。
  - 第 2 行设置英文标题。
  - 第 3 行设置中文标题。
- `@target` - 1 行，设置插件目标分类。Hiplot 网站左侧菜单栏对插件有一些大的目标分类，包括 `basic`、`advance`、`clinical-tools` 等，例如上面的 `https://hiplot.com.cn/basic/diy-gsea` 就是对应基础分类 `basic`。 `@target` 和 `@appname` 2 个标签共同组成了你开发插件的子域名（注意，不能和已发布的插件同名）。
- `@tag` - 1 行，设置插件的（功能性）英文标签，用空格分隔。 例如 `heatmap clustering GSEA`。
- `@author` - 1 行，你的名字。
- `@url` - （可选）1 行，你的插件项目地址，一般是 GitHub 仓库，当然也可以设置为你的个人介绍等其他页面。
- `@citation` - （可选）多行，你插件的参考文献或者其他人该如何引用该插件。支持 Markdown 语法渲染。
- `@version` - 1 行，该插件的版本号，一般使用语义版本号，以 0.1 起始，后续可以更新为 0.2、0.3 等等。
- `@release` - 1 行，该插件的发布日期。 
- `@description` - 多行，一段话简要介绍你的插件。另起一行按下面的格式输入内容：
  - 对于英文介绍，以 `en:` 作为一段话的起始。
  - 对于中文介绍，以 `zh:` 作为一段话的起始。
- `@main` - 1 行，用来调用绘图（或者其他处理）的主函数名称，如 README 示例中的 `helloworld`。
- `@library` - 1 行，运行你的插件所需要的 R 包依赖（其他依赖也可以），主要方便 Hiplot 的审查人员查看和确认是否安装好了相应的依赖，以及以后插件出问题后可能的复查。 
- `@param` - 多行，设定主函数参数对应的前端控件和参数的说明文档。从第 2 行开始，它的用法与 `@description` 相同，用于参数说明。而对于第 1 行，它有如下的规则：
  - `<param_name> export::<param-type>::<widget-type>::<param_setting>`
  - `param_name` 用于描述主函数的参数名字。
  - `param-type` 设定参数的前端数据类型，可以是 `data`（对应用户的输入）、`dataArg`（如果用户需要输入一个数据表，则用于对应数据表格中的某一列名）和 `extra`（主函数中的其他自定义参数）。
  - `widget-type` 设定前端展示的控件，可以是 `hiplot-textarea`（对应数据表），`slider`、`switch`、`select`、 `autocomplete`、`color-picker`、`text-field` 等，具体查看本文档**Vue 控件类型**一节。
  - `param_setting` 设定控件的参数，使用 JSON 格式，参数根据不同的 `widget-type` 而有所不同。在大多数情况中，我们对控件参数增加了一个统一的 `default` 元素用于设定默认的控件参数值，其他的全部参数都会直接传到前端控件中，即**Vue 控件类型**一节介绍的内容。
- `@return` - 1 行，它遵循如下规则：
  - `<output-type>::<output-format>::<output-setting>`
  - `output-type` 可以是 `ggplot`、`plot`（对应非 ggplot2 生成的图，一般指 base 包生成的图）和 `directory`（输出是一个目录，而不是单纯的图形，这可以用来支持一切软件的输出）。
  - `output-format` 使用 JSON 格式，用来设定输出图片的格式，包括 PDF、PNG 等。
  - `output-setting` 使用 JSON 格式，对应 Hiplot 插件通用的参数，它不需要开发者自己在主函数中进行设定，这些通用参数一般是为 ggplot2 图服务的，包括 `title`、`palette`、`theme`、`width` 和 `height`。另外有一个 `cliMode` 参数，建议设定为 `true`，它用于为简单的插件加速在 Hiplot 中的调用。
- `@data` - （可选）多行，它用于编写生成示例数据的代码，生成的数据文件一般与数据表的默认参数值对应，请阅读 helloworld 中的相应示例。

## 通用参数

一般是为 ggplot2 设定的
## Vue 控件类型

`<param-type>::<widget-type>::<param_setting>`

vue 控件类型和常用参数

## 全局变量

conf 和 opt 这两个全局变量