## iAppTrim

背景

在iOS包体大小的优化工作中，有些工作经常需要手动去逐个更改，操作存在一定的繁琐。

比如在业务迭代的过程中，经常会添加新的png图片，但这些图片未必是最小化的，后期也可能会对它们进行压缩。

再如编译配置项，有时候配置项会被误改，或者因为Xcode的升级带来了新的可优化包体大小的配置项，我们就需要去项目中找到并进行修改。

iAppTrim

针对这些手动操作的优化包体大小方法，我们设计了iAppTrim这一款Mac App，只需要打开App，选择需要优化的项目，即可一键自动优化。
https://github.com/DSAppTeam/iAppTrim/blob/main/ReadMeSource/包大小配置示例.png
https://github.com/DSAppTeam/iAppTrim/blob/main/ReadMeSource/编译速度.png
https://github.com/DSAppTeam/iAppTrim/blob/main/ReadMeSource/是否存在图片检测示例.png
https://github.com/DSAppTeam/iAppTrim/blob/main/ReadMeSource/压缩图片示例.png
https://github.com/DSAppTeam/iAppTrim/blob/main/ReadMeSource/重复图片检测不存在示例.png
https://github.com/DSAppTeam/iAppTrim/blob/main/ReadMeSource/重复图片检测示例.png
<img src="https://github.com/DSAppTeam/iAppTrim/blob/main/ReadMeSource/App首页示例.png" width = "360" height = "790"/>
![App首页示例.png](https://github.com/DSAppTeam/iAppTrim/blob/main/ReadMeSource/App首页示例.png)


目前主要支持以下功能：

（1）项目配置项优化

       主要是针对一些优化配置，比如LLVM_LTO、SWIFT_OPTIMIZATION_LEVEL等，会自动使用xcodeproj工具检测后进行更改。



（2）png图片批量压缩

       这里是通过使用Swift Process执行node.js，上传png图片到tinypng进行压缩后替换原文件。

       建议先安装homebrew再执行，执行时会自动检测和安装node，如执行失败，请根据提示进行操作。



（3）重复png图片检测，用于删除多余重复的图片，使用Vision框架检测



可以输出总数量以及预计收益哦：

（4）检测项目内是否已有png图片，避免重复导入，使用Vision框架检测

eg：已存在



eg：未存在



（5）编译速度优化

        主要是针对一些优化配置，比如ASSETCATALOG_COMPILER_OPTIMIZATION，会自动使用xcodeproj工具检测后进行更改。


