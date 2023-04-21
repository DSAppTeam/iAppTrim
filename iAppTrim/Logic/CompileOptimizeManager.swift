//
//  File.swift
//  iAppTrim
//
//  Created by Jerrydu on 2023/4/21.
//

import Foundation
import XcodeProj  // @tuist ~> 8.8.0
import PathKit

class CompileOptimizeManager {
    func optimizeCompileSpeedForDebug(path: String, handleBlock: @escaping StringHandlingBlock) {
        do {
            let path = Path(path)
            let xcodeproj = try XcodeProj(path: path)
            handleBlock("-----------配置更新开始----------\n")
            for target in xcodeproj.pbxproj.nativeTargets {
                if let buildConfigurationList = target.buildConfigurationList {
                    handleBlock("--------开始检查Target：" + target.name + " 的Debug配置项--------")
                    for config in buildConfigurationList.buildConfigurations {
                        if config.name == "Debug" {
                            // Debug环境下的配置，尽量使用编译速度更快的配置，提升开发效率
                            if let DEPLOYMENT_POSTPROCESSING = config.buildSettings["DEPLOYMENT_POSTPROCESSING"] as? String, DEPLOYMENT_POSTPROCESSING == "NO" {
                                handleBlock("DEPLOYMENT_POSTPROCESSING已为「NO」，无需更改")
                            } else {
                                config.buildSettings["DEPLOYMENT_POSTPROCESSING"] = "NO"
                                handleBlock("DEPLOYMENT_POSTPROCESSING设定项更改为「NO」")
                            }
                            if let GCC_SYMBOLS_PRIVATE_EXTERN = config.buildSettings["GCC_SYMBOLS_PRIVATE_EXTERN"] as? String, GCC_SYMBOLS_PRIVATE_EXTERN == "NO" {
                                handleBlock("GCC_SYMBOLS_PRIVATE_EXTERN已为「NO」，无需更改")
                            } else {
                                config.buildSettings["GCC_SYMBOLS_PRIVATE_EXTERN"] = "NO"
                                handleBlock("GCC_SYMBOLS_PRIVATE_EXTERN设定项更改为「NO」")
                            }
                            if let COPY_PHASE_STRIP = config.buildSettings["COPY_PHASE_STRIP"] as? String, COPY_PHASE_STRIP == "NO" {
                                handleBlock("COPY_PHASE_STRIP已为「NO」，无需更改")
                            } else {
                                config.buildSettings["COPY_PHASE_STRIP"] = "NO"
                                handleBlock("COPY_PHASE_STRIP设定项更改为「NO」")
                            }
                            if let STRIP_INSTALLED_PRODUCT = config.buildSettings["STRIP_INSTALLED_PRODUCT"] as? String, STRIP_INSTALLED_PRODUCT == "NO" {
                                handleBlock("STRIP_INSTALLED_PRODUCT已为「NO」，无需更改")
                            } else {
                                config.buildSettings["STRIP_INSTALLED_PRODUCT"] = "NO"
                                handleBlock("STRIP_INSTALLED_PRODUCT设定项更改为「NO」")
                            }
                            if let LLVM_LTO = config.buildSettings["LLVM_LTO"] as? String, LLVM_LTO == "NO" {
                                handleBlock("LLVM_LTO已为「NO」，无需更改")
                            } else {
                                config.buildSettings["LLVM_LTO"] = "NO"
                                handleBlock("LLVM_LTO设定项更改为「NO」")
                            }
                            if let GCC_OPTIMIZATION_LEVEL = config.buildSettings["GCC_OPTIMIZATION_LEVEL"] as? String, GCC_OPTIMIZATION_LEVEL == "0" {
                                handleBlock("GCC_OPTIMIZATION_LEVEL已为「0」，无需更改")
                            } else {
                                config.buildSettings["GCC_OPTIMIZATION_LEVEL"] = "0"
                                handleBlock("GCC_OPTIMIZATION_LEVEL设定项更改为「0」")
                            }
                            if let SWIFT_OPTIMIZATION_LEVEL = config.buildSettings["SWIFT_OPTIMIZATION_LEVEL"] as? String, SWIFT_OPTIMIZATION_LEVEL == "-Onone" {
                                handleBlock("SWIFT_OPTIMIZATION_LEVEL已为「-Onone」，无需更改")
                            } else {
                                config.buildSettings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone"
                                handleBlock("SWIFT_OPTIMIZATION_LEVEL设定项更改为「-Onone」")
                            }
                            if let LD_GENERATE_MAP_FILE = config.buildSettings["LD_GENERATE_MAP_FILE"] as? String, LD_GENERATE_MAP_FILE == "NO" {
                                handleBlock("LD_GENERATE_MAP_FILE已为「NO」，无需更改")
                            } else {
                                config.buildSettings["LD_GENERATE_MAP_FILE"] = "NO"
                                handleBlock("LD_GENERATE_MAP_FILE设定项更改为「NO」")
                            }
                            if let DEBUG_INFORMATION_FORMAT = config.buildSettings["DEBUG_INFORMATION_FORMAT"] as? String, DEBUG_INFORMATION_FORMAT == "dwarf" {
                                handleBlock("DEBUG_INFORMATION_FORMAT已为「dwarf」，无需更改")
                            } else {
                                config.buildSettings["DEBUG_INFORMATION_FORMAT"] = "dwarf"
                                handleBlock("DEBUG_INFORMATION_FORMAT设定项更改为「dwarf」")
                            }
                            if let ASSETCATALOG_COMPILER_OPTIMIZATION = config.buildSettings["ASSETCATALOG_COMPILER_OPTIMIZATION"] as? String, ASSETCATALOG_COMPILER_OPTIMIZATION == "space" {
                                handleBlock("ASSETCATALOG_COMPILER_OPTIMIZATION已为「space」，无需更改")
                            } else {
                                config.buildSettings["ASSETCATALOG_COMPILER_OPTIMIZATION"] = "space"
                                handleBlock("ASSETCATALOG_COMPILER_OPTIMIZATION设定项更改为「space」")
                            }
                        }
                    }
                    handleBlock("--------Target：" + target.name + " 的Debug配置项更改完毕--------\n")
                }
            }
            handleBlock("--------更改配置已完成---------")
            try? xcodeproj.write(path: path)
        } catch {
            handleBlock(error.localizedDescription)
        }
    }
}
