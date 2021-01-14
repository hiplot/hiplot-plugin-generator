package main

import "fmt"

/*
解析器工作原理：
1. 读入文件
2. 移除无关行
3. 为每一个 tag 创建一个对应的解析函数（类实现？）
4. 解析所有内容并整理输出，为生成 .json 配置提供内容
5. 生成 .json
6. 基于配置和输入文件生成 plot.R
 */

func main()  {
	fmt.Println("Hello world!")
}