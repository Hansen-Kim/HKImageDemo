//
//  Loggable.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/17.
//

import Foundation
import os.log

class Logger {
    enum Level: String {
        case `default` = " "
        case info = "I"
        case debug = "D"
        case error = "E"
        case fault = "F"
        
        fileprivate var type: OSLogType {
            switch self {
            case .info:
                return .info
            case .debug:
                return .debug
            case .error:
                return .error
            case .fault:
                return .fault
            default:
                return .default
            }
        }
    }
    
    enum Category: String {
        case debug = "Debug"
        case release = "Release"

        #if DEBUG
        static let `default` = Category.debug
        #else
        static let `default` = Category.release
        #endif
    }
    
    static let shared = Logger()

    private func makeOSLog(category: Category) -> OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier ?? "seunghan.kim.image.demo", category: category.rawValue)
    }
    
    fileprivate func log(level: Level = .default, category: Category = .default, message: String) {
        os_log("%@", log: makeOSLog(category: category), type: level.type, message)
    }
}

protocol Loggable {
}

extension Loggable {
    func log(level: Logger.Level = .default, category: Logger.Category = .default, message: String) {
        Logger.shared.log(level: level, category: category, message: message)
    }
    
    func log(level: Logger.Level = .default, category: Logger.Category = .default, format: String, _ arguments: CVarArg...) {
        Logger.shared.log(level: level, category: category, message: String(format: format, arguments))
    }
}
