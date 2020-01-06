//
//  ViewController.swift
//  ImageCarouselDemo
//
//  Created by Min on 2020/1/6.
//  Copyright © 2020 Min. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let demoInfo: [DemoColorType] = [.red, .blue, .green]
  
  private var autoScorllTimer: DispatchSourceTimer?
  var currentIndex = 1

  private var isBeginAutoScroll = false {
    didSet {
      switch isBeginAutoScroll {
        case true:
          startAutoScrollTimer()
        case false:
          cancelAutoScrollTimer()
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
    scrollToCenterItem()

    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "滑到最大值", style: .plain, target: self, action: #selector(scrollToMaxItems))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "滑到最小值", style: .plain, target: self, action: #selector(scrollToMinItem))

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
    pageControl.numberOfPages = demoInfo.count
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

  private func scrollToCenterItem(with gap: Int = 0) {
    let count = collectionView.numberOfItems(inSection: 0)
    currentIndex = count + gap
    collectionView.scrollToItem(at: IndexPath(item: (count / 2) + gap, section: 0), at: .centeredHorizontally, animated: false)
  }

  private func getInfoIndex(with indexPath: IndexPath) -> Int {
    switch indexPath.row % demoInfo.count {
    case let x where x > 0 && x < demoInfo.count:
        return x - 1
    default:
        return demoInfo.count - 1
    }
  }

  // MARK: - Action Methods

  @objc private func scrollCell() {
    print(Date(), " Start ------------------->")
    DispatchQueue.main.async { [weak self] in
      guard let currentIndex = self?.currentIndex, let view = self?.view else { return }
      let index = currentIndex + 1
      self?.currentIndex = index
      self?.collectionView.scrollRectToVisible(CGRect(origin: CGPoint(x: view.bounds.width * CGFloat(index), y: 0), size: view.frame.size), animated: true)
    }
  }

  // MARK: - Test Methods

  @objc private func scrollToMaxItems() {
    let count = collectionView.numberOfItems(inSection: 0)
    currentIndex = count
    collectionView.scrollToItem(at: IndexPath(item: count, section: 0), at: .centeredHorizontally, animated: true)
  }

  @objc private func scrollToMinItem() {
    currentIndex = 1
    collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: true)
  }
}

  // MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let controller = SecondViewController()
    print("didSelectItem itemType: ", demoInfo[getInfoIndex(with: indexPath)])
    navigationController?.pushViewController(controller, animated: true)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.frame.size
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    guard isBeginAutoScroll else { return }
    isBeginAutoScroll = false
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let screenWidth = view.bounds.width
    let xPoint = ((scrollView.contentOffset.x - screenWidth) / screenWidth).truncatingRemainder(dividingBy: CGFloat(demoInfo.count))
    currentIndex = Int(scrollView.contentOffset.x / screenWidth)
    switch xPoint {
    case let x where x > CGFloat(demoInfo.count) - 0.5:
      pageControl.currentPage = 0
    default:
      pageControl.currentPage = lround(Double(xPoint))
    }
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if !isBeginAutoScroll {
      isBeginAutoScroll = true
    }
    switch scrollView.contentOffset.x {
      case let x where x >= scrollView.contentSize.width - scrollView.frame.width || x == 0:
      scrollToCenterItem(with: x == 0 ? -1 : 0)
    default:
      break
    }
  }
}

  // MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print(demoInfo.count * Int(Int16.max))
    return demoInfo.count * Int(Int16.max)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DemoCollectionViewCell.identifier, for: indexPath) as? DemoCollectionViewCell else {
      fatalError("DemoCollectionViewCell init fail")
    }

    cell.colorType = demoInfo[getInfoIndex(with: indexPath)]
    return cell
  }
}
