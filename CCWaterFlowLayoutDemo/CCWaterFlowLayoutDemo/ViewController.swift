//
//  ViewController.swift
//  CCWaterFlowLayoutDemo
//
//  Created by Halo on 2017/6/28.
//  Copyright © 2017年 Choice. All rights reserved.
//

import UIKit

let SCREENWIDTH = UIScreen.main.bounds.size.width
let SCREENHEIGHT = UIScreen.main.bounds.size.height
let collectionViewCellIdentifier = "collectionViewCellIdentifier"

class ViewController: UIViewController {

    fileprivate lazy var collectionView : UICollectionView = { [unowned self] in
        let layout = CCWaterFlowLayout()
        layout.delegate = self
        let fllow = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT), collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView .register(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier)
        
        
    }

}

extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource,CCWaterFlowLayoutDelegate{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 20
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.orange
        
        return cell
    }
    
    func setUpWaterFlowLayoutHeight(waterflowLayout: CCWaterFlowLayout,heightForItemAtIndex indexPath: IndexPath,itemWidth: CGFloat) -> CGFloat{
        let height = arc4random_uniform(100) + 100

        return CGFloat(height)
        
    }

}
