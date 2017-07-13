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
    @objc public static let shared: TPHCloudAnalyticsReporter = TPHCloudAnalyticsReporter()
    
    public func setCustomEvent<T>(forKey key: TPHAnalyticsCustomKey, value: T?) {
        let record = CKRecord(recordType: "TPHAnalyticsCustomEvent")
        record[key.rawValue] = value as? CKRecordValue
        record["session"] = CKReference(record: _sessionRecord, action: .deleteSelf)
        
        let database = CKContainer.default().publicCloudDatabase
        database.save(record) { (savedRecord, error) in
            let success = error == nil
            print("Success = \(success)")
        }
    }
    
    //MARK: Private
    override private init() {
        func setSessionValue<T: CKRecordValue>(_ value: T?, forKey key: TPHAnalyticsSessionKey) {
            _sessionRecord[key.rawValue] = value
        }
        
        super.init()
        
        setSessionValue(NSDate(), forKey: .date)
        setSessionValue(_uuid.uuidString as NSString, forKey: .GUID)
        setSessionValue(ProcessInfo().operatingSystemVersionString as NSString, forKey: .OS)
        setSessionValue(DeviceInfo.retrieveDeviceType() as NSString, forKey: .device)
        
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            setSessionValue(bundleVersion as NSString, forKey: .appVersion)
        }
        
        if let shortBundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            setSessionValue(shortBundleVersion as NSString, forKey: .appVersion)
        }
        
        let database = CKContainer.default().publicCloudDatabase
        database.save(_sessionRecord) { (sessionRecord, error) in
            let success = error == nil
            print("Success = \(success), error: \(error?.localizedDescription ?? "unknown")")
            
            let query = CKQuery(recordType: "TPHAnalyticsSession", predicate: NSPredicate(value: true))
            database.perform(query, inZoneWith: nil, completionHandler: { (returnRecords, error) in
                guard error == nil else {
                    print("error fetching all the records: \(error!.localizedDescription)")
                    return
                }
                
                let records = returnRecords ?? [CKRecord]()
                print("there were \(records.count) records")
            })
        }
    }
    
    private let _uuid = UUID()
    private let _sessionRecord = CKRecord(recordType: "TPHAnalyticsSession")
}


