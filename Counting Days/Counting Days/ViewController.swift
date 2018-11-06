//
//  ViewController.swift
//  Counting Days
//
//  Created by apple on 2018/10/31.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var backView: UIView!
    var tableView:UITableView!
    var labelArray:[UILabel] = [UILabel]()
    
    let holidayArray:[String] = [NSLocalizedString("CHRISTMAS", comment: "Christmas"),NSLocalizedString("KWANZA", comment: "Kwanza"),NSLocalizedString("CHANUKAH", comment: "Chanukah")]
    let colorArray:[UIColor] = [UIColor.red,UIColor.green,UIColor.blue]
    var debugMode:Bool = false
    var holidayType:Int = 0
    var storeDay:Int = 0

    @IBOutlet var debugSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backView.center = self.view.center
        NotificationCenter.default.addObserver(self, selector: #selector(receiverNotification), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        let resetBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 44))
        resetBtn.addTarget(self, action: #selector(resetBtnClick), for: .touchUpInside)
        let reserBtnTitle = NSLocalizedString("RESET_NAME", comment: "Reset")
        resetBtn.setTitle(reserBtnTitle, for: .normal)
        resetBtn.setTitleColor(UIColor.black, for: .normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: resetBtn)
        
        let holidayBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 44))
        holidayBtn.addTarget(self, action: #selector(holidayBtnClick), for: .touchUpInside)
        
        
        let holidayBtnTitle = NSLocalizedString("SELECT_HOLIDAY", comment: "Select Holiday")
        holidayBtn.setTitle(holidayBtnTitle, for: .normal)
        holidayBtn.setTitleColor(UIColor.black, for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: holidayBtn)
        
        self.tableView = UITableView.init(frame: CGRect.init(x: self.view.frame.size.width - 30 - 200, y: (self.navigationController?.navigationBar.frame.size.height)! + 30, width: 200, height: 230))
        self.tableView.isHidden = true
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.tableView.backgroundColor = UIColor.yellow
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.readStore()
    }
    
    func readStore() -> Void {
        self.debugMode = UserDefaults.standard.bool(forKey: "debug")
        self.holidayType = UserDefaults.standard.integer(forKey: "holidayType")
        self.storeDay = UserDefaults.standard.integer(forKey: "storeDay")

        print(self.debugMode)
        print(self.holidayType)
        print(self.storeDay)

        self.debugSwitch.isOn = self.debugMode
        if (self.holidayType > 0) {
            self.navigationItem.title = self.holidayArray[self.holidayType - 1]
            self.view.backgroundColor = self.colorArray[self.holidayType - 1]
        } else {
            self.navigationItem.title = "Counting Days"
            self.view.backgroundColor = UIColor.brown
        }
        for index in 0..<self.storeDay {
                let label:UILabel = self.backView.viewWithTag(index + 1) as! UILabel
                label.text = self.createEmoji()
        }
    }
    
    @objc func labelClick(tag:Int) -> Void {
        let clicklabel:UILabel = self.backView.viewWithTag(tag) as! UILabel
        if (clicklabel.text != String.init(format: "%d", tag)) {
            return
        }
        if (!self.debugMode) {
            if (!self.check(currentIndex: tag)) {
                let message = NSLocalizedString("TIPS_IN_ORDER", comment: "Please tap the days in order")
                let yesTitle = NSLocalizedString("TIPS_IN_ORDER", comment: "YES")
                let alt = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
                let yesAction = UIAlertAction.init(title: yesTitle, style: .default) { (action) in
                }
                alt.addAction(yesAction)
                self.present(alt, animated: true, completion: nil)
                return
            }
        }
   
        let label:UILabel = self.backView.viewWithTag(tag) as! UILabel
        let basicAnimation = CABasicAnimation.init(keyPath: "transform.rotation.y")
        basicAnimation.toValue = NSNumber.init(value: Double.pi)
        basicAnimation.duration = 0.3
        basicAnimation.isCumulative = true
        basicAnimation.repeatCount = 0
        label.layer.add(basicAnimation, forKey: "rotationAnimation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            label.text = self.createEmoji()
        }
        print("tag === ",tag)
        UserDefaults.standard.set(tag, forKey: "storeDay")
        UserDefaults.standard.synchronize()
    }
    
    func createEmoji() -> String {
        let str = "0x1f600"
        let scnner = Scanner.init(string: str)
        var result:UInt32 = 0
        scnner.scanHexInt32(&result)
        let c = Character(UnicodeScalar.init(result + arc4random() % 40)!)
        let emoji = String(c)
        return emoji
    }
    
    func check(currentIndex:Int) -> Bool {
        for index in 0..<currentIndex-1 {
            let label:UILabel = self.backView.viewWithTag(index + 1) as! UILabel
            let indexStr = String.init(format: "%zd", index + 1)
            if label.text == indexStr {
                return false
            }
        }
        return true
    }
    
    @objc func resetBtnClick() -> Void {
        if (self.debugMode) {
            self.reset()
            return
        }
        let message = NSLocalizedString("TIPS_RESER_IT", comment: "Make sure you reset it")
        let yesTitle = NSLocalizedString("YES", comment: "YES")
        let noTitle = NSLocalizedString("NO", comment: "NO")
        let alt = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        let noAction = UIAlertAction.init(title: noTitle, style: .cancel, handler: nil)
        let yesAction = UIAlertAction.init(title: yesTitle, style: .default) { (action) in
            self.reset()
        }
        alt.addAction(noAction)
        alt.addAction(yesAction)
        self.present(alt, animated: true, completion: nil)
    }
    
    @objc func holidayBtnClick() -> Void {
        self.tableView.isHidden = false
    }
    
    func reset() -> Void {
        for index in 0..<self.backView.subviews.count {
            let label:UILabel = self.backView.viewWithTag(index + 1) as! UILabel
            let intTitle = String.init(format: "%d", index + 1)
            label.text = intTitle
        }
        UserDefaults.standard.set(0, forKey: "storeDay")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(0, forKey: "holidayType")
        UserDefaults.standard.synchronize()
        self.readStore()
    }
    
    @objc func receiverNotification() -> Void {
        self.backView.center = self.view.center
        self.tableView.frame = CGRect.init(x: self.view.frame.size.width - 30 - 200, y: (self.navigationController?.navigationBar.frame.size.height)! + 30, width: 200, height: 230)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.holidayArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.textLabel?.text = self.holidayArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationItem.title = self.holidayArray[indexPath.row]
        self.view.backgroundColor = self.colorArray[indexPath.row]
        self.tableView.isHidden = true
        UserDefaults.standard.set(indexPath.row + 1, forKey: "holidayType")
        UserDefaults.standard.synchronize()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (self.debugMode) {
            return true
        } else {
            if (!self.check(currentIndex: 24)) {
                self.labelClick(tag: 24)
                return false
            } else {
                return true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let theSegue = segue.destination as! HolidaysViewController
        theSegue.navigationItem.title = self.navigationItem.title
    }
    
    @IBAction func debugClick(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "debug")
        UserDefaults.standard.synchronize()
        self.debugMode = sender.isOn
        if (!self.debugMode) {
            self.reset()
        }
    }
    
    @IBAction func tapClick(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag
        self.labelClick(tag: tag!)
    }
    
}

