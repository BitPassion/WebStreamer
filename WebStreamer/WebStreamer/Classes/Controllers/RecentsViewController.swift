//
//  RecentsViewController.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/3/23.
//

import UIKit

protocol RecentsViewControllerDelegate {
    func didTapDone(_ controller: RecentsViewController)
    func didTapClearAll(_ controller: RecentsViewController)
    func didSelectLiveURL(_ url: LiveURL)
}

class RecentsViewController: WSViewController {

    @IBOutlet weak var recentsTableView: UITableView!
    
    var delegate: RecentsViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    @IBAction func didTapDone(_ sender: UIButton) {
        delegate?.didTapDone(self)
    }
    
    @IBAction func didTapClearAll(_ sender: UIButton) {
        delegate?.didTapClearAll(self)
    }
}

// MARK: - UITableViewDataSource
extension RecentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HistoryManager.shared.urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentTableCell", for: indexPath) as! RecentTableCell
        cell.url = HistoryManager.shared.urls[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RecentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = HistoryManager.shared.urls[indexPath.row]
        delegate?.didSelectLiveURL(url)
    }
}
