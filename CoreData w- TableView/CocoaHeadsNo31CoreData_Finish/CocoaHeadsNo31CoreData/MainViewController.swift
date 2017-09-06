//
//  MainViewController.swift
//  CocoaHeadsNo31CoreData
//
//  Created by Knight on 29/08/2017.
//  Copyright © 2017 Knight. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    @IBOutlet weak var noteTableView: UITableView!


    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupManagedObjectContext()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupFetchedResultsController()
    }

    // MARK: - Fileprivate Method
    fileprivate func setupManagedObjectContext(){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.managedObjectContext = appDelegate.dataController.persistentContainer.viewContext
        }
    }

    fileprivate func setupFetchedResultsController(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let titleSort = NSSortDescriptor(key: "time", ascending: false)
        request.sortDescriptors = [titleSort]

        if let moc = self.managedObjectContext {
            fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)

            fetchResultsController.delegate = self
            fetchResultsController.performFetchForResults()
            self.noteTableView.reloadData()
        }
    }

    @IBAction func didTapAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: NewNoteViewController.segueId, sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case NewNoteViewController.segueId?:
            guard let destinationNAVVC = segue.destination as? UINavigationController else { return }
            guard let destinationVC = destinationNAVVC.topViewController as? NewNoteViewController else { return }
            destinationVC.delegate = self
            destinationVC.managedObjectContext = self.managedObjectContext


        case EditNoteViewController.segueId?:
            guard let destinationVC = segue.destination as? EditNoteViewController else { return }
            destinationVC.managedObjectContext = self.managedObjectContext
            if let note = sender as? Note {
                destinationVC.note = note
            }

        default:
            print(#function + " " + "Unknown Segue")
        }
    }

}

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let note = self.fetchResultsController.object(at: indexPath) as? Note {
            self.performSegue(withIdentifier: EditNoteViewController.segueId, sender: note)
        }
        
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            if let note = self.fetchResultsController.object(at: indexPath) as? Note {
                self.managedObjectContext.delete(note)
                self.managedObjectContext.saveContext()
            }
        }
    }

}

extension MainViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        if let sections = self.fetchResultsController.sections {
            return sections.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let sections = self.fetchResultsController.sections  {
            return sections[section].numberOfObjects
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellId = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        if let note = self.fetchResultsController.object(at: indexPath) as? Note,
            let noteTime = note.time as Date? {
            cell.detailTextLabel?.text = String(describing: noteTime)

            cell.textLabel?.text = note.title ?? "---"
        }
        
        return cell
    }
}

extension MainViewController: NewNoteViewControllerDelegate {

    func didTapCancel(from newNoteViewController: NewNoteViewController) {
        newNoteViewController.dismiss(animated: true) { 

        }
    }

    func didTapSave(from newNoteViewController: NewNoteViewController) {
        newNoteViewController.dismiss(animated: true) {

        }
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        self.noteTableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        switch type {
        case .insert:
            print(#function + " " + "'Note' section Inserted in NSFetchedResultsController.")
            self.noteTableView.insertSections(IndexSet(integer:sectionIndex), with: .fade)
        case .delete:
            print(#function + " " + "'Note' section Deleted in NSFetchedResultsController.")
            self.noteTableView.deleteSections(IndexSet(integer:sectionIndex), with: .fade)
        case .move:
            print(#function + " " + "'Note' section Moved in NSFetchedResultsController.")
        case .update:
            print(#function + " " + "'Note' section Updated in NSFetchedResultsController.")

        }

    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {


        switch type {
        case .insert:
            print(#function + " " + "'Note' row Inserted in NSFetchedResultsController.")
            if let validNewIndexPath = newIndexPath {
                self.noteTableView.insertRows(at: [validNewIndexPath], with: .fade)
            }
        case .delete:
            print(#function + " " + "'Note' row Deleted in NSFetchedResultsController.")
            if let validIndexPath = indexPath {
                self.noteTableView.deleteRows(at: [validIndexPath], with: .fade)
            }
        case .move:
            print(#function + " " + "'Note' row  Moved in NSFetchedResultsController.")
            if let validIndexPath = indexPath {
                self.noteTableView.reloadRows(at: [validIndexPath], with: .fade)
            }
        case .update:
            print(#function + " " + "'Note' row Updated in NSFetchedResultsController.")
            if  let validNewIndexPath = newIndexPath,
                let validIndexPath = indexPath {
                self.noteTableView.moveRow(at: validIndexPath, to: validNewIndexPath)
            }

        }

    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.noteTableView.endUpdates()
    }
}
