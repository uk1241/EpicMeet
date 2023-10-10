//  EpicMeetHomeViewController.swift
//  EpicMeet
//  Created by R.Unnikrishnan on 21/07/23.
import UIKit
import Starscream
import SwiftyJSON
import WebRTC
import AVFoundation
let activitiesArray = ["Recent calls","Scheduled Meeting","Groups","Favourites"]
class EpicMeetHomeViewController: UIViewController {
    @IBOutlet var homeTableviewHome: UITableView!
    @IBOutlet var collectionViewHome: UICollectionView!
  //  private var kSocketIp =  "vps271818.vps.ovh.ca:3018/"
    private let peerId = ""
    private let roomId = ""
    private var command:RequestHelper!
    var isRecentCallCellVisible = true
    var isScheduledMeetingCellVisible = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "wss://\(SocketUtil.BASE_URL)?roomId=\(roomId)&peerId=\(peerId)")!
        var request = URLRequest(url: url)
        request.setValue("protoo", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        let pinner = FoundationSecurity(allowSelfSigned: false)
        let compression = WSCompression()
        let socket = WebSocket(request: request, certPinner:pinner, compressionHandler: compression)
        socket.callbackQueue = DispatchQueue.global()
        //command = RequestHelper.create(socket, ip: kSocketIp, roomId: roomId)
//        command.connect()
        socket.connect()
        //register the CollectionView cell
        collectionViewHome.register(UINib(nibName: "EpicMeetHomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EpicMeetHomeCollectionViewCell")
        //Register the TableView Cell
        homeTableviewHome.register(UINib(nibName: "RecentCallsTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentCallsTableViewCell") //RecentCallCell
        homeTableviewHome.register(UINib(nibName: "ScheduledMeetingTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduledMeetingTableViewCell") //ScheduleMeetingCell
    }
}
extension EpicMeetHomeViewController: UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRecentCallCellVisible
        {
            return 1
        }
        else if isScheduledMeetingCellVisible
        {
            return 1
        }
        else
        {
            return 1
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isRecentCallCellVisible
        {
            let recentCallCell = tableView.dequeueReusableCell(withIdentifier: "RecentCallsTableViewCell", for: indexPath) as! RecentCallsTableViewCell
            return recentCallCell
        }
        else if isScheduledMeetingCellVisible
        {
            let scheduledCallCell = tableView.dequeueReusableCell(withIdentifier: "ScheduledMeetingTableViewCell", for: indexPath) as! ScheduledMeetingTableViewCell
            return scheduledCallCell
        }
        else
        {
            return UITableViewCell()
        }
    }
}
extension EpicMeetHomeViewController: UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) ->Int
    {
        return activitiesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpicMeetHomeCollectionViewCell", for: indexPath) as! EpicMeetHomeCollectionViewCell
        cell.activitiesBtn.setTitle(String(activitiesArray[indexPath.row]), for: .normal)
        cell.activitiesBtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return cell
    }
    @objc func buttonTapped()
    {
        switch activitiesArray.count
        {
        case 0 :
            isRecentCallCellVisible = true
            homeTableviewHome.reloadData()
        case 1 :
            isRecentCallCellVisible = false
            isScheduledMeetingCellVisible = true
            homeTableviewHome.reloadData()
        default :
            print(activitiesArray.count)
        }
    }
}
