//
//  ViewController.swift
//  ImageCarouselDemo
//
//  Created by Min on 2020/1/6.
//  Copyright © 2020 Min. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let demoInfo: [DemoColorType] = [.green, .red, .blue, .green, .red]
  
  private var autoScorllTimer: DispatchSourceTimer?
  var currentIndex = 1

  private var isBeginAutoScroll = false {
    didSet {
      switch isBeginAutoScroll {
        case true:
          cancelAutoScrollTimer()
        case false:
          startAutoScrollTimer()
      }
    }
  }

  lazy private var flowLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.scrollDirection = .horizontal
    return layout
  }()

  lazy private var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    collectionView.backgroundColor = .black
    collectionView.register(DemoCollectionViewCell.self, forCellWithReuseIdentifier: DemoCollectionViewCell.identifier)
    return collectionView
  }()

  lazy private var pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    pageControl.isEnabled = false
    return pageControl
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setUserInterface()
  }

  // MARK: - Private Methods

  private func setUserInterface() {
    view.backgroundColor = .white
    view.addSubviews([collectionView, pageControl])
    setUpLayout()
    setUpPageControl()

    collectionView.layoutIfNeeded()
    collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)

    startAutoScrollTimer()
  }

  private func setUpLayout() {
    view.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[collectionView]|",
      options: [],
      metrics: nil,
      views: ["collectionView": collectionView]))

    view.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-100-[collectionView(200)]",
      options: [],
      metrics: nil,
      views: ["collectionView": collectionView]))

    view.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[pageControl]|",
      options: [],
      metrics: nil,
      views: ["pageControl": pageControl]))

    view.addConstraints(NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-270-[pageControl(30)]",
      options: [],
      metrics: nil,
      views: ["pageControl": pageControl]))
  }

  private func setUpPageControl() {
    pageControl.currentPage = 0
    pageControl.numberOfPages = demoInfo.count - 2
  }

  private func startAutoScrollTimer() {
    guard autoScorllTimer == nil else { return }
    print(#function, "startTime: \(Date())")
    let workItem = DispatchWorkItem { [weak self] in
      self?.scrollCell()
    }
    autoScorllTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    autoScorllTimer?.schedule(deadline: .now() + .seconds(3), repeating: .seconds(3), leeway: .milliseconds(10))
    autoScorllTimer?.setEventHandler(handler: workItem)

    autoScorllTimer?.resume()
  }

  private func cancelAutoScrollTimer() {
    guard autoScorllTimer != nil else { return }
    autoScorllTimer?.cancel()
    autoScorllTimer = nil
  }

  // MARK: - Action Methods

  @objc private func scrollCell() {
    print(Date(), " Start ------------------->")
    DispatchQueue.main.async { [weak self] in
      guard let currentIndex = self?.currentIndex, let demoInfo = self?.demoInfo, let view = self?.view else { return }
      switch currentIndex {
        case let x where x >= demoInfo.count - 2:
          self?.currentIndex = 1
          self?.collectionView.scrollToItem(at: IndexPath(item: 4, section: 0), at: .centeredHorizontally, animated: true)
          Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
        }
        case let x where x >= 1 && x <= demoInfo.count - 2:
          let index = currentIndex + 1
          self?.currentIndex = index
          self?.collectionView.scrollRectToVisible(CGRect(origin: CGPoint(x: view.bounds.width * CGFloat(index), y: 0), size: view.frame.size), animated: true)
        default:
          break
      }
    }
  }
}

  // MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let controller = SecondViewController()
    navigationController?.pushViewController(controller, animated: true)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.frame.size
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    guard !isBeginAutoScroll else { return }
    isBeginAutoScroll = true
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let screenWidth = view.bounds.width
    let xPoint = (scrollView.contentOffset.x - screenWidth) / screenWidth
    currentIndex = lround(Double(xPoint)) < 1 ? 1 : lround(Double(xPoint)) > demoInfo.count - 2 ? 3 : lround(Double(xPoint)) + 1
    switch xPoint {
      case let x where x > (CGFloat(demoInfo.count - 2) - 0.5):
        pageControl.currentPage = 0
      case let x where x < -0.5:
        pageControl.currentPage = demoInfo.count - 2
      default:
        pageControl.currentPage = lround(Double(xPoint))
    }
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if isBeginAutoScroll {
      isBeginAutoScroll = false
    }
    let screenWidth = view.bounds.width
    switch scrollView.contentOffset.x {
      case let x where x > (screenWidth * (CGFloat(demoInfo.count - 2) + 0.5)):
        scrollView.contentOffset = CGPoint(x: screenWidth, y: 0)
      case let x where x < screenWidth * 0.5:
        scrollView.contentOffset = CGPoint(x: screenWidth * 3, y: 0)
      default:
        break
    }
  }
}

  // MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return demoInfo.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DemoCollectionViewCell.identifier, for: indexPath) as? DemoCollectionViewCell else {
      fatalError("DemoCollectionViewCell init fail")
    }
    cell.colorType = demoInfo[indexPath.row]
    return cell
  }
}
