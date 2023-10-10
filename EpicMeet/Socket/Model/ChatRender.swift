//
//  ChatRender.swift
//  mediasoup_ios_swift_demo
//
//  Created by KOYO on 2022/11/10.
//

import Foundation

class ChatRender: NSObject {
    var videoId = ""
    var videoView:RTCEAGLVideoView!
    
    
    override init() {
        super.init()
        videoView = RTCEAGLVideoView(frame:.zero)
       
    }
}
class consumerModel:NSObject{
    var consumerArray:[Consumer]=[]
   
    override init() {
        
    }
    init(consumerArray:[Consumer]){
        self.consumerArray = consumerArray
       
       
    }
    
}
