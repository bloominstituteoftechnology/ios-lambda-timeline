//
//  CommentPageViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class CommentPageViewController: UIPageViewController {
	var proseVC: ProseCommentViewController? = {
		UIStoryboard(name: "Comments", bundle: nil).instantiateViewController(withIdentifier: "ProseCommentViewController") as? ProseCommentViewController
	}()

	var singingVC: SingingCommentViewController? = {
		UIStoryboard(name: "Comments", bundle: nil).instantiateViewController(withIdentifier: "SingingCommentViewController") as? SingingCommentViewController
	}()

	lazy var pagedVCs: [UIViewController] = {
		[proseVC, singingVC].compactMap { $0 }
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		delegate = self
		setViewControllers([pagedViewController(at: 0)].compactMap { $0 }, direction: .forward, animated: true)
		view.backgroundColor = .white
		updateTitle()
	}

	func pagedViewController(at index: Int) -> UIViewController? {
		guard index >= 0, index < pagedVCs.count else { return nil }
		return pagedVCs[index]
	}

	private func updateTitle() {
		navigationItem.title = viewControllers?.first?.navigationItem.title ?? navigationItem.title
	}
}

extension CommentPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = pagedVCs.firstIndex(of: viewController) else { return nil }
		let vc = pagedViewController(at: index - 1)
		return vc
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = pagedVCs.firstIndex(of: viewController) else { return nil }
		let vc = pagedViewController(at: index + 1)
		return vc
	}

	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		guard let currentVC = pageViewController.viewControllers?.first else { return 0 }
		return pagedVCs.firstIndex(of: currentVC) ?? 0
	}

	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return pagedVCs.count
	}

	func pageViewController(_ pageViewController: UIPageViewController,
							didFinishAnimating finished: Bool,
							previousViewControllers: [UIViewController],
							transitionCompleted completed: Bool) {
		updateTitle()
	}
}
