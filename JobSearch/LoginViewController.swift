//
//  LoginViewController.swift
//  JobSearch
//
//  Created by Carl Chen on 3/6/15.
//  Copyright (c) 2015 Purdue Bang. All rights reserved.
//

import UIKit

class LoginViewController: UITableViewController, UITextFieldDelegate{
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    var socket = SIOSocket()
    var username:UITextField = UITextField()
    var password:UITextField = UITextField()
    
    //var data : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 245, green: 146, blue: 108, alpha: 1)]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 245.0/255, green: 146.0/255, blue: 108.0/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 245, green: 146, blue: 108, alpha: 1)

        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            return 3
        }
        return 2
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 1 {
//            let name1:UILabel = UILabel()
//            let username:UITextField = UITextField()
//            
//            name1.text = "Username:"
//            name1.frame.size = CGSizeMake(200, 50)
//            username.borderStyle = UITextBorderStyle.RoundedRect
//            username.frame.origin = CGPointMake(name1.frame.origin.x+name1.frame.size.width+10, name1.frame.origin.y)
//            username.frame.size = CGSizeMake(200, cell.frame.size.height-10)
//            cell.contentView.addSubview(name1)
//            
//            cell.contentView.addSubview(username)
////            let constraint:NSLayoutConstraint = NSLayoutConstraint(item: username, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: name1, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 5)
////            username.addConstraint(constraint)
//            
////            let constraint1:NSLayoutConstraint = NSLayoutConstraint(item: name1, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: cell.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20)
////            let constraint2:NSLayoutConstraint = NSLayoutConstraint(item: name1, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: name1.superview, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 5)
////            let constraint3:NSLayoutConstraint = NSLayoutConstraint(item: name1, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: name1.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
////            name1.superview?.addConstraint(constraint1)
////            name1.superview?.addConstraint(constraint2)
////            name1.superview?.addConstraint(constraint3)
//            
            //Username row
            //cell = (tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as CustomTableViewCell)
            let cell = (tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as CustomTableViewCell)
            cell.label1.text = "Email       "
            cell.textField1.delegate = self
            cell.textField1.keyboardType = UIKeyboardType.EmailAddress
            username = cell.textField1
            return cell
        } else if indexPath.section == 0 && indexPath.row == 2 {
            let cell = (tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as CustomTableViewCell)
            cell.label1.text = "Password"
            cell.textField1.secureTextEntry = true;
            cell.textField1.delegate = self;
            password = cell.textField1
            return cell
            //Password row
        } else if indexPath.section == 0 && indexPath.row == 0 {
            let cell = (tableView.dequeueReusableCellWithIdentifier("image",forIndexPath: indexPath) as CustomTableViewCell)
            cell.imageView1.image = UIImage(named: "Group")
            cell.backgroundColor = UIColor.clearColor()
            return cell
        } else if indexPath.section == 1 && indexPath.row == 0{
            //Submit row
            let cell = tableView.dequeueReusableCellWithIdentifier("submit", forIndexPath:indexPath) as UITableViewCell
            cell.textLabel?.text = "Login"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("submit", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = "Sign Up"
            return cell
            
        }
        
        //cell.textLabel?.text="hello"
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
                let userInfo = NSDictionary(objectsAndKeys: self.username.text,"email",self.password.text,"password")
                println(userInfo)
                
                
                self.socket.emit("login", args: [userInfo])
                self.socket.on("response", callback: { (args:[AnyObject]!)  in
                    let arg = args as SIOParameterArray
                    //println(arg.firstObject!)
                    let dict = arg[0] as NSDictionary
                    if  dict["code"] as Int != 200 {
                        let alert = UIAlertView(title: "Incorrect email or password", message: "Incorrect email or password, please check your input", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    } else {
                        let defaults = NSUserDefaults.standardUserDefaults()
                        //println("token is " + (dict["token"] as String))
                        defaults.setValue(dict["data"], forKey: "token")
                        NSNotificationCenter.defaultCenter().postNotificationName("loggedin", object: nil)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    //let code: AnyObject? = dict["message"]
                    
                    //self.data.append(code! as String)
                    //self.tableView.reloadData()
                })
            })
        } else if indexPath.section == 1 {
            self.performSegueWithIdentifier("showSignup", sender: self)
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 200
        } else {
            return 40
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
