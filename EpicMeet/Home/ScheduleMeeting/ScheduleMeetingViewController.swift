//
//  ScheduleMeetingViewController.swift
//  EpicMeet
//
//  Created by R.Unnikrishnan on 21/07/23.
//

import UIKit
import DropDown


class ScheduleMeetingViewController: UIViewController {
    
    @IBOutlet var scheduleMeetingTableView: UITableView!
    
    @IBOutlet var dayView: UIView!
    @IBOutlet var monthView: UIView!
    @IBOutlet var yearView: UIView!
    
    @IBOutlet var scheduleMeetingBtn: RoundedButton!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.isNavigationBarHidden = true
        //Register the cells
        scheduleMeetingTableView.register(UINib(nibName: "ScheduleMeetingTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleMeetingTableViewCell")
        scheduleMeetingTableView.register(UINib(nibName: "invitedParticipentsTableViewCell", bundle: nil), forCellReuseIdentifier: "invitedParticipentsTableViewCell")
    }
    
    @IBAction func scheduleBtnAction(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let groupPage = storyboard.instantiateViewController(withIdentifier: "GroupViewController") as! GroupViewController
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(groupPage, animated: true)
            
        }
    }
    
}


extension ScheduleMeetingViewController : UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return 1
        }
        else
        {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleMeetingTableViewCell", for: indexPath) as! ScheduleMeetingTableViewCell
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
            return 250
        }
        else
        {
            return 67
        }
    }
}
