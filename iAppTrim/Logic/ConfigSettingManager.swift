//
//  configSettingManager.swift
//  IpaSmaller
//
//  Created by Jerrydu on 2023/2/7.
//
import Foundation
import XcodeProj  // @tuist ~> 8.8.0
import PathKit

typealias StringHandlingBlock = (_ content: String?) -> ()

class ConfigSettingManager {
    func optimizeProjectSetting(path: String, handleBlock: @escaping StringHandlingBlock) {
        do {
            let path = Path(path)
            let xcodeproj = try XcodeProj(path: path)
            handleBlock("-----------配置更新开始----------\n")
            for target in xcodeproj.pbxproj.nativeTargets {
                if let buildConfigurationList = target.buildConfigurationList {
                    handleBlock("------------开始检查Target：" + target.name + " 的Release配置项------------")
                    for config in buildConfigurationList.buildConfigurations {
                        if config.name == "Release" {
                            handleBlock("因为包大小配置可能会减慢编译速度，仅更改Release下的配置 Begin!")
                            // Release环境下的配置，都是可以缩减包大小，并且副作用不大的配置项
                            if let DEPLOYMENT_POSTPROCESSING = config.buildSettings["DEPLOYMENT_POSTPROCESSING"] as? String, DEPLOYMENT_POSTPROCESSING == "YES" {
                                handleBlock("DEPLOYMENT_POSTPROCESSING已为「YES」，无需更改")
                            } else {
                                config.buildSettings["DEPLOYMENT_POSTPROCESSING"] = "YES"
                                handleBlock("DEPLOYMENT_POSTPROCESSING设定项更改为「YES」")
                            }
                            if let GCC_SYMBOLS_PRIVATE_EXTERN = config.buildSettings["GCC_SYMBOLS_PRIVATE_EXTERN"] as? String, GCC_SYMBOLS_PRIVATE_EXTERN == "YES" {
                                handleBlock("GCC_SYMBOLS_PRIVATE_EXTERN已为「YES」，无需更改")
                            } else {
                                config.buildSettings["GCC_SYMBOLS_PRIVATE_EXTERN"] = "YES"
                                handleBlock("GCC_SYMBOLS_PRIVATE_EXTERN设定项更改为「YES」")
                            }
                            if let COPY_PHASE_STRIP = config.buildSettings["COPY_PHASE_STRIP"] as? String, COPY_PHASE_STRIP == "YES" {
                                handleBlock("COPY_PHASE_STRIP已为「YES」，无需更改")
                            } else {
                                config.buildSettings["COPY_PHASE_STRIP"] = "YES"
                                handleBlock("COPY_PHASE_STRIP设定项更改为「YES」")
                            }
                            if let STRIP_INSTALLED_PRODUCT = config.buildSettings["STRIP_INSTALLED_PRODUCT"] as? String, STRIP_INSTALLED_PRODUCT == "YES" {
                                handleBlock("STRIP_INSTALLED_PRODUCT已为「YES」，无需更改")
                            } else {
                                config.buildSettings["STRIP_INSTALLED_PRODUCT"] = "YES"
                                handleBlock("STRIP_INSTALLED_PRODUCT设定项更改为「YES」")
                            }
                            if let LLVM_LTO = config.buildSettings["LLVM_LTO"] as? String, LLVM_LTO == "YES" {
                                handleBlock("LLVM_LTO已为「YES」，无需更改")
                            } else {
                                config.buildSettings["LLVM_LTO"] = "YES"
                                handleBlock("LLVM_LTO设定项更改为「YES」")
                            }
                            if let GCC_OPTIMIZATION_LEVEL = config.buildSettings["GCC_OPTIMIZATION_LEVEL"] as? String, GCC_OPTIMIZATION_LEVEL == "z" {
                                handleBlock("GCC_OPTIMIZATION_LEVEL已为「z」，无需更改")
                            } else {
                                config.buildSettings["GCC_OPTIMIZATION_LEVEL"] = "z"
                                handleBlock("GCC_OPTIMIZATION_LEVEL设定项更改为「z」")
                            }
                            if let SWIFT_OPTIMIZATION_LEVEL = config.buildSettings["SWIFT_OPTIMIZATION_LEVEL"] as? String, SWIFT_OPTIMIZATION_LEVEL == "-Osize" {
                                handleBlock("SWIFT_OPTIMIZATION_LEVEL已为「-Osize」，无需更改")
                            } else {
                                config.buildSettings["SWIFT_OPTIMIZATION_LEVEL"] = "-Osize"
                                handleBlock("GCC_OPTIMIZATION_LEVEL设定项更改为「-Osize」")
                            }
                            if let ASSETCATALOG_COMPILER_OPTIMIZATION = config.buildSettings["ASSETCATALOG_COMPILER_OPTIMIZATION"] as? String, ASSETCATALOG_COMPILER_OPTIMIZATION == "space" {
                                handleBlock("ASSETCATALOG_COMPILER_OPTIMIZATION已为「space」，无需更改")
                            } else {
                                config.buildSettings["ASSETCATALOG_COMPILER_OPTIMIZATION"] = "space"
                                handleBlock("ASSETCATALOG_COMPILER_OPTIMIZATION设定项更改为「space」")
                            }
                        }
                    }
                    handleBlock("------------Target：" + target.name + " 的Release配置项检查完毕------------\n")
                }
            }
            handleBlock("--------更改配置已完成---------")
            try? xcodeproj.write(path: path)
        } catch {
            handleBlock(error.localizedDescription)
        }
    }
}


