//  VideoViewController.swift
//  EpicMeet
//  Created by R.Unnikrishnan on 19/07/23.
//

import UIKit
import Starscream
import SwiftyJSON
import WebRTC
import AVFoundation
import ReplayKit

class VideoViewController: UIViewController {
    @IBOutlet weak var EndCallBtn : UIButton!
    //var roomiD as! Int
    var videoFlag = false
    private var collectionView:ChatCollectionView!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    var command:RequestHelper!
    @IBOutlet  weak var localVideoView : RTCEAGLVideoView!
    @IBOutlet weak var cameraRotateBtn : UIButton!
    var consumerArray:[Consumer]=[]
    var ProducerArray:[Producer]=[]
    private let peerId = ""
    var videoCollectionViewCell=VideoCollectionViewCell()
    var captureSession = AVCaptureSession()
    var cameraPreviewLayer = AVCaptureVideoPreviewLayer()
    override func viewDidLoad() {
        command.delegate = self
        command.exitRoomDelegate = self
        super.viewDidLoad()
        //MARK: - Registering the cell
        videoCollectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoCollectionViewCell")
    }

    @IBAction func endCallAction(_ sender: Any) {
        command.exitRoom(name: nameID, roomid: roomID)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let DashVc = storyboard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
//        DashVc.command = self.command
//        if let navigationController = self.navigationController {
//            navigationController.pushViewController(DashVc, animated: true)
//
//        }
    }
    
}
extension VideoViewController:RequestHelperDelegate,UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return consumerArray.count
        //
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        videoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
        //           let item = consumerArray[indexPath.row]
        //                   item.videoView.removeFromSuperview()
        //
        //                   item.videoView.frame = videoCollectionViewCell.remoteVideoBGView.bounds
        //           videoCollectionViewCell.remoteVideoBGView.addSubview(item.videoView)
        
        if let videoTrack = consumerArray[indexPath.row].getTrack() as? RTCVideoTrack {
            videoTrack.isEnabled = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return // Return early if self is deallocated
                }
            }
            let videoView = RTCEAGLVideoView(frame: videoCollectionViewCell.remoteVideoBGView.bounds)
            videoCollectionViewCell.remoteVideoBGView.addSubview(videoView)
            print("Video Track >>>>",videoTrack)
            
            videoTrack.add(videoView)
        }
        return videoCollectionViewCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width:200, height:200)
    }
    func onProducerUpdateUI(helper: RequestHelper, producer: Producer) {
        print("\r\nready to updateUI  \(Thread.current)")
        print("producer",producer)
        
        
        ProducerArray.append(producer)
        self.localVideoView.removeAllSubviews()
        
        
        
        //        DispatchQueue.main.async{
        //            self.videoCollectionView.reloadData()   //maybe of reload of collectionview
        //        }
        //        print("consumerArray",consumerArray)
        ////        print("Consumer Array Count",consumerArray.count)
        //        print("count :",String(consumerArray.count))
        
        //        if consumerArray.count>0{
        //
        //            for i in 0...consumerArray.count-1{
        //                if let videoTrack = consumer.getTrack() as? RTCVideoTrack {
        //                    videoTrack.isEnabled = true
        //                    DispatchQueue.main.async { [weak self] in
        //                        guard let self = self else {
        //                            return // Return early if self is deallocated
        //                        }
        //                        //self.remoteVideoBGView.removeAllSubviews()
        //                        let videoView = RTCEAGLVideoView(frame: videoCollectionViewCell.remoteVideoBGView.bounds)
        //                        videoCollectionViewCell.remoteVideoBGView.addSubview(videoView)
        //                        print("Video Track >>>>",videoTrack)
        //                        videoTrack.add(videoView)
        //                    }
        //                } else {
        //                    print("Failed to retrieve video track")
        //                    // Display an error message to the user or take appropriate action
        //                }
        //            }
        //        }
    }
    func onNewConsumerUpdateUI(helper: RequestHelper, consumer: Consumer) {
        print("\r\nready to updateUI  \(Thread.current)")
        print("consumer",consumer)
        consumerArray.append(consumer)
        DispatchQueue.main.async{
            self.videoCollectionView.reloadData()
            //maybe of reload of collectionview
        }
        print("consumerArray",consumerArray)
        //        print("Consumer Array Count",consumerArray.count)
        print("count :",String(consumerArray.count))
    
        //        if consumerArray.count>0{
        //
        //            for i in 0...consumerArray.count-1{
        //                if let videoTrack = consumer.getTrack() as? RTCVideoTrack {
        //                    videoTrack.isEnabled = true
        //                    DispatchQueue.main.async { [weak self] in
        //                        guard let self = self else {
        //                            return // Return early if self is deallocated
        //                        }
        //                        //self.remoteVideoBGView.removeAllSubviews()
        //                        let videoView = RTCEAGLVideoView(frame: videoCollectionViewCell.remoteVideoBGView.bounds)
        //                        videoCollectionViewCell.remoteVideoBGView.addSubview(videoView)
        //                        print("Video Track >>>>",videoTrack)
        //                        videoTrack.add(videoView)
        //                    }
        //                } else {
        //                    print("Failed to retrieve video track")
        //                    // Display an error message to the user or take appropriate action
        //                }
        //            }
        //        }
    }
    func getLocalRanderView(helper: RequestHelper) -> RTCEAGLVideoView {
        
        return self.localVideoView
    }
}
extension UIView {
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
extension UIViewController
{
    func logMessage(messageText: String) {
        NSLog(messageText)
    }
}

extension VideoViewController : exitRoomDelegate
{
    func rootback() {
        DispatchQueue.main.async{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let dashVC = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            self.navigationController?.pushViewController(dashVC, animated: true)
        }
    }
    
    
}
