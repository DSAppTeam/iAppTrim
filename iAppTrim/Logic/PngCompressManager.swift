//
//  File2.swift
//  iAppTrim
//
//  Created by Jerrydu on 2023/4/21.
//

import Foundation

class PngCompressManager {
    
    func checkNodeInstall() -> Bool {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-l", "-c", "which node"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        task.terminate()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let node = output, !node.isEmpty, node.contains("/node") {
            return true
        } else {
            return false
        }
    }
    
    @discardableResult func installNodeJs(handleBlock: @escaping StringHandlingBlock) -> Bool {
        // 可以执行
        handleBlock("正在执行brew install node安装node.js环境")
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-l", "-c", "brew install node"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        task.waitUntilExit()
        task.terminate()
        handleBlock("--------安装命令已结束！---------")
        let result = checkNodeInstall()
        if result {
            // 安装成功
            handleBlock("--------node.js安装成功！---------")
        } else {
            // 没安装成功
            handleBlock("--------node.js安装失败！---------")
        }
        return result
    }
    
    func checkHomeBrewInstall() -> Bool {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-l", "-c", "which brew"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        task.terminate()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let homebrew = output, !homebrew.isEmpty, homebrew.contains("/brew") {
            return true
        } else {
            return false
        }
    }
    
    func installHomeBrew() -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        task.terminate()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return output ?? ""
    }
    
    func compress(with path: String, handleBlock: @escaping StringHandlingBlock) {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-l", "-c", "which node"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let nodePath = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        task.waitUntilExit()
        task.terminate()
        
        if let nodePath = nodePath, let jsSourcePath = Bundle.main.path(forResource: "tinypngCompress", ofType: "js") {
            // 找到node
            handleBlock("--------开始压缩PNG!---------\n")
            let task = Process()
            let executableURL = URL(fileURLWithPath: nodePath)
            task.executableURL = executableURL
            task.arguments = [jsSourcePath, path]
            let outputPipe = Pipe()
            task.standardOutput = outputPipe
            let errorPipe = Pipe()
            task.standardError = errorPipe
            let outputHandle = outputPipe.fileHandleForReading
            let errorHandle = errorPipe.fileHandleForReading
            task.launch()
            
            var totalCount = 0
            var currentCount = 0
            NotificationCenter.default.addObserver(forName: FileHandle.readCompletionNotification, object: outputHandle, queue: nil) { notification in
                guard let handle = notification.object as? FileHandle, let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data else { return }
                if data.count > 0 {
                    let message = String(data: data, encoding: String.Encoding.utf8)!
                    // 处理输出信息
                    handleBlock(message)
                }
                handle.readInBackgroundAndNotify()
            }
            NotificationCenter.default.addObserver(forName: FileHandle.readCompletionNotification, object: errorHandle, queue: nil) { notification in
                guard let handle = notification.object as? FileHandle, let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data else { return }
                if data.count > 0 {
                    let message = String(data: data, encoding: String.Encoding.utf8)!
                    // 处理错误信息
                    handleBlock(message)
                }
                handle.readInBackgroundAndNotify()
            }
            
            outputHandle.readInBackgroundAndNotify()
            errorHandle.readInBackgroundAndNotify()
            
            task.waitUntilExit()
            task.terminate()
            NotificationCenter.default.removeObserver(self)
        }
        
    }
}
