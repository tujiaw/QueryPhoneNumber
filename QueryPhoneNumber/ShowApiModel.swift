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
    
    func date() -> String {
        var curDate = NSDate()
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = self // "yyyyMMddHHmmss"
        return timeFormatter.stringFromDate(curDate)
    }
    
    func date(date: NSDate) -> String {
        var timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = self
        return timeFormatter.stringFromDate(date)
    }
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
        self.timestamp = "yyyyMMddHHmmss".date()
    }
    
    func systemUrl() -> String {
        return "\(self.route)\(self.serverId)?showapi_appid=\(self.appId)&showapi_timestamp=\(self.timestamp)"
    }
}

class ShowApiResponse {
    var resCode: Int?
    var resError = ""
    
    init(resCode: Int, resError: String) {
        self.resCode = resCode
        self.resError = resError
    }
}

class PhoneNumberRequest : ShowApiRequest {
    var num = ""
    
    init(num: String) {
        super.init(serverId: "6-1", appId: "4150")
        self.num = num
    }

    func url() -> String {
        var sign = "num\(self.num)showapi_appid\(self.appId)showapi_timestamp\(self.timestamp)\(self.secret)".md5()
        return "\(self.systemUrl())&num=\(self.num)&showapi_sign=\(sign)"
    }
}

class PhoneNumberResponse : ShowApiResponse {
    static let resultKey = ["city", "name", "areaCode", "postCode", "prov", "provCode"]
    var resultValue = [String: String]()
    
    init(data: AnyObject) {
        var json = JSON(data)
        var resCode = json["showapi_res_code"].int ?? -1
        var resError = json["showapi_res_error"].string ?? "response error"
        super.init(resCode: resCode, resError: resError)
        
        if resCode == 0 {
            var body:JSON = json["showapi_res_body"]
            for key in PhoneNumberResponse.resultKey {
                self.resultValue[key] = body[key].string
            }
        }
    }
}

class JokeRequest : ShowApiRequest {
    var time = ""
    var page = 1
    
    init(serverId: String, appId: String, time: String, page: Int) {
        super.init(serverId: serverId, appId: appId)
        self.time = time
        self.page = page
    }
    
    func url() -> String {
        var sign = "page\(self.page)showapi_appid\(self.appId)showapi_timestamp\(self.timestamp)time\(self.time)\(self.secret)".md5()
        return "\(self.systemUrl())&time=\(self.time)&page=\(self.page)&showapi_sign=\(sign)"
    }
}

class JokeResponse : ShowApiResponse {
    struct Content {
        var tile = ""
        var text = ""
        var ct = ""
    }
    
    var allNum: Int = 0
    var allPages: Int = 0
    var contentList: [Content] = []
    var currentPage: Int = 0
    var maxResult: Int = 0
    
    init(data: AnyObject) {
        var json = JSON(data)
        var resCode = json["showapi_res_code"].int ?? -1
        var resError = json["showapi_res_error"].string ?? "response error"
        super.init(resCode: resCode, resError: resError)
        
        if self.resCode == 0 {
            var body:JSON = json["showapi_res_body"]
            println(body)
            if let allNum = body["allNum"].int {
                self.allNum = allNum
            }
            if let allPages = body["allPages"].int {
                self.allPages = allPages
            }
            if let currentPage = body["currentPage"].int {
                self.currentPage = currentPage
            }
            if let maxResult = body["maxResult"].int {
                self.maxResult = maxResult
            }
            if let contentList = body["contentlist"].array {
                for item in contentList {
                    var title = item["title"].string
                    var text = item["text"].string
                    var ct = item["ct"].string
                    if title != nil && text != nil && ct != nil {
                        self.contentList.append(Content(tile: title!, text: text!, ct: ct!))
                    }
                }
            }
        } else {
            println(self.resError)
        }
    }
}

class HisRequest : ShowApiRequest
{
    override init(serverId: String, appId: String) {
        super.init(serverId: serverId, appId: appId)
    }
    
    func url() -> String {
        var sign = "showapi_appid\(self.appId)showapi_timestamp\(self.timestamp)\(self.secret)".md5()
        return "\(self.systemUrl())&showapi_sign=\(sign)"
    }
}

class HisResponse: ShowApiResponse {
    var result: [String: AnyObject]?
    
    init(data: AnyObject) {
        var json = JSON(data)
        var resCode = json["showapi_res_code"].int ?? -1
        var resError = json["showapi_res_error"].string ?? "response error"
        super.init(resCode: resCode, resError: resError)
        if self.resCode == 0 {
            var body:JSON = json["showapi_res_body"]
            if let items = body.dictionaryObject {
                result = items
            }
        }
    }
}

class ResponseManager {
    static var s_instance = ResponseManager()
    class var instance: ResponseManager {
        return s_instance
    }
    
    var phone: PhoneNumberResponse?
    var joke: JokeResponse?
    var his: HisResponse?
}



