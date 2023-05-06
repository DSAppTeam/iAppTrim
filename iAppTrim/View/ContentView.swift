//
//  ContentView.swift
//  IpaSmaller
//
//  Created by Jerrydu on 2023/2/7.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State var oldStateText: String = "\n点击上方按钮，即可完成相应的自动优化\n"
    @State var stateText: String = ContentView.defaultText()
    
    static func defaultText() -> String {
            """
                目前主要支持以下功能：
            （1）包大小优化-项目编译配置优化（选择工程目录下的.xcodeproj文件）：
                主要是针对一些优化配置，比如LLVM_LTO、SWIFT_OPTIMIZATION_LEVEL等，会自动使用检测后进行更改。
            
            （2）包大小优化-Png图片压缩（选择文件夹，即可对文件夹内的所有PNG图片进行高质量的压缩）
                这里是通过使用Swift Process执行node.js，上传png图片到tinypng进行压缩后替换原文件。
                因为涉及网络，建议选择所需要的图片压缩，压缩会自动替换掉原图，有需要请备份
                建议先安装homebrew再执行，执行时会自动检测和安装node，如执行失败，请根据提示进行操作。
            
            （3）包大小优化-检测文件夹内所有的重复png图片（图片Size以及外观相同，名字可以不同）
                重复图片检测，用于删除多余重复的图片，使用Vision框架检测
            
            （4）包大小优化-检测文件夹是否已经存在某张png图片，避免重复导入（图片Size以及外观相同，名字可以不同）
                检测项目内是否已有图片，避免重复导入，使用Vision框架检测
            
            （5）编译速度优化-Debug模式下项目编译配置优化
                主要是针对一些优化配置，比如ASSETCATALOG_COMPILER_OPTIMIZATION，会自动检测后进行更改。
                效果会跟项目本身有关系，修改的配置均为网上搜索以及OpenAI询问所得。
            
                *---------点击上方按钮，即可完成相应的自动优化---------*
            
            git地址：https://github.com/DSAppTeam/iAppTrim\n联系方式：394687964@qq.com
            
            """
    }
    
    var body: some View {
        
        VSplitView() {
            HSplitView() {
                List() {
                    //------------------------------------------------//
//                    HStack {
//                        Text("当前选择项目Git目录路径：")
//                        Button("切换项目仓库")
//                        {
//                            if let path = OpenPanelHelper.selectFloder() {
//
//                            }
//                        }
//                    }
                    //------------------------------------------------//
//                    Button("一键包大小优化")
//                    {
//                        if let path = OpenPanelHelper.selectFile() {
//
//                        }
//                    }
//                    .controlSize(.large)
//                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
                    Button("包大小优化-项目编译配置优化（选择工程目录下的.xcodeproj文件）")
                    {
                        if let path = OpenPanelHelper.selectFile() {
                            ConfigSettingManager().optimizeProjectSetting(path: path) { content in
                                if let content = content, !content.isEmpty {
                                    stateText = stateText + content + "\n"
                                }
                            }
                        }
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
                    Button("包大小优化-Png图片压缩（选择文件夹，即可对文件夹内的所有PNG图片进行高质量的压缩）") {
                        if let path = OpenPanelHelper.selectFloder() {
                            let compresser = PngCompressManager()
                            if compresser.checkNodeInstall() {
                                stateText = stateText + "\n--------已安装node，现在执行压缩选中目录下PNG的指令---------\n"
                                compresser.compress(with: path, handleBlock: { content in
                                    stateText = stateText + (content ?? "")
                                })
                            } else {
                                stateText = "------未安装node------"
                                let installHomeBrew = compresser.checkHomeBrewInstall()
                                if installHomeBrew {
                                    stateText = "------已安装homebrew，使用brew进行安装node------"
                                    let result = compresser.installNodeJs { content in
                                        // 拿出来计算下总减少的kb
                                        stateText = stateText + "\n"
                                        stateText = stateText + (content ?? "")
                                    }
                                    if result {
                                        // 安装成功
                                        stateText = stateText + "\n--------已安装node，现在执行压缩选中目录下PNG的指令---------\n"
                                        compresser.compress(with: path, handleBlock: { content in
                                            stateText = stateText + (content ?? "")
                                        })
                                    }
                                } else {
                                    stateText = stateText + "------未安装homebrew，请自行安装homebrew或node后再使用png图片压缩功能------\n"
                                    stateText = stateText + "https://brew.sh/index_zh-cn\n"
                                    stateText = stateText + "https://nodejs.dev/en/learn/how-to-install-nodejs\n"
                                }
                            }
                        }
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
                    Button("包大小优化-检测文件夹内所有的重复png图片（图片Size以及外观相同，名字可以不同）") {
                        if let path = OpenPanelHelper.selectFloderForURL(message: "请选择需要检测的文件夹") {
                            stateText = "--------检测重复图片ing--------Wait……--------" + "\n"
                            DispatchQueue.main.async {
                                let imageSimilarCheckManager = ImageSimilarCheckManager()
                                imageSimilarCheckManager.scanPng(from: path) { content in
                                    if let content = content, !content.isEmpty {
                                        stateText = stateText + content + "\n"
                                    }
                                }
                            }
                        }
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
                    Button("包大小优化-检测文件夹是否已经存在某张png图片，避免重复导入（图片Size以及外观相同，名字可以不同）") {
                        if let checkFile = OpenPanelHelper.selectFileForURL(message: "请选择需要检测的的图片", allowedFileTypes: ["png"]) {
                            if let path = OpenPanelHelper.selectFloderForURL(message: "请选择需要检测的文件夹") {
                                stateText = "--------检测重复图片ing--------Wait……--------" + "\n"
                                DispatchQueue.main.async {
                                    let imageSimilarCheckManager = ImageSimilarCheckManager()
                                    imageSimilarCheckManager.checkImageExist(fileUrl: checkFile, folderUrl: path) { content in
                                        if let content = content, !content.isEmpty {
                                            stateText = stateText + content + "\n"
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
//                    Button("包大小优化-LinkMap分析大小") {
//
//                    }
//                    .controlSize(.large)
//                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
//                    Button("包大小优化-无用类扫描") {
//
//                    }
//                    .controlSize(.large)
//                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
//                    Button("编译速度优化-Debug模式下项目编译配置优化") {
//                        if let path = OpenPanelHelper.selectFile() {
//                            let compileOptimizeManager = CompileOptimizeManager()
//                            compileOptimizeManager.optimizeCompileSpeedForDebug(path: path) { content in
//                                if let content = content, !content.isEmpty {
//                                    stateText = stateText + content + "\n"
//                                }
//                            }
//                        }
//                    }
//                    .controlSize(.large)
//                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
                    Button("功能使用说明") {
                        stateText = ContentView.defaultText()
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
//                    Button("有疑问或需要更多功能") {
//                        stateText = "git地址：https://github.com/DSAppTeam/iAppTrim\n联系方式：394687964@qq.com"
//                    }
//                    .controlSize(.large)
//                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
                    Button("输出信息清空") {
                        stateText = ""
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                }
            }
            VStack {
                Text("输出信息")
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                TextEditor(text: .constant(self.stateText))
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//                ScrollView {
//                    Text(stateText)
//                        .font(.system(size: 12))
//                        .textSelection(.enabled)
//                        .lineSpacing(2)
//                        .lineLimit(nil)
//                        .multilineTextAlignment(.leading)
//                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//                }
            }
        }
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
