//
//  ProfileVC.swift
//  MyBooks
//
//  Created by Dodi Sitorus on 10/01/21.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var Image_Avatar: UIImageView!
    @IBOutlet weak var Label_Fullname: UILabel!
    @IBOutlet weak var Label_username: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.isHidden = true
        self.LoadingView.isHidden = false

        self.getProfileUser()
    }
    
    // START::: Request Data
    // ====================================================================
    
    func getProfileUser() {
        
        LocalStore.get(key: keyStores.token) { (token) in
            
            Service.Alamofire_JSON(vc: self, urlString: "users/me?token=" + token, method: "GET") { (data, error) in
                
                if (data != nil) {
                    
                    if let response: [String: Any] = data?[0] {
                     
                        let responseData: [String: Any] = response["data"] as? [String: Any] ?? [:]
                        let status_code: Int = response["status_code"] as? Int ?? 0
                        
                        if status_code == 200 {
                            
                            let fullname: String = responseData["fullname"] as? String ?? "-"
                            let username: String = responseData["username"] as? String ?? "-"
                            
                            self.Label_Fullname.text = fullname
                            self.Label_username.text = "\(NSLocalizedString("username", comment: "")) : @\(username)"
                            
                        } else {
                            let desc_err: String = response["description"] as? String ?? "-"
                            AlertIOS(vc: self, title: NSLocalizedString("failed", comment: ""), message: desc_err)
                        }
                       
                        self.scrollView.isHidden = false
                        self.LoadingView.isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func onSignOut(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sign Out", message: NSLocalizedString("warningLogout", comment: ""), preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertAction.Style.destructive, handler: { _ in
            //Cancel Action
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            
            self.showLoading()
            
            signOutAccount(vc: self) { (state) in
             
                self.hideLoading { (state) in
             
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                    let controller = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                    
//                    DispatchQueue.main.async {
//                        if #available(iOS 13, *) {
//                            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = controller
//                        } else {
//                            UIApplication.shared.keyWindow?.rootViewController = controller
//                        }
//                    }
                }
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    // END::: Request Data
    // ====================================================================
    
    // START::: Loading Show & Hide
    // ====================================================================
    func showLoading() {
        
        let alert = UIAlertController(title: "Loading...", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Tutup", style: .destructive, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideLoading(completionHandler: @escaping (Bool) -> ()) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completionHandler(true)
        }
    }
    // END::: Loading Show & Hide
    // ====================================================================
}

class ProfileNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
