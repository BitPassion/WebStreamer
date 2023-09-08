//
//  TabsViewController.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/1/23.
//

import UIKit

protocol TabsViewControllerDelegate {
    func didSelectLiveURL(_ url: LiveURL)
}

class TabsViewController: WSViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tabsCollectionView: UICollectionView!
    @IBOutlet weak var newButtonView: UIView!
    @IBOutlet weak var newButton: UIButton!
    
    fileprivate var urls: [LiveURL] = []
    
    var delegate: TabsViewControllerDelegate? = nil
    var showsBackButton: Bool = false
    var isFromBrowser: Bool = false
    var selectedURL: LiveURL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
        
        layoutView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchURLs()
        
        TabBarViewController.current.tabBarView.tabs = LiveURLManager.shared.urls.count
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { context in
            self.layoutView()
            self.tabsCollectionView.reloadData()
        } completion: { context in
            
        }
    }
    
    fileprivate func initView() {
        newButtonView.shadow(6.0)
    }
    
    fileprivate func layoutView() {
        var frame = searchView.frame
        frame.size.width = UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - 120.0
        frame.origin.x = (UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - frame.width) / 2.0
        searchView.frame = frame
        
        if showsBackButton == false {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    fileprivate func searchURLs() {
        if searchTextField.text == "" {
            urls = LiveURLManager.shared.urls
        } else {
            urls = LiveURLManager.shared.urls.filter({ url in
                return url.url.lowercased().contains(searchTextField.text!.lowercased())
            })
        }
        tabsCollectionView.reloadData()
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "NewTabViewController" {
            let controller = segue.destination as! NewTabViewController
            controller.delegate = self
        }
    }

    // MARK: - IBAction
    @IBAction func didTapNewTab(_ sender: Any) {
        performSegue(withIdentifier: "NewTabViewController", sender: nil)
    }
}

// MARK: - UITextFieldDelegate
extension TabsViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchURLs()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - NewTabViewControllerDelegate
extension TabsViewController: NewTabViewControllerDelegate {
    func didAddNewTab(_ url: LiveURL, _ viewController: NewTabViewController) {
        TabBarViewController.current.performSegue(withIdentifier: "BrowserViewController", sender: url)
    }
}

// MARK: - UICollectionViewDataSource
extension TabsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCollectionCell", for: indexPath) as! TabCollectionCell
        let url = urls[indexPath.item]
        cell.url = url
        cell.isSelection = selectedURL?.id == url.id
        cell.delegate = self
        cell.index = indexPath.item
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TabsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = urls[indexPath.item]
        LiveURLManager.shared.currentURLIndex = LiveURLManager.shared.urls.firstIndex(where: { _url in
            return url.id == _url.id
        }) ?? -1
        if isFromBrowser {
            delegate?.didSelectLiveURL(url)
            dismiss(animated: true)
        } else {
            TabBarViewController.current.performSegue(withIdentifier: "BrowserViewController", sender: url)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TabsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var count: CGFloat = 2.0
        if Utilities.isPad {
            count = 3.0
        }
        if UIApplication.orientation() == .landscapeLeft || UIApplication.orientation() == .landscapeRight {
            count = 3.0
            if Utilities.isPad {
                count = 4.0
            }
        }
        let width = floor(collectionView.frame.width - (count + 1.0) * 20.0) / count
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
}

// MARK: - TabCollectionCellDelegate
extension TabsViewController: TabCollectionCellDelegate {
    func didTapRemove(_ cell: TabCollectionCell) {
        Utilities.showAlertView(error: nil, title: APP_ALERT_TITLE, message: "Are you sure you want to delete this URL?", from: self, cancel: "Cancel") {
            if let url = cell.url {
                LiveURLManager.shared.removeURL(url)
                if let connection = LiveStreamManager.shared.connection(with: url.connectionId) {
                    LiveStreamManager.shared.removeConnection(connection)
                }
            }
            self.urls.remove(at: cell.index)
            self.tabsCollectionView.deleteItems(at: [IndexPath(item: cell.index, section: 0)])
            TabBarViewController.current.updateTabs()
        }
    }
}
