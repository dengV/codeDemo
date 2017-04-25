//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import UIKit

// Protocol for the parent object (such as: View Controller) to adopt for handling dimiss the current view controller and passing data from the child object to the parent object.

protocol HueConfigMainViewDelegate {
    func didTapCancelConfigAction(from hueConfigMainViewController: HueConfigMainViewController)
    func didTapValidateConfigAction(from hueConfigMainViewController: HueConfigMainViewController)

}

class HueConfigMainViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var hueBulbsCollectionView: UICollectionView!
    @IBOutlet weak var selectActionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var brightnessPercentageLabel: UILabel!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var selectColorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var lightStateControlPanel: UIView!
    @IBOutlet weak var validateButton: UIButton!

    // MARK: - Properties

    let segueIdToColorPicker = "showPickerPopupView"
    let reuseIdCollectionViewCell = "HueLightCollectionViewCell"
    var niuButtonActionMode: NIUButtonActionController.NIUButtonActionMode!
    let phLightStore = PHLightStore.sharedInstance
    var selectedLights:[PHLight]? {
        if let selectedIndexPaths = hueBulbsCollectionView.indexPathsForSelectedItems {
            return self.phLights(at: selectedIndexPaths)
        } else {
            return nil
        }
    }
    var selectActionSegmentedItemTitles: [String] {

        switch self.niuButtonActionMode {
        case NIUButtonActionController.NIUButtonActionMode.LongPress?:
            return ["On", "Off", "Toggle", "Dimmer"]
        default:
            return ["On", "Off", "Toggle"]
        }


    }
    let selectColorSegmentedItemTitles = ["Cold", "Warm", "Picker"]

    var hueParentViewController:HueConfigMainViewDelegate!
    var niuHueButtonMode:NIUHueButtonModeController.ButtonMode?
    var niuHueLightTargetBrightness: Int! = 128
    var niuHueLightTargetColor: UIColor! = UIColor.NIUHueColdColor


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hueBulbsCollectionView.allowsMultipleSelection = true
        self.enableControlIfNeeded()
        self.setupSelectActionSegmentedControl()
        self.setupSelectColorSegmentedControl()
    }

    // MARK: - Actions

    @IBAction func selectActionValueChanged(_ sender: UISegmentedControl) {

        let selectedSegmentIndex = sender.selectedSegmentIndex

        if selectedSegmentIndex == 3 {
            self.brightnessSlider.isEnabled = false
            self.selectColorSegmentedControl.isEnabled = false
        } else {
            self.brightnessSlider.isEnabled = true
            self.selectColorSegmentedControl.isEnabled = true

        }

    }

    @IBAction func brightnessValueChanged(_ sender: UISlider) {


        self.setupBrightnessSlider()

        print(#function + " " + "niuHueLightTargetBrightness: \(self.niuHueLightTargetBrightness)")


    
    }

    @IBAction func selectColorValueChanged(_ sender: UISegmentedControl) {

        let selectedSegmentIndex = sender.selectedSegmentIndex
        self.setNIUButtonColor(bySegmentIndex: selectedSegmentIndex)
        print(#function + " " + "niuHueLightTargetColor: \(self.niuHueLightTargetColor)")



    }


    @IBAction func didTapCancel(_ sender: UIButton) {
        self.hueParentViewController.didTapCancelConfigAction(from: self)
    }

    @IBAction func didTapValidate(_ sender: UIButton) {
        self.setNIUButtonActionMode()


        // TODO: Notify or Display to the user for successfully saved button

        self.hueParentViewController.didTapValidateConfigAction(from: self)
        
    }

    // MARK: - Private Methods
    fileprivate func enableControlIfNeeded(){
        let itemCount = self.hueBulbsCollectionView.indexPathsForSelectedItems?.count ?? 0
        self.lightStateControlPanel.isHidden = itemCount == 0
        self.lightStateControlPanel.isUserInteractionEnabled = itemCount > 0
        self.validateButton.isEnabled = itemCount > 0
        self.brightnessSlider.value = Float(self.niuHueLightTargetBrightness)
        self.setupBrightnessSlider()



    }

    fileprivate func setupBrightnessSlider(){

        let currentValue = self.brightnessSlider.value
        let currentPercentage = Int(currentValue / self.brightnessSlider.maximumValue * 100)
        self.niuHueLightTargetBrightness = Int(currentValue)
        self.brightnessPercentageLabel.text = "\(currentPercentage)%"
    }


    fileprivate func setupSelectActionSegmentedControl(){

        self.selectActionSegmentedControl.removeAllSegments()
        for (index, segmentedTitle) in self.selectActionSegmentedItemTitles.enumerated() {
            self.selectActionSegmentedControl.insertSegment(withTitle: segmentedTitle, at: index, animated: false)
        }
    }

    fileprivate func setupSelectColorSegmentedControl(){

        self.selectColorSegmentedControl.removeAllSegments()
        for (index, segmentedTitle) in self.selectColorSegmentedItemTitles.enumerated() {
            self.selectColorSegmentedControl.insertSegment(withTitle: segmentedTitle, at: index, animated: false)
        }
    }

    fileprivate func niuHueButtonMode(bySegmentIndex index: Int) -> NIUHueButtonModeController.ButtonMode? {

        guard let selectedLightsToSet = self.selectedLights else { return nil }

        switch index {
        case 0:
            return NIUHueButtonModeController.ButtonMode.TurnLightOn(selectedLightsToSet, self.niuHueLightTargetBrightness, self.niuHueLightTargetColor)
        case 1:
            return NIUHueButtonModeController.ButtonMode.TurnLightOff(selectedLightsToSet)
        case 2:
            return NIUHueButtonModeController.ButtonMode.ToggleLightOnOff(selectedLightsToSet, self.niuHueLightTargetBrightness, self.niuHueLightTargetColor)
        case 3:
            return NIUHueButtonModeController.ButtonMode.ToggleLightBrightnessLevel(selectedLightsToSet)
        default:
            print(#function + " " + "This line should never be called unless there is any uncovered tag")
            return nil
        }
    }

    fileprivate func setNIUButtonActionMode(){

        let selectedActionSegmentIndex = self.selectActionSegmentedControl.selectedSegmentIndex
        niuHueButtonMode = self.niuHueButtonMode(bySegmentIndex: selectedActionSegmentIndex)

        switch self.niuButtonActionMode {
        case NIUButtonActionController.NIUButtonActionMode.SingleTap?:
            NIUHueButtonModeController.sharedInstance.singleTapButtonMode = niuHueButtonMode
        case NIUButtonActionController.NIUButtonActionMode.DoubleTap?:
            NIUHueButtonModeController.sharedInstance.doubleTapButtonMode = niuHueButtonMode
        case NIUButtonActionController.NIUButtonActionMode.LongPress?:
            NIUHueButtonModeController.sharedInstance.longPressButtonMode = niuHueButtonMode
        default:
            print(#function + " " + "This line should never be called unless there is any uncovered enum")
        }

    }

    fileprivate func setNIUButtonColor(bySegmentIndex index: Int) {

        switch index {
        case 0:
            self.niuHueLightTargetColor = UIColor.NIUHueColdColor
            self.selectColorSegmentedControl.backgroundColor = UIColor.NIUHueColdColor
        case 1:
            self.niuHueLightTargetColor = UIColor.NIUHueWarmColor
            self.selectColorSegmentedControl.backgroundColor = UIColor.NIUHueWarmColor
        case 2:
            self.performSegue(withIdentifier: self.segueIdToColorPicker, sender: self)
        default:
            print(#function + " " + "This line should never be called unless there is any uncovered enum")
        }

    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case self.segueIdToColorPicker?:
            let targetVC: HueConfigPickerPopupViewController = segue.destination as! HueConfigPickerPopupViewController
            targetVC.hueParentViewController = self
        default:
            print(#function + " " + "This line should never be called unless there is any uncovered segue")
        }
    }


}

// Adopting the protocols by Swift extension for clarity

extension HueConfigMainViewController: UICollectionViewDataSource {

    fileprivate func phLight(for indexPath: IndexPath) -> PHLight? {

        guard let allValidLightsKeyValue = self.phLightStore.allLightsInConnectedBridges else { return nil }
        let phLights = Array(allValidLightsKeyValue.values) as [PHLight]
        return phLights[indexPath.row] as PHLight
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return phLightStore.allLightsInConnectedBridges?.count ?? 0

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdCollectionViewCell, for: indexPath)

        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        guard let cell:HueLightCollectionViewCell = cell as? HueLightCollectionViewCell else { return }
        guard let phLight:PHLight = self.phLight(for: indexPath) else {return}

        print(#function + " " + "PHLight: \(self.phLight)")

        cell.lightBulbNameLabel.text = phLight.name
    }

}


extension HueConfigMainViewController: UICollectionViewDelegate {

    fileprivate func phLights(at indexPaths:[IndexPath]) -> [PHLight] {
        var lights = [PHLight]()
        for indexPath in indexPaths {
            guard let light = phLight(for: indexPath) else { continue }
            lights.append(light)
        }
        return lights
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.enableControlIfNeeded()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.enableControlIfNeeded()
    }

}

extension HueConfigMainViewController: HueConfigPickerPopupViewDelegate {

    func didTapConfirmColorPicker(from hueConfigPickerPopupViewController: HueConfigPickerPopupViewController) {

    }

    func didTapConfirmColorPicker(from hueConfigPickerPopupViewController: HueConfigPickerPopupViewController, withPickedColor pickedColor: UIColor) {

        self.niuHueLightTargetColor = pickedColor

        self.selectColorSegmentedControl.backgroundColor = pickedColor

        print(#function + " " + "niuHueLightTargetColor: \(self.niuHueLightTargetColor)")


        // Dismiss the child view controller by the parent view controller (current view controller) as a recommended practice.
        hueConfigPickerPopupViewController.dismiss(animated: true) {
            print(#function + " " + "hueConfigPickerPopupViewController dismissed")

        }

    }

    func didTapCancelColorPicker(from hueConfigPickerPopupViewController: HueConfigPickerPopupViewController) {
        hueConfigPickerPopupViewController.dismiss(animated: true) { 
            print(#function + " " + "hueConfigPickerPopupViewController dismissed")
        }
    }
}
