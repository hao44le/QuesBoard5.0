//
//  LocationViewController.swift
//  JobSearch
//
//  Created by Carl Chen on 3/6/15.
//  Copyright (c) 2015 Purdue Bang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class LocationViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    var jobArray:[Job] = []
    var currentJob:Job?
    var qTree = QTree()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(40.426102, -86.9096881), 5000, 5000), animated: true)
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        //The "Find me" button
        let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 70, self.view.frame.height - 110, 50, 50)
        button.setImage(UIImage(named: "MyLocation"), forState: .Normal)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSizeMake(0, 0)
        button.layer.shadowRadius = 2
        self.view.addSubview(button)
        
        for job in jobArray {
            let annotation = JobAnnotation(coordinate: CLLocationCoordinate2DMake(job.latitude, job.longitude), title: job.title,subtitle:job.salary)
            self.qTree.insertObject(annotation)
            
            //self.mapView.addAnnotation(annotation)
        }
        self.reloadAnnotations()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func buttonAction(sender:UIButton!)
    {
        let myLocation = mapView.userLocation.coordinate as CLLocationCoordinate2D
        let zoomRegion = MKCoordinateRegionMakeWithDistance(myLocation,5000,5000)
        self.mapView.setRegion(zoomRegion, animated: true)
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(QCluster.classForCoder()) {
            let PinIdentifier = "PinIdentifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(ClusterAnnotationView.reuseId()) as? ClusterAnnotationView
            if annotationView == nil {
                annotationView = ClusterAnnotationView(cluster: annotation)
            }
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
            annotationView!.cluster = annotation
            return annotationView
        }
        return nil
    }

   
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        for job in jobArray {
            if job.title == (view.annotation as JobAnnotation).title {
                self.currentJob = job
                self.performSegueWithIdentifier("transformToJobDetail", sender: self)
            }
        }
    }
    
    func reloadAnnotations(){
        if self.isViewLoaded() == false {
            return
        }
        let mapRegion = self.mapView.region
        let minNonClusteredSpan = min(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5
        let objects = self.qTree.getObjectsInRegion(mapRegion, minNonClusteredSpan: minNonClusteredSpan) as NSArray
        let annotationsToRemove = (self.mapView.annotations as NSArray).mutableCopy() as NSMutableArray
        annotationsToRemove.removeObject(self.mapView.userLocation)
        annotationsToRemove.removeObjectsInArray(objects)
        self.mapView.removeAnnotations(annotationsToRemove)
        let annotationsToAdd = objects.mutableCopy() as NSMutableArray
        annotationsToAdd.removeObjectsInArray(self.mapView.annotations)
        
        self.mapView.addAnnotations(annotationsToAdd)


    }
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.reloadAnnotations()
    }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "transformToJobDetail" {
            let viewController = segue.destinationViewController as JobDetailViewController
            viewController.currentJob = currentJob
        }
        
    }

}
