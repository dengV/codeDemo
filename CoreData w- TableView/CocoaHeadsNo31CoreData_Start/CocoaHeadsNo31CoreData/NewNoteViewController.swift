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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Action

    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        self.delegate.didTapSave(from: self)
    }
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        self.delegate.didTapCancel(from: self)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
