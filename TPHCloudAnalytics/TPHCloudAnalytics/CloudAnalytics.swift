//
//  CloudAnalytics.swift
//  TPHCloudAnalytics
//
//  Created by Jared Sorge on 7/13/17.
//  Copyright © 2017 Taphouse Software. All rights reserved.
//

import Foundation
import CloudKit

@objc public final class TPHCloudAnalyticsReporter: NSObject {
    //MARK: API
    /// The singleton to be used for all access to this class
    @objc(sharedReporter)
    public static var shared: TPHCloudAnalyticsReporter {
        guard let _shared = _shared else { fatalError("The analytics reporter needs to be started before the singleton is accessed") }
        return _shared
    }
    
    /// Use this to startup the reporter. This must be called before the singleton is accessed. If it is not, then the app will fatal error.
    /// This method will also add the initial analytics record for the session to the public database.
    ///
    /// - Parameter containerID: The iCloud container ID to send data to
    @objc public static func start(withContainerID containerID: String) {
        _shared = TPHCloudAnalyticsReporter(containerID: containerID)
    }
    
    /// Allows for a custom event to be tracked.
    ///
    /// - Parameters:
    ///   - key: The key to be set in CloudKit. This corresponds to a column in the database.
    ///   - value: The value of the key to be set. This value must be castable to a `CKRecordValue` type. See https://developer.apple.com/documentation/cloudkit/ckrecordvalue
    @objc public func trackCustomEvent(forKey key: String, value: CKRecordValue?) {
        let record = CKRecord(recordType: "TPHAnalyticsCustomEvent")
        record[key] = value
        record["session"] = CKReference(record: _sessionRecord, action: .deleteSelf)
        
        let database = CKContainer(identifier: _containerID).publicCloudDatabase
        database.save(record) { (savedRecord, error) in
            let success = error == nil
            print("Success saving custom value = \(success)")
        }
    }
    
    /// Adds a screen view event to the TPHAnalyticsScreenViewEvent record type and links it to the current session.
    ///
    /// - Parameter screenName: The name of the screen being viewed.
    @objc public func trackScreenView(_ screenName: String) {
        let record = CKRecord(recordType: "TPHAnalyticsScreenViewEvent")
        record["screenName"] = screenName as NSString
        record["session"] = CKReference(record: _sessionRecord, action: .deleteSelf)
        
        let database = CKContainer(identifier: _containerID).publicCloudDatabase
        database.save(record) { (savedRecord, error) in
            let success = error == nil
            print("Success saving screen view = \(success)")
        }
    }
    
    //MARK: Private
    private enum SessionKey: String {
        case guid = "GUID"
        case date = "Date"
        case device = "device"
        case os = "OS"
        case bundleID = "BundleID"
        case appVersion = "AppVersion"
        case appShortVersion = "AppShortVersion"
    }
    
    private init(containerID: String) {
        func setSessionValue<T: CKRecordValue>(_ value: T?, forKey key: SessionKey) {
            _sessionRecord[key.rawValue] = value
        }
        
        _containerID = containerID
        super.init()
        
        setSessionValue(NSDate(), forKey: .date)
        setSessionValue(_uuid.uuidString as NSString, forKey: .guid)
        setSessionValue(ProcessInfo().operatingSystemVersionString as NSString, forKey: .os)
        setSessionValue(DeviceInfo.retrieveDeviceType() as NSString, forKey: .device)
        
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            setSessionValue(bundleVersion as NSString, forKey: .appVersion)
        }
        
        if let shortBundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            setSessionValue(shortBundleVersion as NSString, forKey: .appVersion)
        }
        
        if let bundleID = Bundle.main.infoDictionary?[""] as? String {
            setSessionValue(bundleID as NSString, forKey: .bundleID)
        }
        
        let database = CKContainer(identifier: _containerID).publicCloudDatabase
        database.save(_sessionRecord) { (sessionRecord, error) in
            let success = error == nil
            print("Success registering the session = \(success), error: \(error?.localizedDescription ?? "none")")
        }
    }
    
    private static var _shared: TPHCloudAnalyticsReporter?
    private let _containerID: String
    private let _uuid = UUID()
    private let _sessionRecord = CKRecord(recordType: "TPHAnalyticsSession")
}


