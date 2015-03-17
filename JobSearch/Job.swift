//
//  Job.swift
//  JobSearch
//
//  Created by Gelei Chen on 15/3/7.
//  Copyright (c) 2015年 Purdue Bang. All rights reserved.
//

import Foundation

class Job:NSObject{
    var longitude: Double
    var latitude : Double
    var salary : String
    var title : String
    var detail : String
    var date:String
    var expireDate:String
    var jobID : String
    var tags :NSArray
    var UUID : String
    var postID : String
    
    init(longitude:Double,latitude:Double,salary:String,title:String,detail:String,date:String,expireDate:String,jobID:String,tags:NSArray,UUID:String,postID:String){
        self.longitude = longitude
        self.latitude = latitude
        self.salary = salary
        self.title = title
        self.detail = detail
        self.date = date
        self.expireDate = expireDate
        self.jobID = jobID
        self.tags = tags
        self.UUID = UUID
        self.postID = postID
    }
}