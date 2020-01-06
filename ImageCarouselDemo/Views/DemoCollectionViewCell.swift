//
//  DemoCollectionViewCell.swift
//  ImageCarouselDemo
//
//  Created by Min on 2020/1/6.
//  Copyright © 2020 Min. All rights reserved.
//

import UIKit

enum DemoColorType {
  case red, blue, green
}

extension DemoColorType {
  var color: UIColor {
    switch self {
      case .red:
        return .systemRed
      case .blue:
        return.systemBlue
      case .green:
        return .systemGreen
    }
  }

  var index: Int {
    switch self {
      case .red:
        return 1
      case .blue:
        return 2
      case .green:
        return 3
    }
  }
}

class DemoCollectionViewCell: UICollectionViewCell {

  lazy private var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: bounds.height - 20, weight: .bold)
    label.textAlignment = .center
    return label
  }()

  var colorType: DemoColorType = .red {
    didSet {
      contentView.backgroundColor = colorType.color
      titleLabel.text = "\(colorType.index)"
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUserInterface()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Private Methods

  private func setUserInterface() {
    contentView.addSubview(titleLabel)
    setUpLayout()
  }

  private func setUpLayout() {
    contentView.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[titleLabel]|",
      options: [],
      metrics: nil,
      views: ["titleLabel": titleLabel]))

    contentView.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "V:|[titleLabel]|",
      options: [],
      metrics: nil,
      views: ["titleLabel": titleLabel]))
  }
}
