//
//  JobDetailViewController.swift
//
//
//  Created by Gelei Chen on 15/3/7.
//
//

import UIKit
import MapKit

class JobDetailViewController: UIViewController,UIAlertViewDelegate {
    
    
    @IBAction func deletePressed(sender: UIButton) {
        //postid token
        let alertBigController = UIAlertController(title: "Please conform", message: "Are you sure you want to continue?", preferredStyle: .Alert)
        
        
        
        let yes = UIAlertAction(title: "Yes", style: .Default) { (_) in
            let defaults = NSUserDefaults.standardUserDefaults()
            if let token:String = defaults.valueForKey("token") as? String {
                SIOSocket.socketWithHost("http://nerved.herokuapp.com", response: { (socket:SIOSocket!) in
                    self.socket = socket;
                    let dict = NSDictionary(objectsAndKeys: token,"token",self.currentJob!.postID,"postid")
                    self.socket.emit("delete", args: [dict])
                    self.socket.on("response", callback: { (args:[AnyObject]!)  in
                        let arg = args as SIOParameterArray
                        let dict = arg[0] as NSDictionary
                        println(dict)
                        if dict.objectForKey("message") as String == "post delete failed" {
                            let alertController = UIAlertController(title: "Sorry", message: "Since you are not the poster of this quest, you can't delete this quest", preferredStyle: .Alert)
                            let ok = UIAlertAction(title: "OK", style: .Default) { (_) in
                                
                                
                            }
                            
                            alertController.addAction(ok)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: "Successful", message: "You have successfully deleted the quest", preferredStyle: .Alert)
                            let ok = UIAlertAction(title: "OK", style: .Default) { (_) in
                            NSNotificationCenter.defaultCenter().postNotificationName("addedJob", object: nil)
                                self.navigationController?.popViewControllerAnimated(true)
                                
                            }
                            
                            alertController.addAction(ok)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    })
                })
            } else {
                self.performSegueWithIdentifier("showLogin", sender: self)
            }
            
            
        }
        
        let cancel = UIAlertAction(title: "No", style: .Default) { (_) in
            
            
        }
        alertBigController.addAction(yes)
        alertBigController.addAction(cancel)
        self.presentViewController(alertBigController, animated: true, completion: nil)
        
        
        
        
        
    }
    var currentJob:Job?
    var socket = SIOSocket()
    var phoneNumber : String?
    var email : String?
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var apply: UIButton!
    @IBAction func apply(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let token:String = defaults.valueForKey("token") as? String {
            SIOSocket.socketWithHost("http://nerved.herokuapp.com", response: { (socket:SIOSocket!) in
                self.socket = socket;
                let dict = NSDictionary(objectsAndKeys: token,"token",self.currentJob!.postID,"postid")
                self.socket.emit("accept", args: [dict])
                self.socket.on("response", callback: { (args:[AnyObject]!)  in
                    let arg = args as SIOParameterArray
                    let dict = arg[0] as NSDictionary
                    println(dict)
                    
                })
            })
            
            
            let alertController = UIAlertController(title: "Publisher's Contact", message: nil, preferredStyle: .Alert)
            
            var oneAction:UIAlertAction
            var twoAction:UIAlertAction
            
            if let thePhone = phoneNumber {
                
                oneAction = UIAlertAction(title: "Phone: \(thePhone)", style: .Default, handler: nil)
                if let theEmail = email {
                    twoAction = UIAlertAction(title: "Email:\(theEmail)", style: .Default, handler: nil)
                } else {
                    twoAction = UIAlertAction(title: "Email: N/A", style: .Default, handler: nil)
                }
                
            } else {
                oneAction = UIAlertAction(title: "Phone: N/A", style: .Default, handler: nil)
                if let theEmail = email {
                    twoAction = UIAlertAction(title: "Email:\(theEmail)", style: .Default, handler: nil)
                } else {
                    twoAction = UIAlertAction(title: "Email: N/A", style: .Default, handler: nil)
                }
            }
            let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            
            alertController.addAction(oneAction)
            alertController.addAction(twoAction)
            alertController.addAction(ok)
            self.presentViewController(alertController, animated: true, completion: nil)
            self.apply.backgroundColor = UIColor(red: 81/255.0, green: 193/255.0, blue: 183/255.0, alpha: 1)
            self.apply.tintColor = UIColor(red: 245, green: 146, blue: 108, alpha: 1)
            self.apply.setTitle("Show Publisher's Contact", forState: UIControlState.Normal)
            
        } else {
            self.performSegueWithIdentifier("showLogin", sender: self)
            
        }
        
    }
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var jobDescription: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var jobID: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delete.backgroundColor = UIColor(red: 255/255.0, green: 110/255.0, blue: 128/255.0, alpha: 1)
        self.delete.tintColor = UIColor(red: 245, green: 146, blue: 108, alpha: 1)
        SIOSocket.socketWithHost("http://nerved.herokuapp.com", response: { (socket:SIOSocket!) in
            self.socket = socket;
            let dict = NSDictionary(objectsAndKeys: self.currentJob!.UUID,"uuid")
            self.socket.emit("uuid2phone", args: [dict])
            self.socket.on("response", callback: { (args:[AnyObject]!)  in
                let arg = args as SIOParameterArray
                let dict = arg[0] as NSDictionary
                self.email = dict.objectForKey("data")![0] as? String
                self.phoneNumber = dict.objectForKey("data")![1] as? String
                
            })
        })
        salary.textColor = UIColor(red: 245.0/255, green: 146.0/255, blue: 108.0/255, alpha: 1)
        self.apply.backgroundColor = UIColor(red: 245.0/255, green: 146.0/255, blue: 108.0/255, alpha: 1)
        self.apply.tintColor = UIColor(red: 245, green: 146, blue: 108, alpha: 1)
        map.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(currentJob!.latitude, currentJob!.longitude), 5000, 5000), animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(currentJob!.latitude, currentJob!.longitude)
        map.addAnnotation(annotation)
        self.hidesBottomBarWhenPushed = true
        
        self.jobDescription.text = currentJob!.detail
        self.postTime.text = "Update : \(currentJob!.date)"
        self.jobTitle.text = currentJob!.title
        self.salary.text = currentJob!.salary
        self.endDate.text = currentJob!.expireDate
        self.jobID.text = "Job ID :\(currentJob!.jobID)"
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
