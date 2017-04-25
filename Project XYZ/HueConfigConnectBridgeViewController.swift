//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import UIKit

// Protocol for the parent object (such as: View Controller) to adopt for handling dimiss the current view controller and passing data from the child object to the parent object.
protocol HueConfigConnectBridgeViewDelegate {
    func didTapCancel(from hueConfigConnectBridgeViewController: HueConfigConnectBridgeViewController, animated: Bool, backToNIUButtonListViewController: Bool)
}

// A object for connecting to the Philips Hue Smart Light Bulb
class HueConfigConnectBridgeViewController: UIViewController {

    // MARK: - Properties

    let segueIdToConnectOk = "showConnectOkView"
    let segueIdToConnectNok = "showConnectNokView"
    let segueIdToConnectPushlinkingView = "showPushlinkingView"
    let segueIdToBridgesFoundListView = "showbridgesFoundList"
    let segueIdToHueConfigMainView = "showConfigMainView"
    var hueParentViewController: HueConfigConnectBridgeViewDelegate!
    let hueDelegate: HueDelegate! = HueDelegate.sharedInstance
    var niuButtonActionMode: NIUButtonActionController.NIUButtonActionMode!
    var selectedBridgeId: String?
    var selectedBridgeIpAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.connectWithHueBridge()

    }

    func connectWithHueBridge(){

        self.hueDelegate.referencedViewController = self
        self.hueDelegate.startUpHueSDK()
        self.hueDelegate.registerNotification(delegate: self)
        self.hueDelegate.enableLocalHeartbeat()

    }

    func doAuthentication(){

        self.hueDelegate.disableLocalHeartbeat()
        self.performSegue(withIdentifier: self.segueIdToConnectPushlinkingView, sender: self)
    }

    @IBAction func didTapCancel(_ sender: UIButton) {

        self.hueParentViewController.didTapCancel(from: self, animated: false, backToNIUButtonListViewController: false)

    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {


        switch segue.identifier {
        case self.segueIdToConnectPushlinkingView?:
            let targetVC: HueConfigPushlinkViewController = segue.destination as! HueConfigPushlinkViewController
            targetVC.hueParentViewController = self
        case self.segueIdToBridgesFoundListView?:
            let targetNAVVC: UINavigationController = segue.destination as! UINavigationController
            let targetVC: HueConfigBridgeSelectionViewController = targetNAVVC.topViewController as! HueConfigBridgeSelectionViewController
            targetVC.hueParentViewController = self
            let bridgesFound = sender as! [AnyHashable : Any]
            targetVC.bridgesFound = bridgesFound
        case self.segueIdToConnectOk?:
            let targetVC: HueConfigConnectOkViewController = segue.destination as! HueConfigConnectOkViewController
            targetVC.hueParentViewController = self
            guard let selectedBridgeIdToPass = self.selectedBridgeId else { return }
            targetVC.bridgeId = selectedBridgeIdToPass
            guard let selectedBridgeIpAddressToPass = self.selectedBridgeIpAddress else { return }
            targetVC.bridgeIpAddress = selectedBridgeIpAddressToPass
        case self.segueIdToConnectNok?:
            let targetVC: HueConfigConnectNokViewController = segue.destination as! HueConfigConnectNokViewController
            targetVC.hueParentViewController = self
        case self.segueIdToHueConfigMainView?:
            let targetVC: HueConfigMainViewController = segue.destination as! HueConfigMainViewController
            targetVC.hueParentViewController = self
            targetVC.niuButtonActionMode = self.niuButtonActionMode
        default:
            print(#function + " " + "This line should never be called unless there is any uncovered segue")

        }

    }

}

// Adopting the protocols by Swift extension for clarity

extension HueConfigConnectBridgeViewController: PHNotificationDelegate {

    // MARK: - PHNotificationDelegate
    func localConnection(){

        print(#function + " " + "")
        self.hueDelegate.checkConnectionState(withBridgeId: self.selectedBridgeId)
    }
    func noLocalConnection(){

        print(#function + " " + "")
        self.hueDelegate.checkConnectionState(withBridgeId: nil)
    }
    func notAuthenticated(){

        print(#function + " " + "We are not authenticated so we start the authentication process")

        self.doAuthentication()

    }

}

extension HueConfigConnectBridgeViewController: HueConfigPushlinkViewDelegate {

    // MARK: - HueConfigPushlinkViewDelegate
    func didAuthenticateByPushlinkButton(from hueConfigPushlinkViewController: HueConfigPushlinkViewController) {

        // Dismiss the child view controller by the parent view controller (current view controller) as a recommended practice.
        hueConfigPushlinkViewController.dismiss(animated: true) {

            print(#function + " " + "hueConfigPushlinkViewController dismissed")
            self.hueDelegate.enableLocalHeartbeat()

        }
    }

    func didFailAuthenticationByPushlinkButton(from hueConfigPushlinkViewController: HueConfigPushlinkViewController, withError error: PHError) {

        hueConfigPushlinkViewController.dismiss(animated: true) {

            print(#function + " " + "hueConfigPushlinkViewController dimissed")

            if error.code == Int(PUSHLINK_NO_CONNECTION.rawValue) {
                print(#function + " " + "No local connection to bridge")
                self.noLocalConnection()

                self.hueDelegate.enableLocalHeartbeat()

            } else {
                print(#function + " " + "Bridge button not pressed in time")
            }
            
        }
    }

}

extension HueConfigConnectBridgeViewController: HueDelegateReferenceViewController {

    // MARK: - HueDelegateReferenceViewController
    func presentViewController(withBridges bridgesFound: [AnyHashable : Any]) {

        self.performSegue(withIdentifier: self.segueIdToBridgesFoundListView, sender: bridgesFound)

    }

    func segueToHueConfigConnectOkViewController(bridgeId: String?) {

        self.hueDelegate.disableLocalHeartbeat()
        self.performSegue(withIdentifier: self.segueIdToConnectOk, sender: self)
    }

    func segueToHueConfigConnectNokViewController() {

        self.performSegue(withIdentifier: self.segueIdToConnectNok, sender: self)
    }

}

extension HueConfigConnectBridgeViewController: HueConfigBridgeSelectionViewDelegate {

    // MARK: - HueConfigBridgeSelectionViewDelegate
    func didCancelSeletion(from hueConfigBridgeSelectionViewController: HueConfigBridgeSelectionViewController) {
        print(#function + " " + "")
        hueConfigBridgeSelectionViewController.dismiss(animated: true) {
            print(#function + " " + "")
        }
    }

    func didSelect(bridge bridgeInfo: (bridgeId: String, ip: String), from hueConfigBridgeSelectionViewController: HueConfigBridgeSelectionViewController) {
        print(#function + " " + "")

        self.selectedBridgeId = bridgeInfo.bridgeId
        self.selectedBridgeIpAddress = bridgeInfo.ip

        hueConfigBridgeSelectionViewController.dismiss(animated: true) {

            print(#function + " " + "hueConfigBridgeSelectionViewController dismissed")

            self.hueDelegate.bridgeSelectedWithIpAddress(ip: bridgeInfo.ip, andBridgeId: bridgeInfo.bridgeId)
        }

    }

    func doRefreshSearch(from hueConfigBridgeSelectionViewController: HueConfigBridgeSelectionViewController) {

        hueConfigBridgeSelectionViewController.dismiss(animated: true) {

            print(#function + " " + "hueConfigBridgeSelectionViewController dismissed")
            self.hueDelegate.searchForBridgeLocal()
        }
    }

}

extension HueConfigConnectBridgeViewController: HueConfigMainViewDelegate {

    // MARK: - HueConfigMainViewDelegate
    func didTapCancelConfigAction(from hueConfigMainViewController: HueConfigMainViewController) {

        hueConfigMainViewController.dismiss(animated: false) {

            print(#function + " " + "hueConfigMainViewController dimissed")
            self.hueParentViewController.didTapCancel(from: self, animated: false, backToNIUButtonListViewController: false)
        }
    }

    func didTapValidateConfigAction(from hueConfigMainViewController: HueConfigMainViewController) {

        hueConfigMainViewController.dismiss(animated: true) {

            print(#function + " " + "hueConfigMainViewController dimissed")
            self.hueParentViewController.didTapCancel(from: self, animated: false, backToNIUButtonListViewController: true)
        }
    }

}

extension HueConfigConnectBridgeViewController: HueConfigConnectOkViewDelegate {

    // MARK: - HueConfigConnectOkViewDelegate
    func didTapNext(from hueConfigConnectOkViewController: HueConfigConnectOkViewController) {


        hueConfigConnectOkViewController.dismiss(animated: false) {
            print(#function + " " + "hueConfigConnectOkViewController dismissed")

            self.performSegue(withIdentifier: self.segueIdToHueConfigMainView, sender: self)
            
        }
    }

}

extension HueConfigConnectBridgeViewController: HueConfigConnectNokViewDelegate {

    // MARK: - HueConfigConnectNokViewDelegate
    func didTapRetry(from hueConfigConnectNokViewController: HueConfigConnectNokViewController) {

        hueConfigConnectNokViewController.dismiss(animated: true) {

            print(#function + " " + "hueConfigConnectNokViewController dimissed")
            self.hueDelegate.enableLocalHeartbeat()

        }
    }

    func didTapCancel(from hueConfigConnectNokViewController: HueConfigConnectNokViewController) {
        hueConfigConnectNokViewController.dismiss(animated: true) {

            print(#function + " " + "hueConfigConnectNokViewController dimissed")
            self.hueParentViewController.didTapCancel(from: self, animated: false, backToNIUButtonListViewController: false)
            
        }
    }

}
