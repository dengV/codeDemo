//
//  EditNoteViewController.swift
//  CocoaHeadsNo31CoreData
//
//  Created by Knight on 29/08/2017.
//  Copyright © 2017 Knight. All rights reserved.
//

import UIKit
import CoreData

class EditNoteViewController: UIViewController {

    static let segueId = "SegueToEditNoteViewController"

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!


    var note: Note!
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDateLabelUI()
        self.setupTextFieldUI()

    }

    override func viewWillDisappear(_ animated: Bool) {
        self.updateTitle()
        self.managedObjectContext.saveContext()
        super.viewWillDisappear(animated)
    }

    // MARK: - Fileprivate Method
    fileprivate func setupDateLabelUI() {
        if let noteTime = self.note.time as Date? {
            self.dateLabel.text = String(describing: noteTime)
        }
    }

    fileprivate func setupTextFieldUI() {
        self.titleTextField.text = self.note.title ?? ""
    }

    fileprivate func updateTitle(){

        if let titleText = self.titleTextField.text,
            !titleText.isEmpty {
            self.note.title = titleText
        }
    }


    fileprivate func updateTimeToNow(){
        self.note.time = Date() as NSDate
        self.setupDateLabelUI()
    }


    // MARK: - Action
    
    @IBAction func didTapUpdateToNow(_ sender: UIButton) {
        self.updateTimeToNow()
    }



}
