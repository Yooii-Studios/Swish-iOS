//
//  UITableView+Reload.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 13..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

extension UITableView {
    func reloadData(completion: () -> Void) {
        UIView.animateWithDuration(0, animations: { self.reloadData() }, completion: { _ in
            completion()
        })
    }
}
