//
//  CollectionViewStackFlowLayout.swift
//  NavigationStackDemo
//
//  Created by Alex K. on 25/02/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

// MARK: CollectionViewStackFlowLayout

class CollectionViewStackFlowLayout: UICollectionViewFlowLayout {
  
  let itemsCount: Int
  let overlay: Float
  
  init(itemsCount: Int, overlay: Float) {
    self.itemsCount = itemsCount
    self.overlay    = overlay
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

}

extension CollectionViewStackFlowLayout {
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let items = NSArray (array: super.layoutAttributesForElementsInRect(rect)!, copyItems: true)
    var headerAttributes: UICollectionViewLayoutAttributes?
    
    items.enumerateObjectsUsingBlock { (object, idex, stop) -> Void in
      let attributes = object as! UICollectionViewLayoutAttributes
      
      if attributes.representedElementKind == UICollectionElementKindSectionHeader {
        headerAttributes = attributes
      }
      else {
        self.updateCellAttributes(attributes, headerAttributes: headerAttributes)
      }
    }
    return items as? [UICollectionViewLayoutAttributes]
  }
  
  func updateCellAttributes(attributes: UICollectionViewLayoutAttributes, headerAttributes: UICollectionViewLayoutAttributes?) {
    
    guard let collectionView = self.collectionView else {
      return;
    }
    let itemWidth = collectionView.bounds.size.width - collectionView.bounds.size.width * CGFloat(overlay)
    let allWidth = itemWidth * CGFloat(itemsCount - 1)
    
    // set contentOffset range
    let contentOffsetX = min(max(0, collectionView.contentOffset.x), allWidth)
    
    let scale = transformScale(attributes, allWidth: allWidth, offset: contentOffsetX)
    let move  = transformMove(attributes, itemWidth: itemWidth, offset: contentOffsetX)
    attributes.transform = CGAffineTransformConcat(scale, move)

    attributes.zIndex    = attributes.indexPath.row
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
}

// MARK: helpers

extension CollectionViewStackFlowLayout {

  private func transformScale(attributes: UICollectionViewLayoutAttributes, allWidth: CGFloat, offset: CGFloat) -> CGAffineTransform {
    let maxScale = 0.8 - CGFloat(itemsCount - attributes.indexPath.row) / 50.0
    let minScale = 0.7 - CGFloat(itemsCount - attributes.indexPath.row) / 50.0
    
    var currentScale = (maxScale + minScale) - (minScale + offset / (allWidth / (maxScale - minScale)))
    currentScale = max(min(maxScale, currentScale), minScale)
    return CGAffineTransformMakeScale(currentScale, currentScale)
  }
  
  private func transformMove(attributes: UICollectionViewLayoutAttributes, itemWidth: CGFloat, offset: CGFloat) -> CGAffineTransform {
    var currentContentOffsetX = offset - itemWidth * CGFloat(attributes.indexPath.row)
    currentContentOffsetX = min(max(currentContentOffsetX, 0),itemWidth)
    
    var dx = (currentContentOffsetX / itemWidth)
    if dx == 1 {
      attributes.hidden = true
    } else {
      attributes.hidden = false
    }
    
    dx = pow(dx,2) * 150
    return CGAffineTransformMakeTranslation(dx, 0)
  }


}
