//
//  DeliveryHomeTableViewCell.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/31/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit

class HighlightedRestaurantCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    let peekImplementation = MSPeekCollectionViewDelegateImplementation(cellSpacing: 10, cellPeekWidth: 16)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "HighlightedRestaurantCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HighlightedRestaurantCell")
        
        collectionView.configureForPeekingDelegate()
        collectionView.delegate = peekImplementation
    }

    func setCollectionViewDataSourceDelegate(_ dataSource: UICollectionViewDataSource, forRow row: Int) {
        collectionView.dataSource = dataSource
        collectionView.tag = row
        collectionView.reloadData()
    }
}
