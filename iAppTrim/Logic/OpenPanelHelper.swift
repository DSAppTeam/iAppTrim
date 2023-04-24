//
//  OpenPanelHelper.swift
//  iAppTrim
//
//  Created by N24404 on 2023/4/23.
//

import Foundation
import SwiftUI

class OpenPanelHelper {
    static func selectFile() -> String? {
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

    static func selectFileForURL(message: String = "", allowedFileTypes: [String]) -> URL? {
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

    static func selectFloder() -> String? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.title = "请选择目录"
        panel.message = "请选择需要压缩png图片的文件目录"
        if panel.runModal() == .OK {
            let url = panel.url?.relativePath ?? ""
            return url
        }
        return nil
    }

    static func selectFloderForURL(message: String = "") -> URL? {
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
}
