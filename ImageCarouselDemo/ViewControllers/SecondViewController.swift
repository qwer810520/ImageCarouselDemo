//
//  SecondViewController.swift
//  ImageCarouselDemo
//
//  Created by Min on 2020/1/6.
//  Copyright © 2020 Min. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.backgroundColor = .systemPink
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    navigationController?.popViewController(animated: true)
  }
}
