//
//  RequestHelper.swift
//
import Foundation
import SwiftyJSON
import WebRTC
import Starscream
var userID = String()
var nameID = String()
var userIds: [[String:Any]] = []
//var roomList = [[String:Any]]()
protocol RequestHelperDelegate {
    func onNewConsumerUpdateUI(helper:RequestHelper,consumer:Consumer)
    func getLocalRanderView(helper:RequestHelper)->RTCEAGLVideoView
}
protocol signIndelegate
{
    func passData()
}
protocol dashBoardDelegate
{
    func dashboardData(roomlist : [[String:Any]])
}
class RequestHelper : NSObject{
    var dashBoardClassDelegate:dashBoardDelegate!
    var signIndelegate : signIndelegate?
    var email = ""
    var password = ""
    var delegate:RequestHelperDelegate?
    private var socket:WebSocket?
    var producer_idArray=[String]()
    var producerId=[String]()
    var videoProducer:Producer!
    public var joinedRoom = false
    private var device:MediasoupDevice?
    private var sendTransport:SendTransport?
    private var sendListener:MySendTransportListener!
    private var recvTransport:RecvTransport?
    private var recvListener:MyRecvTransportListener!
    private var producerHandler:ProducerHandler!
    private var consumerHandler:ConsumerHandler!
    private var peerConnectionFactory:RTCPeerConnectionFactory?
    private var mediaStream:RTCMediaStream?
    private var totalProducers:[String:Producer] = [:]
    var totalConsumers:[String:Consumer] = [:]
    private var videoCapture:RTCCameraVideoCapturer?
    private var isStaredVideo = false
    //    private let semaphare = DispatchSemaphore(value: 0)
    var consumersInfoAudios:[[String:Any]] = []
    var consumersInfoVideos:[[String:Any]] = []
    private var peersIDs:[String] = []
    private var socketIp = ""
    private var roomId : Int!
    var userIds: [String] = []
    var Consumercapabilities = String()
    var  id = String()
    var capabilityJSON=JSON()
    var transportConnctFlag=0
    var videoflag=0
    var audioFlag=0
    //    var signInviewController : SignInViewController!
    public static func initHelper()
    {
        let helper = RequestHelper()
        helper.initSome()
        helper.socket?.delegate = helper
    }
    public static func create(_ socket:WebSocket,ip:String,roomId:Int)->RequestHelper {
        let helper = RequestHelper()
        helper.socketIp = ip
        helper.initSome()
        helper.roomId = roomId
        helper.socket = socket
        helper.socket?.delegate = helper
        return helper
    }
    public static func createOpen(_ socket:WebSocket,ip:String)->RequestHelper {
        let helper = RequestHelper()
        helper.socketIp = ip
        helper.initSome()
        helper.socket = socket
        helper.socket?.delegate = helper
        return helper
    }
    private func initSome(){
        if peerConnectionFactory == nil{
            peerConnectionFactory = RTCPeerConnectionFactory()
        }
        
        if mediaStream == nil{
            mediaStream = peerConnectionFactory?.mediaStream(withStreamId: ARDEmu.kARDMediaStreamId)
        }
    }
    
    public func connect()
    {
        socket?.connect()
    }
    public func disConnect()
    {
        socket?.disconnect()
    }
    private func onSocketConnected(){
        
        //        socket?.connect()
        //                sendCreateRoomRequest(roomId: roomId)
        //        sendLoginRequest(email: email, password: password)
        
        //        let capabilities = sendGetRoomRtpCapabilitiesRequest(roomId: roomId)
        //        guard let device = MediasoupDevice() else { return }
        //        if let data = capabilities["Data"] as? String {
        //            device.load(data)
        //        } else {
        //            print("Invalid capabilities data.")
        //            return
        //        }
        //        self.device = device
        //                onCreateSendTransport()
        //                onCreateRecvTransport()
        //        b(device: device)
        //
        //                 startVideoAndAudio()
        //                createConsumerAndResume()
    }
    
    ///Common send data interface
    private func sendData(id:Int,method:String,data:[String:Any]){
        let body:JSON = JSON(data)
        let sendData:JSON = ["request":NSNumber.init(value: true),
                             "id":id,
                             "method":method,
                             "data":body]
        print("\r\nComingsoon\(String(describing:Thread.current.name))*********datainput:\(sendData.description)\r\n")
        self.socket?.write(string: sendData.description, completion: nil)
    }
    ///Obtain Send，Recv Parameters for pipeline creation
    private func questSendOrRecvTransportParam(isSend:Bool){
        let trueVal = NSNumber.init(value: true)
        let falseVal = NSNumber.init(value: false)
        
        let data:[String:Any] = ["forceTcp":falseVal,
                                 "producing":isSend ? trueVal : falseVal,
                                 "consuming":isSend ? falseVal : trueVal]
        let id = isSend ? ActionEventID.kCreateSendID : ActionEventID.kCreateRecvID
        sendData(id:id,method: ActionEvent.createWebRtcTransport, data: data)
    }
}

extension RequestHelper{
    //MARK: - request connection string
    //    public func onGetCapabilities1()->String{
    //        guard let socket = self.socket else{return ""}
    //        let message = Message(socket: socket,messageId: ActionEventID.kConnectID)
    //        let data:[String:Any] =  ["action":"getRoomRtpCapabilities","roomId":roomId]
    //        let result = message.send(method: ActionEvent.getRouterRtpCapabilities, data: data)
    //        let json:JSON = JSON(result)
    //        print( "Connection string successfully obtained...")
    //        return json.description
    //
    //    }
    public func sendCreateRoomRequest(roomId: Int) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
        let dataRequest: JSON = ["RoomId": roomId]
        let getCreateRoomRequest: JSON = [
            "commandType": "CreateRoom",
            "Data": dataRequest
        ]
        print(getCreateRoomRequest)
        let returnadata = message.sendData(method: getCreateRoomRequest)
        print(returnadata)
        return JSON(rawValue: returnadata) ?? ""
    }
    public func joinRoomRequest(roomId: Int,name:String,userId : String) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
        let dataRequest: JSON = ["Name": name,
                                 "RoomId": roomId,
                                 "UserId":userId
        ]
        let getJoinRoomRequest: JSON = [
            "commandType": "JoinRoom",
            "Data": dataRequest
        ]
        print("JoinRequest:",getJoinRoomRequest)
        let returnadata = message.sendData(method: getJoinRoomRequest)
        
        return JSON(rawValue: returnadata) ?? ""
    }
    //    public func joinRoomRequest(roomId: String) -> JSON {
    //        guard let socket = self.socket else { return JSON() }
    //        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
    //        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
    //        let dataRequest: JSON = ["Name": "","RoomId": roomId]
    //        let getJoinRoomRequest: JSON = [
    //            "commandType": "JoinRoom",
    //            "Data": dataRequest
    //        ]
    //        let returnadata = message.sendData(method: getJoinRoomRequest)
    //        print(returnadata)
    //        return JSON(rawValue: returnadata) ?? ""
    //    }
    func sendGetRoomRtpCapabilitiesRequest(roomId: Int) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let dataRequest: JSON = ["Name": nameID, "RoomId": roomID]
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        let getRoomRtpCapabilitiesRequest: JSON = [
            "commandType": "getRouterRtpCapabilities",
            "Data": dataRequest
        ]
        print("RTP CAPABLITIES\(getRoomRtpCapabilitiesRequest)")
        let returnadata = message.sendData(method: getRoomRtpCapabilitiesRequest)
        // print("RTP CAPABLITIES\(getRoomRtpCapabilitiesRequest)")
        let json:JSON = JSON(returnadata)
        return getRoomRtpCapabilitiesRequest
    }
    //MARK: -
    
    //    public func onGetCapabilities()->String{
    //        guard let socket = self.socket else{return ""}
    //        let message = Message(socket: socket,messageId: ActionEventID.kConnectID)
    //        let data:[String:Any] =  ["action":"getRoomRtpCapabilities","roomId":roomId]
    //        let result = message.send(method: ActionEvent.getRouterRtpCapabilities, data: data)
    //        let json:JSON = JSON(result)
    //        print("Connection string obtained successfully. . .")
    //        return json.description
    //
    //    }
    
    /* func createConsumerTransport(roomId: String) -> JSON {
     guard let socket = self.socket else { return JSON() }
     let dataRequest: JSON = ["transport_id": "Rihesh", "RoomId": roomId, "dtlsParameters":]
     let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
     let getRoomRtpCapabilitiesRequest: JSON = [
     "commandType": "connectTransport",
     "Data": dataRequest
     ]
     let returnadata = message.sendData(method: getRoomRtpCapabilitiesRequest)
     print("RTP CAPABLITIES\(returnadata)")
     let json:JSON = JSON(returnadata)
     return getRoomRtpCapabilitiesRequest
     }*/
    public func createWebRtcTransport(transportTypeStr: String,RoomId:Int,deviceObj: MediasoupDevice) -> JSON
    {
        guard let socket = self.socket else { return JSON() }
        let dataRequest: JSON = ["forceTcp": false, "RoomId": RoomId,"transportType":transportTypeStr]
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        let createWebrtcTransportRequest: JSON = [
            "commandType": "createWebRtcTransport",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: createWebrtcTransportRequest)
        print("RTP CAPABLITIES\(returnadata)")
        let json:JSON = JSON(returnadata)
        return createWebrtcTransportRequest
    }
    public func connectTransport(transportTypeStr: String,transportID: String, RoomId:Int,dtlsParameters: JSON,role: String) -> JSON
    {
        guard let socket = self.socket else { return JSON() }
        let dataRequest: JSON = ["transport_id": transportID, "RoomId": RoomId,"TransportsType":transportTypeStr,"dtlsParameters": dtlsParameters , "role": role]
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        let connectTransportRequest: JSON = [
            "commandType": "connectTransport",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: connectTransportRequest)
        print("return data of connect transport:\(returnadata)")
        let json:JSON = JSON(returnadata)
        return connectTransportRequest
    }
    public func produceTransport(transportTypeStr: String,transportID: String,dtlsParameters: JSON,role: String) -> JSON
    {
        guard let socket = self.socket else { return JSON() }
        let dataRequest: JSON = ["transport_id": transportID, "RoomId": roomId,"transportType":transportTypeStr,"dtlsParameters": dtlsParameters , "role": role]
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        let produceTransportRequest: JSON = [
            "commandType": "produceTransport",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: produceTransportRequest)
        print("RTP CAPABLITIES\(returnadata)")
        let json:JSON = JSON(returnadata)
        return produceTransportRequest
    }
    public func getProducerList()
    {
        let socket = self.socket
        let dataRequest: JSON = ["Name": nameID, "RoomId": roomId]
        let message = Message(socket: socket!, messageId: ActionEventID.kConnectID)
        let getProducersRequest: JSON = [
            "commandType": "getProducers",
            "Data": dataRequest
        ]
        message.sendData(method: getProducersRequest)
    }
    //MARK: - Create a sending channel
    public func onCreateSendTransport(){
        guard let socket = self.socket else{return}
        let trueVal = NSNumber.init(value: true)
        let falseVal = NSNumber.init(value: false)
        
        let params:[String:Any] = ["forceTcp":falseVal,
                                   "producing":trueVal,
                                   "consuming":falseVal]
        
        let message = Message(socket: socket,messageId: ActionEventID.kCreateSendID)
        let transportDic = message.send(method: ActionEvent.createWebRtcTransport, data: params)
        
        let id = transportDic.strValue("id")
        let iceParameters = JSON(transportDic.dictionary("iceParameters")).description
        var iceCandidatesArray = transportDic.array("iceCandidates")
        if var first = iceCandidatesArray.first{
            
            first["ip"] = socketIp
            iceCandidatesArray[0] = first
        }
        let iceCandidates = JSON(iceCandidatesArray).description
        let dtlsParameters = JSON(transportDic.dictionary("dtlsParameters")).description
        
        self.sendListener = MySendTransportListener()
        self.sendListener.helper = self
        
        self.sendTransport = device?.createSendTransport(self.sendListener, id:id, iceParameters: iceParameters, iceCandidates: iceCandidates, dtlsParameters: dtlsParameters)
    }
    //MARK: - Create a receive channel
    public func onCreateRecvTransport(){
        guard let socket = self.socket else{return}
        let trueVal = NSNumber.init(value: true)
        let falseVal = NSNumber.init(value: false)
        
        let data:[String:Any] = ["forceTcp":falseVal,
                                 "producing":falseVal,
                                 "consuming":trueVal]
        let message = Message(socket: socket,messageId: ActionEventID.kCreateSendID)
        let dataDic = message.send(method: ActionEvent.createWebRtcTransport, data: data)
        
        let id = dataDic.strValue("id")
        let iceParameters = JSON(dataDic.dictionary("iceParameters")).description
        var iceCandidatesArray = dataDic.array("iceCandidates")
        if var first = iceCandidatesArray.first{
            first["ip"] = socketIp
            iceCandidatesArray[0] = first
        }
        let iceCandidates = JSON(iceCandidatesArray).description
        let dtlsParameters = JSON(dataDic.dictionary("dtlsParameters")).description
        
        self.recvListener = MyRecvTransportListener()
        self.recvListener.helper = self
        self.recvTransport = device?.createRecvTransport(self.recvListener, id: id, iceParameters: iceParameters, iceCandidates: iceCandidates, dtlsParameters: dtlsParameters)
    }
    //MARK: -  login request with email and password
    public func loginRequest(email: String,password:String) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
        let dataRequest: JSON = ["email": email,"password": password]
        let getLoginRequest: JSON = [
            "commandType": "UserLogin",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: getLoginRequest)
        print(returnadata)
        return JSON(rawValue: returnadata) ?? ""
    }
    //MARK: -  UpdateUserClientId function
    public func UpdateUserClientId(userid: String,clientid:String) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
        let dataRequest: JSON = ["UserId": userid,"NewClientId": clientid]
        let getUpdateUserClientId: JSON = [
            "commandType": "UpdateUserClientId",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: getUpdateUserClientId)
        print(returnadata)
        return JSON(rawValue: returnadata) ?? ""
    }
    //MARK: - signUp request with email and password
    public func signUpRequest(
        name :String,email: String,
        password:String,
        clientID: String,
        isPasswordRequired: Bool,
        allowMultiple:Bool,
        profile :[String:Any],
        groupName:String,
        sessionID: String,
        sessions: [Any]
    ) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
        let dataRequest: JSON = [
            "name" :name,
            "email": email,
            "password": password,
            "clientID" : clientID,
            "isPasswordRequired": isPasswordRequired,
            "allowMultiple":allowMultiple,
            "profile":profile,
            "groupName":groupName,
            "sessionID":sessionID,
            "sessions":sessions
        ]
        let getsignUpRequest: JSON = [
            "commandType": "SignUp",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: getsignUpRequest)
        print(returnadata)
        return JSON(rawValue: returnadata) ?? ""
    }
    //MARK: - DASHBOARD FUNCTIONS
    public func acknowledgeUserStatus(SearchKey: String,userId : String) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
        let dataRequest: JSON = [
            "SearchKey":SearchKey,
            "UserId": userId
        ]
        let getAcknowledgeUserStatus: JSON = [
            "commandType": "AcknowledgeUserStatus",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: getAcknowledgeUserStatus)
        print(returnadata)
        return JSON(rawValue: returnadata) ?? ""
    }
    //MARK: - TO GET PARTICIPANT LIST
    public func DashboardParticipantsList(SearchKey: String,userId : String) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
        let dataRequest: JSON = [
            "SearchKey":SearchKey,
            "UserId": userId
        ]
        let getDashboardParticipantsLists: JSON = [
            "commandType": "DashboardParticipantsList",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: getDashboardParticipantsLists)
        print(returnadata)
        return JSON(rawValue: returnadata) ?? ""
    }
    //MARK: - join Room.
    public func onJoinRoom(device:MediasoupDevice){
        
        if !device.isLoaded() {
            print("The device has been loaded, return directly")
            return
        }
        if joinedRoom{
            print("Already added to the room, return directly")
            return
        }
        
        guard let socket = self.socket else{return}
        let deviceRtpCapabilities = device.getRtpCapabilities() ?? ""
        let data:[String:Any] = [
            "device":SocketUtil.deviceInfo(),
            "displayName": nameID,
            "rtpCapabilities": JSON.init(parseJSON: deviceRtpCapabilities)
        ]
        let message = Message(socket: socket, messageId: ActionEventID.kJoinID)
        let _ = message.send(method: ActionEvent.join, data: data)
        self.joinedRoom = true
    }
    //MARK: - create producer
    func onProduceCallBack(transportId:String,kind:String,rtpParameters:String)->JSON{
        //        guard let socket = self.socket else{return [:]}
        //        let rtpDic = rtpParameters.toDic()
        //        let params:[String:Any] = ["transportId":transportId,"kind":kind,"rtpParameters":rtpDic]
        //        let message = Message(socket: socket, messageId: ActionEventID.kProduce)
        //        let result = message.send(method: ActionEvent.produce, data: params)
        //        return result
        let jsonArray = JSON ()
        let data = rtpParameters.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                print(jsonArray) // use the json here
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        let rtpDic = rtpParameters.toDic()
        guard let socket = self.socket else { return JSON() }
        let dataRequest: JSON = ["producerTransportId": transportId, "RoomId": roomID,"kind":kind,"rtpParameters": rtpDic]
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        let produce: JSON = [
            "commandType": "produce",
            "Data": dataRequest
        ]
        print("ProduceJSON :",produce)
        let returnadata = message.sendData(method: produce)
        print("RTP CAPABLITIES\(returnadata)")
        let json:JSON = JSON(returnadata)
        return produce
    }
    func getCosumerStream(roomid:Int,transportId:String,ProducerId:String,RtpCapabilities:JSON)->JSON{
        
        let jsonArray = JSON ()
        //        let data = RtpCapabilities.data(using: .utf8)!
        //        do {
        //            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
        //            {
        //               print(jsonArray) // use the json here
        //            } else {
        //                print("bad json")
        //            }
        //        } catch let error as NSError {
        //            print(error)
        //        }
        // let rtpDic = RtpCapabilities.toDic()
        let rtpDic = RtpCapabilities
        guard let socket = self.socket else { return JSON() }
        let dataRequest: JSON = ["consumerTransportId": transportId, "RoomId": roomid,"ProducerId":ProducerId,"RtpCapabilities": rtpDic]
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        let consume: JSON = [
            "commandType": "consume",
            "Data": dataRequest
        ]
        print("ProduceJSON :",consume)
        let returnadata = message.sendData(method: consume)
        print("RTP CAPABLITIES\(returnadata)")
        let json:JSON = JSON(returnadata)
        return consume
    }
    //MARK: -connect new users
    public func onConnectCallBack(transportId:String,dtlsParameters:String){
        guard let socket = self.socket else{return}
        let dtl = dtlsParameters.toDic()
        let params:[String:Any] = ["transportId": transportId,"dtlsParameters":dtl]
        
        let message = Message(socket: socket, messageId:SocketUtil.getSocketKey())
        let _ = message.send(method: ActionEvent.connectWebRtcTransport, data: params)
        //        semaphare.signal()
    }
    //MARK: - test pipeline
    public func sendResponse(requestId:Int){
        DispatchQueue.global().async {
            let sendData:JSON = ["response":NSNumber.init(value: true),
                                 "id":requestId,
                                 "ok" :NSNumber.init(value: true),
                                 "data":""]
            print("Send empty data:\(sendData.description)")
            self.socket?.write(string: sendData.description, completion: nil)
        }
    }
}
extension RequestHelper{
    
    func consumerClosed(consumerId:String){
        for (i,item) in consumersInfoVideos.enumerated() {
            let idV = item.strValue("id")
            if idV == consumerId {
                consumersInfoVideos.remove(at: i)
                print("consumeCount : ",String(consumersInfoVideos.count))
            }
        }
        for (i,item) in consumersInfoAudios.enumerated() {
            let idV = item.strValue("id")
            if idV == consumerId {
                consumersInfoAudios.remove(at: i)
            }
        }
        print("User logged out. . . .")
    }
    
}
extension RequestHelper{
    func createConsumerAndResume(){
        
        self.consumerHandler = ConsumerHandler()
        print("Number of existing videos:\(self.consumersInfoVideos.count)")
        print("Existing audio quantity:\(self.consumersInfoVideos.count)")
        
        
        for consumerVideo in self.consumersInfoVideos{
            //video
            let requestIdV = consumerVideo.intValue("requestId")
            let kindV = consumerVideo.strValue("kind")
            let idV = consumerVideo.strValue("id")
            let producerIdV = consumerVideo.strValue("producerId")
            let rtpParametersV = consumerVideo.dictionary("rtpParameters")
            let rtp = JSON(rtpParametersV).description
            let peerId = consumerVideo.strValue("peerId")
            
            
            print("\r\nPrepare to recycle video subscriptions(\(peerId))  id：\(idV),producerId:\(producerIdV)  \(Thread.current)\r\n")
            
            guard let consumer = self.recvTransport?.consume(self.consumerHandler, id: idV, producerId: producerIdV, kind: kindV, rtpParameters:rtp)else{
                print("Failed to subscribe new user video")
                return
            }
            
            self.totalConsumers[consumer.getId()] = consumer
            print("\r\nComplete the cyclic subscription video and prepare to send empty data\(Thread.current)\r\n")
            self.delegate?.onNewConsumerUpdateUI(helper: self, consumer: consumer)
            //  self.sendResponse(requestId: requestIdV)
        }
        
        for consumerAudio in self.consumersInfoAudios{
            //audio
            let requestIdA = consumerAudio.intValue("requestId")
            let kindA = consumerAudio.strValue("kind")
            let idA = consumerAudio.strValue("id")
            let producerIdA = consumerAudio.strValue("producerId")
            let rtpParametersA = consumerAudio.dictionary("rtpParameters")
            let paramsJsonA = JSON(rtpParametersA).description
            let peerId = consumerAudio.strValue("peerId")
            
            print("\r\nReady to Loop Subscribe to Audio(\(peerId))  id：\(idA),producerId:\(producerIdA)  \(Thread.current)\r\n")
            
            guard let consumer = self.recvTransport?.consume(self.consumerHandler, id: idA, producerId: producerIdA, kind: kindA, rtpParameters:paramsJsonA) else{
                print("Failed to subscribe new user audio")
                return
            }
            print("\r\n Prepare to send empty data \r\n")
            self.totalConsumers[consumer.getId()] = consumer
            self.sendResponse(requestId: requestIdA)
            print("\r\ncomplete loop creation consume audio\(Thread.current)")
        }
    }
    ///Turn on audio and video 4
    func startVideoAndAudio() {
        print("Ready to start audio and video ：\(Thread.current)") //Ready to start audio and video
        if AVCaptureDevice.authorizationStatus(for: .audio) != .authorized {
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (isGranted: Bool) in
                //                self.startAudio()
            })
        } else {
            self.startAudio()
            //            self.startVideo()
        }
        print("ready to start video startVideo()：\(Thread.current)")
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (isGranted: Bool) in
                self.startVideo()
            })
        } else {
            self.startVideo()
        }
        
    }
    //build video
    func startVideo(){
        guard let cameraDevice = SocketUtil.getCameraDevice()else{return}
        guard let videoSource = peerConnectionFactory?.videoSource() else{return}
        videoSource.adaptOutputFormat(toWidth: 144, height: 192, fps: 30)
        videoCapture = RTCCameraVideoCapturer(delegate: videoSource)
        guard let format = RTCCameraVideoCapturer.supportedFormats(for: cameraDevice).last else{return}
        let fps:Int = Int(format.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 30)
        videoCapture?.startCapture(with: cameraDevice, format:format, fps: fps)
        guard let videoTrack = peerConnectionFactory?.videoTrack(with: videoSource, trackId: ARDEmu.kARDVideoTrackId) else{return}
        videoTrack.isEnabled = true
        guard let localVideoView = delegate?.getLocalRanderView(helper: self) else{return}
        self.mediaStream?.addVideoTrack(videoTrack)
        videoTrack.add(localVideoView)
        let codecOptions: JSON = [
            "videoGoogleStartBitrate": 1000
        ]
        print("\r\nready to create video produce()，thread:\(Thread.current)")
        self.producerHandler = ProducerHandler()
        guard let producer = self.sendTransport?.produce(producerHandler, track: videoTrack, encodings: nil, codecOptions: codecOptions.description) else{
            print("创建失败........error")
            return
        }
        print("\r\nVideo --- produce successfully created 1111")
        self.totalProducers[producer.getId()] = producer
        createConsumerAndResume()
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoChat, options: .defaultToSpeaker)
    }
    func startVideo1(){
        guard let videoTrack = self.mediaStream?.videoTracks.first else {
            return
        }
        videoTrack.isEnabled = true
    }
    func videoOnoFF(){
        if videoflag==0{
            videoflag=1
            stopAudio()
            stopVideo()
        }else{
            videoflag=0
            startAudio1()
            startVideo1()
            
        }
    }
    func AudioOnoFF(){
        if audioFlag==0{
            audioFlag=1
            stopAudio()
            
        }else{
            audioFlag=0
            startAudio1()
        }
    }
    public func producerClosed(roomId: String,producerId:String,type:String) -> JSON {
        guard let socket = self.socket else { return JSON() }
        let message = Message(socket: socket, messageId: ActionEventID.kConnectID)
        // Data: {"commandType":"CreateRoom","Data":{"RoomId":"123"}}
        let dataRequest: JSON = ["RoomId": roomId,"ProducerId":producerId,"Type":type]
        let getJoinRoomRequest: JSON = [
            "commandType": "producerClosed",
            "Data": dataRequest
        ]
        let returnadata = message.sendData(method: getJoinRoomRequest)
        print(returnadata)
        return JSON(rawValue: returnadata) ?? ""
    }
    func stopVideo(){
        //        videoProducer.close()
        
        //        var dataObj = { commandType: "producerClosed", Data: { RoomId: this.room_id, ProducerId: producer_id, Type: type } };
        //        this.socket.sendCommand(JSON.stringify(dataObj))
        //    producerClosed(roomId: roomId, producerId: producer_idArray[0], type: "video")
        //           let cameraDevice = SocketUtil.removeCameraDevice()
        
        //
        guard let videoTrack = self.mediaStream?.videoTracks.first else {
            return
        }
        
        // Remove the video track from the local video view
        //        guard let localVideoView = delegate?.getLocalRanderView(helper: self) else {
        //            return
        //        }
        //        videoTrack.remove(localVideoView)
        //
        //        // Stop the video capture and remove the track from the media stream
        //        videoCapture?.stopCapture()
        //        self.mediaStream?.removeVideoTrack(videoTrack)
        
        // Dispose the video track
        videoTrack.isEnabled = false
        
        
        print("video Stopped")
    }
    ///build audio
    func startAudio(){
        
        guard let audioTrack = peerConnectionFactory?.audioTrack(withTrackId: ARDEmu.kARDAudioTrackId) else{return}
        audioTrack.isEnabled = true
        mediaStream?.addAudioTrack(audioTrack)
        print("\r\nReady to Create Audio produce")
        self.producerHandler = ProducerHandler()
        guard let kindProducer = self.sendTransport?.produce(self.producerHandler, track: audioTrack, encodings:nil, codecOptions:nil) else{
            print("sendTransport Creation failed。。。。。。")
            return
        }
        print("\r\nAudio created successfully")
        self.totalProducers[kindProducer.getId()] = kindProducer
    }
    func stopAudio(){
        guard let audioTrack = peerConnectionFactory?.audioTrack(withTrackId: ARDEmu.kARDAudioTrackId) else{return}
        audioTrack.isEnabled = false
        print("Audio Stopped")
    }
    func startAudio1(){
        guard let audioTrack = peerConnectionFactory?.audioTrack(withTrackId: ARDEmu.kARDAudioTrackId) else{return}
        audioTrack.isEnabled = true
        print("Audio Restarted")
    }
}
// MARK: - events happening after the call
extension RequestHelper:WebSocketDelegate{
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        //        print("RequestHelper收到消息。。\(event)")
        switch event {
        case .connected(_):
            //            print("链接成功:\(dictionary)")
            self.onSocketConnected()
        case .disconnected(let string,_):
            print("disconnected:\(string)")
            
        case .text(let string):
            let dic = string.toDic()
            //            let method = dic.strValue("method")
            onDidReceiveMessage(message: dic)
            
        case .binary(let data):
            print("binary----optional:\(data)")
        case .pong(let optional):
            print("pong----optional:\(String(describing: optional))")
            
        case .ping(let optional):
            print("ping----optional:\(String(describing: optional))")
            
        case .error(let optional):
            print("error----optional:\(String(describing: optional))")
            
        case .viabilityChanged(let bool):
            print("viabilityChanged----bool:\(bool)")
        case .reconnectSuggested(let bool):
            print("reconnectSuggested----bool:\(bool)")
            
        case .cancelled:
            print("cancelled----")
        }
    }
    
    func onDidReceiveMessage(message:[String:Any]) {
        let requestId = message.intValue("id")
        let method = message.strValue("method")
        let data = message.dictionary("data")
        let Event = message.strValue("Event")
        print("Event : " ,Event)
        if method == "activeSpeaker" || method == "downlinkBwe"{
            return
        }
        //        if method == "newConsumer"{
        print("\rreceived data： (\(message) \r\n")
        //        }
        //        if requestId != ActionEventID.kConnectID{
        //        print("\r 收到数据id:\(requestId)  method:(\(method) \r\n")
        //        }
        //RoomCreated
        if Event == "RoomCreated"
        {
            joinRoomRequest(roomId: roomID, name: nameID, userId: userID)
            
        }
        
        if Event == "JoinedRoom"
        {
            sendGetRoomRtpCapabilitiesRequest(roomId: roomID)
            
        }
        if Event == "RoomAlreadyExist"
        {
            joinRoomRequest(roomId: roomID, name: nameID, userId: userID)
            print("room already exist")
            //sendGetRoomRtpCapabilitiesRequest(roomId: roomId)
        }
        
        if Event == "RtpCapabilitiesReceived"
        {
            guard let device = MediasoupDevice() else{return}
            Consumercapabilities = message.strValue("Capabilities")
            let jsonRTPCapabilities:JSON = JSON(message)
            let capabilityData = jsonRTPCapabilities["Data"]
            capabilityJSON = capabilityData["Capabilities"]
            print("jsonCapabilities : " ,capabilityJSON)
            device.load(capabilityJSON.description)
            if !(device.canProduce("audio")) {
                print(" Audio not supported ===2===")
            }
            if !(device.canProduce("video")) {
                print(" Video not supported ===2===")
            }
            self.device = device
            createWebRtcTransport(transportTypeStr: "producerTransport", RoomId: roomID, deviceObj: self.device!)
            
        }
        if Event == "CreateWebRtcTransportSuccess"
        {
            let jsonWebRTCTransportObj:JSON = JSON(message)
            //let jsonWebRTCTransportData:JSON = JSON(jsonWebRTCTransportObj)
            // let id = jsonWebRTCTransportObj["transportId"]
            let data =  message.dictionary("Data")
            id = data.strValue("transportId")
            let transportTypeSTR = data.strValue("transportType")
            let params = jsonWebRTCTransportObj["params"]
            let paramsDict = data.dictionary("params")
            let iceParameters = JSON(paramsDict.dictionary("iceParameters")).description //paramsDict.dictionary("iceParameters")   // JSON(params["iceParameters"]).description
            var iceCandidatesArray = paramsDict.array("iceCandidates")
            if var first = iceCandidatesArray.first{
                first["ip"] = socketIp
                iceCandidatesArray[0] = first
            }
            let iceCandidates = JSON(iceCandidatesArray).description
            let dtlsParameters = JSON(paramsDict.dictionary("dtlsParameters")).description
            if transportTypeSTR == "producerTransport"
            {
                self.sendListener = MySendTransportListener()
                self.sendListener.helper = self
                
                self.sendTransport = device?.createSendTransport(self.sendListener, id:id, iceParameters: iceParameters, iceCandidates: iceCandidates, dtlsParameters: dtlsParameters)
                //                connectTransport(transportTypeStr: "Producer", transportID: id, dtlsParameters: JSON(paramsDict.dictionary("dtlsParameters")), role: "server")
                createWebRtcTransport(transportTypeStr: "consumerTransport", RoomId: roomID, deviceObj: self.device!)
                startVideoAndAudio()
                createConsumerAndResume()
            }
            else
            {
                self.recvListener = MyRecvTransportListener()
                self.recvListener.helper = self
                self.recvTransport = device?.createRecvTransport(self.recvListener, id: id, iceParameters: iceParameters, iceCandidates: iceCandidates, dtlsParameters: dtlsParameters)
                // connectTransport(transportTypeStr: "Consumer", transportID: id, dtlsParameters: JSON(paramsDict.dictionary("dtlsParameters")), role: "client")
                //startVideoAndAudio()
                //                 createConsumerAndResume()
            }
        }
        if Event == "Transportconnected"
        {
            if transportConnctFlag==0{
                
                getProducerList()
            }
            transportConnctFlag=1
        }
        if Event == "produced"
        {
            //                        startVideoAndAudio()
            //            startVideoAndAudio()
            //                        createConsumerAndResume()
            //            getProducerList()
            
        }
        if Event == "ProducersReceived"
        {
            let data =  message.dictionary("Data")
            print("data",data)
            let dataArray = data["producerList"] as! [[String:Any]]
            print("dataArray",dataArray)
            
            if  dataArray.count>0{
                for i in 0...dataArray.count-1{
                    let producerid=dataArray[i]["producer_id"]
                    print("producerid",producerid)
                    producer_idArray.append(producerid as? String ?? "")
                }
            }
            print("producer_idArray",producer_idArray)
            
            if producer_idArray.count>0{
                for i in 0...producer_idArray.count-1{
                    getCosumerStream(roomid: roomID, transportId: id, ProducerId: producer_idArray[i] , RtpCapabilities: capabilityJSON)
                }
            }
        }
        if Event == "ParticipantListUpdate"
        {
            let data =  message.dictionary("Data")
            print("ParticipantListUpdate data : ",data)
            let dataArray = data.array("Data")
            let producerDic = dataArray
            
            ////                        if let dataArray = data["Data"] as? [[String: Any]]
            ////                            if let userId = item["transports"] as? [[String:Any]] {
            ////                        {
            ////                            for item in dataArray {
            //////                                    userIds.append(userId)
            ////                                }
            ////                            }
            ////                            print(userIds)
            ////                        }
            //                              var transportsArray: [String: Any] = [:]
            //                              var tempArrayDict=[String:Any]()
            //                              var mainArray=[[String:Any]]()
            //                              if let dataArray = data["Data"] as? [[String: Any]]
            //                              {
            //                                  print("dataArray",dataArray)
            //
            //                                  for items in dataArray
            //                                  {
            //
            ////                                      tempArrayDict.updateValue(items["transports"] as! [String], forKey: "transports")
            //                                      tempArrayDict.updateValue(items["user_id"] as! String, forKey: "user_id")
            //                                      tempArrayDict.updateValue(items["user_name"] as! String, forKey: "user_name")
            //                                      tempArrayDict.updateValue(items["producers"] as! [String], forKey: "producers")
            //
            //
            //                                      //                    if let transports = items["transports"] as? [String: Any
            //                                      //                    {
            //                                      //                        transportsArray.append(transports)
            //                                      //                    }
            //                                      //                    print(transportsArray)
            //                                      if !(items["user_name"] as! String ==  "Rihesh")
            //                                      {
            //                                          mainArray.append(tempArrayDict)
            //                                      }
            //
            //                                  }
            //                                  print("MainArray : ",mainArray)
            //                                  if mainArray.count > 0
            //                                  {
            //                                      for i in 0...mainArray.count-1{
            //
            //                                          let test = mainArray[i]["producers"] as! [String]
            //                                          print("test",test)
            //                                          if test.count > 0
            //                                          {
            //                                              for i in 0...test.count-1{
            //                                                  getCosumerStream(roomid: roomID, transportId: id, ProducerId: test[i] , RtpCapabilities: capabilityJSON)
            //                                              }
            //                                          }
            //
            //                                      }
            //                                  }
            //                                  print("mainArray",mainArray)
            //                              }
            
            //            for items in transpo {
            //                if let userName = items["user_name"] as? String, userName != "Rihesh" {
            //                    if let transports = items["transports"] as? [String] {
            //                        let dictionary: [String: Any] = ["user_name": userName, "transports": transports]
            //                        transportsArray.append(dictionary)
            //                    }
            //                }
            //            }
            //
            //            //            print(transportsArray)
            //
            //            print("Producer Data :" , dataArray)
        }
        
        if Event == "consumed"
        {
            let data = message.dictionary("Data")
            //let dataArray = data.array("params")
            let paramsData = data.dictionary("params")
            var consumerIndoDic:[String:Any] = paramsData
            consumerIndoDic["requestId"] = requestId
            let kind = consumerIndoDic.strValue("kind")
            
            //音频
            if kind == "audio"{
                self.consumersInfoAudios.append(consumerIndoDic)
                //视频
            }else{
                self.consumersInfoVideos.append(consumerIndoDic)
                
            }
            // if !peersIDs.isEmpty{
            let id = consumerIndoDic.strValue("id")
            let producerId = consumerIndoDic.strValue("producerId")
            let rtpParameters = JSON(consumerIndoDic.dictionary("rtpParameters")).description
            let appData = JSON(consumerIndoDic.dictionary("appData")).description
            print("\r\nReady to create a new user\npeersIDs:  \(peersIDs)，\nid:  \(id),  \nproducerId:  \(producerId)，kind:\(kind),\(Thread.current)")
            //Subscribe to the video and audio data corresponding to the user
            guard let consumer = self.recvTransport?.consume(self.consumerHandler, id: id, producerId: producerId, kind: kind, rtpParameters: rtpParameters) else{
                print("New users join. . . . . Failed. . . . .")
                return
            }
            print("***newConsumer created successfully****\(kind)  id:\(String(describing: consumer.getId())), \(Thread.current)")
            self.totalConsumers[consumer.getId()] = consumer
            if kind == "video"{
                self.delegate?.onNewConsumerUpdateUI(helper: self, consumer: consumer)
                print("UIupdate completed")
            }
            //             createConsumerAndResume() //to be uncommented
            //            startVideoAndAudio()
            // self.sendResponse(requestId:requestId)
            // }
        }
        // MARK: - Event new producers
        if Event == "newProducers"
        {
            let data =  message.array("Data")
            print("data",data)
            if data.count>0{
                for i in 0...data.count-1{
                    let producerid=data[i]["producer_id"]
                    print("producerid of new producers",producerid)
                    producerId.append(producerid as? String ?? "")
                }
            }
        }
        //MARK: - Login Events
        if Event == "UserLoginCallBack"
        {
            self.signIndelegate?.passData()
        }
        if Event == "UserLoginFailed"
        {
            print("Login Failed")
        }
        if Event == "UserLoginSuccess"
        {
            self.signIndelegate?.passData()
            let data =  message.dictionary("Data")
            print("MAin array of login sucess",data)
            let dataArray = data["UserDetails"] as! [String:Any]
            print("dataArray of login success",dataArray)
            let userid = dataArray["userID"] as! String
            let name = dataArray["name"] as! String
            let NewClientId = data["ClientID"] as! String
            print(userid)
            print("new client id is : \n",NewClientId)
            userID = userid
            nameID = name
            UpdateUserClientId(userid: userID, clientid: NewClientId)
            print("acknowledgeUserStatus user id :",userID)
        }
        //MARK: - SignUp Events
        if Event == "SignUpSuccess"
        {
            self.signIndelegate?.passData()
            print("SignUp Success event called successfully\n")
        }
        if Event == "SignUpFailed"
        {
            let data = message.array("Data")
            print("SignUp Failed\n",data)
        }
        //MARK: - EVENT UpdateUserClientIdSuccess
        if Event == "UpdateUserClientIdSuccess"
        {
            acknowledgeUserStatus(SearchKey: "", userId: userID)
            DashboardParticipantsList(SearchKey: "", userId: userID)
        }
        
        //MARK: - DASHBOARD EVENTS AND PARTICIPANT LIST
        if Event == "acknowledgeUserStatusSuccess"
        {
            let data =  message.dictionary("Data")
            print("acknowledgeUserStatusSuccess : \n",data)
        }
        if Event == "DashboardParticipantsListSuccess"
        {
            let data =  message.dictionary("Data")
            print("Dashboardparticipant List array :",data)
            let dataArray = data.array("RoomList") as! [[String: Any]]
            print ("RoomList DataArray : \n",dataArray)
            NotificationCenter.default.post(name: NSNotification.Name("DashboardParticipantsListSuccess"), object: dataArray)
            self.dashBoardClassDelegate?.dashboardData(roomlist: dataArray)
        }
        //MARK: - new consumer event
        NotificationCenter.default.post(name: NSNotification.Name("kOnRecveMessage"), object: message)
        if method == "newConsumer"{
            //The requestId must be added here, because this field is taken later for subscription
            var consumerIndoDic:[String:Any] = data
            consumerIndoDic["requestId"] = requestId
            let kind = consumerIndoDic.strValue("kind")
            
            //audio
            if kind == "audio"{
                self.consumersInfoAudios.append(consumerIndoDic)
                //video
            }else{
                self.consumersInfoVideos.append(consumerIndoDic)
            }
            if !peersIDs.isEmpty{
                let id = consumerIndoDic.strValue("id")
                let producerId = consumerIndoDic.strValue("producerId")
                let rtpParameters = JSON(consumerIndoDic.dictionary("rtpParameters")).description
                let appData = JSON(consumerIndoDic.dictionary("appData")).description
                print("\r\nReady to create a new user\npeersIDs:  \(peersIDs)，\nid:  \(id),  \nproducerId:  \(producerId)，kind:\(kind),\(Thread.current)")
                
                //Subscribe to the video and audio data corresponding to the user
                guard let consumer = self.recvTransport?.consume(self.consumerHandler, id: id, producerId: producerId, kind: kind, rtpParameters: rtpParameters,appData:appData) else{
                    print("New users join. . . . . Failed. . . . .")
                    return
                }
                print("***newConsumer created successfully****\(kind)  id:\(String(describing: consumer.getId())), \(Thread.current)")
                self.totalConsumers[consumer.getId()] = consumer
                if kind == "video"{
                    self.delegate?.onNewConsumerUpdateUI(helper: self, consumer: consumer)
                    print("UI update complete")
                }
                self.sendResponse(requestId:requestId)
            }
        }
        else if method == "newPeer"
        {
            let id = data.strValue("id")
            self.peersIDs.append(id)
            
        }
        else if method == "consumerClosed"
        {
            print("---method user logged out -->\(method)")
            // consumerClosed(consumerId: data.strValue("consumerId"))
        }
    }
}
