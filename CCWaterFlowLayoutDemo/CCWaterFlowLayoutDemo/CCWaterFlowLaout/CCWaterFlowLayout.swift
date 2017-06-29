//
//  CCWaterFlowLayout.swift
//  CCWaterFlowLayoutDemo
//
//  Created by Halo on 2017/6/28.
//  Copyright © 2017年 Choice. All rights reserved.
//

import UIKit

@objc
protocol CCWaterFlowLayoutDelegate {
    //返回item高度
    @objc func setUpWaterFlowLayoutHeight(waterflowLayout: CCWaterFlowLayout,heightForItemAtIndex indexPath: IndexPath,itemWidth: CGFloat) -> CGFloat
    //返回列数，自动根据列数适应item宽度
    @objc optional  func waterFlowLayout(waterflowLayout: CCWaterFlowLayout, columCountAtSection section: Int) -> Int
    //列间距
    @objc optional  func waterFlowLayout(waterflowLayout: CCWaterFlowLayout, columSpecingAtSection section: Int) -> CGFloat
    //行间距
    @objc optional  func waterFlowLayout(waterflowLayout: CCWaterFlowLayout, rowSpecingAtSection section: Int) -> CGFloat
    //edgeInset
    @objc optional  func waterFlowLayout(waterflowLayout: CCWaterFlowLayout, itemEdgeInsetsAtSection section: Int) -> UIEdgeInsets
    
    @objc optional func layoutCollectionView(collectionView: UICollectionView,layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath)
}
//MARK: - default
/** 默认的列数 */
private let defaultColumCount: Int = 3
/** 每一列之间的间距 */
private let defaultColumnSpecing: CGFloat = 10
/** 每一行之间的间距 */
private let defaultRowSpecing: CGFloat = 10
/** 边缘间距 */
private let defaultItemEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)


class CCWaterFlowLayout: UICollectionViewLayout {
    
    /** 存放所有cell的布局属性 */
    fileprivate var layoutAttrsArray = [UICollectionViewLayoutAttributes]()
    
    fileprivate struct columHeight{
        var section : Int
        var height : CGFloat
    }
    /** 存放所有列的当前高度 */
    fileprivate var columnHeights: [columHeight] = [columHeight]()
    
    weak var delegate: CCWaterFlowLayoutDelegate?
    
}
//MARK: - delegate
extension CCWaterFlowLayout {
    func rowSpecing(forSection:Int) -> CGFloat {

        if (self.delegate?.waterFlowLayout?(waterflowLayout: self, rowSpecingAtSection: forSection)) != nil {
            return (delegate?.waterFlowLayout!(waterflowLayout: self, rowSpecingAtSection: forSection))!
        }
        else{
            return defaultRowSpecing
        }
    }
    
    func columSpecing(forSection:Int) -> CGFloat {

        if (self.delegate?.waterFlowLayout?(waterflowLayout: self, columSpecingAtSection: forSection)) != nil {
            return (delegate?.waterFlowLayout!(waterflowLayout: self, columSpecingAtSection: forSection))!
        }
        else{
            return defaultColumnSpecing
        }
    }

    
    func edgeInsets(forSection:Int) -> UIEdgeInsets {

        if (self.delegate?.waterFlowLayout?(waterflowLayout: self, itemEdgeInsetsAtSection: forSection)) != nil {
            return (delegate?.waterFlowLayout!(waterflowLayout: self, itemEdgeInsetsAtSection: forSection))!
        }
        else{
            return defaultItemEdgeInsets
        }
    }
    
    func columCount(forSection:Int) -> Int {

        if (self.delegate?.waterFlowLayout?(waterflowLayout:self, columCountAtSection: forSection)) != nil {
            return (delegate?.waterFlowLayout!(waterflowLayout: self, columCountAtSection: forSection))!
        }
        else{
            return defaultColumCount
        }
    }

}
//MARK: - override
extension CCWaterFlowLayout {
    override func prepare() {
        super.prepare()
        // 清除之前所有的布局属性
        columnHeights.removeAll()
        layoutAttrsArray.removeAll()

        for i in 0  ..< (collectionView?.numberOfSections)!{
            let columCount = self.columCount(forSection: i)
            for _ in 0 ..< columCount {
                //每列的高度
                let height = self.edgeInsets(forSection: i).top
                self.columnHeights.append(columHeight(section: i, height: height))
            }
            for j in 0 ..< (collectionView?.numberOfItems(inSection: i))!{
                let indexPaht = IndexPath(item: j, section: i)
                let attArr = self.layoutAttributesForItem(at: indexPaht)
                layoutAttrsArray.append(attArr!)
            }
        }
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForItem(at: indexPath)
        // 创建布局属性
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        var x,y,w,h :CGFloat
        
        w = (self.collectionView!.frame.size.width - self.edgeInsets(forSection: indexPath.section).left - self.edgeInsets(forSection: indexPath.section).right - (CGFloat(self.columCount(forSection: indexPath.section) - 1) * self.columSpecing(forSection: indexPath.section))) / CGFloat(self.columCount(forSection: indexPath.section))
        
        // 通过代理可以设置高度
        if (self.delegate?.setUpWaterFlowLayoutHeight(waterflowLayout: self, heightForItemAtIndex: indexPath, itemWidth: w)) != nil   {
            h = (self.delegate?.setUpWaterFlowLayoutHeight(waterflowLayout: self, heightForItemAtIndex: indexPath, itemWidth: w))!
        }
        else{
            h = CGFloat(100) + CGFloat(arc4random_uniform(100))
        }
        
        // 取得所有列中高度最短的列
        let minHeightColumn = self.minHeightColumn()
        
        x = self.edgeInsets(forSection: indexPath.section).left + CGFloat(minHeightColumn) * (w + self.columSpecing(forSection: indexPath.section));
        
        y = self.edgeInsets(forSection: indexPath.section).top + self.columnHeights[minHeightColumn].height + self.rowSpecing(forSection: indexPath.section)
        
        // #warning 更改最短的一列
        self.columnHeights[minHeightColumn].height = y + h
        
        attrs.frame = CGRect(x: x, y: y, width: w, height: h)
        
        return attrs;
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)
        return self.layoutAttrsArray
    }
    
    /// 返回collectionView的滚动范围
    override var collectionViewContentSize: CGSize {
        let _ = super.collectionViewContentSize
        if (self.columnHeights.count == 0) {
            return CGSize.zero
        }
        
        // 获得最高的列
        let maxColum = self.maxHeightColumn()
        
        let height: CGFloat = self.columnHeights[maxColum].height + defaultItemEdgeInsets.bottom;
        let width: CGFloat = self.collectionView!.frame.size.width;
        
        return CGSize(width: width, height: height)
    }
}

//MARK: - private
extension CCWaterFlowLayout {
    /// 取得所有列中高度最短的列
    fileprivate func minHeightColumn() -> Int {
        // 找出columnHeights的最小值
        var minHeightColum: Int = 0
        var minColumHeight: columHeight = self.columnHeights[0]
        
        for i in 1..<columnHeights.count {
            let tempHeight:columHeight = self.columnHeights[i]
            
            if (tempHeight.height < minColumHeight.height) {
                minHeightColum = i;
                minColumHeight = tempHeight;
            }
        }
        return minHeightColum
    }
    
    /// 取得所有列中长度最长的列
    fileprivate func maxHeightColumn() -> Int {
        // 找出columnHeights的最高值
        var maxHeightColumn: Int = 0
        var maxColumnHeight: columHeight = self.columnHeights[0]
        
        for i in 1..<columnHeights.count {
            let tempHeight:columHeight = self.columnHeights[i]
            
            if (tempHeight.height > maxColumnHeight.height) {
                maxHeightColumn = i
                maxColumnHeight = tempHeight
            }
        }
        return maxHeightColumn
    }
}
