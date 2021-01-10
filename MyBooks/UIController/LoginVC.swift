//
//  LoginVC.swift
//  MyBooks
//
//  Created by Dodi Sitorus on 09/01/21.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var TF_Username: UITextField!
    @IBOutlet weak var TF_Password: UITextField!
    
    @IBOutlet weak var BtnView_Login_Email: CardView!
    @IBOutlet weak var btnEyePassword: UIButton!
    
    private var notificationName: String = "BackHandlerHome"
    
    private var statePassword: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initiate Tap Gesture - UIView -> Btn Action
        self.TapGestureInitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // START::: Initiate of Tap Gesture
    // ====================================================================
    func TapGestureInitial()  {
        // set tap gesture on View
        view.addGestureRecognizer(setTapGesture())
        
        // set tap gesture on BtnView Sign In with Email
        self.BtnView_Login_Email.addGestureRecognizer(setTapGesture())
    }
    
    func setTapGesture() -> UITapGestureRecognizer {
        // ui tap gesture
        var tapRecognizer = UITapGestureRecognizer()
        // set selector action for gesture
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.selectorTapGesture(sender:)))
        // return gesture
        return tapRecognizer
    }
    
    @objc func selectorTapGesture(sender: UITapGestureRecognizer) {
        switch sender.view {
        case self.view:
            view.endEditing(true)
        case self.BtnView_Login_Email:
            self.SignInWithUsername()
            setOpacityTapGesture(VC: self, InitialView: self.BtnView_Login_Email, time: .now() + 0.2)
        default:
            print("none")
        }
    }
    // END::: Initiate of Tap Gesture
    // ====================================================================
    
    // START::: Request API
    // ====================================================================
    func SignInWithUsername() {
        
        self.showLoading()
        
        let bodyJson: [String: String] = ["username" : self.TF_Username.text ?? "", "password": self.TF_Password.text ?? ""]
        
        Service.Alamofire_MultipartFormData(vc: self, urlString: "users/login", parameters: bodyJson) { (data, error) in
            
            self.hideLoading { (load) in
                
                if (data != nil) {
                    
                    if let response: [String: Any] = data?[0] {
                        
                        let responseData: [String: Any] = response["data"] as? [String: Any] ?? [:]
                        let status_code: Int = response["status_code"] as? Int ?? 0
                        
                        if status_code == 200 {
                            let token: String = responseData["token"] as? String ?? ""
                            
                            let user: [String: Any] = responseData["user"] as? [String: Any] ?? [:]
                            
                            let fullname: String = user["fullname"] as? String ?? ""
                            let userid: String = user["userid"] as? String ?? ""
                            let username: String = user["username"] as? String ?? ""
                            
                            let tokenData = token.data(using: .utf8)
                            let statusLoginData = "true".data(using: .utf8)
                            
                            let fullnameData = fullname.data(using: .utf8)
                            let useridData = userid.data(using: .utf8)
                            let usernameData = username.data(using: .utf8)
                            
                            LocalStore.setMulti(keys: [keyStores.statusLogin, keyStores.token, keyStores.fullname, keyStores.userid, keyStores.username], values: [statusLoginData!, tokenData!, fullnameData!, useridData!, usernameData!], completionHandler: { (result) in
                                
                                // notify when back
                                DispatchQueue.main.async {
                                    let dataInfo = ["login": "true"]
                                    NotificationCenter.default.post(name: NSNotification.Name(self.notificationName), object: nil, userInfo: dataInfo)
                                    // back to previous screen
                                }
                                
                                // next navigate to home screen
                                self.navigateHomeScreen()
                            })
                            
                        } else {
                            let desc_err: String = response["description"] as? String ?? "-"
                            AlertIOS(vc: self, title: NSLocalizedString("failed", comment: ""), message: desc_err)
                        }
                    }
                    
                } else {
                    print(error ?? "")
                    print(error?.localizedDescription ?? "")
                    AlertIOS(vc: self, title: "Gagal", message: error?.localizedDescription ?? "")
                }
            }
        }
    }
    // END::: Request API
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
    
    // START::: Navigation Handler
    // ====================================================================
    func navigateHomeScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "MainVC") as! MainVC

        self.navigationController?.pushViewController(controller, animated: true)
        
//        DispatchQueue.main.async {
//            if #available(iOS 13, *) {
//                UIApplication.shared.windows.first?.rootViewController = controller
//            } else {
//                UIApplication.shared.keyWindow?.rootViewController = controller
//            }
//        }
    }
    // END::: Navigation Handler
    // ====================================================================
    
    @IBAction func setStatePassword(_ sender: Any) {
        
        self.TF_Password.isSecureTextEntry = self.statePassword
        
        if self.statePassword == false {
            
            self.btnEyePassword.setImage(UIImage(named: "show-password"), for: .normal)
            
        } else {
            self.btnEyePassword.setImage(UIImage(named: "hide-password"), for: .normal)
        }
        
        self.statePassword = !self.statePassword
    }
}

class LoginNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
