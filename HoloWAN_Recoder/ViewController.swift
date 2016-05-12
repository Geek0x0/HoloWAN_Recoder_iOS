//
//  ViewController.swift
//  HoloWAN_Recoder
//
//  Created by 史凯迪 on 16/5/10.
//  Copyright © 2016年 msy. All rights reserved.
//

import UIKit
import GBPing
import Charts
import Popover

var sendFreq: Double = 1;
var sendSize: UInt = 56;

class ViewController: UIViewController, GBPingDelegate, ChartViewDelegate  {

    @IBOutlet weak var Input: UITextField!
    @IBOutlet weak var Chart: LineChartView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var actionBtn: UIButton!
    
    private var ping: GBPing!
    private var enablePing: Bool = false;
    private var pingCount: Int = 0;
    private let pingMaxCount: Int = 10000;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLineChart();
    }
    
    private func initXaxis()
    {
        self.Chart.xAxis.labelPosition = .Bottom;
        self.Chart.xAxis.drawGridLinesEnabled = true;
        self.Chart.xAxis.drawAxisLineEnabled = true;
        self.Chart.xAxis.spaceBetweenLabels = 10;
        self.Chart.xAxis.drawLabelsEnabled = true;
    }
    
    private func initYaxis()
    {
        self.Chart.rightAxis.enabled = false;
        self.Chart.leftAxis.axisMinValue = 0;
        self.Chart.leftAxis.axisMaxValue = 40;
    }
    
    private func initDataLine()
    {
        let line = LineChartDataSet(yVals: [ChartDataEntry(value: 0, xIndex: 0)], label: "Delay");
        line.colors = [UIColor.blackColor()];
        line.drawCirclesEnabled = false;
        line.mode = .CubicBezier;
        
        let data: LineChartData = LineChartData(xVals: [nil], dataSets: [line]);
        data.setValueTextColor(UIColor.whiteColor());
        data.setDrawValues(false);
        
        self.Chart.data = data;
    }
    
    private func initLineChart()
    {
        self.Chart.delegate = self;
        self.Chart.descriptionText = "";
        self.Chart.noDataTextDescription = "";
        self.Chart.dragEnabled = true;
        self.Chart.scaleXEnabled = true;
        self.Chart.drawGridBackgroundEnabled = true;
        self.Chart.pinchZoomEnabled = true;
        self.Chart.drawGridBackgroundEnabled = true;
        self.Chart.descriptionTextColor = UIColor.whiteColor();
        self.Chart.gridBackgroundColor = UIColor.darkGrayColor();
        
        self.initXaxis();
        self.initYaxis();
        self.initDataLine();
    }
    
    private func addChartData(value: Double)
    {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "HH:mm:ss";
        let xvalue = dateFormatter.stringFromDate(NSDate());
        
        if value > self.Chart.leftAxis.axisMaxValue {
            self.Chart.leftAxis.axisMaxValue = Double((Int(value / 10) + 1) * 10)
        }
        
        let set1 = self.Chart.data?.getDataSetByIndex(0);
        let index = set1?.entryCount;
        let chartEntry = ChartDataEntry(value: value, xIndex: index!);
        set1?.addEntry(chartEntry);
        self.Chart.data?.addXValue(xvalue);
        self.Chart.notifyDataSetChanged();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func Start(sender: AnyObject) {
        if self.enablePing {
            
            self.ping.stop()
            self.actionBtn.setTitle("开始", forState: .Normal)
            self.enablePing = false;
            
        } else {
            
            if let ipString: String! = Input.text! {
                
                print(ipString);
                
                self.ping = GBPing();
                self.ping.host = ipString;
                self.ping.delegate = self
                self.ping.timeout = 1;
                self.ping.pingPeriod = sendFreq;
                self.ping.payloadSize = sendSize;
                
                ping.setupWithBlock({ success, error in
                    if success {
                        self.Chart.data?.getDataSetByIndex(0).clear()
                        self.ping.startPinging();
                    } else {
                        //TODO
                    }
                })
                
                self.actionBtn.setTitle("停止", forState: .Normal)
                self.enablePing = true;
                
            } else {
                //TODO
            }
        }
    }
    
    @IBAction func CloseKeyboard(sender: AnyObject) {
        Input.resignFirstResponder()
    }
    
    func stopPing() {
        self.ping.stop()
        self.ping = nil
        self.enablePing = false
    }
    
    func ping(pinger: GBPing!, didFailToSendPingWithSummary summary: GBPingSummary!, error: NSError!) {
        //print("FFSENT> \(summary) \(error)")
    }
    
    func ping(pinger: GBPing!, didFailWithError error: NSError!) {
        //print("FAIL> \(error)")
    }
    
    func ping(pinger: GBPing!, didReceiveReplyWithSummary summary: GBPingSummary!) {
        //print("REPLY SUCCESS> \(summary)")
        
        let tx_time = Double(summary.sendDate.timeIntervalSince1970 * 1000);
        let rx_time = Double(summary.receiveDate.timeIntervalSince1970 * 1000)
        
        if self.pingCount >= self.pingMaxCount {
            self.stopPing()
            return
        }
        
        //print("REPLY SUCCESS> \(rx_time - tx_time)")
        addChartData(rx_time - tx_time);
        self.pingCount += 1;
    }
    
    func ping(pinger: GBPing!, didReceiveUnexpectedReplyWithSummary summary: GBPingSummary!) {
        //print("RREPLY Unexpected> \(summary)")
        
    }
    
    func ping(pinger: GBPing!, didSendPingWithSummary summary: GBPingSummary!) {
        //print("SENT> \(summary)")
        
    }
    
    func ping(pinger: GBPing!, didTimeoutWithSummary summary: GBPingSummary!) {
        //print("TIMEOUT> \(summary)")
    }
    
    private var popover: Popover!
    private var tableView: UITableView!
    private var popoverOptions: [PopoverOption] = [
        .Type(.Down),
        .BlackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    private var items = ["发包频率", "报文大小", "更多操作"]
    
    private func initSettingMenu() {
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width:
            self.view.frame.width, height: 132));
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = false;
        self.tableView.separatorStyle = .None;
        
        self.tableView.registerNib(UINib(nibName:"settingFreqCell", bundle:nil),
                                   forCellReuseIdentifier:"settingFreqCell")
        self.tableView.registerNib(UINib(nibName:"settingPktSizeCell", bundle:nil),
                                   forCellReuseIdentifier:"settingPktSizeCell")
    }
    
    @IBAction func settingMenuAction(sender: AnyObject) {
        self.initSettingMenu();
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil);
        self.popover.show(self.tableView, fromView: self.settingButton);
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.popover.dismiss();
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.row) {
        case 0:
            let cell: settingFreqCell = tableView.dequeueReusableCellWithIdentifier("settingFreqCell") as! settingFreqCell;
            cell.title.text = self.items[indexPath.row];
            
            cell.dropDown.dataSource = [
                "0.2",
                "0.5",
                "1.0",
                "2.0",
                "5.0",
            ]
            
            cell.selectButton.setTitle("\(sendFreq)", forState: .Normal)
            
            cell.dropDown.selectionAction = { [unowned cell] (index, item) in
                cell.selectButton.setTitle(item, forState: .Normal)
                sendFreq = (item as NSString).doubleValue;
            }
            cell.dropDown.anchorView = cell.selectButton
            cell.dropDown.bottomOffset = CGPoint(x: 0, y:cell.selectButton.bounds.height)
            
            return cell;
        case 1:
            let cell: settingPktSizeCell = tableView.dequeueReusableCellWithIdentifier("settingPktSizeCell") as! settingPktSizeCell;
            cell.title.text = self.items[indexPath.row];
            cell.input.text = "\(sendSize)"
            
            return cell;
        default:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel?.text = self.items[indexPath.row]
            return cell;
        }
    }
}
