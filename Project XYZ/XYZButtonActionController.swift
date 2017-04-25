//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.

import Foundation

// An object that helps to control the Philips Hue Lights with various button action.
class XYZButtonActionController {

    public enum XYZButtonActionMode {
        case SingleTap
        case DoubleTap
        case LongPress
    }

    // The singletone object getter
    static let xyzButtonModeController = XYZHueButtonModeController.sharedInstance

    // Use Timer and Swift Optional to safely control actions based on the "Start" and the "End" of long press gesture.
    static var brightnessIsIncrementing: Bool? {
        didSet {

            if brightnessIsIncrementing == true {
                self.brightnessIncrementTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.incrementLight), userInfo: nil, repeats: true)
            } else {
                
                self.brightnessIncrementTimer?.invalidate()
                self.brightnessIncrementTimer = nil
            }

        }
    }
    static var brightnessIsDecrementing: Bool? {
        didSet {

            if brightnessIsDecrementing == true {
                self.brightnessDecrementTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.decrementLight), userInfo: nil, repeats: true)
            } else {
                self.brightnessDecrementTimer?.invalidate()
                self.brightnessDecrementTimer = nil
            }

        }
    }
    static var brightnessIsToIncrementNotDecrement: Bool = false
    static var brightnessIncrementTimer: Timer!
    static var brightnessDecrementTimer: Timer!
    static var selectedLightsForBrightnessIncrementOrDecrement: [PHLight]?
    static let longPressSingleTapSimDelayInSeconds = 1.0
    

    static func singleTapButtonAction(){
        
        if let singleTapButtonMode = xyzButtonModeController.singleTapButtonMode {
            self.performAction(withMode: singleTapButtonMode, longPressBeganOrEnded: nil)
        } else {
            print(#function + " " + "Does not set singleTapButtonMode")
        }
    }

    static func doubleTapButtonAction(){
        if let doubleTapButtonMode = xyzButtonModeController.doubleTapButtonMode {
            self.performAction(withMode: doubleTapButtonMode, longPressBeganOrEnded: nil)
        } else {
            print(#function + " " + "Does not set doubleTapButtonMode")
        }
    }

    static func longPressButtonAction(pressBeganOrEnded: Bool?){

        if let longPressButtonMode = xyzButtonModeController.longPressButtonMode {
            self.performAction(withMode: longPressButtonMode, longPressBeganOrEnded: pressBeganOrEnded)
        } else {
            print(#function + " " + "Does not set longPressButtonMode")
        }
    }

    fileprivate static func setupBrightnessIncrementDecrementState(longPressBeganOrEnded: Bool?){

        if self.brightnessIsToIncrementNotDecrement == true {

            self.brightnessIsDecrementing = nil

            switch longPressBeganOrEnded {
            case true?:
                self.brightnessIsIncrementing = true
            case false?:
                self.brightnessIsIncrementing = false
            case nil:
                self.brightnessIsIncrementing = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.longPressSingleTapSimDelayInSeconds){
                    self.brightnessIsIncrementing = false
                }
            }


        } else if self.brightnessIsToIncrementNotDecrement == false {


            self.brightnessIsIncrementing = nil

            switch longPressBeganOrEnded {
            case true?:
                self.brightnessIsDecrementing = true
            case false?:
                self.brightnessIsDecrementing = false
            case nil:
                self.brightnessIsDecrementing = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.longPressSingleTapSimDelayInSeconds){
                    self.brightnessIsDecrementing = false
                }
            }

        }

    }

    fileprivate static func performAction(withMode mode: XYZHueButtonModeController.ButtonMode, longPressBeganOrEnded: Bool?) {
        switch mode {
        case .TurnLightOn(let phLights, let targetBrightness, let targetColor):
            turnLightOn(forLights: phLights, targetBrightness: targetBrightness, targetColor: targetColor)
        case .TurnLightOff(let phLights):
            turnLightOff(forLights: phLights)
        case .ToggleLightOnOff(let phLights, let targetBrightness, let targetColor):
            toggleLightOnOff(forLights: phLights, targetBrightness: targetBrightness, targetColor: targetColor)
        case .ToggleLightBrightnessLevel(let phLights):
            toggleLightBrightnessLevel(forLights: phLights, longPressBeganOrEnded: longPressBeganOrEnded)
        }
    }

    fileprivate static func turnLightOn(forLights phLights: [PHLight], targetBrightness: Int?, targetColor: UIColor?){
        print(#function + " " + "ready to control Hue Lights: \(phLights)")
        phLights.forEach { phLight in
            phLight.setLightOn(isOn: true, targetBrightness: targetBrightness, targetColor: targetColor)
        }
    }

    fileprivate static func turnLightOff(forLights phLights: [PHLight]){
        print(#function + " " + "ready to control Hue Lights: \(phLights)")
        phLights.forEach { phLight in
            phLight.setLightOn(isOn: false)
        }
    }

    fileprivate static func toggleLightOnOff(forLights phLights: [PHLight], targetBrightness: Int?, targetColor: UIColor?){
        print(#function + " " + "ready to control Hue Lights: \(phLights)")
        phLights.forEach { phLight in
            phLight.toggleLightOnOffMode(targetBrightness: targetBrightness, targetColor: targetColor)
        }
    }

}


// Implement additional features by using 'extension'for clarity

extension XYZButtonActionController {

    fileprivate static func toggleLightBrightnessLevel(forLights phLights: [PHLight], longPressBeganOrEnded: Bool?){
        print(#function + " " + "ready to control Hue Lights: \(phLights)")

        self.selectedLightsForBrightnessIncrementOrDecrement = phLights

        if longPressBeganOrEnded != false {
            self.brightnessIsToIncrementNotDecrement = !self.brightnessIsToIncrementNotDecrement
            print(#function + " " + "brightnessIsIncrementingNotDecrementing: \(self.brightnessIsToIncrementNotDecrement)")
        }

        self.setupBrightnessIncrementDecrementState(longPressBeganOrEnded: longPressBeganOrEnded)


    }


    @objc static fileprivate func decrementLight(){

         self.selectedLightsForBrightnessIncrementOrDecrement?.forEach { phLight in

            phLight.decrementLight()
        }
    }

    @objc static fileprivate func incrementLight(){

        self.selectedLightsForBrightnessIncrementOrDecrement?.forEach { phLight in

            phLight.incrementLight()
        }
        
    }



}
