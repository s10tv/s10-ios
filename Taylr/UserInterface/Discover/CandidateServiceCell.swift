//
//  CandidateServiceCell.swift
//  S10
//
//  Created by Tony Xiao on 7/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Core

class CandidateServiceCell : UICollectionViewCell, BindableCell {
    typealias ViewModel = UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    func bind(vm: UIImage?) {
        imageView.image = vm
    }
    
    static func reuseId() -> String {
        return CollectionViewCellreuseIdentifier.CandidateService.rawValue
    }
}