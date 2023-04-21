//
//  File3.swift
//  iAppTrim
//
//  Created by Jerrydu on 2023/4/21.
//

import Foundation
import XcodeProj  // @tuist ~> 8.8.0
import PathKit
import Vision

class ImageSimilarCheckManager {
    
    class PngImageModel {
        var path: URL
        var vis: VNFeaturePrintObservation
        var size: CGSize
        var fileSize: Float = 0 // Kb
        init(path: URL, vis: VNFeaturePrintObservation, size: CGSize) {
            self.path = path
            self.vis = vis
            self.size = size
        }
    }
    
    func featureprintObservationForImage(atURL url: URL) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(url: url)
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
    
    func checkImageExist(fileUrl: URL, folderUrl: URL, handleBlock: @escaping StringHandlingBlock) {
        // 存放所有的model
        var allModels = [PngImageModel]()
        // 2. 创建文件管理器
        let fileManager = FileManager.default
        // 3. 枚举URL下的所有文件和目录
        if let enumerator = fileManager.enumerator(at: folderUrl, includingPropertiesForKeys: nil) {
            // 4. 遍历枚举器中的所有URL
            for case let fileURL as URL in enumerator {
                // 5. 过滤出PNG文件
                if fileURL.pathExtension.lowercased() == "png" {
                    // 6. 处理PNG文件
                    if let vis = featureprintObservationForImage(atURL: fileUrl), let image = NSImage(contentsOf: fileUrl) {
                        var size: CGSize = .zero
                        if let imageRep = image.representations.first as? NSBitmapImageRep {
                            size = NSSize(width: imageRep.pixelsWide, height: imageRep.pixelsHigh)
                        }
                        let model = PngImageModel(path: fileURL, vis: vis, size: size)
                        allModels.append(model)
                    }
                }
            }
        }
        // 比较所有图片的相似度
        if fileUrl.pathExtension.lowercased() == "png" {
            if let vis = featureprintObservationForImage(atURL: fileUrl), let image = NSImage(contentsOf: fileUrl) {
                var size: CGSize = .zero
                if let imageRep = image.representations.first as? NSBitmapImageRep {
                    size = NSSize(width: imageRep.pixelsWide, height: imageRep.pixelsHigh)
                }
                let fileModel = PngImageModel(path: fileUrl, vis: vis, size: size)
                
                var existFilePaths: [String] = [String]()
                for a in allModels {
                    if a.path.absoluteString != fileUrl.absoluteString {
                        do {
                            var distant: Float = 0
                            try a.vis.computeDistance(&distant, to: fileModel.vis)
                            if distant == 0 && CGSizeEqualToSize(a.size, fileModel.size) {
                                let existFilePath = a.path.absoluteString
                                existFilePaths.append(existFilePath)
                            }
                        } catch {
                            print("出错！")
                        }
                    }
                }
                if existFilePaths.count > 0 {
                    var index = 1
                    for existFilePath in existFilePaths {
                        handleBlock("已找到相同图片，无需重复导入")
                        handleBlock("相同图片\(index)路径为：" + (existFilePath.removingPercentEncoding ?? ""))
                        index = index + 1
                    }
                } else {
                    handleBlock("未找到相同图片，请检查是否需要导入到项目内")
                }
            }
        }
        
    }
    
    func scanPng(from url: URL, handleBlock: @escaping StringHandlingBlock) {
        // 总可优化空间大小
        var allFileSize: Float = 0
        // 总重复图片张数
        var allFileCount: Int = 0
        // 存放所有的model
        var allModels = [PngImageModel]()
        // 2. 创建文件管理器
        let fileManager = FileManager.default
        // 3. 枚举URL下的所有文件和目录
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil) {
            // 4. 遍历枚举器中的所有URL
            for case let fileURL as URL in enumerator {
                // 5. 过滤出PNG文件
                if fileURL.pathExtension.lowercased() == "png" {
                    // 6. 处理PNG文件
                    autoreleasepool {
                        
                        if let vis = featureprintObservationForImage(atURL: fileURL), let image = NSImage(contentsOf: fileURL) {
                            var size: CGSize = .zero
                            if let imageRep = image.representations.first as? NSBitmapImageRep {
                                size = NSSize(width: imageRep.pixelsWide, height: imageRep.pixelsHigh)
                            }
                            
                            let model = PngImageModel(path: fileURL, vis: vis, size: size)
                            var fileSize: Float = 0
                            do {
                                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                                fileSize = Float(resourceValues.fileSize ?? 0) / Float(1024)
                            } catch {
                                print("Error: \(error)")
                            }
                            model.fileSize = fileSize
                            allModels.append(model)
                        }
                    }
                }
            }
        }
        // 比较所有图片的相似度
        let allSet = NSMutableArray()//[[PngImageModel]]()
        for a in allModels {
            for b in allModels {
                if a.path.absoluteString != b.path.absoluteString {
                    autoreleasepool {
                        do {
                            var distant: Float = 0
                            try a.vis.computeDistance(&distant, to: b.vis)
                            if distant == 0 && CGSizeEqualToSize(a.size, b.size) {
                                var exist = false
                                for set in allSet {
                                    if set is NSMutableArray {
                                        let muSet = set as! NSMutableArray
                                        if muSet.contains(a) && !muSet.contains(b) {
                                            exist = true
                                            muSet.add(b)
                                        }
                                        if muSet.contains(b) && !muSet.contains(a) {
                                            exist = true
                                            muSet.add(a)
                                        }
                                        if muSet.contains(a) && muSet.contains(b) {
                                            exist = true
                                        }
                                    }
                                }
                                if !exist {
                                    let muSet = NSMutableArray()
                                    muSet.add(a)
                                    muSet.add(b)
                                    allSet.add(muSet)
                                }
                            }
                        } catch {
                            print("出错！")
                        }
                    }
                }
            }
        }
        allSet.sort { obj1, obj2 in
            if let obj1 = obj1 as? NSMutableArray, let x1 = obj1.firstObject as? PngImageModel, let obj2 = obj2 as? NSMutableArray, let x2 = obj2.firstObject as? PngImageModel {
                if x1.fileSize > x2.fileSize {
                    return .orderedAscending
                } else {
                    return .orderedDescending
                }
            }
            return .orderedSame
        }
        var index = 1
        for kk in allSet {
            handleBlock("--------**重复图片组\(index)**--------")
            if let kk = kk as? NSMutableArray {
                for kkk in kk {
                    if let kkk = kkk as? PngImageModel {
                        allFileCount = allFileCount + 1
                        allFileSize = allFileSize + kkk.fileSize
                        handleBlock((kkk.path.absoluteString.removingPercentEncoding ?? "") + "  **图片大小=\(kkk.fileSize) kb**")
                    }
                }
            }
            index = index + 1
        }
        handleBlock("-----------重复图片总数量为\(allFileCount)张，总大小为\(allFileSize)KB-----------")
    }
}
