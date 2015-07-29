//
//  HisViewController.swift
//  QueryPhoneNumber
//
//  Created by tutujiaw on 15/7/27.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import UIKit

class HisViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var curDate = "yyyyMMdd".date()
        var request = HisRequest(serverId: "148-1", appId: "4150")
        println(request.url())
        Alamofire.manager.request(Method.GET, request.url()).responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: {
            (_, _, data, err) -> Void in
            if let data: AnyObject = data {
                ResponseManager.instance.his = HisResponse(data: data)
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let result = ResponseManager.instance.his?.result {
            return result.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let hisCell = "hisCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(hisCell, forIndexPath: indexPath) as! UITableViewCell
        if let result = ResponseManager.instance.his?.result {
            var key = result.keys.array[indexPath.row]
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = result[key] as? String
        }
        return cell
    }
    
}