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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        let request = PhoneNumberRequest(num: phoneNumber)
        println(request.url())
        
        Alamofire.manager.request(Method.GET, request.url()).responseJSON(
            options: NSJSONReadingOptions.MutableContainers, completionHandler: {
                (_, _, data, err) -> Void in
                if let data: AnyObject = data {
                    ResponseManager.instance.phone = PhoneNumberResponse(data: data)
                    self.tableView.reloadData();
                    self.numberTextField.resignFirstResponder()
                }
            }
        )
    }
    
    // table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PhoneNumberResponse.resultKey.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell = "phone_result_cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as! UITableViewCell
        var key = PhoneNumberResponse.resultKey[indexPath.row]
        cell.textLabel?.text = key
        if let phone = ResponseManager.instance.phone {
            cell.detailTextLabel?.text = phone.resultValue[key]
        }
        return cell
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        numberTextField.resignFirstResponder()
    }
}

