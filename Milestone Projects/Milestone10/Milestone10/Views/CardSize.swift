//
//  CardSize.swift
//  Milestone10
//
//  Created by Brian Coleman on 2022-06-02.
//

import UIKit

class CardSize {
    var imageSize: CGSize
    var gridSide1: Int
    var gridSide2: Int
    
    init(imageSize: CGSize, gridSide1: Int, gridSide2: Int) {
        self.imageSize = imageSize
        self.gridSide1 = gridSide1
        self.gridSide2 = gridSide2
    }
    
    func getCardSize(collectionView: UICollectionView) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        
        let layoutMargins = collectionView.layoutMargins
        let leftRightMargin = layoutMargins.left + layoutMargins.right
        let topBottomMargin = layoutMargins.top + layoutMargins.bottom
        
        var availableWidth = width - leftRightMargin
        var availableHeight = height - topBottomMargin
        
        let (widthCardNumber, heightCardNumber) = getWidthHeightCardNumber(availableWidth: availableWidth, availableHeight: availableHeight)
        
        var cardWidth = availableWidth / widthCardNumber
        var cardHeight = availableHeight / heightCardNumber
        
        let widthSpacing = floor(min(cardWidth, cardHeight) / 10)
        let heightSpacing = widthSpacing
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        layout?.minimumInteritemSpacing = heightSpacing
        layout?.minimumLineSpacing = widthSpacing
        
        availableWidth -= widthSpacing * (widthCardNumber + 1)
        availableHeight -= heightSpacing * (heightCardNumber + 1)
        
        cardWidth = availableWidth / widthCardNumber
        cardHeight = availableHeight / heightCardNumber
        
        let widthDifference = cardWidth - (cardHeight * imageSize.width / imageSize.height)
        let heightDifference = cardHeight - (cardWidth * imageSize.height / imageSize.width)
        
        if widthDifference > heightDifference {
            let totalDifference = widthDifference * widthCardNumber
            let leftRightSectionInset = floor(widthSpacing + (totalDifference / 2))
            let topBottomSectionInset = heightSpacing
            
            layout?.sectionInset = UIEdgeInsets(top: topBottomSectionInset, left: leftRightSectionInset, bottom: topBottomSectionInset, right: leftRightSectionInset)
            
            availableWidth -= totalDifference
        }
        else if heightDifference > widthDifference {
            let totalDifference = heightDifference * heightCardNumber
            let topBottomSectionInset = floor(heightSpacing + (totalDifference / 2))
            let leftRightSectionInset = widthSpacing
            
            layout?.sectionInset = UIEdgeInsets(top: topBottomSectionInset, left: leftRightSectionInset, bottom: topBottomSectionInset, right: leftRightSectionInset)
            
            availableHeight -= totalDifference
        }
        
        cardWidth = floor(availableWidth / widthCardNumber)
        cardHeight = floor(availableHeight / heightCardNumber)
        
        let widthRemainder = floor((availableWidth - (cardWidth * widthCardNumber)) / 2)
        let heightRemainder = floor((availableHeight - (cardHeight * heightCardNumber)) / 2)
        
        if let layout = layout {
            let left = layout.sectionInset.left + widthRemainder
            let right = layout.sectionInset.right + widthRemainder
            let top = layout.sectionInset.top + heightRemainder
            let bottom = layout.sectionInset.bottom + heightRemainder
            
            layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        guard cardWidth > 0 && cardHeight > 0 else {
            fatalError("Too many cards to display")
        }
        
        return CGSize(width: cardWidth, height: cardHeight)
    }
    
    func getWidthHeightCardNumber(availableWidth: CGFloat, availableHeight: CGFloat) -> (widthCardNumber: CGFloat, heightCardNumber: CGFloat) {
        if availableWidth > availableHeight {
            let availableRatio = availableWidth / availableHeight

            let gridSide = getSideWithClosestRatio(referenceRatio: availableRatio, imageSide1: imageSize.width, imageSide2: imageSize.height)

            let widthCardNumber = CGFloat(gridSide == gridSide1 ? gridSide1 : gridSide2)
            let heightCardNumber = CGFloat(gridSide == gridSide1 ? gridSide2 : gridSide1)
            
            return (widthCardNumber: widthCardNumber, heightCardNumber: heightCardNumber)
        }
            
        let availableRatio = availableHeight / availableWidth
        
        let gridSide = getSideWithClosestRatio(referenceRatio: availableRatio, imageSide1: imageSize.height, imageSide2: imageSize.width)
        
        let heightCardNumber = CGFloat(gridSide == gridSide1 ? gridSide1 : gridSide2)
        let widthCardNumber = CGFloat(gridSide == gridSide1 ? gridSide2 : gridSide1)

        return (widthCardNumber: widthCardNumber, heightCardNumber: heightCardNumber)
    }
    
    func getSideWithClosestRatio(referenceRatio: CGFloat, imageSide1: CGFloat, imageSide2: CGFloat) -> Int {
        let gridSide1Ratio = imageSide1 * CGFloat(gridSide1) / (imageSide2 * CGFloat(gridSide2))
        let gridSide2Ratio = imageSide1 * CGFloat(gridSide2) / (imageSide2 * CGFloat(gridSide1))

        let gridSide1IsClosest: Bool

        if gridSide1Ratio >= 1 && gridSide2Ratio >= 1 {
            gridSide1IsClosest = abs(gridSide1Ratio - referenceRatio) <= abs(gridSide2Ratio - referenceRatio)
        } else if gridSide1Ratio < 1 && gridSide2Ratio < 1{
            gridSide1IsClosest = gridSide1Ratio >= gridSide2Ratio
        } else {
            gridSide1IsClosest = gridSide1Ratio >= 1
        }

        return gridSide1IsClosest ? gridSide1 : gridSide2
    }
}
