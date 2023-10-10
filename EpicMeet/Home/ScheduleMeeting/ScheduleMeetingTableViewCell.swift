//
//  ScheduleMeetingTableViewCell.swift
//  EpicMeet
//
//  Created by R.Unnikrishnan on 24/07/23.
//

import UIKit
import DropDown

class ScheduleMeetingTableViewCell: UITableViewCell {
    @IBOutlet var dateButton: UIButton!
    @IBOutlet var monthButton: UIButton!
    @IBOutlet var yearButton: UIButton!
    var dateDropDown: DropDown?
    var monthDropDown: DropDown?
    var yearDropDown: DropDown?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set up the DropDown lists for date, month, and year buttons
      
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setupDropDown(for: dateButton, dataSource: (1...31).map { String($0) })
        setupDropDown(for: monthButton, dataSource: DateFormatter().monthSymbols!)
        setupDropDown(for: yearButton, dataSource: (1900...2030).map { String($0) })
    }
    func setupDropDown(for button: UIButton,  dataSource: [String]) {
            let dropDown = DropDown()
            dropDown.dataSource = dataSource
            dropDown.anchorView = button
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                button.setTitle(item, for: .normal)
            }
            if button == dateButton
            {
                dateDropDown = dropDown
            }
            else if button == monthButton
            {
                monthDropDown = dropDown
            } else if button == yearButton
            {
                yearDropDown = dropDown
            }
            button.addTarget(self, action: #selector(showDropDown(_:)), for: .touchUpInside)
        }


    @objc func showDropDown(_ sender: UIButton) {
            if sender == dateButton
            {
                dateDropDown?.show()
            } else if sender == monthButton {
                monthDropDown?.show()
            } else if sender == yearButton {
                yearDropDown?.show()
            }
        }
    
}
