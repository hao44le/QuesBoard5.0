//
//  ProfileViewController.swift
//  JobSearch
//
//  Created by Gelei Chen on 15/3/7.
//  Copyright (c) 2015年 Purdue Bang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableview1: UITableView!
    @IBOutlet weak var name: UILabel!
    var loggedin:Bool = false
    var acceptedCourse : [String] = []
    var socket = SIOSocket()
    var jobArray : [Job] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"loggedin:", name: "loggedin", object: nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 245, green: 146, blue: 108, alpha: 1)]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 245.0/255, green: 146.0/255, blue: 108.0/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 245, green: 146, blue: 108, alpha: 1)
        // Do any additional setup after loading the view.
    }
    
    func loggedin(notification: NSNotification) {
        self.tableview1.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0{
            return 2
        } else {
            return 1
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "My Quest"
                
            } else{
                cell.textLabel?.text = "Accepted Quest"
                SIOSocket.socketWithHost("http://nerved.herokuapp.com", response: { (socket:SIOSocket!) in
                    let defaults = NSUserDefaults.standardUserDefaults()
                    if let token:String = defaults.valueForKey("token") as? String {
                        self.socket = socket;
                        let theToken = NSDictionary(objectsAndKeys: token, "token")
                        self.socket.emit("whoami", args: [theToken])
                        self.socket.on("response", callback: { (args:[AnyObject]!)  in
                            let arg = args as SIOParameterArray
                            let dict = arg[0] as NSDictionary
                            let arr: AnyObject = dict.objectForKey("data")!.objectForKey("accepted")!
                            
                            var i = 0
                            while i < arr.count {
                                self.acceptedCourse.append(arr[i] as String)
                                i++
                            }

                    
                })
                    }
                }
            
        )
            }
        }else {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let token:String = defaults.valueForKey("token") as? String {
                SIOSocket.socketWithHost("http://nerved.herokuapp.com", response: { (socket:SIOSocket!) in
                    
                    self.socket = socket;
                    self.socket.on("handshake", callback: { (args:[AnyObject]!)  in
                        let arg = args as SIOParameterArray
                        let dict = arg[0] as NSDictionary
                        //self.UIID.text = uuid as String?
                        
                    })
                    //let userInfo = NSDictionary(objectsAndKeys: self.username.text,"email",self.password.text,"password")
                    //println(userInfo)
                    
                    let theToken = NSDictionary(objectsAndKeys: token, "token")
                    self.socket.emit("whoami", args: [theToken])
                    self.socket.on("response", callback: { (args:[AnyObject]!)  in
                        let arg = args as SIOParameterArray
                        //println(arg.firstObject!)
                        let dict = arg[0] as NSDictionary
                        //println(dict)
                        self.name.text = dict.objectForKey("data")!.objectForKey("name") as? String
                        //let accpptedArray = dict.objectForKey("data")!.objectForKey("accepted")!)
                        //for acc in accpptedArray {
                          //  self.acceptedCourse.append(acc)
                        //}
                        
                        
                        if  dict["code"] as Int != 200 {
                            
                            let alert = UIAlertView(title: "Incorrect email or password", message: "Incorrect email or password, please check your input", delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        } else {
                            
                            //let defaults = NSUserDefaults.standardUserDefaults()
                            //println("token is " + (dict["token"] as String))
                            //defaults.setValue(dict["data"], forKey: "token")
                            //self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        
                        //let code: AnyObject? = dict["message"]
                        
                        //self.data.append(code! as String)
                        //self.tableView.reloadData()
                    })
                })
                cell.textLabel?.text =  "Log Out"
            } else {
                cell.textLabel?.text =  "Login"
                self.name.text = ""
            }
            
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.accessoryType = UITableViewCellAccessoryType.None
            
        }
        
        // Configure the cell...
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let token:String = defaults.valueForKey("token") as? String {

                SIOSocket.socketWithHost("http://nerved.herokuapp.com", response: { (socket:SIOSocket!) in
                    
                    self.socket = socket;
                    let theToken = NSDictionary(objectsAndKeys: self.acceptedCourse, "uuid")
                    self.socket.emit("postfromid", args: [theToken])
                    self.socket.on("response", callback: { (args:[AnyObject]!)  in
                        self.jobArray = []
                        let arg = args as SIOParameterArray
                        //println(arg.firstObject!)
                        let dict = arg[0] as NSDictionary
                        let data: NSArray = dict["data"] as NSArray//get data
                        for entryDict in data{
                            //println(entryDict)
                            
                            //location && coordinate
                            let location:NSDictionary = entryDict.objectForKey("location") as NSDictionary
                            let coordinate:NSArray = (location.objectForKey("coordinates") as NSArray)
                            let title:String = entryDict.objectForKey("title") as String
                            //title
                            let description:String = entryDict.objectForKey("description") as String
                            let salaryDouble:String = entryDict.objectForKey("comp") as String
                            let salary = "$" + salaryDouble
                            
                            let date = entryDict.objectForKey("date") as String
                            let expireDate = entryDict.objectForKey("expire") as String
                            
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                            
                            let dateMid = dateFormatter.dateFromString(date)
                            let expireDateMid = dateFormatter.dateFromString(expireDate)
                            
                            let dateFormatter2 = NSDateFormatter()
                            dateFormatter2.dateFormat = "MMM dd"
                            let dateResult = dateFormatter2.stringFromDate(dateMid!)
                            let expireDateResult = dateFormatter2.stringFromDate(expireDateMid!)
                            
                            
                            let hay = entryDict.objectForKey("postid") as String
                            let endIndex = advance(hay.startIndex, 5)
                            let id = hay.substringToIndex(endIndex)
                            
                            let tags:NSArray = entryDict.objectForKey("tags") as NSArray
                            
                            
                            
                            let uuid = entryDict.objectForKey("uuid") as String
                            
                            
                            let job = Job(longitude: coordinate[0] as Double, latitude: coordinate[1] as Double,salary:salary,title:title,detail:description,date:dateResult,expireDate:expireDateResult,jobID:id,tags:tags,UUID:uuid,postID:hay)
                            self.jobArray.append(job)
                            
                        }
                        
                        self.performSegueWithIdentifier("toAccpted", sender: self)
                        
                    })
                    
                    
                })
            } else {
                self.performSegueWithIdentifier("showLogin", sender: self)
            }
        

        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let token:String = defaults.valueForKey("token") as? String {
                defaults.setValue(nil, forKey: "token")
                self.performSegueWithIdentifier("showLogin", sender: self)
                
            } else {
                
                self.performSegueWithIdentifier("showLogin", sender: self)
                
            }
            
            tableView.reloadData()
            
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        if segue.identifier == "toAccpted" {
            let viewController = segue.destinationViewController as MyAcceptedTableViewController
            viewController.jobArray = self.jobArray
        }
    }
    
    
}
