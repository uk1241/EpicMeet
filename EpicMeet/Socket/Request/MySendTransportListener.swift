
import Foundation
import SwiftyJSON
import WebRTC
//Send pipeline monitoring
class MySendTransportListener:NSObject,SendTransportListener{
    
    public var helper:RequestHelper!
    //Whether the local video resource has been constructed
    private var isVideoLaunchFinish = false
    private var isAudioLaunchFinish = false
    public var dtlsParameters = ""
    public var transportId = ""
    public var flag = -1
    
    //Pipeline creation success callback
    func onConnect(_ transport: Transport!, dtlsParameters: String!) {
        print("\r\n ********SendTransportListener onConnect \(Thread.current)\r\n \(transport.getId()!)\r\n")
        self.dtlsParameters = dtlsParameters
        //self.helper.connectTransport(transportTypeStr: "Producer", transportID: transportId, dtlsParameters: JSON(rawValue: dtlsParameters.toDic()) ?? "", role: "server")
       
    }
    
    func onConnectionStateChange(_ transport: Transport!, connectionState: String!) {
        print("SendTransportListener onConnectionStateChange:\(String(describing: connectionState))")
        if connectionState.contains("disconnected"){
            transport.close()
            print("SendTransportListener closed ************")
        }
    }
    
    func onProduce(_ transport: Transport!, kind: String!, rtpParameters: String!, appData: String!, callback: ((String?) -> Void)!) {
        
        print("\r\n ********MySendTransportListener(onProduce) \r\n \(transport.getId()!),\(kind!),\(Thread.current), rtpParameters:\(rtpParameters!)\r\n")
        let result = self.helper.onProduceCallBack(transportId: transport.getId(), kind: kind, rtpParameters: rtpParameters)
        callback?("")
        //callback?(result.strValue("id"))
        
        if kind == "video"{
            self.isVideoLaunchFinish = true
        }
        if kind == "audio"{
            self.isAudioLaunchFinish = true
        }
        
         transportId = transport.getId() ?? ""
       // let rtpDic = rtpParameters.toDic()
        if self.isAudioLaunchFinish && self.isVideoLaunchFinish {
            print("Check if all done，transfer onConnectCallBack")
           // self.helper.onConnectCallBack(transportId:transportId, dtlsParameters:self.dtlsParameters)
            
            self.helper.connectTransport(transportTypeStr: "Producer", transportID: producerTransportId, RoomId: roomID, dtlsParameters: JSON(rawValue: self.dtlsParameters.toDic()) ?? "", role: "server")
            
            print("transportId : ",transport.getId() , " dtlsParameters :" ,  JSON(rawValue: self.dtlsParameters.toDic()))
        }
    }
}
//Receive pipeline monitoring
class MyRecvTransportListener : NSObject, RecvTransportListener{
    public var helper:RequestHelper!
    public var sender:MySendTransportListener!
    
    func onConnect(_ transport: Transport!, dtlsParameters: String!) {
        let id = transport.getId() ?? ""
       
//        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+2.5) {
            print("\r\n *********MyRecvTransportListener(onConnect) \r\n:\(id),\(Thread.current)\r\n")
           // self.helper.onConnectCallBack(transportId: id, dtlsParameters: dtlsParameters)
        self.helper.connectTransport(transportTypeStr: "Consumer", transportID: consumerTransportId, RoomId: roomID, dtlsParameters: JSON(rawValue: dtlsParameters.toDic()) ?? "", role: "client")
        
//         }

    }
    
    func onConnectionStateChange(_ transport: Transport!, connectionState: String!) {
        print("MyRecvTransportListener  onConnectionStateChange:\(String(describing: connectionState))  (\(transport.getId())) ")
        if connectionState.contains("disconnected"){
            transport.close()
        }
    }
}

class ProducerHandler:NSObject,ProducerListener{
    
    func onTransportClose(_ producer: Producer!) {
        print("ProducerHandler--ni-")
    }
}

class ConsumerHandler:NSObject,ConsumerListener{
    
    func onTransportClose(_ consumer: Consumer!) {
        print("ConsumerHandler--onTransportClose-")
    }
}

