//
//  SignUpViewController.swift
//  JobSearch
//
//  Created by Carl Chen on 3/7/15.
//  Copyright (c) 2015 Purdue Bang. All rights reserved.
//
import CoreLocation
import UIKit

class AddViewController: UITableViewController,UITextFieldDelegate , CLLocationManagerDelegate{
    @IBAction func cencel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    var socket = SIOSocket()
    var jobTitle = UITextField()
    var jobDescription = UITextField()
    var remarks = UITextField()
    var duration = UITextField()
    var pay = UITextField()
    var skills = UITextField()
    var location:CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 245, green: 146, blue: 108, alpha: 1)]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 245.0/255, green: 146.0/255, blue: 108.0/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 245, green: 146, blue: 108, alpha: 1)

        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse{
            locationManager.requestWhenInUseAuthorization()
        } else {
            
            locationManager.startUpdatingLocation()
            
            
        }
        self.title = "Add Job"
        
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
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as CustomTableViewCell
            switch indexPath.row {
            case 0:
                cell.label1?.text = "Job Title"
                self.jobTitle = cell.textField1
            case 1:
                cell.label1.text = "Description"
                self.jobDescription = cell.textField1
            case 2:
                cell.label1.text = "Pay per hour"
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
                    cell.textField1.keyboardType = UIKeyboardType.DecimalPad
                }
                self.pay = cell.textField1
            case 3:
                cell.label1.text = "Skills"
                self.skills = cell.textField1
            case 4:
                cell.label1.text = "Duration"
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
                    cell.textField1.keyboardType = UIKeyboardType.PhonePad
                }
                self.duration = cell.textField1
            case 5:
                cell.label1.text = "Remark"
                self.remarks = cell.textField1
            default:
                break
            }
            cell.textField1.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("submit", forIndexPath: indexPath) as UITableViewCell
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
                
                
                
                //println(userInfo)
                
                
                let defaults = NSUserDefaults.standardUserDefaults()
                let token = defaults.valueForKey("token") as String
                println(token)
                let skills = self.skills.text.componentsSeparatedByString(",")
                if let theLocation = self.location {
                    let location = NSDictionary(objectsAndKeys: NSDictionary(objectsAndKeys: "Point","type",[theLocation.longitude, theLocation.latitude],"coordinates"),"location")
                
                //println(location)
                    let userInfo = NSDictionary(objectsAndKeys: self.jobTitle.text,"title",self.jobDescription.text,"description",self.remarks.text, "remarks",skills,"skills",self.pay.text,"comp",(self.duration.text as NSString).doubleValue,"duration",token,"token",location["location"]!,"location")
                    self.socket.emit("post", args: [userInfo])
                } else {
                    let error = UIAlertView(title: "No location Found", message: "Please enable your location in privacy settings", delegate: self, cancelButtonTitle: "OK")
                    error.show()
                }
                self.socket.on("response", callback: { (args:[AnyObject]!)  in
                    let arg = args as SIOParameterArray
                    println(arg.firstObject!)
                    let dict = arg[0] as NSDictionary
                    if  dict["code"] as Int != 200 {
                        let alert = UIAlertView(title: "Incorrect email or password", message: "Incorrect email or password, please check your input", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName("addedJob", object: nil)
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
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let currentLocation = locations {
            let thisLocation : CLLocation = currentLocation[0] as CLLocation
            location = thisLocation.coordinate
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
