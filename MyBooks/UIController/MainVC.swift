//
//  ViewController.swift
//  MyBooks
//
//  Created by Dodi Sitorus on 09/01/21.
//

import UIKit

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var LoadingView: UIView!
    
    @IBOutlet weak var CollectionView_Book: UICollectionView!
    @IBOutlet weak var heightConstraint_CollectionView_Book: NSLayoutConstraint!
    
    @IBOutlet weak var label_GreetUser: UILabel!
    @IBOutlet weak var label_GreetingMore: UILabel!
    
    @IBOutlet weak var BtnView_Add: CircleCardView!
    
    @IBOutlet weak var TF_SearchBook: UITextField!
    
    private let refreshControll = UIRefreshControl()
    
    private var listBook: [Book] = []
    
    private var listBook_Default: [Book] = []
    
    private var notificationName: String = "BackHandlerMain"
    
    private var updatedState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // initiate view
        self.initialView()
        
        // set gesture
        self.TapGestureInitial()
        
        // get list book
        self.getListBook()
        
        // intitate notificatin center when success edited
        self.NotificationCenterInit()
        
        self.LoadingView.isHidden = false
        self.scrollView.isHidden = true
        
        LocalStore.get(key: keyStores.token) { (token) in
            print(token)
        }
        LocalStore.get(key: keyStores.statusLogin) { (status) in
            print(status)
        }
        
        self.TF_SearchBook.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.updatedState == true {
            
            self.getListBook()
        }
        
        self.updatedState = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        LocalStore.getMulti(keys: [keyStores.statusLogin, keyStores.token]) { (dataLocal) in
         
            if dataLocal[0].value != "true" {

                let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(controller, animated: false)
            }
        }
        
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
    
    // START :: ===> Initial View
    // -----------------------------------------------------------
    func initialView() {
        
        self.scrollView.isHidden = true
        
        // refresh controll
        refreshControll.addTarget(self, action: #selector(self.refreshControllScrollView), for: .valueChanged)
        refreshControll.attributedTitle = NSAttributedString(string: "Loading data...")
        self.scrollView.refreshControl = refreshControll
        
        // set greeting name user
        LocalStore.get(key: keyStores.fullname) { (name) in
            self.label_GreetUser.text = "Hai \(name),"
            self.label_GreetingMore.attributedText = NSAttributedString(string: "\(NSLocalizedString("greetingMainScreen", comment: "")) 🙂")
        }
    }
    
    @objc func refreshControllScrollView() {

        self.refreshControll.beginRefreshing()
        
        self.getListBook()
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
                
                self.updatedState = true
                
            }
        }
    }
    // END :: ===> Notification Center Init
    // -----------------------------------------------------------
    
    
    // START::: Config of Collection View
    // ====================================================================
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.listBook.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BooksCell", for: indexPath) as! BooksCell
        
        cell.name.text = self.listBook[indexPath.row].name
        
        cell.btnDetail.tag = indexPath.row
        cell.btnDetail.addTarget(self, action: #selector(self.onActionNavigateDetailBook(sender:)), for: .touchUpInside)
        
        let height = self.CollectionView_Book.contentSize.height
        self.heightConstraint_CollectionView_Book.constant = height
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let name: String = "\(self.listBook[indexPath.row].name)"
        let height = calculateSizeOf(text: name, view: self.view, spacing: 91, fontSize: 19, fontWeight: .medium, fontName: "AvenirNext-Medium").height
        
        return CGSize(width: self.view.frame.width, height: 42 + height)
    }
    
    // END::: Config of Collection View
    // ====================================================================
    
    // START::: Request Data
    // ====================================================================
    
    func getListBook() {
        
        LocalStore.get(key: keyStores.token) { (token) in
            
            Service.Alamofire_JSON(vc: self, urlString: "books?token=" + token, method: "GET") { (data, error) in
                
                if error?.errorCode == 403 {
                    LocalStore.removeAll { (state) in
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                        let controller = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        
                        self.navigationController?.pushViewController(controller, animated: false)
                    }
                }
                
                if (data != nil) {
                    
                    if let response: [String: Any] = data?[0] {
                     
                        let responseData: [String: Any] = response["data"] as? [String: Any] ?? [:]
                        let status_code: Int = response["status_code"] as? Int ?? 0
                        
                        print(responseData)
                        
                        if status_code == 200 {
                            let dataBooks: [[String: Any]] = responseData["books"] as? [[String: Any]] ?? []
                            
                            var list: [Book] = []
                            
                            for i in 0..<dataBooks.count {
                                
                                let id: String = dataBooks[i]["id"] as? String ?? "";
                                let name: String = dataBooks[i]["name"] as? String ?? "";
                                let description: String = dataBooks[i]["description"] as? String ?? "";
                                    
                                list.append(Book(id: id, name: name, desc: description))
                            }
                            
                            self.listBook = list
                            
                            self.listBook_Default = list
                            
                            self.scrollView.isHidden = false
                            
                            self.CollectionView_Book.reloadData()
                            
                        } else {
                            let desc_err: String = response["description"] as? String ?? "-"
                            AlertIOS(vc: self, title: NSLocalizedString("failed", comment: ""), message: desc_err)
                        }
                        
                        self.refreshControll.endRefreshing()
                        
                        self.LoadingView.isHidden = true
                    }
                }
            }
        }
        
    }
    
    // END::: Request Data
    // ====================================================================

    // START::: Action
    // ====================================================================
    @objc func onActionNavigateDetailBook(sender: UIButton) {
        
        let index: Int = sender.tag
        
        // set touch down button effect
        let indexPath: IndexPath = IndexPath(row: index, section: 0)
        let cell = CollectionView_Book.cellForItem(at: indexPath) as! BooksCell
        self.touchDownButtonOn(view: cell.parentView)
        
        let id: String = self.listBook[index].id
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "BookDetail", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
        
        controller.id = id

        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func onNavigateFormBook(_ sender: Any) {
        
        setOpacityTapGesture(VC: self, InitialView: self.BtnView_Add)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "FormBook", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "FormBookVC") as! FormBookVC
        
        controller.navigateFor = keyStores.createNew

        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func OnLogout(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sign Out", message: NSLocalizedString("warningLogout", comment: ""), preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertAction.Style.destructive, handler: { _ in
            //Cancel Action
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            
            signOutAccount(vc: self) { (state) in
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                let controller = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                
                self.navigationController?.pushViewController(controller, animated: true)
                
//                DispatchQueue.main.async {
//                    if #available(iOS 13, *) {
//                        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = controller
//                    } else {
//                        UIApplication.shared.keyWindow?.rootViewController = controller
//                    }
//                }
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func OnNavigateProfile(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC

        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func touchDownButtonOn(view: UIView) {
        
        setOpacityTapGesture(VC: self, InitialView: view)
    }
    // END::: Action
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
    
    
    // END::: Text Field Config Search Auto Complete
    // ====================================================================
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        self.autoComplete(key: txtAfterUpdate)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.autoComplete(key: "")
        return true
    }
    
    func autoComplete(key: String) {
        if key == "" {
            self.listBook = self.listBook_Default
            
            self.CollectionView_Book.reloadData()
        } else {
            
            let filtered: [Book] = self.listBook_Default.filter { (book) -> Bool in
                book.name.lowercased().contains(key.lowercased())
            }
            
            self.listBook = filtered
            
            self.CollectionView_Book.reloadData()
        }
    }
}

class BooksCell: UICollectionViewCell {
    
    @IBOutlet weak var parentView: BookCardView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var btnDetail: UIButton!
    
}

