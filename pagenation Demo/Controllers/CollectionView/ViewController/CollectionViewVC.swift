//
//  CollectionViewVC.swift
//  pagenation Demo
//
//  Created by Nihar Vaghela on 27/10/23.
//

import UIKit
import Kingfisher
import GoogleSignIn

@available(iOS 16.0, *)
class CollectionViewVC: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet var collectionView: UICollectionView!
    
    //MARK: - Variable
    
    var isLoading = false
    var imageUrls: [String] = []
    var currentPage = 1
    let itemsPerPage = 100
    var arrImgList = [String]()
    var limit = 20
    var imgCount = 0
    var index = 0
    var loadingIndicator: UIActivityIndicatorView!
    var profilePopupView: ProfileBottomPopupView?
    var email : String?
    var userName : String?
    var profileImg : UIImage?
    var visualEffectView: UIVisualEffectView?
    var profileButton : UIBarButtonItem?
    var logOutButton : UIBarButtonItem?
    var BackButton : UIBarButtonItem?
    
    //MARK: - ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        fetchImages(page: 1)
        setupLoadingIndicator()
        // Setup Navigation Bar
        let imageIcon = UIImage(systemName: "person.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        profileButton = UIBarButtonItem(image: imageIcon, style: .plain, target: self, action: #selector(profileButtonTapped))
        self.navigationItem.leftBarButtonItem = profileButton
        logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logoutTapped))
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // Change the color to blue
        logOutButton?.setTitleTextAttributes(titleAttributes, for: .normal)
        self.navigationItem.rightBarButtonItem = logOutButton
        logOutButton?.isHidden = true
        
        self.title = "CollectionView VC"
        
    }
    
    //MARK: - Function methods
    
    @objc func profileButtonTapped() {
        if profilePopupView == nil {
            let userProfilePopup = ProfileBottomPopupView()
            userProfilePopup.nameLabel.text = UserDefaults.standard.string(forKey: "name")
            userProfilePopup.emailLabel.text = UserDefaults.standard.string(forKey: "email")
            userProfilePopup.userImageView.image = UIImage(systemName: "person")
            profilePopupView = userProfilePopup
            showBottomPopup(view: userProfilePopup)
        }
    }
    @objc func logoutTapped() {
        logOutButton?.isHidden = true
        profileButton?.isHidden = false
        dismissProfilePopup()
        removeVisualEffectOverlay()
        let googleSignIn = GIDSignIn.sharedInstance
        
        // Perform sign-out action from Google
        googleSignIn.signOut()
        
        // Clear user data and reset login state
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.set(false, forKey: "isLogin")
        
        // Clear the current user
        googleSignIn.disconnect { error in
            if let error = error {
                // Handle error during disconnection if needed
                print("Error during disconnect: \(error.localizedDescription)")
            } else {
                // Update UI or navigate to the login screen
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    // Reset any UI elements or perform additional actions after logout
                }
            }
        }
    }
    
    @objc func BackTapped() {
        logOutButton?.isHidden = true
        profileButton?.isHidden = false
        dismissProfilePopup()
        removeVisualEffectOverlay()
        
    }
    
    func showBottomPopup(view: UIView) {
        logOutButton?.isHidden = false
        profileButton?.isHidden = true
        addVisualEffectOverlay()
        
        // Adjust the position of the popup view
        view.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: 300)
        self.view.addSubview(view)
        
        UIView.animate(withDuration: 0.3) {
            view.frame = CGRect(x: 0, y: self.view.frame.size.height - 300, width: self.view.frame.size.width, height: 300)
        }
    }
    func dismissProfilePopup() {
        // Dismiss the popup and remove the translucent overlay
        if let popup = profilePopupView {
            popup.removeFromSuperview()
            profilePopupView = nil
        }
        
        if let overlay = self.view.viewWithTag(999) {
            overlay.removeFromSuperview()
        }
    }
    
    func addVisualEffectOverlay() {
        let blurEffect = UIBlurEffect(style: .light)
        visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView?.frame = self.view.bounds
        visualEffectView?.alpha = 0.8
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(visualEffectViewTapped))
        visualEffectView?.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(visualEffectView!)
    }
    
    @objc func visualEffectViewTapped() {
        logOutButton?.isHidden = true
        profileButton?.isHidden = false
        dismissProfilePopup()
        removeVisualEffectOverlay()
    }
    
    func removeVisualEffectOverlay() {
        visualEffectView?.removeFromSuperview()
        visualEffectView = nil
    }
    
    func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        let indicatorY = self.view.bounds.size.height - 20 - loadingIndicator.bounds.size.height / 2
        loadingIndicator.center = CGPoint(x: self.view.bounds.size.width / 2, y: indicatorY)
        loadingIndicator.hidesWhenStopped = true
        self.view.addSubview(loadingIndicator)
    }
    func fetchImages(page: Int) {
        let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(itemsPerPage)")!
        URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            if let data = data {
                do {
                    let imageInfo = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                    for info in imageInfo {
                        if let imageUrl = info["download_url"] as? String {
                            self.arrImgList.append(imageUrl)
                        }
                    }
                    imageUrls.removeAll()
                    imgCount = arrImgList.count
                    while index < limit
                    {
                        imageUrls.append(arrImgList[index])
                        index = index + 1
                        
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at:self.collectionView.indexPathsForVisibleItems)
                        self.isLoading = false
                        self.loadingIndicator.stopAnimating()
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

//MARK: - Extension CollectionView methods

@available(iOS 16.0, *)
extension CollectionViewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewItemCell", for: indexPath) as! CollectionViewItemCell
        if let imageUrl = URL(string: imageUrls[indexPath.row]) {
            cell.imgOutput.contentMode = .scaleToFill
            cell.imgOutput.kf.setImage(with: imageUrl)
            cell.imgOutput.layer.cornerRadius = 20
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == imageUrls.count - 1 && !isLoading {
            let nextIndex = indexPath.row + 1
            
            if nextIndex < arrImgList.count {
                let remainingCount = min(10, arrImgList.count - nextIndex)
                let endIndex = nextIndex + remainingCount
                
                isLoading = true // Set loading state to true
                
                loadingIndicator.startAnimating()
                
                imageUrls.append(contentsOf: arrImgList[nextIndex..<endIndex])
                
                collectionView.insertItems(at: (nextIndex..<endIndex).map { IndexPath(item: $0, section: 0) })
                self.perform(#selector(loadCollection), with: nil, afterDelay: 0.5)
            }
        }
    }
    @objc func loadCollection() {
        isLoading = false
        loadingIndicator.stopAnimating()
    }
}


