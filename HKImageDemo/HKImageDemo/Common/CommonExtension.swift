//
//  CommonExtension.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/18.
//

import UIKit
import CommonCrypto

extension CustomStringConvertible where Self: RawRepresentable, Self.RawValue: CustomStringConvertible {
    var description: String { return self.rawValue.description }
}

extension Hashable where Self: CustomStringConvertible {
    func hash(into hasher: inout Hasher) {
        self.description.hash(into: &hasher)
    }
}

extension CustomStringConvertible {
    var md5: Data {
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        if let data = self.description.data(using: .utf8) {
            _ = digest.withUnsafeMutableBytes { (digestRawPointer) -> Int in
                data.withUnsafeBytes { (dataRawPointer) -> Int in
                    if let dataAddress = dataRawPointer.baseAddress, let digestAddress = digestRawPointer.bindMemory(to: UInt8.self).baseAddress {
                        CC_MD5(dataAddress, CC_LONG(data.count), digestAddress)
                    }
                    return 0
                }
            }
        }
        
        return digest
    }
    
    var md5String: String {
        return self.md5.map({ String(format: "%02hhx", $0) }).joined()
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hex: UInt64 = 0
        
        Scanner(string: hexString).scanHexInt64(&hex)
        
        let alpha: CGFloat
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        
        switch hexString.count {
        case 3:
            alpha = 255.0
            red = CGFloat(hex >> 8 & 0xF) * 17.0
            green = CGFloat(hex >> 4 & 0xF) * 17.0
            blue = CGFloat(hex & 0xF) * 17.0
        case 6:
            alpha = 255.0
            red = CGFloat(hex >> 16 & 0xFF)
            green = CGFloat(hex >> 8 & 0xFF)
            blue = CGFloat(hex & 0xFF)
        case 8:
            alpha = CGFloat(hex >> 24 & 0xFF)
            red = CGFloat(hex >> 16 & 0xFF)
            green = CGFloat(hex >> 8 & 0xFF)
            blue = CGFloat(hex & 0xFF)
        default:
            alpha = 255.0
            red = 0.0
            green = 0.0
            blue = 0.0
        }
        
        self.init(red: red / 255.0,
                  green: green / 255.0,
                  blue: blue / 255.0,
                  alpha: alpha / 255.0)
    }
}

extension UITableView {
    func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.cellIdentifier, for: indexPath) as? T else {
            fatalError("failure to dequeue cell (\(T.cellIdentifier))")
        }
        return cell
    }
}

extension UITableViewCell {
    static var cellIdentifier: String { String(describing: self.self) }
}
