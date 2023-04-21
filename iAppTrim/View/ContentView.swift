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
    @State var stateText: String = "\n点击上方按钮，即可完成相应的自动优化\n"
    
    func selectFile() -> String? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["com.apple.xcode.project"]
        panel.title = "请选择项目"
        panel.message = "请选择工程目录下的.xcodeproj文件"
        if panel.runModal() == .OK {
            let url = panel.url?.relativePath ?? ""
            return url
        }
        return nil
    }
    
    func selectFileForURL(message: String = "", allowedFileTypes: [String]) -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = allowedFileTypes
        panel.message = message
        if panel.runModal() == .OK {
            let url = panel.url
            return url
        }
        return nil
    }
    
    func selectFloder() -> String? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.title = "请选择目录"
        panel.message = "请选择需要压缩png图片的文件目录"
        if panel.runModal() == .OK {
            let url = panel.url?.relativePath ?? ""
            return url
        }
        return nil
    }
    
    func selectFloderForURL(message: String = "") -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.title = "请选择目录"
        panel.message = !message.isEmpty ? message : "请选择需要压缩png图片的文件目录"
        if panel.runModal() == .OK {
            let url = panel.url
            return url
        }
        return nil
    }
    
    var body: some View {
        
        VSplitView() {
            HSplitView() {
                List() {
                    Button("包大小优化-项目编译配置优化（选择工程目录下的.xcodeproj文件）")
                    {
                        if let path = selectFile() {
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
                        if let path = selectFloder() {
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
                    
//                    Button("包大小优化-一键优化（自动执行工程目录下的编译配置项优化以及PNG图片压缩）") {
//                        stateText = "功能尚未支持"
//                    }
//                    .controlSize(.large)
//                    .buttonStyle(.borderedProminent)
                    
//                    Button("包大小输出（请提前配置好项目证书）") {
//                        stateText = "功能尚未支持"
//                    }
//                    .controlSize(.large)
//                    .buttonStyle(.borderedProminent)
                    
                    //------------------------------------------------//
                    Button("包大小优化-检测文件夹内所有的重复图片（图片Size以及外观相同，名字可以不同）") {
                        if let path = selectFloderForURL(message: "请选择需要检测的文件夹") {
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
                    Button("包大小优化-检测文件夹是否已经存在某张图片，避免重复导入（图片Size以及外观相同，名字可以不同）") {
                        if let checkFile = selectFileForURL(message: "请选择需要检测的的图片", allowedFileTypes: ["png"]) {
                            if let path = selectFloderForURL(message: "请选择需要检测的文件夹") {
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
                    Button("编译速度优化-Debug模式下项目编译配置优化") {
                        if let path = selectFile() {
                            let compileOptimizeManager = CompileOptimizeManager()
                            compileOptimizeManager.optimizeCompileSpeedForDebug(path: path) { content in
                                if let content = content, !content.isEmpty {
                                    stateText = stateText + content + "\n"
                                }
                            }
                        }
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    //------------------------------------------------//
                    Button {
                        stateText = "联系方式：394687964@qq.com"
                        stateText = "git地址：https://github.com/DSAppTeam/iAppTrim"
                    } label: {
                        Text("有问题更多功能请联系")
                            .frame(width: 150)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                }
            }
            VStack {
                Text("输出信息")
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                ScrollView {
                    Text(stateText)
                        .textSelection(.enabled)
                        .lineSpacing(2)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
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
