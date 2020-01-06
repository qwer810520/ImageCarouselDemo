//
//  Extension.swift
//  ImageCarouselDemo
//
//  Created by Min on 2020/1/6.
//  Copyright © 2020 Min. All rights reserved.
//

import UIKit

  // MARK: - UIView Extension

extension UIView {
  func addSubviews(_ views: [UIView]) {
    views.forEach { addSubview($0) }
  }
}

  // MARK: - UICollectionReusableView Extension

extension UICollectionReusableView {
  static var identifier: String {
    return String(describing: self)
  }
}


