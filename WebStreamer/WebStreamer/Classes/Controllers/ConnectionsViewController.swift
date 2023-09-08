//
//  ConnectionsViewController.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 5/22/23.
//

import UIKit

class ConnectionsViewController: WSViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var connectionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        connectionsTableView.reloadData()
    }
    
    fileprivate func deleteConnection(_ index: Int) {
        LiveStreamManager.shared.removeConnection(LiveStreamManager.shared.connections[index])
        connectionsTableView.reloadData()
    }
    
    fileprivate func editConnection(_ index: Int) {
        performSegue(withIdentifier: "NewConnectionViewController", sender: LiveStreamManager.shared.connections[index])
        connectionsTableView.reloadData()
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "NewConnectionViewController" {
            let controller = segue.destination as! NewConnectionViewController
            if let connection = sender as? LiveStream {
                controller.connection = connection.copy() as! LiveStream
            }
        }
    }
    
    // MARK: - IBAction
    override func actionBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAdd(_ sender: UIButton) {
        performSegue(withIdentifier: "NewConnectionViewController", sender: nil)
    }
}

// MARK: - UITableViewDataSource
extension ConnectionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LiveStreamManager.shared.connections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionViewCell", for: indexPath) as! ConnectionViewCell
        cell.selectionStyle = .none
        cell.connection = LiveStreamManager.shared.connections[indexPath.row]
        cell.isSelection = indexPath.row == LiveStreamManager.shared.currentConnectionIndex
        cell.delegate = self
        cell.didChangeSelection = { selected in
            if LiveStreamManager.shared.currentConnectionIndex != -1, selected {
                if let cell = tableView.cellForRow(at: IndexPath(row: LiveStreamManager.shared.currentConnectionIndex, section: 0)) as? ConnectionViewCell {
                    cell.isSelection = false
                }
            }
            
            if LiveStreamManager.shared.currentConnectionIndex == indexPath.row, selected == false {
                LiveStreamManager.shared.currentConnectionIndex = -1
            } else if selected == true {
                LiveStreamManager.shared.currentConnectionIndex = indexPath.row
                if let cell = tableView.cellForRow(at: IndexPath(row: LiveStreamManager.shared.currentConnectionIndex, section: 0)) as? ConnectionViewCell {
                    cell.isSelection = true
                }
            } else {
                print("Connection selected = \(selected) +++++ exception")
            }
            
            LiveStreamManager.shared.updateConnection()
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ConnectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - SwipeTableViewCellDelegate
extension ConnectionsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left {
            return nil
        }
        
        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 16.0 : 20.0
        var editActions: [SwipeAction] = []
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteConnection(indexPath.row)
        }
        deleteAction.font = UIFont(name: "MyriadPro-Regular", size: fontSize)
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            self.editConnection(indexPath.row)
        }
        editAction.backgroundColor = .systemBlue
        editAction.font = UIFont(name: "MyriadPro-Regular", size: fontSize)
        editActions.append(deleteAction)
        editActions.append(editAction)
        return editActions
    }
}
