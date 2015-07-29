//
//  JokeViewController.swift
//  QueryPhoneNumber
//
//  Created by tutujiaw on 15/7/26.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import UIKit

class JokeViewController : UIViewController, UITableViewDelegate, UITableViewDataSource,
UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.requestJoke(1)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var joke = ResponseManager.instance.joke
        if component == 3 {
            return (joke != nil) ? joke!.allPages : 1
        } else {
            return 1
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        var joke = ResponseManager.instance.joke
        if component == 0 {
            return "记录数"
        } else if component == 1 {
            return String(joke?.allNum ?? 0)
        } else if component == 2 {
            return "页数"
        } else if component == 3 {
            return String(joke != nil ? row + 1 : 0)
        } else {
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 3 {
            self.requestJoke(row)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let joke = ResponseManager.instance.joke {
            return joke.contentList.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let jokeCellId = "jokeCellId"
        let cell = tableView.dequeueReusableCellWithIdentifier(jokeCellId, forIndexPath: indexPath) as! UITableViewCell
        if let joke = ResponseManager.instance.joke {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds)
            var srcText = joke.contentList[indexPath.row].text
            var attrStr = NSAttributedString(data: srcText.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
            cell.textLabel?.attributedText = attrStr
        } else {
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func requestJoke(page: Int) -> Void {
        var request = JokeRequest(serverId: "341-1", appId: "4150", time: "yyyy-MM-dd".date(), page: page)
        println(request.url())
        Alamofire.manager.request(Method.GET, request.url()).responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: {
            (_, _, data, err) -> Void in
            if let data: AnyObject = data {
                ResponseManager.instance.joke = JokeResponse(data: data)
                self.tableView.reloadData()
                self.pickerView.reloadAllComponents()
            }
        })
    }
}
