//
//  NewNoteViewController.swift
//  CocoaHeadsNo31CoreData
//
//  Created by Knight on 29/08/2017.
//  Copyright © 2017 Knight. All rights reserved.
//

import UIKit
import CoreData

protocol NewNoteViewControllerDelegate {
    func didTapSave(from newNoteViewController: NewNoteViewController)
    func didTapCancel(from newNoteViewController: NewNoteViewController)
}

class NewNoteViewController: UIViewController {

    static let segueId = "SegueToNewNoteViewController"

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!

    var delegate: NewNoteViewControllerDelegate!
    var note: Note!
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeTargetNote()
        self.setupUI()

    }

    // MARK: - Fileprivate Methods
    fileprivate func initializeTargetNote(){

        self.note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: self.managedObjectContext) as! Note
        self.note.time = Date() as NSDate
        
    }

    fileprivate func setupUI(){

        if let noteTime = self.note.time as Date? {
            self.dateLabel.text = String(describing: noteTime)
        }
    }

    fileprivate func discardNote(){

        self.managedObjectContext.delete(self.note)
        self.managedObjectContext.saveContext()

    }

    fileprivate func saveNote(){

        if let titleText = self.titleTextField.text,
            !titleText.isEmpty {
            self.note.title = titleText
        }

        self.managedObjectContext.saveContext()
        
    }


    // MARK: - Action
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        self.saveNote()
        self.delegate.didTapSave(from: self)
    }
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        self.discardNote()
        self.delegate.didTapCancel(from: self)
    }


}
