//
//  GroupViewController.swift
//  EpicMeet
//
//  Created by R.Unnikrishnan on 25/07/23.
//

import UIKit

class GroupViewController: UIViewController {
    @IBOutlet var groupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.isNavigationBarHidden = true
      //Register The Cells
        groupTableView.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupTableViewCell")
        groupTableView.register(UINib(nibName: "invitedParticipentsTableViewCell", bundle: nil), forCellReuseIdentifier: "invitedParticipentsTableViewCell")
    }
}
extension GroupViewController : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return 1
        }
        else
        {
            return 25
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath) as! GroupTableViewCell
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "invitedParticipentsTableViewCell", for: indexPath) as! invitedParticipentsTableViewCell
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0
        {
            return 280
        }
        else
        {
            return 67
        }
    }
    
    
}
