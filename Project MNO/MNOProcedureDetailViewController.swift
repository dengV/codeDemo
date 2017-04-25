//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import UIKit
import CoreData
import CloudKit
import MediaPlayer

enum ProcedureDetailViewDisplayMode {
    case showDetail
    case CreateNewProcedure
}

// Protocol for the parent object (such as: View Controller) to adopt for handling dimiss the current view controller and passing data from the child object to the parent object.

protocol MNOProcedureDetailViewControllerDelegate {

    func didTapSaveOnProcedureDetailView(sender:AnyObject)
    func didTapCancelOnProcedureDetailView(sender:AnyObject)

}

class MNOProcedureDetailViewController: UIViewController {


    // MARK: - Outlet

    @IBOutlet weak var procedureDetailTableView: UITableView!
    @IBOutlet weak var procedureTitleTextView: UITextView!
    @IBOutlet weak var procedureDescriptionTextView: UITextView!
    @IBOutlet weak var navBarAddButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var placeholderButton: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var musicTrackLabel: UILabel!
    @IBOutlet weak var musicSelectionRow: UIView!

    // MARK: - Properties
    var procedureIndex: Int!
    var intervalProcedure: MNOProcedure?
    var intervalProcedureCKSCMOWithFetchedCKRecord:MNOProcedureCKSCMO?
    var procedureDetailViewDisplayMode: ProcedureDetailViewDisplayMode?
    var delegate: MNOProcedureDetailViewControllerDelegate?
    var intervalComponentCKSCFetchedResultsController: NSFetchedResultsController!

    // MARK: - Constant
    let createNewComponentSegueIdentifier = "createNewComponent"
    let editDetailOfComponentSegueIdentifier = "editDetailOfComponent"
    let showModuleDetailFromNestedCollecionViewCellSegueIdentifier = "showModuleDetailFromNestedCollecionViewCell"
    let backFromProcedureDetailSegueIdentifier = "backFromProcedureDetail"
    let favoriteButtonNormalImage = UIImage(named: "FuncFavoriteRegular")
    let favoriteButtonMarkedImage = UIImage(named: "FuncFavoriteMarked")
    var saveBarButtonItem:UIBarButtonItem?

    // MARK: - Init
    override func viewWillAppear(animated: Bool) {
        self.procedureDetailTableView.reloadData()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initFetchedResultsController()
        self.procedureTitleTextView.tag = 1001
        self.procedureTitleTextView.delegate = self
        self.procedureTitleTextView.text = NSLocalizedString("Procedure", comment: "Procedure")
        self.procedureTitleTextView.textColor = MNOColorDarkPale
        self.procedureDescriptionTextView.tag = 1002
        self.procedureDescriptionTextView.delegate = self
        self.procedureDescriptionTextView.textColor = MNOColorDarkPale

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.musicSelectionRowTapped(_:)))

        musicSelectionRow.addGestureRecognizer(tapGesture)

        // Add the edit bar button item to the navigation view
        editButtonItem().image = MNONavEditButtonImage
        editButtonItem().tintColor = MNOColorLightPale
        editButtonItem().title = nil
        self.navigationItem.rightBarButtonItems?.insert(self.editButtonItem(), atIndex: 0)

        self.toggleFavoriteButtonUI(self.favoriteButton, isFavorite: intervalProcedureCKSCMOWithFetchedCKRecord!.isFavorite == true)

        if procedureDetailViewDisplayMode == ProcedureDetailViewDisplayMode.CreateNewProcedure {

            // Add a cancel button programatically
            let cancelBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Back"), style: .Plain, target: self, action: #selector(self.cancelButtonTapped(_:)))
            cancelBarButtonItem.tintColor = MNOColorLightPale

            self.navigationItem.leftBarButtonItem = cancelBarButtonItem

            // Add a save button programatically
            saveBarButtonItem = UIBarButtonItem(withImage: MNONavSaveButtonImage!, forTarget: self, action: #selector(self.saveButtonTapped(_:)))

            self.navigationItem.rightBarButtonItems?.insert(saveBarButtonItem!, atIndex: 0)


        } else if procedureDetailViewDisplayMode == ProcedureDetailViewDisplayMode.showDetail {

            // Add a cancel button programatically
            let backBarButtonItem = UIBarButtonItem(withImage: MNONavSaveButtonImage!, forTarget: self, action: #selector(self.backButtonTapped(_:)))

            self.navigationItem.leftBarButtonItem = backBarButtonItem

            // Convert the CloudKit Record Name into Record ID
            let mnoProcedureRecordID = CKRecordID(recordName: (self.intervalProcedureCKSCMOWithFetchedCKRecord?.ckRecordIDNameString)!)

            if intervalProcedureCKSCMOWithFetchedCKRecord?.mediaItemCollection != nil {
                self.musicTrackLabel.text = (self.intervalProcedureCKSCMOWithFetchedCKRecord?.mediaItemCollection as! MPMediaItemCollection).items.first?.title
                self.musicTrackLabel.alpha = 1
            } else {
                self.musicTrackLabel.alpha = 0.3

            }

            // Use the manageobject to fetch data on the Cloudkit
            CloudKitDataController.sharedInstance.privateDB.fetchRecordWithID(mnoProcedureRecordID) { (fetchedCKRecord: CKRecord?, error: NSError?) in
                if error != nil {
                    print(error)

                    if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                        MNOErrorHandler.handleAuthError()

                    }

                } else {

                    NSOperationQueue.mainQueue().addOperationWithBlock({

                        self.intervalProcedureCKSCMOWithFetchedCKRecord?.fetchedCKRecord = fetchedCKRecord

                        self.intervalProcedure?.procedureTitle = fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureTitle] as! String
                        self.intervalProcedure?.procedureDescription = fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureDescription] as? String

                        print(self.intervalProcedure?.procedureDescription)

                        self.procedureTitleTextView.text = fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureTitle] as! String
                        self.procedureDescriptionTextView.text = fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureDescription] as! String

                        CoreDataController.sharedInstance.saveContext()

                    })

                }

            }

        }

    }



    // MARK: - Segue Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {


        if segue.identifier == createNewComponentSegueIdentifier {

            let dnvc = segue.destinationViewController as! UINavigationController
            let dvc = dnvc.viewControllers[0] as! MNOCompoentDetailViewController

            dvc.displayMode = MNOCompoentDetailViewControllerDisplayMode.createNewComponent
            dvc.delegate = self

            let newMNOComponent = NSEntityDescription.insertNewObjectForEntityForName("MNOComponentCKSC", inManagedObjectContext: self.intervalComponentCKSCFetchedResultsController.managedObjectContext) as! MNOComponentCKSCMO

            newMNOComponent.ckRecordIDNameString = "Component \(newMNOComponent.ckRecordCreationDate)"
            newMNOComponent.parentProcedure = self.intervalProcedureCKSCMOWithFetchedCKRecord
            dvc.intervalComponentWithFetchedCKRecord = newMNOComponent

        } else if segue.identifier == editDetailOfComponentSegueIdentifier {

            let dvc = segue.destinationViewController as! MNOCompoentDetailViewController
            dvc.displayMode = MNOCompoentDetailViewControllerDisplayMode.showComponentDetail
            let targetIndexPath = NSIndexPath(forRow: (sender?.tag)!, inSection: 0)
            let mnoComponentToPass = self.intervalComponentCKSCFetchedResultsController.objectAtIndexPath(targetIndexPath) as! MNOComponentCKSCMO
            dvc.intervalComponentWithFetchedCKRecord = mnoComponentToPass
        } else if segue.identifier == showModuleDetailFromNestedCollecionViewCellSegueIdentifier {

            let dvc = segue.destinationViewController as! MNOModuleDetailViewController
            dvc.intervalModuleCKSCMOWithFetchedCKRecord = sender as? MNOModuleCKSCMO
            dvc.showedModally = false
            dvc.isFromProcedureDetailRatherThanModuleOverview = true
        }



    }


    // MARK: - Action

    @IBAction func musicDeletionButtonTapped(sender: AnyObject) {

        self.intervalProcedureCKSCMOWithFetchedCKRecord?.mediaItemCollection = nil
        self.musicTrackLabel.text = NSLocalizedString("None", comment: "None")
        self.musicTrackLabel.alpha = 0.3

    }

    @IBAction func musicSelectionRowTapped(sender:AnyObject) {

        self.showMediaPicker(sender)

    }


    @IBAction func favoriteButtonTapped(sender: AnyObject) {

        self.intervalProcedureCKSCMOWithFetchedCKRecord!.isFavorite = (intervalProcedureCKSCMOWithFetchedCKRecord!.isFavorite == false)

        CoreDataController.sharedInstance.saveContext()

        self.toggleFavoriteButtonUI(self.favoriteButton, isFavorite: intervalProcedureCKSCMOWithFetchedCKRecord!.isFavorite == true)

    }


    @IBAction func addButtonTapped(sender: AnyObject) {


        self.performSegueWithIdentifier(createNewComponentSegueIdentifier, sender: sender)

    }

    @IBAction func placeholderButtonTapped(sender: AnyObject) {

        self.performSegueWithIdentifier(createNewComponentSegueIdentifier, sender: sender)

    }
    @IBAction func cellDuplicateButtonTapped(sender: AnyObject) {


        self.duplicateComponent(sender)

    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {

        self.intervalComponentCKSCFetchedResultsController.managedObjectContext.deleteObject(self.intervalProcedureCKSCMOWithFetchedCKRecord!)
        self.delegate?.didTapCancelOnProcedureDetailView(sender)

    }

    @IBAction func saveButtonTapped(sender: AnyObject) {

        CoreDataController.sharedInstance.saveContext()

        self.saveIntervalProcedureToCloudKit(sender)

    }

    @IBAction func backButtonTapped(sender: AnyObject) {

        if anyProcedureInfoChanged() {

            self.intervalProcedureCKSCMOWithFetchedCKRecord!.fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureLastModifiedDate] = NSDate()

            self.modifyData()

        }

        self.performSegueWithIdentifier(backFromProcedureDetailSegueIdentifier, sender: sender)

    }


    // MARK: - Support Methods
    func initFetchedResultsController() {

        if self.intervalComponentCKSCFetchedResultsController == nil {

            let request = NSFetchRequest(entityName: "MNOComponentCKSC")
            let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
            request.sortDescriptors = [sortDescriptor]

            let predicate = NSPredicate(format: "parentProcedure == %@ ", self.intervalProcedureCKSCMOWithFetchedCKRecord!)
            request.predicate = predicate

            self.intervalComponentCKSCFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataController.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            self.intervalComponentCKSCFetchedResultsController.delegate = self

            do {
                try self.intervalComponentCKSCFetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }

        }

    }

    func toggleFavoriteButtonUI(button:UIButton, isFavorite: Bool ) {

        if isFavorite {
            button.setImage(self.favoriteButtonMarkedImage, forState: .Normal)
        } else {
            button.setImage(self.favoriteButtonNormalImage, forState: .Normal)
        }

    }

    func showMediaPicker(sender: AnyObject) {

        let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.AnyAudio)
        mediaPicker.modalTransitionStyle = .CrossDissolve
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.prompt = "Select Procedure's background music"

        self.presentViewController(mediaPicker, animated: true) {
        }

    }

    func saveIntervalProcedureToCloudKit(sender: AnyObject){

        let newMNOProcedureCKSCRecordName = self.intervalProcedureCKSCMOWithFetchedCKRecord?.ckRecordIDNameString
        let newMNOProcedureCKSCRecordID = CKRecordID(recordName: newMNOProcedureCKSCRecordName!)

        let newMNOProcedureCKSCToBeSavedCKRecord = CKRecord(recordType: "MNOProcedure", recordID: newMNOProcedureCKSCRecordID)
        self.intervalProcedureCKSCMOWithFetchedCKRecord?.ckRecordChangeTag = nil
        self.intervalProcedureCKSCMOWithFetchedCKRecord?.ckRecordCreationDate = NSDate()

        // input the attribute of the CKRecord
        newMNOProcedureCKSCToBeSavedCKRecord[MNOProcedureCKSCMO.CDKProcedureTitle] = self.procedureTitleTextView.text
        newMNOProcedureCKSCToBeSavedCKRecord[MNOProcedureCKSCMO.CDKProcedureDescription] = self.procedureDescriptionTextView.text


        newMNOProcedureCKSCToBeSavedCKRecord[MNOProcedureCKSCMO.CDKProcedureCreationDate] = self.intervalProcedureCKSCMOWithFetchedCKRecord?.ckRecordCreationDate
        newMNOProcedureCKSCToBeSavedCKRecord[MNOProcedureCKSCMO.CDKProcedureLastModifiedDate] = NSDate()


        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.startAnimating()
        saveBarButtonItem?.customView = activityIndicator

        CloudKitDataController.sharedInstance.privateDB.saveRecord(newMNOProcedureCKSCToBeSavedCKRecord) { (savedCKRecord: CKRecord?, error: NSError?) in
            if error != nil {
                print(error)

                if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                    MNOErrorHandler.handleAuthError()

                }

            } else {

                print("newMNOProcedureCKSCToBeSavedCKRecord \(savedCKRecord?.recordID) saved successfully.")

                self.intervalProcedureCKSCMOWithFetchedCKRecord?.ckRecordChangeTag = savedCKRecord?.recordChangeTag
                self.intervalProcedureCKSCMOWithFetchedCKRecord?.fetchedCKRecord = savedCKRecord
                CoreDataController.sharedInstance.saveContext()
                self.delegate?.didTapSaveOnProcedureDetailView(sender)

            }

        }

    }


    func modifyData() {

        if intervalProcedure?.procedureTitle != self.procedureTitleTextView.text {
            self.intervalProcedureCKSCMOWithFetchedCKRecord!.fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureTitle] = self.procedureTitleTextView.text
        }

        if intervalProcedure?.procedureDescription != self.procedureDescriptionTextView.text {
            self.intervalProcedureCKSCMOWithFetchedCKRecord!.fetchedCKRecord![MNOProcedureCKSCMO.CDKProcedureDescription] = self.procedureDescriptionTextView.text
        }

        CloudKitDataController.sharedInstance.privateDB.saveRecord(self.intervalProcedureCKSCMOWithFetchedCKRecord!.fetchedCKRecord!) { (savedCKRecord: CKRecord?, error: NSError?) in

            if error != nil {
                print(error)

                if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                    MNOErrorHandler.handleAuthError()

                }

            } else {

                let oldProcedureSystemContent = self.intervalProcedureCKSCMOWithFetchedCKRecord

                oldProcedureSystemContent!.ckRecordChangeTag = savedCKRecord?.recordChangeTag

                CoreDataController.sharedInstance.saveContext()

            }

        }

    }


    func createNewComponent(sender: AnyObject){

        let newMNOComponent = NSEntityDescription.insertNewObjectForEntityForName("MNOComponentCKSC", inManagedObjectContext: self.intervalComponentCKSCFetchedResultsController.managedObjectContext) as! MNOComponentCKSCMO

        newMNOComponent.ckRecordIDNameString = "Component \(newMNOComponent.ckRecordCreationDate)"

        newMNOComponent.parentProcedure = self.intervalProcedureCKSCMOWithFetchedCKRecord

    }

    func duplicateComponent(sender: AnyObject){

        let targetSection = 0
        let targetRow = sender.tag
        let targetIndexPath = NSIndexPath(forRow: targetRow, inSection: targetSection)

        let theDuplicatedComponentCKSCMO = self.intervalComponentCKSCFetchedResultsController.objectAtIndexPath(targetIndexPath) as! MNOComponentCKSCMO

        let aDuplicateComponentCKSCMO = NSEntityDescription.insertNewObjectForEntityForName("MNOComponentCKSC", inManagedObjectContext: self.intervalComponentCKSCFetchedResultsController.managedObjectContext) as! MNOComponentCKSCMO
        aDuplicateComponentCKSCMO.ckRecordCreationDate = NSDate()
        aDuplicateComponentCKSCMO.ckRecordIDNameString = "Component \(aDuplicateComponentCKSCMO.ckRecordCreationDate)"
        aDuplicateComponentCKSCMO.parentProcedure = self.intervalProcedureCKSCMOWithFetchedCKRecord
        aDuplicateComponentCKSCMO.ckRecordChangeTag = nil
        aDuplicateComponentCKSCMO.fetchedCKRecord = theDuplicatedComponentCKSCMO.fetchedCKRecord

        let theDuplicatedModuleComponentDetailCKSCMOs = self.getNestedModuleComponentDetailsCKSCOfComponent(theDuplicatedComponentCKSCMO)

        for i in 0..<theDuplicatedModuleComponentDetailCKSCMOs.count {

            let oneOfTheDuplicatedModuleComponentDetailCKSCMO = theDuplicatedModuleComponentDetailCKSCMOs[i]
            let newModuleComponentDetailCKSCMOToSet = NSEntityDescription.insertNewObjectForEntityForName("MNOComponetModuleCKSCDetails", inManagedObjectContext: self.intervalComponentCKSCFetchedResultsController.managedObjectContext) as? MNOComponetModuleCKSCDetailsMO

            newModuleComponentDetailCKSCMOToSet!.parentComponent = aDuplicateComponentCKSCMO
            newModuleComponentDetailCKSCMOToSet?.nestedModule = oneOfTheDuplicatedModuleComponentDetailCKSCMO.nestedModule
        }

        CoreDataController.sharedInstance.saveContext()
        self.procedureDetailTableView.reloadData()

        let sectionInfo = self.intervalComponentCKSCFetchedResultsController.sections![0]
        let newIndexPathToScrollTo = NSIndexPath(forRow: sectionInfo.numberOfObjects - 1, inSection: 0)
        self.procedureDetailTableView.scrollToRowAtIndexPath(newIndexPathToScrollTo, atScrollPosition: .Bottom, animated: true)
        self.saveIntervalComponentToCloudKit(aDuplicateComponentCKSCMO)

    }

    func anyProcedureInfoChanged() -> Bool {

        if intervalProcedure?.procedureTitle != self.procedureTitleTextView.text {
            return true
        }

        if intervalProcedure?.procedureDescription != self.procedureDescriptionTextView.text {
            return true
        }

        return false

    }

    func autoScrollToNewRow() {


        let targetSection = 0
        let sectionInfo = self.intervalComponentCKSCFetchedResultsController.sections![targetSection]
        let targetRow = sectionInfo.numberOfObjects - 1
        let targetIndexPath = NSIndexPath.init(forRow: targetRow, inSection: targetSection)
        self.procedureDetailTableView.scrollToRowAtIndexPath(targetIndexPath, atScrollPosition: .Bottom, animated: true)

    }


    @IBAction func unwindFromModuleDetailToProceudreDetail(segue: UIStoryboardSegue){
        
        
    }
    

}

extension MNOProcedureDetailViewController: UITableViewDataSource {

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        let sectionNumber = self.intervalComponentCKSCFetchedResultsController.sections?.count ?? 0

        return sectionNumber

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sectionInfo = self.intervalComponentCKSCFetchedResultsController.sections![section]

        self.placeholderButton.hidden = (sectionInfo.numberOfObjects > 0)
        self.placeholderLabel.hidden = (sectionInfo.numberOfObjects > 0)

        if sectionInfo.numberOfObjects <= 0 {

            self.editButtonItem().enabled = false
            self.editButtonItem().tintColor = UIColor.clearColor()
            self.navBarAddButton.enabled = false
            self.navBarAddButton.tintColor = UIColor.clearColor()

        } else {

            self.editButtonItem().enabled = true
            self.editButtonItem().tintColor = MNOColorLightPale
            self.navBarAddButton.enabled = true
            self.navBarAddButton.tintColor = MNOColorLightPale
        }

        return sectionInfo.numberOfObjects

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let identifier = "componentTableViewCell"

        if let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)  as? MNOComponentTableViewCell {

            cell.tag = indexPath.row
            cell.setTagForSubView()

            let mnoComponentCKSCMO = self.intervalComponentCKSCFetchedResultsController.objectAtIndexPath(indexPath) as? MNOComponentCKSCMO

            if mnoComponentCKSCMO != nil {
                self.configureCell(cell, mnoComponentCKSCMO: mnoComponentCKSCMO!)
                return cell
                
            }
            
        }
        
        return MNOComponentTableViewCell()
        
    }

    func configureCell(cell: MNOComponentTableViewCell, mnoComponentCKSCMO: MNOComponentCKSCMO) {


        cell.tableViewCellNavigationDelegate = self

        let mnoComponentRecordIDNameString = mnoComponentCKSCMO.ckRecordIDNameString
        let mnoComponentRecordID = CKRecordID(recordName: mnoComponentRecordIDNameString!)
        let mnoModuleComponentCKCSDetailsMOs = getNestedModuleComponentDetailsCKSCOfComponent(mnoComponentCKSCMO)

        var mnoModuleCKSCMOs:[MNOModuleCKSCMO] = []

        for i in 0..<mnoModuleComponentCKCSDetailsMOs.count {

            if mnoModuleComponentCKCSDetailsMOs[i].nestedModule != nil {
                mnoModuleCKSCMOs.append(mnoModuleComponentCKCSDetailsMOs[i].nestedModule! as MNOModuleCKSCMO)

            }

        }

        cell.displayedModules = mnoModuleCKSCMOs

        // Use the manageobject to fetch data on the cloudkit
        CloudKitDataController.sharedInstance.privateDB.fetchRecordWithID(mnoComponentRecordID) { (fetchedCKRecord: CKRecord?, error: NSError?) in
            if error != nil {
                print(error)

                if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                    MNOErrorHandler.handleAuthError()

                }

            } else {

                NSOperationQueue.mainQueue().addOperationWithBlock({

                    mnoComponentCKSCMO.fetchedCKRecord = fetchedCKRecord
                    cell.componentTitleLabel.text = fetchedCKRecord![MNOComponentCKSCMO.CDKComponentTitle] as? String
                    CoreDataController.sharedInstance.saveContext()
                    
                })
                
            }
            
        }
    }


}

extension MNOProcedureDetailViewController: UITableViewDelegate {

    // MARK: - UITableViewDelegate

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        procedureDetailTableView.setEditing(editing, animated: true)
        if editing {
            navBarAddButton.enabled = false
            editButtonItem().title = ""
        } else {
            navBarAddButton.enabled = true
            editButtonItem().title = ""
        }

    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == .Delete {

            // Remove the data locally
            let managedObjectToDelete = self.intervalComponentCKSCFetchedResultsController.objectAtIndexPath(indexPath) as! MNOComponentCKSCMO

            self.intervalComponentCKSCFetchedResultsController.managedObjectContext.deleteObject(managedObjectToDelete)

            // Remove the data on the cloudkit
            let mnoComponentToBeDeletedCKRecordIDNameString = managedObjectToDelete.ckRecordIDNameString

            let mnoComponentToBeDeletedCKRecordID = CKRecordID(recordName: mnoComponentToBeDeletedCKRecordIDNameString!)

            CloudKitDataController.sharedInstance.privateDB.deleteRecordWithID(mnoComponentToBeDeletedCKRecordID){ (deletedCKRecordID: CKRecordID?, error: NSError?) in

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

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        return true
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {

        if tableView.editing {
            return .Delete;
        }

        return .None

    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {

        let mnoComponentCKSCMO = self.intervalComponentCKSCFetchedResultsController.objectAtIndexPath(sourceIndexPath) as! MNOComponentCKSCMO

        let beforeDestinationIndexPath = NSIndexPath(forRow: destinationIndexPath.row - 1, inSection: destinationIndexPath.section)


        let afterDestinationIndexPath = destinationIndexPath

        var mnoComponentCKSCMOBeforeDestinationDisplayOrder = NSNumber(double: 0)

        if beforeDestinationIndexPath.row >= 0 {

            mnoComponentCKSCMOBeforeDestinationDisplayOrder = (self.intervalComponentCKSCFetchedResultsController.objectAtIndexPath(beforeDestinationIndexPath) as! MNOComponentCKSCMO).displayOrder!
        }


        var mnoComponentCKSCMOAfterDestinationDisplayOrder = mnoComponentCKSCMO.displayOrder

        mnoComponentCKSCMOAfterDestinationDisplayOrder = (self.intervalComponentCKSCFetchedResultsController.objectAtIndexPath(afterDestinationIndexPath) as! MNOComponentCKSCMO).displayOrder!

        let newDisplayOrderForTheSelectedComponentCKSCMODoubleValue = ((mnoComponentCKSCMOBeforeDestinationDisplayOrder.doubleValue) + (mnoComponentCKSCMOAfterDestinationDisplayOrder!.doubleValue))/2
        let newDisplayOrderForTheSelectedComponentCKSCMO = NSNumber(double: newDisplayOrderForTheSelectedComponentCKSCMODoubleValue)
        
        mnoComponentCKSCMO.displayOrder = newDisplayOrderForTheSelectedComponentCKSCMO
        CoreDataController.sharedInstance.saveContext()
        self.procedureDetailTableView.reloadData()
        
        
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
        
    }


}

extension MNOProcedureDetailViewController: NSFetchedResultsControllerDelegate {

    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.procedureDetailTableView.beginUpdates()

    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.procedureDetailTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)

        case .Delete:
            self.procedureDetailTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }


    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case .Insert:
            self.procedureDetailTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)


        case .Delete:
            self.procedureDetailTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:

            self.procedureDetailTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            if let cell = self.procedureDetailTableView.cellForRowAtIndexPath(indexPath!)  {
                let mnoComponentTableViewCell = cell as! MNOComponentTableViewCell
                self.configureCell(mnoComponentTableViewCell, mnoComponentCKSCMO: anObject as! MNOComponentCKSCMO)
            }


        case .Move:

            self.procedureDetailTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.procedureDetailTableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }


    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.procedureDetailTableView.endUpdates()
        
    }


}

extension MNOProcedureDetailViewController: MNOCompoentDetailViewControllerDelegate {

    // MARK: - MNOCompoentDetailViewControllerDelegate
    func didTapSaveButtonOnMNOCompoentDetailViewController(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)
        CoreDataController.sharedInstance.saveContext()
        self.procedureDetailTableView.reloadData()

    }

    func didTapCancelButtonOnMNOCompoentDetailViewController(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)
        CoreDataController.sharedInstance.saveContext()
        self.procedureDetailTableView.reloadData()
        
    }

}

extension MNOProcedureDetailViewController: MNOComponentTableViewCellNavigationDelegate {

    // MARK: - MNOComponentTableViewCellNavigationDelegate
    func segueFromSelectedCollectionViewCellToModuleDetail(nestedModuleComponentIndexPath: NSIndexPath, moduleCKSCMO: MNOModuleCKSCMO) {

        self.performSegueWithIdentifier(showModuleDetailFromNestedCollecionViewCellSegueIdentifier, sender: moduleCKSCMO)

    }

    func saveIntervalComponentToCloudKit(intervalComponentWithFetchedCKRecord: MNOComponentCKSCMO){
        let newMNOComponentCKSCRecordName = intervalComponentWithFetchedCKRecord.ckRecordIDNameString
        let newMNOComponentCKSCRecordID = CKRecordID(recordName: newMNOComponentCKSCRecordName!)

        let newMNOComponentCKSCToBeSavedCKRecord = CKRecord(recordType: "MNOComponent", recordID: newMNOComponentCKSCRecordID)
        intervalComponentWithFetchedCKRecord.ckRecordChangeTag = nil
        intervalComponentWithFetchedCKRecord.ckRecordCreationDate = NSDate()

        newMNOComponentCKSCToBeSavedCKRecord[MNOComponentCKSCMO.CDKComponentTitle] = intervalComponentWithFetchedCKRecord.fetchedCKRecord![MNOComponentCKSCMO.CDKComponentTitle]
        newMNOComponentCKSCToBeSavedCKRecord[MNOComponentCKSCMO.CDKComponentDescription] = intervalComponentWithFetchedCKRecord.fetchedCKRecord![MNOComponentCKSCMO.CDKComponentDescription]

        var intervalModuleComponentDetailsArray: [MNOComponetModuleCKSCDetailsMO] = self.getNestedModuleComponentDetailsCKSCOfComponent(intervalComponentWithFetchedCKRecord)

        var intervalModuleComponentDetailsNSDataArray: [NSData] = []

        for i in 0..<intervalModuleComponentDetailsArray.count {
            intervalModuleComponentDetailsNSDataArray.append(NSKeyedArchiver.archivedDataWithRootObject(intervalModuleComponentDetailsArray[i]))
        }

        newMNOComponentCKSCToBeSavedCKRecord[MNOComponentCKSCMO.CDKComponentNestedModuleComponentDetails] = intervalModuleComponentDetailsNSDataArray

        newMNOComponentCKSCToBeSavedCKRecord[MNOComponentCKSCMO.CDKComponentCreationDate] = intervalComponentWithFetchedCKRecord.ckRecordCreationDate
        newMNOComponentCKSCToBeSavedCKRecord[MNOComponentCKSCMO.CDKComponentLastModifiedDate] = NSDate()

        CloudKitDataController.sharedInstance.privateDB.saveRecord(newMNOComponentCKSCToBeSavedCKRecord) { (savedCKRecord: CKRecord?, error: NSError?) in
            if error != nil {
                 print(error)

                if error?.code == CKErrorCode.NotAuthenticated.rawValue {

                    MNOErrorHandler.handleAuthError()

                }

            } else {
                 print("newMNOComponentCKSCToBeSavedCKRecord \(savedCKRecord?.recordID) saved successfully.")

                intervalComponentWithFetchedCKRecord.ckRecordChangeTag = savedCKRecord?.recordChangeTag
                intervalComponentWithFetchedCKRecord.fetchedCKRecord = savedCKRecord

            }

        }

    }


    func getNestedModuleComponentDetailsCKSCOfComponent(intervalComponentWithFetchedCKRecord: MNOComponentCKSCMO) -> [MNOComponetModuleCKSCDetailsMO] {

        var intervalModuleComponentDetailsArray: [MNOComponetModuleCKSCDetailsMO] = []
        let mnoModuleComponentCKCSDetailsMOsFetchRequest = NSFetchRequest(entityName: "MNOComponetModuleCKSCDetails")
        let predicate = NSPredicate(format: "parentComponent == %@ ", intervalComponentWithFetchedCKRecord)
        mnoModuleComponentCKCSDetailsMOsFetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "moduleDisplayOrderInComponent", ascending: true)
        mnoModuleComponentCKCSDetailsMOsFetchRequest.sortDescriptors = [sortDescriptor]

        do {
            intervalModuleComponentDetailsArray = try CoreDataController.sharedInstance.managedObjectContext.executeFetchRequest(mnoModuleComponentCKCSDetailsMOsFetchRequest) as! [MNOComponetModuleCKSCDetailsMO]

        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }

        return intervalModuleComponentDetailsArray
        
        
    }


}

extension MNOProcedureDetailViewController: UITextViewDelegate {

    // MARK: - TextView Delegate

    func textViewDidBeginEditing(textView: UITextView) {

        if textView.tag == 1001 {

            if textView.textColor == MNOColorDarkPale {
                textView.text = nil
                textView.textColor = MNOColorLightPale
            }

        } else if textView.tag == 1002 {

            if textView.textColor == MNOColorDarkPale {
                textView.text = nil
                textView.textColor = MNOColorLightPale
            }


        }
    }

    func textViewDidEndEditing(textView: UITextView) {

        if textView.tag == 1001 {

            if textView.text.isEmpty {
                textView.text = NSLocalizedString("Procedure", comment: "Procedure")
                textView.textColor = MNOColorDarkPale
            }

        } else if textView.tag == 1002 {

            if textView.text.isEmpty {
                textView.text = NSLocalizedString("Tap Here to describe the Procedure.", comment: "Tap Here to describe the Procedure.")
                textView.textColor = MNOColorDarkPale
            }
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {


        if text == "\n" {
            textView.resignFirstResponder()
            return false


        } else {
            return true
        }

    }


}

extension MNOProcedureDetailViewController: MPMediaPickerControllerDelegate {

    // MARK: - MPMediaPickerControllerDelegate
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {

        self.dismissViewControllerAnimated(true) {

        }

    }

    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

        if mediaItemCollection.count > 0 {

            self.intervalProcedure?.mediaItemCollection = mediaItemCollection

            self.musicTrackLabel.text = mediaItemCollection.items.first?.title
            self.musicTrackLabel.alpha = 1

            self.intervalProcedureCKSCMOWithFetchedCKRecord?.mediaItemCollection = mediaItemCollection

        }

        self.dismissViewControllerAnimated(true) {


        }


    }


}


