//
//  NewNoteViewController.swift
//  CocoaHeadsNo31CoreData
//
//  Created by Knight on 29/08/2017.
//  Copyright © 2017 Knight. All rights reserved.
//

import UIKit

protocol NewNoteViewControllerDelegate {
    func didTapSave(from newNoteViewController: NewNoteViewController)
    func didTapCancel(from newNoteViewController: NewNoteViewController)
}

class NewNoteViewController: UIViewController {

    static let segueId = "SegueToNewNoteViewController"

    @IBOutlet weak var dateLabel: UILabel!

    var delegate: NewNoteViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Fileprivate Method

    // MARK: - Action

    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        self.delegate.didTapSave(from: self)
    }
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        self.delegate.didTapCancel(from: self)
    }

}
