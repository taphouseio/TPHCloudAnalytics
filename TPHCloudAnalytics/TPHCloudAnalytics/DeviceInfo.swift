//
//  DeviceInfo.swift
//  TPHCloudAnalytics
//
//  Created by Jared Sorge on 7/13/17.
//  Copyright © 2017 Taphouse Software. All rights reserved.
//

import Foundation

internal struct DeviceInfo {
    static func retrieveDeviceType() -> String {
        // Got this implementation from https://www.sajeel.me/ios-swift-get-device-model/
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
}
