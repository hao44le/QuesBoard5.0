//
//  SignUpViewController.swift
//  JobSearch
//
//  Created by Carl Chen on 3/7/15.
//  Copyright (c) 2015 Purdue Bang. All rights reserved.
//

import UIKit

class SignUpViewController: UITableViewController,UITextFieldDelegate {
    var socket = SIOSocket()
    var name = UITextField()
    var email = UITextField()
    var profession = UITextField()
    var talents = UITextField()
    var phone = UITextField()
    var password = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign Up"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 245, green: 146, blue: 108, alpha: 1)]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 245.0/255, green: 146.0/255, blue: 108.0/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 245, green: 146, blue: 108, alpha: 1)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 6
        } else {
            return 1
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as CustomTableViewCell
            switch indexPath.row {
            case 0:
                cell.label1?.text = "Name        "
                self.name = cell.textField1
            case 1:
                cell.label1?.text = "Email         "
                self.email = cell.textField1
                cell.textField1.keyboardType = UIKeyboardType.EmailAddress
            case 2:
                cell.label1.text = "Profession "
                self.profession = cell.textField1
            case 3:
                cell.label1.text = "Talents         "
                self.talents = cell.textField1
            case 4:
                cell.label1.text = "Phone Number"
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
                    cell.textField1.keyboardType = UIKeyboardType.PhonePad
                }
                self.phone = cell.textField1
            case 5:
                cell.label1.text = "Password       "
                cell.textField1.secureTextEntry = true
                self.password = cell.textField1
            default:
                break
            }
            cell.textField1.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("signup", forIndexPath: indexPath) as UITableViewCell
            return cell
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1  && indexPath.row == 0{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            SIOSocket.socketWithHost("http://nerved.herokuapp.com", response: { (socket:SIOSocket!) in
                
                self.socket = socket;
                self.socket.on("handshake", callback: { (args:[AnyObject]!)  in
                    let arg = args as SIOParameterArray
                    let dict = arg[0] as NSDictionary
                    //self.UIID.text = uuid as String?
                    
                })
                
                
                let talent = self.talents.text.componentsSeparatedByString(",")
                let userInfo = NSDictionary(objectsAndKeys: self.name.text,"name",self.email.text,"email",self.profession.text, "profession",talent,"talents",self.password.text,"pass",self.phone.text,"phone")
                println(userInfo)
                
                
                self.socket.emit("register", args: [userInfo])
                self.socket.on("response", callback: { (args:[AnyObject]!)  in
                    let arg = args as SIOParameterArray
                    println(arg.firstObject!)
                    let dict = arg[0] as NSDictionary
                    if  dict["code"] as Int != 200 {
                        let alert = UIAlertView(title: "Incorrect email or password", message: "Incorrect email or password, please check your input", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    //let code: AnyObject? = dict["message"]
                    
                    //self.data.append(code! as String)
                    //self.tableView.reloadData()
                })
            })
        } else {
            
        }
        
    }
    
    

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
