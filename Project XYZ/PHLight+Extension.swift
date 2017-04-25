//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import Foundation

// Extend the concrete object that is provided by the vendor for custom features
extension PHLight {

    func setLightOn(isOn: Bool) {

            let targetLightState = PHLightState()
            targetLightState.setOn(isOn)
            self.updateLightState(lightState: targetLightState)

    }

    func setLightOn(isOn: Bool, targetBrightness: Int?, targetColor: UIColor?) {

        let targetLightState = PHLightState()
        targetLightState.setOn(isOn)

        self.configure(lightState: targetLightState, withTargetBrightness: targetBrightness)
        self.configure(lightState: targetLightState, withTargetColor: targetColor)
        self.updateLightState(lightState: targetLightState)

    }


    func toggleLightOnOffMode(targetBrightness: Int?, targetColor: UIColor?){

        if let currentLightState = self.lightState {

            print(#function + " " + "currentLightState.on is \(currentLightState.on.boolValue)")

            if currentLightState.on.boolValue {
                self.setLightOn(isOn: false)
            } else {
                self.setLightOn(isOn: true, targetBrightness: targetBrightness, targetColor: targetColor)
            }

        } else {
            print(#function + " " + "Can't get current light state.")
        }


    }

    fileprivate func getPHxy(fromUIColor color: UIColor) -> CGPoint {

        return PHUtilities.calculateXY(color, forModel: self.modelNumber)

    }

    fileprivate func setLightColor(WithXYValue xy: CGPoint){

        let targetLightState = PHLightState()

            targetLightState.x = NSNumber(value: Float(xy.x))
            targetLightState.y = NSNumber(value: Float(xy.y))

            self.updateLightState(lightState: targetLightState)
    }

    func setLightColor(WithUIColor color: UIColor) {
        self.setLightColor(WithXYValue: self.getPHxy(fromUIColor: color))
    }


    fileprivate func configure(lightState: PHLightState, withTargetBrightness targetBrightness: Int?) {

        guard let validTargetBrightness = targetBrightness else { return }
        lightState.brightness = NSNumber(value: validTargetBrightness)

    }

    fileprivate func configure(lightState: PHLightState, withTargetColor targetColor: UIColor?) {

        guard let validTargetColor = targetColor else { return }

        let targetPHxy = self.getPHxy(fromUIColor: validTargetColor)

        lightState.x = NSNumber(value: Float(targetPHxy.x))
        lightState.y = NSNumber(value: Float(targetPHxy.y))
    }



    func setLightBrightness(WithBrightnessValue brightnessValue: Int) {

            let targetLightState = PHLightState()

            targetLightState.brightness = NSNumber(value: brightnessValue)
            self.updateLightState(lightState: targetLightState)
    }

    func setLightColorAndBrightnessCombo(WithUIColor color: UIColor, andBrightnessValue brightnessValue: Int) {

        let targetLightState = PHLightState()

            let xy = self.getPHxy(fromUIColor: color)

            targetLightState.x = NSNumber(value: Float(xy.x))
            targetLightState.y = NSNumber(value: Float(xy.y))

            targetLightState.brightness = brightnessValue as NSNumber!

            self.updateLightState(lightState: targetLightState)
    }


    func updateLightState(lightState: PHLightState) {

        let bridgeSendAPI = PHBridgeSendAPI()


        bridgeSendAPI.updateLightState(forId: self.identifier, with: lightState) { error in

            if error != nil {

                print(#function + " " + "Can't set the lightstate: \(error)")

            } else {

                print(#function + " " + "set the lightstate successfully")
            }
        }
    }


    @objc func sliderLight(WithBrightnessIncrement brightnessIncrement: Int){


            let targetLightState = PHLightState()
            targetLightState.brightnessIncrement = NSNumber(value: brightnessIncrement)

            self.updateLightState(lightState: targetLightState)


    }

    @objc  func decrementLight(){

        self.sliderLight(WithBrightnessIncrement: -32)

    }

    @objc  func incrementLight(){

        self.sliderLight(WithBrightnessIncrement: 32)

    }

}
