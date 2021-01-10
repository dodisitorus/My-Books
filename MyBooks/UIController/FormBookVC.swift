//
//  FormEditBookVC.swift
//  MyBooks
//
//  Created by Dodi Sitorus on 10/01/21.
//

import UIKit

class FormBookVC: UIViewController {

    @IBOutlet weak var TF_Name: UITextField!
    @IBOutlet weak var TF_Desc: UITextView!
    
    @IBOutlet weak var BtnView_Save: BookCardView!
    
    var id: String = ""
    var nameFinal: String = ""
    var descFinal: String = ""
    
    var navigateFor: String = "edit"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // intitate view
        self.initialView()
        
        // set gesture
        self.TapGestureInitial()
    }
    
    // START :: ===> Initial View
    // -----------------------------------------------------------
    func initialView() {
        
        self.TF_Name.text = self.nameFinal
        self.TF_Desc.text = self.descFinal
        
        if self.navigateFor == "edit" {
            self.title = NSLocalizedString("editBook", comment: "")
        } else {
            self.title = NSLocalizedString("createNewBook", comment: "")
        }
    }
    // END :: ===> Initial View
    // -----------------------------------------------------------
    
    
    // START::: Initiate of Tap Gesture
    // ====================================================================
    func TapGestureInitial()  {
        // set tap gesture on View
        view.addGestureRecognizer(setTapGesture())
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
        default:
            print("none")
        }
    }
    // END::: Initiate of Tap Gesture
    // ====================================================================
    
    @IBAction func OnSaveBook(_ sender: Any) {
        
        self.checkFormInput { (state, message) in
            
            if state == true {
                
                self.showLoading()
                
                if self.navigateFor == keyStores.createNew {
                    
                    self.requestCreateNewBook()
                } else {
                 
                    self.requestEditBook()
                }
            } else {
                
                AlertIOS(vc: self, title: NSLocalizedString("pleaseCheckInput", comment: ""), message: message)
            }
        }
    }
    
    func checkFormInput(completionHandler: @escaping(Bool, String) -> ()) {
        var allow:  Bool = true
        var message: String = ""
        
        if self.TF_Name.text == "" {
            allow = false
            message = NSLocalizedString("nameCannotEmpty", comment: "")
        } else if self.TF_Desc.text == "" {
            allow = false
            message = NSLocalizedString("descCannotEmpty", comment: "")
        }
        
        completionHandler(allow, message)
    }
    
    func requestEditBook() {
        
        LocalStore.get(key: keyStores.token) { (token) in
            
            let bodyJson: [String: String] = ["name" : self.TF_Name.text ?? "", "description": self.TF_Desc.text ?? "", "id": self.id]
            
            Service.Alamofire_MultipartFormData(vc: self, urlString: "books/edit?token=" + token, parameters: bodyJson) { (data, error) in
                
                self.hideLoading { (load) in
                    
                    if let response: [String: Any] = data?[0] {
                        
                        let status_code: Int = response["status_code"] as? Int ?? 0
                        
                        let message: String = response["description"] as? String ?? "-"
                        
                        if status_code == 200 {
                            
                            AlertIOS(vc: self, title: NSLocalizedString("success", comment: ""), message: message)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true, completion: nil)
                                
                                self.notifyPreviousScreen()
                            }

                        } else {
                            
                            AlertIOS(vc: self, title: NSLocalizedString("failed", comment: ""), message: message)
                        }
                    }
                }
            }
        }
    }
    
    func requestCreateNewBook() {
        
        LocalStore.get(key: keyStores.token) { (token) in
            
            let bodyJson: [String: String] = ["name" : self.TF_Name.text ?? "", "description": self.TF_Desc.text ?? ""]
            
            Service.Alamofire_MultipartFormData(vc: self, urlString: "books/insert?token=" + token, parameters: bodyJson) { (data, error) in
                
                self.hideLoading { (load) in
                    
                    if let response: [String: Any] = data?[0] {
                        
                        let status_code: Int = response["status_code"] as? Int ?? 0
                        
                        let message: String = response["description"] as? String ?? "-"
                        
                        if status_code == 200 {
                            
                            AlertIOS(vc: self, title: NSLocalizedString("success", comment: ""), message: message)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.dismiss(animated: true, completion: nil)
                                
                                self.notifyPreviousScreen()
                            }

                        } else {
                            
                            AlertIOS(vc: self, title: NSLocalizedString("failed", comment: ""), message: message)
                        }
                    }
                }
            }
        }
    }
    
    func notifyPreviousScreen() {
        
        DispatchQueue.main.async {
            let dataInfo = ["update": "true"]
            
            if self.navigateFor == keyStores.edit {
                NotificationCenter.default.post(name: NSNotification.Name("BackHandlerDetail"), object: nil, userInfo: dataInfo)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("BackHandlerMain"), object: nil, userInfo: dataInfo)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {

            self.navigationController?.popViewController(animated: true)
        })
    }
    
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

class FormBookNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
