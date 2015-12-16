//
//  PhotoVoteType.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 16..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

protocol PhotoVoteType {

    var photo: Photo! { get }
    var photoActionView: PhotoActionView! { get }
    
    func mapButtonDidTap(sender: AnyObject)
    func chatButtonDidTap(sender: AnyObject)
}
