//
//  ShowApiModel.swift
//  QueryPhoneNumber
//
//  Created by tutujiaw on 15/7/25.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import Foundation

extension String {
    func md5() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CC_MD5(str!, strLen, result)
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.destroy()
        return String(format: hash as String)
    }
}

func getCurrentTime() -> String {
    var curDate = NSDate()
    var timeFormatter = NSDateFormatter()
    timeFormatter.dateFormat = "yyyyMMddHHmmss"
    return timeFormatter.stringFromDate(curDate)
}

class ShowApiRequest {
    let route = "http://route.showapi.com/"
    let secret = "6a619d14ba434e82b121ce7fa137faf8"
    var serverId = ""
    var appId = ""
    var timestamp = ""
    
    init(serverId: String, appId: String) {
        self.serverId = serverId
        self.appId = appId
        self.timestamp = getCurrentTime()
    }
    
    func systemUrl() -> String {
        return "\(self.route)\(self.serverId)?showapi_appid=\(self.appId)&showapi_timestamp=\(self.timestamp)"
    }
}

class PhoneNumberRequest : ShowApiRequest {
    var num = ""
    
    init(serverId: String, appId: String, num: String) {
        super.init(serverId: "6-1", appId: "4150")
        self.num = num
    }

    func url() -> String {
        var sign = "num\(self.num)showapi_appid\(self.appId)showapi_timestamp\(self.timestamp)\(self.secret)".md5()
        return "\(self.systemUrl())&num=\(self.num)&showapi_sign=\(sign)"
    }
}