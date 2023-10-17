//
//  SocketUtil.swift
//  PodDemo3
//
//  Created by KOYO on 2022/9/29.
//

import Foundation
import AVFoundation
import UIKit
var devices: [AVCaptureDevice] = []
struct SocketUtil{
//    static let BASE_URL = "192.168.1.105:3016/"
//    static let BASE_URL = "vps271818.vps.ovh.ca:3018/"
    static let BASE_URL = "167.114.36.64:3018/"
    ///Get 7-digit random characters, random numbers
    public static func getSocketKey() -> Int {
        var randomString = ""
        for _ in stride(from: 1, to: 8, by: 1) {
            let val = max(1, arc4random() % 9)
            randomString = "\(randomString)\(val)"
        }
        return Int(randomString) ?? 0
    }
    ///Get the current mobile device information
    public static func deviceInfo()->[String:Any]{
        let name = "test"//UIDevice.current.name
        let flag = UIDevice.current.systemName
        let version = UIDevice.current.systemVersion
        return ["name":name,"flag":flag,"version":version]
    }
    
    public static func getCameraDevice()->AVCaptureDevice?{
        
        if #available(iOS 10.2, *) {
            devices = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices;
        } else {
            // Older than iOS 10.1
            devices = AVCaptureDevice.devices().filter({ $0.position == .front });
        }
        
        return devices.first
    }
    
    
    
    public static func removeCameraDevice(){
        devices.remove(at: 0)
        
       
    }
    
}

extension String{
    ///String to dictionary
    func toDic()->[String:Any]{
        if self.count == 0{return[:]}
        let data = self.data(using: String.Encoding.utf8)
        var tempDic:[String:Any] = [:]
        if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
            tempDic = dict
        }
        if !tempDic.isEmpty{return tempDic}
        
        //字符串里的字符串转dic
        guard let dic = try? JSONSerialization.jsonObject(with: self.data(using: .utf8)!, options: .allowFragments) as? [String:Any] ?? [:] else {
            let beginStr = "\"{"
            let endStr = "}\""
            let str = self
            if str.hasPrefix(beginStr) && str.hasSuffix(endStr){
               let subStr = str.getSubString(startIndex: 1, endIndex: str.count-2)
                guard let vDic = try? JSONSerialization.jsonObject(with: subStr.data(using: .utf8)!, options: .allowFragments) as? [String:Any] ?? [:] else {
                    return [:]
                }
                return vDic
            }
            
            return [:]
        }
        return dic
    }
    
    //Get substring Include start and end
    func getSubString(startIndex:Int, endIndex:Int) -> String {
        var endInt = endIndex
        if self.count < endInt{
            endInt = self.count
        }
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: endInt)
        return String(self[start...end])
    }
    
    ///Custom conversion to integer
    func intValue()->Int{
        if self.count == 0{return 0}
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return 0
        }
    }
    
}

extension Dictionary{
    ///获取字符串值
    func strValue(_ key:Key)->String{
        if let val = self[key] as? String {return val}
        if let val2 = self[key] as? Int {return "\(val2)"}
        if let val3 = self[key] as? Double {return "\(val3)"}
        if let val4 = self[key] as? CGFloat {return "\(val4)"}
        if let val5 = self[key] as? Float {return "\(val5)"}
        return ""
    }
//    func strValue(_ key:Key)->String{
//        var rtpcapability=String()
//            if let val = self[key] as? String
//               {
//
//                rtpcapability=val
//
//            }
//            if let val2 = self[key] as? Int {
//                rtpcapability = "\(val2)"
//
//            }
//            if let val3 = self[key] as? Double {
//                rtpcapability = "\(val3)"
//
//            }
//            if let val4 = self[key] as? CGFloat {
//                rtpcapability="\(val4)"
//
//            }
//            if let val5 = self[key] as? Float {
//                rtpcapability = "\(val5)"
//
//            }
//            return rtpcapability
//        }
    ///获取Int值
    func intValue(_ key:Key)->Int{
        if let va = self[key]{
            return "\(va)".intValue()
        }
        return 0
    }
    
    ///获取Int值，replace若获取失败返回的值
    func intValue(_ key:Key,replace:Int)->Int{
        if let va = self[key]{
            return "\(va)".intValue()
        }
        return replace
    }
    
    ///获取字典
    func dictionary(_ key:Key)->[String:Any]{
        let dic = self[key] as? [String:Any] ?? [:]
        return dic
    }
    
    ///数组
    func array(_ key:Key)->[[String:Any]]{
        let array = self[key] as? [[String:Any]] ?? []
        return array
    }
}
