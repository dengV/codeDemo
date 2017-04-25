//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.

import UIKit
import Foundation
import CoreData
import CloudKit

class MNOMainViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var procedureOverviewCollectionView: UICollectionView!
    @IBOutlet weak var placeHolderNewProcedureButton: UIButton!
    @IBOutlet weak var placeHolderNewProcedureLabel: UILabel!
    @IBOutlet weak var addButton: UIBarButtonItem!


    // MARK: - Constant
    let procedureOverviewCollectionViewCellIdentifier = "procedureCollectionViewCell"
    let showProcedureDetailSegueIdentifier = "showProcedureDetail"
    let createNewProcedureSegueIdentifier =  "createANewProcedure"
    let executeTheProcedureFromMainSegueIdentifier = "executeTheProcedureFromMain"
    let favoriteButtonNormalImage = UIImage(named: "FuncFavoriteBarRegular")
    let favoriteButtonMarkedImage = UIImage(named: "FuncFavoriteMarked")

    // MARK: - Properties
    var intervalProcedureCKSCFetchedResultsController: NSFetchedResultsController!

    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        // Change tab bar color
        self.tabBarController?.tabBar.tintColor = UIColor(red: 255/255.0, green: 127/255.0, blue: 0.0, alpha: 1.0)

        // Register Procedure Over view Collection View cell, which can be used in Main View and Favorite View

        procedureOverviewCollectionView.registerNib(UINib.init(nibName: "MNOProcedureOverviewCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: procedureOverviewCollectionViewCellIdentifier)

        self.initFetchedResultsController()

    }


    override func viewWillAppear(animated: Bool) {

        self.procedureOverviewCollectionView.reloadData()
    }



    // MARK: - Support Methods

    func displayActivityControllerWithDataObject(object:AnyObject) {

        let objectToShare = object as! MNOProcedure

        guard let url = MNOProcedureParser().exportTargetProcedureToFileURL(objectToShare) else {
            return
        }

        let avc = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        avc.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in

            if (!completed) {
                return
            }

            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtURL(url)
            } catch {
                //print(error)
            }

        }

        let excludedActivities = [UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                  UIActivityTypePostToWeibo,
                                  UIActivityTypeMessage, UIActivityTypeMail,
                                  UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                  UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                  UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                  UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        avc.excludedActivityTypes = excludedActivities;


        self.presentViewController(avc, animated: true) {


        }


    }

    func targetProcedureDoesHaveModulesToExcute(nestedComponentCKSCMOs: [MNOComponentCKSCMO]) -> Bool {

        for i in 0..<nestedComponentCKSCMOs.count {
            if nestedComponentCKSCMOs[i].nestedModules?.count > 0 {
                return true
            }
        }

        return false

    }


    func toggleFavoriteButtonUI(button:UIButton, isFavorite: Bool ) {

        if isFavorite {
            button.setImage(self.favoriteButtonMarkedImage, forState: .Normal)
        } else {
            button.setImage(self.favoriteButtonNormalImage, forState: .Normal)
        }


    }


    @IBAction func placeHolderButtonTapped(sender: AnyObject) {

        self.segueToCreateNewProcedureView(sender)
    }

    func initFetchedResultsController() {

        if self.intervalProcedureCKSCFetchedResultsController == nil {

            let request = NSFetchRequest(entityName: "MNOProcedureCKSC")
            let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)

            request.sortDescriptors = [sortDescriptor]

            self.intervalProcedureCKSCFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataController.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            self.intervalProcedureCKSCFetchedResultsController.delegate = self

            do {
                try self.intervalProcedureCKSCFetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }


        }

    }

    func configureCell(cell: MNOProcedureOverviewCollectionViewCell, mnoProcedureCKSCMO: MNOProcedureCKSCMO) {

        if let targetIndexPath = self.procedureOverviewCollectionView.indexPathForCell(cell) {
            cell.tag = targetIndexPath.row
            cell.setCellTagForSubviews()
        }

        cell.hostingViewControllerDelegate = self
        let request = NSFetchRequest(entityName: "MNOComponentCKSC")
        let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        let predicate = NSPredicate(format: "parentProcedure == %@ ", mnoProcedureCKSCMO)
        request.predicate = predicate

        do {
            let allNestedComponentCKSCMOs = try self.intervalProcedureCKSCFetchedResultsController.managedObjectContext.executeFetchRequest(request) as! [MNOComponentCKSCMO]

            NSOperationQueue.mainQueue().addOperationWithBlock({

                cell.nestedComponentCKSCMOs = allNestedComponentCKSCMOs
                cell.procedureToExecuteButton.enabled = self.targetProcedureDoesHaveModulesToExcute(allNestedComponentCKSCMOs)

                if cell.intervalModulesTableView != nil {
                    cell.intervalModulesTableView.reloadData()
                }

            })

        } catch {
            print(error)
        }

        // Convert the CloudKit Record Name into Record ID
        let mnoProcedureRecordID = CKRecordID(recordName: mnoProcedureCKSCMO.ckRecordIDNameString!)

        // Use the Core Data manageobject to fetch data on the cloudkit
        CloudKitDataController.sharedInstance.privateDB.fetchRecordWithID(mnoProcedureRecordID) { (fetchedCKRecord: CKRecord?, error: NSError?) in
            if error != nil {
                print(error)

                if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                    MNOErrorHandler.handleAuthError()
                }
            } else {

                // Use the operation queue to fetch data from the CloudKit
                NSOperationQueue.mainQueue().addOperationWithBlock({

                    mnoProcedureCKSCMO.fetchedCKRecord = fetchedCKRecord

                    cell.procedureTitleLabel.text = fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureTitle] as? String

                    if fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureDescription] as? String == NSLocalizedString("Tap Here to describe the Procedure.", comment: "Tap Here to describe the Procedure.")  || fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureDescription] as? String == nil {
                        cell.procedureDescriptionTextView.text = NSLocalizedString("You can add the Procedure description in the detail view by tapping the detail button above.", comment: "You can add the Procedure description in the detail view by tapping the detail button above.")
                    } else {
                        cell.procedureDescriptionTextView.text = fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureDescription] as? String
                    }

                    cell.procedureDescriptionTextView.textColor = MNOColorLightPale


                    CoreDataController.sharedInstance.saveContext()


                })

            }


        }

    }


    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let segueIdentifier = segue.identifier {

            switch segueIdentifier {
            case showProcedureDetailSegueIdentifier:

                // Pass procedure index to the detail view controller
                let destinationViewController = (segue.destinationViewController as! UINavigationController).visibleViewController as! MNOProcedureDetailViewController

                let targetIndexPath = NSIndexPath(forRow: (sender?.tag)!, inSection: 0)
                let intervalProcedureToPass = self.intervalProcedureCKSCFetchedResultsController.objectAtIndexPath(targetIndexPath) as! MNOProcedureCKSCMO
                destinationViewController.procedureDetailViewDisplayMode = ProcedureDetailViewDisplayMode.showDetail


                destinationViewController.intervalProcedureCKSCMOWithFetchedCKRecord = intervalProcedureToPass

            case createNewProcedureSegueIdentifier:


                let newMNOProcedureCKSCMO = NSEntityDescription.insertNewObjectForEntityForName("MNOProcedureCKSC", inManagedObjectContext: self.intervalProcedureCKSCFetchedResultsController.managedObjectContext) as! MNOProcedureCKSCMO

                // Get the current Record Name
                newMNOProcedureCKSCMO.ckRecordIDNameString = "Procedure \(newMNOProcedureCKSCMO.ckRecordCreationDate)"

                let nvc = segue.destinationViewController as! UINavigationController
                let dvc = nvc.viewControllers[0] as? MNOProcedureDetailViewController
                dvc?.procedureDetailViewDisplayMode = ProcedureDetailViewDisplayMode.CreateNewProcedure
                dvc?.intervalProcedureCKSCMOWithFetchedCKRecord = newMNOProcedureCKSCMO
                dvc?.delegate = self


            case executeTheProcedureFromMainSegueIdentifier:

                let nvc = segue.destinationViewController as! UINavigationController
                let dvc = nvc.viewControllers[0] as? MNOProcedureExecutionViewController

                let targetIndexPath = NSIndexPath(forRow: (sender?.tag)!, inSection: 0)
                let intervalProcedureToPass = MNOProcedureParser().getTargetProcedureWithNestedObjects(targetIndexPath.row)
                dvc?.currentIntervalProcedure = intervalProcedureToPass
                dvc?.delegate = self

                print("intervalProcedureToPass is \(intervalProcedureToPass.ckRecordID)")

            default:
                break
            }
        }

    }

    func segueToProcedureDetailView(sender: AnyObject){


        self.performSegueWithIdentifier(showProcedureDetailSegueIdentifier, sender: sender)
    }

    func segueToProcedureExecuteView(sender: AnyObject){

        self.performSegueWithIdentifier(executeTheProcedureFromMainSegueIdentifier, sender: sender)

    }

    func segueToCreateNewProcedureView(sender: AnyObject){
        self.performSegueWithIdentifier(createNewProcedureSegueIdentifier, sender: sender)
    }




    // MARK: - Action
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){

    }

    @IBAction func collectionViewEditButtonTapped(sender: AnyObject){

        print("collectionViewEditButtonTapped")

        segueToProcedureDetailView(sender)

    }

    @IBAction func collectionViewExcuteButtonTapped(sender: AnyObject) {

        print("collectionViewExcuteButtonTapped")
        segueToProcedureExecuteView(sender)

    }

    @IBAction func collectionViewShareButtonTapped(sender: AnyObject) {

        self.procedureOverviewCollectionView.reloadData()

        print("collectionViewShareButtonTapped")

        let button = sender as! UIButton
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.startAnimating()
        button.setImage(nil, forState: .Normal)
        button.addSubview(activityIndicator)

        let procedureToPass = MNOProcedureParser().getTargetProcedureWithNestedObjects(sender.tag)

        MNOProcedureParser().inflateTargetProcedureWithNestedObjectsAndDetailedData(procedureToPass) {

            NSOperationQueue.mainQueue().addOperationWithBlock({

                activityIndicator.removeFromSuperview()
                button.setImage(MNOShareButtonImage, forState: .Normal)


                self.displayActivityControllerWithDataObject(procedureToPass)

            })

        }


    }

    @IBAction func collectionViewFavoriteButtonTapped(sender: AnyObject) {

        print("collectionViewFavoriteButtonTapped")
        let mnoMarkingProcedureCKSCMO = self.intervalProcedureCKSCFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! MNOProcedureCKSCMO

        mnoMarkingProcedureCKSCMO.isFavorite = (mnoMarkingProcedureCKSCMO.isFavorite == false)

        print("mnoMarkingProcedureCKSCMO is Favorite? \(mnoMarkingProcedureCKSCMO.isFavorite)")

        CoreDataController.sharedInstance.saveContext()

        // Change the button
        let button = sender as! UIButton

        self.toggleFavoriteButtonUI(button, isFavorite: mnoMarkingProcedureCKSCMO.isFavorite == true)




    }

    @IBAction func collectionViewAddButtonTapped(sender: AnyObject) {

        print("collectionViewAddButtonTapped")

        segueToCreateNewProcedureView(sender)

    }

    @IBAction func collectionViewDeleteButtonTapped(sender: AnyObject) {

        self.procedureOverviewCollectionView.reloadData()

        let alert = UIAlertController(title: NSLocalizedString("Delete Procedure", comment: "Delete Procedure"), message: NSLocalizedString("Are you going to delete the Interval Procedure ? It will be removed from the app forever.", comment: "Are you going to delete the Interval Procedure ? It will be removed from the app forever.") , preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .Destructive) { (uiAlertAction: UIAlertAction) in

            print("Delete Action is tapped")

            let intervalProcedureToDelete = self.intervalProcedureCKSCFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! MNOProcedureCKSCMO

            let intervalProcedureToDeleteCRRecordID = CKRecordID(recordName: intervalProcedureToDelete.ckRecordIDNameString!)


            CloudKitDataController.sharedInstance.privateDB.deleteRecordWithID(intervalProcedureToDeleteCRRecordID, completionHandler: { (ckRecordID: CKRecordID?, error: NSError?) in

                if error != nil {
                    print(error)

                    if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                        MNOErrorHandler.handleAuthError()

                    }
                } else {
                    CoreDataController.sharedInstance.saveContext()

                }

            })


            self.intervalProcedureCKSCFetchedResultsController.managedObjectContext.deleteObject(intervalProcedureToDelete)

        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel) { (uiAlertAction: UIAlertAction) in


        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.presentViewController(alert, animated: true, completion: nil)

    }

}

extension MNOMainViewController: UICollectionViewDataSource {

    // MARK: - UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.intervalProcedureCKSCFetchedResultsController.sections?.count ?? 0
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.intervalProcedureCKSCFetchedResultsController.sections![section]

        self.placeHolderNewProcedureButton.hidden = (sectionInfo.numberOfObjects > 0)
        self.placeHolderNewProcedureLabel.hidden = (sectionInfo.numberOfObjects > 0)

        if addButton != nil {
            if sectionInfo.numberOfObjects <= 0 {
                self.addButton.enabled = false
                self.addButton.tintColor = UIColor.clearColor()
            } else {
                self.addButton.enabled = true
                self.addButton.tintColor = MNOColorLightPale
            }

        }



        return sectionInfo.numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {


        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(procedureOverviewCollectionViewCellIdentifier, forIndexPath: indexPath) as! MNOProcedureOverviewCollectionViewCell

        cell.tag = indexPath.row
        cell.setCellTagForSubviews()

        // Get the managed Object
        let mnoProcedureCKSCMO = self.intervalProcedureCKSCFetchedResultsController.objectAtIndexPath(indexPath) as? MNOProcedureCKSCMO

        if mnoProcedureCKSCMO != nil {
            self.toggleFavoriteButtonUI(cell.procedureFavoritizeButton, isFavorite: mnoProcedureCKSCMO!.isFavorite == true)

            self.configureCell(cell, mnoProcedureCKSCMO: mnoProcedureCKSCMO!)

        }

        return cell

    }


}

extension MNOMainViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {

        return false
    }


}

extension MNOMainViewController: NSFetchedResultsControllerDelegate {

    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {

    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.procedureOverviewCollectionView.insertSections(NSIndexSet(index: sectionIndex))
        case .Delete:
            self.procedureOverviewCollectionView.deleteSections(NSIndexSet(index: sectionIndex))
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            self.procedureOverviewCollectionView.insertItemsAtIndexPaths([newIndexPath!])
        case .Delete:
            self.procedureOverviewCollectionView.deleteItemsAtIndexPaths([indexPath!])
            self.procedureOverviewCollectionView.reloadData()
            
        case .Update:

            self.procedureOverviewCollectionView.reloadItemsAtIndexPaths([indexPath!])
            if let targetIndex = indexPath, let collectionView = self.procedureOverviewCollectionView, let cell = collectionView.cellForItemAtIndexPath(targetIndex)  {
                
                self.configureCell(cell as! MNOProcedureOverviewCollectionViewCell, mnoProcedureCKSCMO:  anObject as! MNOProcedureCKSCMO)
                
            }
        case .Move:
            
            self.procedureOverviewCollectionView.deleteItemsAtIndexPaths([indexPath!])
            self.procedureOverviewCollectionView.insertItemsAtIndexPaths([indexPath!])
        }
        
        
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.procedureOverviewCollectionView.reloadData()
        
    }
    
}


extension MNOMainViewController: MNOProcedureDetailViewControllerDelegate {
    
    // MARK: - MNOModuleDetailViewControllerDelegate {
    
    func didTapSaveOnProcedureDetailView(sender: AnyObject) {
        
        self.procedureOverviewCollectionView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func didTapCancelOnProcedureDetailView(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}

extension MNOMainViewController: MNOProcedureOverviewCollectionViewCellHostingViewControllerDelegate {
    
    // MARK: - MNOProcedureOverviewCollectionViewCellHostingViewControllerDelegate
    func didTapDeleteOnMNOProcedureOverviewCollectionViewCell(procedureName: String, sender: AnyObject) {
        
    }
    
}

extension MNOMainViewController: MNOProcedureExecutionViewControllerDelegate {
    
    // MARK: - MNOProcedureExecutionViewControllerDelegate
    func didConfirmStoppingProcedure() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}



