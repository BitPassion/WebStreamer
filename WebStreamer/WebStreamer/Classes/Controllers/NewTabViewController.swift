//
//  NewTabViewController.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/1/23.
//

import UIKit

protocol NewTabViewControllerDelegate {
    func didAddNewTab(_ url: LiveURL, _ viewController: NewTabViewController)
}

class NewTabViewController: WSViewController {

    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var recentsTableView: UITableView!
    
    var delegate: NewTabViewControllerDelegate? = nil
    
    fileprivate var panView: RMPanView!
    fileprivate var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
        
        layoutView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { context in
            self.layoutView()
        } completion: { context in
            
        }
    }
    
    fileprivate func initView() {
        recentsTableView.sectionHeaderHeight = 0.0
        if #available(iOS 15.0, *) {
            recentsTableView.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        backgroundView = UIView(frame: view.bounds)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        backgroundView.alpha = 0.0
        view.addSubview(backgroundView)
    }
    
    fileprivate func layoutView() {
        var frame = urlView.frame
        frame.size.width = UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - 120.0
        frame.origin.x = (UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - frame.width) / 2.0
        urlView.frame = frame
    }
    
    fileprivate func recentHeaderView() -> UIView {
        let height: CGFloat = Utilities.isPhone ? 32.0 : 48.0
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: recentsTableView.frame.width, height: height)))
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground
        let label = UILabel(frame: CGRect(x: 20.0, y: 0, width: view.frame.width - 40.0, height: view.frame.height))
        label.textColor = .label
        label.font = .custom(size: Utilities.isPhone ? 16.0 : 20.0, weight: .semiBold)
        label.text = "Recent URLs"
        view.addSubview(label)
        
        let button = UIButton(type: .system)
        button.setTitle("VIEW ALL", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .custom(size: Utilities.isPhone ? 16.0 : 20.0, weight: .semiBold)
        button.frame = CGRect(x: view.frame.width - 20.0 - 88.0, y: 0, width: 88.0, height: view.frame.height)
        button.addTarget(self, action: #selector(didTapRecentViewAll(_:)), for: .touchUpInside)
        view.addSubview(button)
        return view
    }
    
    fileprivate func bookmarkHeaderView() -> UIView {
        let height: CGFloat = Utilities.isPhone ? 32.0 : 48.0
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: recentsTableView.frame.width, height: height)))
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground
        let label = UILabel(frame: CGRect(x: 20.0, y: 0, width: view.frame.width - 40.0, height: view.frame.height))
        label.textColor = .label
        label.font = .custom(size: Utilities.isPhone ? 16.0 : 20.0, weight: .semiBold)
        label.text = "Bookmarks"
        view.addSubview(label)
        
        let button = UIButton(type: .system)
        button.setTitle("VIEW ALL", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .custom(size: Utilities.isPhone ? 16.0 : 20.0, weight: .semiBold)
        button.frame = CGRect(x: view.frame.width - 20.0 - 88.0, y: 0, width: 88.0, height: view.frame.height)
        button.addTarget(self, action: #selector(didTapBookmarkViewAll(_:)), for: .touchUpInside)
        button.isHidden = true
        view.addSubview(button)
        return view
    }
    
    @objc fileprivate func didTapRecentViewAll(_ sender: Any) {
        if panView == nil {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "RecentsViewController") as! RecentsViewController
            controller.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            panView = RMPanView(view: controller.view)
            panView.maxHeight = self.view.frame.size.height - self.view.safeAreaInsets.top
            panView.delegate = self
            controller.delegate = self
            addChild(controller)
        }
        
        if panView.visible == true {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1.0
        }
        panView.show(in: self.view, offset: 0)
    }

    @objc fileprivate func didTapBookmarkViewAll(_ sender: Any) {
        if panView == nil {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "RecentsViewController") as! RecentsViewController
            controller.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            panView = RMPanView(view: controller.view)
            panView.maxHeight = self.view.frame.size.height - self.view.safeAreaInsets.top
            panView.delegate = self
            controller.delegate = self
            addChild(controller)
        }
        
        if panView.visible == true {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1.0
        }
        panView.show(in: self.view, offset: 0)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - IBAction
    @IBAction func didTapDone(_ sender: Any) {
        textFieldDidEndEditing(urlTextField)
    }
}

// MARK: - UITextFieldDelegate
extension NewTabViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if var text = textField.text, text != "" {
            let prefix = String(text.prefix(10))
            if !prefix.contains("http://") && !prefix.contains("https://") {
                text = "https://" + text
            }
            if let url = URL(string: text), UIApplication.shared.canOpenURL(url) {
                let url = LiveURL(name: "", connectionId: "", url: text)
                LiveURLManager.shared.currentURLIndex = LiveURLManager.shared.urls.count
                LiveURLManager.shared.saveURL(url)
                HistoryManager.shared.add(url)
                dismiss(animated: false) {
                    self.delegate?.didAddNewTab(url, self)
                }
            } else {
                Utilities.showAlertView(error: nil, title: "Error", message: "Please input valid url", from: self, nil)
            }
        } else {
            Utilities.showAlertView(error: nil, title: "Error", message: "Please input valid url", from: self, nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension NewTabViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return min(HistoryManager.shared.urls.count, 10)
        } else {
            return BookmarkManager.shared.bookmarks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentTableCell", for: indexPath) as! RecentTableCell
            cell.url = HistoryManager.shared.urls[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkTableCell", for: indexPath) as! BookmarkTableCell
            cell.bookmark = BookmarkManager.shared.bookmarks[indexPath.row]
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension NewTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let url = HistoryManager.shared.urls[indexPath.row]
            urlTextField.text = url.url
        } else {
            let url = BookmarkManager.shared.bookmarks[indexPath.row]
            urlTextField.text = url.url
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let count = min(HistoryManager.shared.urls.count, 10)
        if count == 0, BookmarkManager.shared.bookmarks.count == 0 {
            return 0
        } else {
            return Utilities.isPhone ? 32.0 : 48.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let count = min(HistoryManager.shared.urls.count, 10)
        if section == 0 {
            if count == 0 {
                return bookmarkHeaderView()
            } else {
                return recentHeaderView()
            }
        } else {
            return bookmarkHeaderView()
        }
    }
}

// MARK: - RecentsViewControllerDelegate
extension NewTabViewController: RecentsViewControllerDelegate {
    func didTapDone(_ controller: RecentsViewController) {
        panView.hide()
    }
    
    func didTapClearAll(_ controller: RecentsViewController) {
        HistoryManager.shared.clear()
        recentsTableView.reloadData()
        panView.hide()
    }
    
    func didSelectLiveURL(_ url: LiveURL) {
        urlTextField.text = url.url
        panView.hide()
        urlTextField.becomeFirstResponder()
    }
}

extension NewTabViewController: RMPanViewDelegate {
    func viewWillHide(_ view: RMPanView) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 0.0
        }
    }
    
    func viewDidHide(_ view: RMPanView) {
        
    }
}
