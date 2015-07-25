//
//  ViewController.swift
//  QueryPhoneNumber
//
//  Created by tutujiaw on 15/7/21.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let appId = "4150"
    let secret = "6a619d14ba434e82b121ce7fa137faf8"
    var resultKey = ["city", "name", "area code", "post code", "prov", "prov code"]
    var resultValue = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultValue[self.resultKey[0]] = "unkown"
        self.resultValue[self.resultKey[1]] = "unkown"
        self.resultValue[self.resultKey[2]] = "unkown"
        self.resultValue[self.resultKey[3]] = "unkown"
        self.resultValue[self.resultKey[4]] = "unkown"
        self.resultValue[self.resultKey[5]] = "unkown"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func queryNumber(sender: UIButton) {
        var phoneNumber = numberTextField.text
        if phoneNumber.isEmpty {
            return
        }
        
        let request = PhoneNumberRequest(serverId: "6-1", appId: "4150", num: phoneNumber)
        println(request.url())
        
        Alamofire.manager.request(Method.GET, request.url()).responseJSON(
            options: NSJSONReadingOptions.MutableContainers, completionHandler: {
                (_, _, data, err) -> Void in
                if let data: AnyObject = data {
                    var json = JSON(data)
                    var resCode = json["showapi_res_code"].int
                    if resCode == 0 {
                        var body:JSON = json["showapi_res_body"]
                        self.resultValue[self.resultKey[0]] = body["city"].string
                        self.resultValue[self.resultKey[1]] = body["name"].string
                        self.resultValue[self.resultKey[2]] = body["areaCode"].string
                        self.resultValue[self.resultKey[3]] = body["postCode"].string
                        self.resultValue[self.resultKey[4]] = body["prov"].string
                        self.resultValue[self.resultKey[5]] = body["provCode"].string
                        self.tableView.reloadData();
                        self.numberTextField.resignFirstResponder()
                    }
                }
            }
        )
    }
    
    // table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultKey.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell = "phone_result_cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as! UITableViewCell
        var title = resultKey[indexPath.row]
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = resultValue[title]
        return cell
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        numberTextField.resignFirstResponder()
    }
}

