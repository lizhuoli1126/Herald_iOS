//
//  LectureTableViewController.swift
//  Herald
//
//  Created by lizhuoli on 15/4/5.
//  Copyright (c) 2015年 WangShuo. All rights reserved.
//

import UIKit

class LecturePredictTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIGetter{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noLectureLabel: UILabel!
    
    var detailArray:[NSDictionary]?
    
    var firstLoad = true
    var initResult = false
    var API = HeraldAPI()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "讲座预告"
        initResult = Tool.initNavigationAPI(self)
        if initResult{
            noLectureLabel.hidden = true
            self.API.delegate = self
            API.sendAPI("lectureNotice")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if (initResult && firstLoad){
            firstLoad = false
            Tool.showProgressHUD("正在查询讲座信息")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        Tool.dismissHUD()
        API.cancelAllRequest()
    }
    
    func getResult(APIName: String, results: JSON) {
        Tool.showSuccessHUD("获取数据成功")
        detailArray = results["content"].arrayObject as? [NSDictionary]
        tableView.reloadDataAnimateWithWave(WaveAnimation.RightToLeftWaveAnimation)
    }
    
    func getError(APIName: String, statusCode: Int) {
        Tool.showErrorHUD("获取数据失败")
        noLectureLabel.hidden = false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailArray?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier:String = "LecturePredictTableViewCell"
        let row = indexPath.row
        
        var cell: LecturePredictTableViewCell? = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LecturePredictTableViewCell
        if cell == nil{
            let nibArray:NSArray = NSBundle.mainBundle().loadNibNamed("LecturePredictTableViewCell", owner: self, options: nil)
            cell = nibArray.objectAtIndex(0) as? LecturePredictTableViewCell
        }
        
        if let detailInfoArray = detailArray{
            cell?.lectureNoticeDateLabel.text = detailInfoArray[row].valueForKey("date") as? String ?? ""
            cell?.lectureNoticeTopicLabel.text = detailInfoArray[row].valueForKey("topic") as? String ?? ""
            cell?.lectureNoticeSpeakerLabel.text = detailInfoArray[row].valueForKey("speaker") as? String ?? ""
            cell?.lectureNoticeLocationLabel.text = detailInfoArray[row].valueForKey("location") as? String ?? ""
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        let lectureDetailVC = LecturePredictDetailViewController()
        if let detailInfoArray = detailArray{
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            lectureDetailVC.initWebView(detailInfoArray[row].valueForKey("detail") as! String)
            self.navigationController!.pushViewController(lectureDetailVC, animated: true)
        }
    }
}