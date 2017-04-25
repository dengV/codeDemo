//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import UIKit
import CoreData
import CloudKit


enum MNOModuleViewControllerDisplayMode {
    case TabView
    case ModuleSelection
}


// Protocol for the parent object (such as: View Controller) to adopt for handling dimiss the current view controller and passing data from the child object to the parent object.

protocol MNOModuleViewControllerModuleSelectionDelegate {

    func didSelectModuleInTheSelectionView(atIndexPath indexPath: NSIndexPath, selectedMNOModuleCKSCMO: MNOModuleCKSCMO)
    func didTapCloseButtonInTheSelectionView(sender: AnyObject)

}

class MNOModuleViewController: UIViewController {

    // MARK: - Outlet

    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var intervalModulesTableView: UITableView!
    @IBOutlet weak var placeholderButton: UIButton!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var placeholderLabel: UILabel!

    // MARK: - Constant
    let intervalModulesTableViewCellIdentifier = "moduleTableViewTemplateCell"

    // MARK: - Property
    var intervalModuleCKSCFetchedResultsController: NSFetchedResultsController!
    var displayMode: MNOModuleViewControllerDisplayMode = MNOModuleViewControllerDisplayMode.TabView
    var parentComponentForModuleSelectionMode: MNOComponentCKSCMO?
    var moduleSelectionDelegate: MNOModuleViewControllerModuleSelectionDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Register the xib files for useable views
        // Register Interval Module Table View cell, which can be used in Module Tab View and Interval Component Detail
        intervalModulesTableView.registerNib(UINib.init(nibName: "MNOModuleTableViewTemplateCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: intervalModulesTableViewCellIdentifier)


        if displayMode == .TabView {

            self.navigationItem.leftBarButtonItem = self.editButtonItem()
            self.editButtonItem().image = MNONavEditButtonImage
            editButtonItem().title = nil
            self.navigationItem.leftBarButtonItem?.tintColor = MNOColorLightPale
            self.noteView.hidden = true
            self.noteView.frame = CGRectZero

        } else if displayMode == .ModuleSelection {


            let discareButtonBarItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Back"), style: .Plain, target: self, action: #selector(self.closeButtonTapped(_:)))

            self.navigationItem.leftBarButtonItem = discareButtonBarItem
        }

        // Adding refresh control
        let refresh = UIRefreshControl()
        refresh.tintColor = MNOColorLightPale
        refresh.addTarget(self, action: #selector(self.refreshView(_:)), forControlEvents: .ValueChanged)

        self.intervalModulesTableView.addSubview(refresh)

        self.initFetchedResultsController()

    }


    override func viewWillAppear(animated: Bool) {

        self.intervalModulesTableView.reloadData()
    }


    // MARK: - Action

    func closeButtonTapped(sender: AnyObject) {

        self.moduleSelectionDelegate?.didTapCloseButtonInTheSelectionView(sender)

    }

    @IBAction func placeholderButtonTapped(sender: AnyObject) {


        self.performSegueWithIdentifier("addANewModule", sender: sender)
    }



    // MARK: - Support
    func initFetchedResultsController() {

        if self.intervalModuleCKSCFetchedResultsController == nil {

            let request = NSFetchRequest(entityName: "MNOModuleCKSC")
            let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)

            request.sortDescriptors = [sortDescriptor]

            self.intervalModuleCKSCFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataController.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            self.intervalModuleCKSCFetchedResultsController.delegate = self


            do {
                try self.intervalModuleCKSCFetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }

        }

    }

    func refreshView(refresh: UIRefreshControl) {

        self.intervalModulesTableView.reloadData()
        refresh.endRefreshing()

    }

    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "addANewModule" {
            
            
            let mnoModule = MNOModule()
            let nvc = segue.destinationViewController as! UINavigationController
            let dvc = nvc.viewControllers[0] as? MNOModuleDetailViewController
            dvc?.delegate = self
            dvc?.showedModally = true
            dvc!.intervalModule = mnoModule
            
        } else if segue.identifier == "showModuleDetailSegue" {
            
            
            let mnoModuleCKSCMOWithfetchedCKRecord = sender as! MNOModuleCKSCMO
            let dvc = segue.destinationViewController as? MNOModuleDetailViewController
            dvc?.showedModally = false
            dvc?.isFromProcedureDetailRatherThanModuleOverview = false
            dvc!.intervalModuleCKSCMOWithFetchedCKRecord = mnoModuleCKSCMOWithfetchedCKRecord
            
            
        }
        
    }

}

extension MNOModuleViewController: UITableViewDataSource {

    // MARK: - Table View Data Source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return self.intervalModuleCKSCFetchedResultsController.sections?.count ?? 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sectionInfo = self.intervalModuleCKSCFetchedResultsController.sections![section]

        self.placeholderLabel.hidden = sectionInfo.numberOfObjects > 0
        self.placeholderButton.hidden = sectionInfo.numberOfObjects > 0
        self.placeholderView.hidden = sectionInfo.numberOfObjects > 0
        self.noteView.hidden = sectionInfo.numberOfObjects <= 0

        if sectionInfo.numberOfObjects <= 0 {
            self.addBarButton.enabled = false
            self.addBarButton.tintColor = UIColor.clearColor()
            self.editButtonItem().enabled = false
            self.editButtonItem().tintColor = UIColor.clearColor()
        } else {
            self.addBarButton.enabled = true
            self.addBarButton.tintColor = MNOColorLightPale
            self.editButtonItem().enabled = true
            self.editButtonItem().tintColor = MNOColorLightPale
        }

        return sectionInfo.numberOfObjects

    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(intervalModulesTableViewCellIdentifier, forIndexPath: indexPath) as! MNOModuleTableViewTemplateCell

        // Get the CoreData-based managed object
        let mnoModuleCKSCMO = intervalModuleCKSCFetchedResultsController.objectAtIndexPath(indexPath) as? MNOModuleCKSCMO

        self.configureCell(cell, mnoModuleCKSCMO: mnoModuleCKSCMO!)
        
        return cell
        
    }

    func configureCell(cell: MNOModuleTableViewTemplateCell, mnoModuleCKSCMO: MNOModuleCKSCMO) {

        let mnoModuleRecordIDNameString = mnoModuleCKSCMO.ckRecordIDNameString

        // Convert the CloudKit Record Name into Record ID
        let mnoModuleRecordID = CKRecordID(recordName: mnoModuleRecordIDNameString!)

        // Use the manageobject to fetch data on the cloudkit
        CloudKitDataController.sharedInstance.privateDB.fetchRecordWithID(mnoModuleRecordID) { (fetchedCKRecord: CKRecord?, error: NSError?) in
            if error != nil {
                print(error)

                if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                    MNOErrorHandler.handleAuthError()
                }
                
            } else {

                // Use the operation queue to fetch data from the CloudKit
                NSOperationQueue.mainQueue().addOperationWithBlock({

                    mnoModuleCKSCMO.fetchedCKRecord = fetchedCKRecord

                    cell.moduleEmojiLabel.text = fetchedCKRecord![MNOModuleCKSCMO.CDKModuleIconEmoji] as? String
                    cell.moduleTitleLabel.text = fetchedCKRecord![MNOModuleCKSCMO.CDKModuleTitle] as? String

                    let fetchedCKRecordType = fetchedCKRecord![MNOModuleCKSCMO.CDKModuleType] as? Int == 0 ? IntervalModuleType.Duration : IntervalModuleType.Amount
                    let fetchedDurationValue = fetchedCKRecord![MNOModuleCKSCMO.CDKModuleDurationLength] as? Double
                    let fetchedAmountValue = fetchedCKRecord![MNOModuleCKSCMO.CDKModuleAmountMilestone] as? Int

                    cell.moduleValueLabel.text = (fetchedCKRecordType == IntervalModuleType.Duration) ? getTimeString(fetchedDurationValue!) : String(fetchedAmountValue!)
                    cell.moduleValueLabel.textColor = (fetchedCKRecordType == IntervalModuleType.Duration) ? MNOColorLightGreen : MNOColorLightBlue

                    cell.moduleTypeUnitLabel.text = (fetchedCKRecordType == IntervalModuleType.Duration) ? NSLocalizedString("m:s", comment: "m:s") : NSLocalizedString("mil", comment: "mil")
                    cell.moduleTypeUnitLabel.textColor = (fetchedCKRecordType == IntervalModuleType.Duration) ? MNOColorLightGreen : MNOColorLightBlue
                    CoreDataController.sharedInstance.saveContext()
                    
                    
                    
                })
                
            }
            
            
        }
        
    }

}

extension MNOModuleViewController: UITableViewDelegate {

    // MARK: - UITableViewDelegate

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.intervalModulesTableView.setEditing(editing, animated: true)

        self.addBarButton.enabled = !editing

        editButtonItem().title = nil

    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == .Delete {

            // Remove the data locally from Core Data
            let managedObjectToDelete = self.intervalModuleCKSCFetchedResultsController.objectAtIndexPath(indexPath) as! MNOModuleCKSCMO

            self.intervalModuleCKSCFetchedResultsController.managedObjectContext.deleteObject(managedObjectToDelete)

            // Remove the data from the cloudkit
            let mnoModuleToBeDeletedCKRecordIDNameString = managedObjectToDelete.ckRecordIDNameString

            let mnoModuleToBeDeletedCKRecordID = CKRecordID(recordName: mnoModuleToBeDeletedCKRecordIDNameString!)

            CloudKitDataController.sharedInstance.privateDB.deleteRecordWithID(mnoModuleToBeDeletedCKRecordID){ (deletedCKRecordID: CKRecordID?, error: NSError?) in

                if error != nil {

                    print(error)

                    if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                        MNOErrorHandler.handleAuthError()

                    }

                } else {
                    print("CKRecord \(deletedCKRecordID?.description) Deleted successfully")
                    CoreDataController.sharedInstance.saveContext()


                }

            }
        }

    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {


        if displayMode == .TabView {

            let mnoModuleToDetail = self.intervalModuleCKSCFetchedResultsController.objectAtIndexPath(indexPath) as! MNOModuleCKSCMO

            let mnoModuleRecordIDNameString = mnoModuleToDetail.ckRecordIDNameString

            let mnoModuleRecordID = CKRecordID(recordName: mnoModuleRecordIDNameString!)

            // Use the manageobject to fetch data from the cloudkit
            CloudKitDataController.sharedInstance.privateDB.fetchRecordWithID(mnoModuleRecordID) { (fetchedCKRecord: CKRecord?, error: NSError?) in
                if error != nil {

                    print(error)

                    if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                        MNOErrorHandler.handleAuthError()

                    }

                } else {

                    NSOperationQueue.mainQueue().addOperationWithBlock({

                        mnoModuleToDetail.fetchedCKRecord = fetchedCKRecord!
                        CoreDataController.sharedInstance.saveContext()

                        self.performSegueWithIdentifier("showModuleDetailSegue", sender: mnoModuleToDetail)


                    })

                }

            }

        } else if displayMode == .ModuleSelection {



            let mnoModuleToReferenceForTheComponent = (self.intervalModuleCKSCFetchedResultsController.objectAtIndexPath(indexPath) as! MNOModuleCKSCMO)

            // Call the custom delegate to dismiss the view controller

            self.moduleSelectionDelegate?.didSelectModuleInTheSelectionView(atIndexPath: indexPath, selectedMNOModuleCKSCMO: mnoModuleToReferenceForTheComponent)


        }

    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {

        // get the selected cell object
        let mnoModuleCKSCMO = self.intervalModuleCKSCFetchedResultsController.objectAtIndexPath(sourceIndexPath) as! MNOModuleCKSCMO

        let beforeDestinationIndexPath = NSIndexPath(forRow: destinationIndexPath.row - 1, inSection: destinationIndexPath.section)

        let afterDestinationIndexPath = destinationIndexPath

        var mnoModuleCKSCMOBeforeDestinationDisplayOrder = NSNumber(double: 0)

        if beforeDestinationIndexPath.row >= 0 {

            mnoModuleCKSCMOBeforeDestinationDisplayOrder = (self.intervalModuleCKSCFetchedResultsController.objectAtIndexPath(beforeDestinationIndexPath) as! MNOModuleCKSCMO).displayOrder!
        }


        var mnoModuleCKSCMOAfterDestinationDisplayOrder = mnoModuleCKSCMO.displayOrder

        mnoModuleCKSCMOAfterDestinationDisplayOrder = (self.intervalModuleCKSCFetchedResultsController.objectAtIndexPath(afterDestinationIndexPath) as! MNOModuleCKSCMO).displayOrder!
        
        let newDisplayOrderForTheSelectedModuleCKSCMODoubleValue = ((mnoModuleCKSCMOBeforeDestinationDisplayOrder.doubleValue) + (mnoModuleCKSCMOAfterDestinationDisplayOrder!.doubleValue))/2
        let newDisplayOrderForTheSelectedModuleCKSCMO = NSNumber(double: newDisplayOrderForTheSelectedModuleCKSCMODoubleValue)
        
        mnoModuleCKSCMO.displayOrder = newDisplayOrderForTheSelectedModuleCKSCMO
        CoreDataController.sharedInstance.saveContext()
        self.intervalModulesTableView.reloadData()
        
        
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
        
    }


}

extension MNOModuleViewController: NSFetchedResultsControllerDelegate {

    // MARK: - NSFetchedResultsControllerDelegate for Core Data
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.intervalModulesTableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.intervalModulesTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.intervalModulesTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }


    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case .Insert:
            self.intervalModulesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)

        case .Delete:
            self.intervalModulesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:

            print("NSFetchedResultsController update")
            self.intervalModulesTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            self.configureCell(self.intervalModulesTableView.cellForRowAtIndexPath(indexPath!)! as! MNOModuleTableViewTemplateCell, mnoModuleCKSCMO: anObject as! MNOModuleCKSCMO)
        case .Move:

            print("didChangeObject, Move is called.")
            self.intervalModulesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.intervalModulesTableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }


    }


    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.intervalModulesTableView.endUpdates()
    }


}

extension MNOModuleViewController: MNOModuleDetailViewControllerDelegate {

    // MARK: - MNOModuleDetailViewControllerDelegate
    func didTapSaveOnModuleDetailModuleView(sender: AnyObject) {

        self.intervalModulesTableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)

    }

    func didTapCancelOnModuleDetailModuleView(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)

    }

    func didFinishFetchingDataFromCloudKit(sender: AnyObject) {

        self.intervalModulesTableView.reloadData()
    }


}


