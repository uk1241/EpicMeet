//
//  ChatCollectionView.swift
//  PodDemo3
//
//  Created by KOYO on 2022/10/11.
//

import Foundation
import UIKit

class ChatCollectionView: UIView {
    
    var collectionView: UICollectionView!
    var itemSelectedBlock: ((_ path:IndexPath)->())?
    private var itemH:CGFloat = 100
    private var colCount = 2
    private var footerH:CGFloat = 0.00001
   
    private var dataArr:[ChatRender] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubView()
    }
    
    
    //user join
    func onAddItem(item:ChatRender){
        self.dataArr.append(item)
        self.collectionView.reloadData()
       
        
    }
    
    ///user logout
    func onUserExit(consumerId:String){
        for (i,item) in dataArr.enumerated(){
            if item.videoId == consumerId{
                self.dataArr.remove(at: i)
                self.collectionView.reloadData()
                break
            }
        }
    }
    
    ///This parameter must be set
    func setParams(itemH:CGFloat,colCount:Int,footerH: CGFloat = 0.0001){
        self.itemH = itemH
        self.colCount = colCount
        self.footerH = footerH
    }
    
    ///initialized by the
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
    }
    
    ///registerCELL
   func register(_ cells:[String]){
       for cell in cells{
       collectionView?.register(UINib(nibName: cell, bundle: Bundle.main), forCellWithReuseIdentifier: cell)
       }
   }
    
    ///set data source
    func updateData(_ dataArr:[ChatRender])->CGFloat{
        self.dataArr = dataArr
        let totalH = self.getH()
        return totalH
    }
    
    ///Get the overall height of the control (set the data source first)
    func getH()->CGFloat{
        let count = dataArr.count
        if count == 0{return 0}
        let row = self.colCount///一行几个
        let col = count % row == 0 ? count / row : (count / row)+1
        return CGFloat(col) * self.itemH
    }
    
    
    ///refresh data
    func reloadData(){
        self.collectionView.reloadData()
    }
    ////construct data
    private func setupSubView(){
        if self.collectionView != nil{return}
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        flow.scrollDirection = .vertical
        flow.sectionInset = UIEdgeInsets.init(top:0, left: 0, bottom: 0, right:0)
        
        let collView = UICollectionView(frame:.zero, collectionViewLayout: flow)
        collView.register(UINib(nibName: "ChatCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChatCollectionViewCell")
        collView.delegate = self
        collView.dataSource = self
        collView.backgroundColor = .white
        collectionView = collView
        self.addSubview(collView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
    }
}

extension ChatCollectionView: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    //number of partitions
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatCollectionViewCell", for: indexPath) as! ChatCollectionViewCell
        let item = dataArr[indexPath.row]
        item.videoView.removeFromSuperview()
//        let h = cell.bgView.frame.size.height
//        let w = cell.bgView.frame.size.width
//        item.videoView.frame = CGRect(x: 5, y:5, width: w-10, height: h-10)
        item.videoView.frame = cell.bgView.bounds
        cell.bgView.addSubview(item.videoView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemSelectedBlock?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        //Automatic calculation based on the width and number of columns of the current control (provided that the width of the current control already exists)
//        let h = self.itemH
        let w = CGFloat(self.frame.size.width / CGFloat(self.colCount))
        return CGSize(width:w, height:w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.size.width, height: footerH)
    }
}
