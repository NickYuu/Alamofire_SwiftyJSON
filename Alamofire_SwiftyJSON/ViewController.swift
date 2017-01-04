//
//  ViewController.swift
//  Alamofire_SwiftyJSON
//
//  Created by YU on 2017/1/3.
//  Copyright © 2017年 YU. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    fileprivate lazy var tableView = UITableView()
    
    var data: JSON = JSON([[:]])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        loadData { [weak self] (json, error) in
            guard error == nil      else { return }
            guard let json = json   else { return }
            
            self?.data = json["result", "results"]
            self?.tableView.reloadData()
        }
        
    }
    
    
}

extension ViewController {
    
    fileprivate func setupTableView() -> Void {
        
        let fullScreenSize      = UIScreen.main.bounds.size
        tableView.frame         = CGRect(x: 0, y: 20, width: fullScreenSize.width, height: fullScreenSize.height - 20)
        tableView.dataSource    = self
        tableView.delegate      = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data.arrayValue[indexPath.row]["stitle"].stringValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("點擊了:\(indexPath.row)")
    }
}

extension ViewController {
    
    var netTool: NetworkTools { return .shareInstance }
    var urlString: String {
        return "http://data.taipei/opendata/datalist/apiAccess"
    }
    var parameters: [String:AnyObject] {
        return [
            "scope" :"resourceAquire" as AnyObject,
            "rid":"36847f3f-deff-4183-a5bb-800737591de5" as AnyObject
        ]
    }
    
    func loadData(finished:@escaping (_ result: JSON?, _ error: Error?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            self?.netTool.requestData(urlString: (self?.urlString)!, parameters: self?.parameters) { (result, error) in
                guard error == nil else{
                    print(error!.localizedDescription)
                    DispatchQueue.main.async {
                        finished(nil, error!)
                    }
                    return
                }
                guard let result = result else { return }
                let json = JSON(result)
                DispatchQueue.main.async {
                    finished(json, nil)
                }
            }
        }
    }
}



