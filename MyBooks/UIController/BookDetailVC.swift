//
//  BookDetailVC.swift
//  MyBooks
//
//  Created by Dodi Sitorus on 10/01/21.
//

import UIKit

class BookDetailVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var LoadingView: UIView!
    
    @IBOutlet weak var label_Name: UILabel!
    @IBOutlet weak var label_Desc: UILabel!
    @IBOutlet weak var label_Date: UILabel!
    @IBOutlet weak var label_DateLabel: UILabel!
    
    var id: String = ""
    
    private var nameFinal: String = ""
    private var descFinal: String = ""
    
    private let refreshControll = UIRefreshControl()
    
    private var notificationName: String = "BackHandlerDetail"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.getDetailBook()
        
        // intitate view
        self.initialView()
        
        // intitate notificatin center when success edited
        self.NotificationCenterInit()
    }
    
    // START :: ===> Initial View
    // -----------------------------------------------------------
    func initialView() {
        
        self.scrollView.isHidden = true
        self.LoadingView.isHidden = false
        
        // refresh controll
        refreshControll.addTarget(self, action: #selector(self.refreshControllScrollView), for: .valueChanged)
        self.scrollView.refreshControl = refreshControll
    }
    
    @objc func refreshControllScrollView() {

        self.refreshControll.beginRefreshing()
        
        self.scrollView.isHidden = true
        self.LoadingView.isHidden = false
        
        self.getDetailBook()
    }
    // END :: ===> Initial View
    // -----------------------------------------------------------
    
    // START :: ===> Notification Center Init
    // -----------------------------------------------------------
    func NotificationCenterInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name(rawValue: self.notificationName), object: nil)
    }
    
    // 2 step back handler
    @objc func onDidReceiveData(_ notification:Notification) {
        
        if let data = notification.userInfo as? [String: String]
        {
            
            if data["update"] == "true" {
                
                self.getDetailBook()
                
            }
        }
    }
    // END :: ===> Notification Center Init
    // -----------------------------------------------------------
    
    @IBAction func onNavigateEdit(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "FormBook", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "FormBookVC") as! FormBookVC
        
        controller.id = id
        controller.nameFinal = self.nameFinal
        controller.descFinal = self.descFinal

        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // START::: Request Data
    // ====================================================================
    func getDetailBook() {
        
        LocalStore.get(key: keyStores.token) { (token) in
            
            Service.Alamofire_JSON(vc: self, urlString: "books/detail?token=" + token + "&id=" + self.id, method: "GET") { (data, error) in
                
                if (data != nil) {
                    
                    if let response: [String: Any] = data?[0] {
                     
                        let responseData: [String: Any] = response["data"] as? [String: Any] ?? [:]
                        let status_code: Int = response["status_code"] as? Int ?? 0
                        
                        if status_code == 200 {
                            let name: String = responseData["name"] as? String ?? ""
                            let desc: String = responseData["description"] as? String ?? ""
                            let modifiedAt: Int = responseData["modifiedAt"] as? Int ?? 0
                            let createdAt: Int = responseData["createdAt"] as? Int ?? 0
                            var date: Int = createdAt
                            
                            self.nameFinal = name
                            self.descFinal = desc
                            
                            self.label_Name.text = name
                            self.label_Desc.text = desc
                            
                            if modifiedAt != createdAt {
                                date = modifiedAt
                                
                                self.label_DateLabel.text = NSLocalizedString("lastEditAt", comment: "")
                            }
                            
                            // ============= SET MESSAGE TIME AM PM =================
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "id_ID")
                            dateFormatter.timeZone = TimeZone(identifier: "UTC+7")
                            dateFormatter.dateFormat = "dd MMMM yyyy hh:mm a"
                            dateFormatter.amSymbol = "AM"
                            dateFormatter.pmSymbol = "PM"
                            
                            let timeInterval: Double = Double(date / 1000)
                            
                            let dateTimeAmPm = dateFormatter.string(from: Date(timeIntervalSinceNow: timeInterval))
                            
                            self.label_Date.text = dateTimeAmPm
                            
                        } else {
                            
                            let desc_err: String = response["description"] as? String ?? "-"
                            AlertIOS(vc: self, title: NSLocalizedString("failed", comment: ""), message: desc_err)
                        }
                        
                        self.scrollView.isHidden = false
                        self.LoadingView.isHidden = true
                        
                        self.refreshControll.endRefreshing()
                    }
                }
            }
        }
        
    }
    
    // END::: Request Data
    // ====================================================================
}

class BookDetailNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
