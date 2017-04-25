//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import Foundation

class XYZHueButtonModeController: NSObject, NSCoding {

    // The singletone object getter
    static var sharedInstance: XYZHueButtonModeController = loadSharedInstance()

    static func loadSharedInstance() -> XYZHueButtonModeController {

        if let hueActionsModeConfigData = UserDefaults.standard.object(forKey: XYZHueButtonModeController.kHueSystemActionsForUserInfoModel) as? Data,
            let unarchivedInstance = NSKeyedUnarchiver.unarchiveObject(with: hueActionsModeConfigData) as? XYZHueButtonModeController
        {

            return unarchivedInstance

        }

        return XYZHueButtonModeController.init(singleTapButtonMode: nil, doubleTapButtonMode: nil, longPressButtonMode: nil)

    }

    static let kHueSystemActionsForUserInfoModel = "hueSystemActions"

    // Use Swift Enum with the associate values for efficient action state storing and restoring
    enum ButtonMode {
        case TurnLightOn([PHLight], Int?, UIColor?)
        case TurnLightOff([PHLight])
        case ToggleLightOnOff([PHLight], Int?, UIColor?)
        case ToggleLightBrightnessLevel([PHLight])
    }


    var singleTapButtonMode:ButtonMode?
    var doubleTapButtonMode:ButtonMode?
    var longPressButtonMode:ButtonMode? 

    // MARK: -  Memberwise initializer

    init(singleTapButtonMode:ButtonMode?, doubleTapButtonMode:ButtonMode?, longPressButtonMode:ButtonMode?) {

        self.singleTapButtonMode = singleTapButtonMode
        self.doubleTapButtonMode = doubleTapButtonMode
        self.longPressButtonMode = longPressButtonMode

        super.init()

    }

    // MARK: - NSCoding
    required convenience init?(coder aDecoder: NSCoder) {

        // Use extra steps to decode the Enum that contains the associate values
        func getButtonMode(byBase base: ButtonMode.Base, coder aDecoder: NSCoder) -> ButtonMode? {

            let buttonModeToReturn: ButtonMode?

            switch base {
            case .TurnLightOn:

                guard let phLights = aDecoder.decodeObject(forKey: "phLightsTurnLightOn") as? [PHLight] else { return nil }
                let targetBrightness:Int? = aDecoder.decodeObject(forKey: "targetBrightnessTurnLightOn") as? Int
                let targetColor: UIColor? = aDecoder.decodeObject(forKey: "targetColorTurnLightOn") as? UIColor
                buttonModeToReturn = .TurnLightOn(phLights, targetBrightness, targetColor)

            case .TurnLightOff:

                guard let phLights = aDecoder.decodeObject(forKey: "phLightsTurnLightOff") as? [PHLight] else { return nil }
                buttonModeToReturn = .TurnLightOff(phLights)

            case .ToggleLightOnOff:

                guard let phLights = aDecoder.decodeObject(forKey: "phLightsToggleLightOnOff") as? [PHLight] else { return nil }
                let targetBrightness:Int? = aDecoder.decodeObject(forKey: "targetBrightnessToggleLightOnOff") as? Int
                let targetColor: UIColor? = aDecoder.decodeObject(forKey: "targetColorToggleLightOnOff") as? UIColor
                buttonModeToReturn = .ToggleLightOnOff(phLights, targetBrightness, targetColor)


            case .ToggleLightBrightnessLevel:

                guard let phLights = aDecoder.decodeObject(forKey: "phLightsToggleLightBrightnessLevel") as? [PHLight] else { return nil }
                buttonModeToReturn = .ToggleLightBrightnessLevel(phLights)
                
            }
            
            return buttonModeToReturn
            
        }

        var singleTapButtonModeForInit: ButtonMode? = nil
        var doubleTapButtonModeForInit: ButtonMode? = nil
        var longPressButtonModeForInit: ButtonMode? = nil

        if let singleTapButtonModeRawCase = aDecoder.decodeObject(forKey: "singleTapButtonMode") as? String,
            let base = ButtonMode.Base(rawValue: singleTapButtonModeRawCase) {
            singleTapButtonModeForInit = getButtonMode(byBase: base, coder: aDecoder)
        }
        if let doubleTapButtonModeRawCase = aDecoder.decodeObject(forKey: "doubleTapButtonMode") as? String,
            let base = ButtonMode.Base(rawValue: doubleTapButtonModeRawCase) {
            doubleTapButtonModeForInit = getButtonMode(byBase: base, coder: aDecoder)
        }
        if let longPressButtonModeRawCase = aDecoder.decodeObject(forKey: "longPressButtonMode") as? String,
            let base = ButtonMode.Base(rawValue: longPressButtonModeRawCase) {
            longPressButtonModeForInit = getButtonMode(byBase: base, coder: aDecoder)
        }

        self.init(singleTapButtonMode: singleTapButtonModeForInit, doubleTapButtonMode: doubleTapButtonModeForInit, longPressButtonMode: longPressButtonModeForInit)


    }

    func encode(with aCoder: NSCoder) {

        self.encode(buttonMode: self.singleTapButtonMode, with: aCoder, forKey: "singleTapButtonMode")
        self.encode(buttonMode: self.doubleTapButtonMode, with: aCoder, forKey: "doubleTapButtonMode")
        self.encode(buttonMode: self.longPressButtonMode, with: aCoder, forKey: "longPressButtonMode")
        
    }

    fileprivate func encode(buttonMode: ButtonMode?, with aCoder: NSCoder, forKey key: String) {

        // Use extra steps to encode the Enum that contains the associate values
        guard let validButtonMode = buttonMode else {
            aCoder.encode(nil, forKey: key)
            return
        }

        aCoder.encode(validButtonMode.base.rawValue, forKey: key)

        switch validButtonMode {
        case .TurnLightOn(let phLights, let targetBrightness, let targetColor):
            aCoder.encode(phLights, forKey: "phLightsTurnLightOn")
            aCoder.encode(targetBrightness, forKey: "targetBrightnessTurnLightOn")
            aCoder.encode(targetColor, forKey: "targetColorTurnLightOn")
        case .TurnLightOff(let phLights):
             aCoder.encode(phLights, forKey: "phLightsTurnLightOff")
        case .ToggleLightOnOff(let phLights, let targetBrightness, let targetColor):
            aCoder.encode(phLights, forKey: "phLightsToggleLightOnOff")
            aCoder.encode(targetBrightness, forKey: "targetBrightnessToggleLightOnOff")
            aCoder.encode(targetColor, forKey: "targetColorToggleLightOnOff")
        case .ToggleLightBrightnessLevel(let phLights):
             aCoder.encode(phLights, forKey: "phLightsToggleLightBrightnessLevel")
        }

    }

    func archive(){

        let hueActionsModeConfigData = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(hueActionsModeConfigData, forKey: XYZHueButtonModeController.kHueSystemActionsForUserInfoModel)
    }

    
}

extension XYZHueButtonModeController.ButtonMode {

    // The extra layer of the Enum to encode or decode the Enum that contains the associate values
    enum Base: String {
        case TurnLightOn
        case TurnLightOff
        case ToggleLightOnOff
        case ToggleLightBrightnessLevel
    }

    var base: Base {
        switch self {
        case .TurnLightOn: return .TurnLightOn
        case .TurnLightOff: return .TurnLightOff
        case .ToggleLightOnOff: return .ToggleLightOnOff
        case .ToggleLightBrightnessLevel: return .ToggleLightBrightnessLevel
        }
    }
}


