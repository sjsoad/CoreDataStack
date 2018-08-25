//
//  Bundle.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 25.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import Foundation

extension Bundle {
    
    var appName: String {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            let log = String(format: "E | %@:%@/%@ Unable to fetch CFBundleName from main bundle",
                             String(describing: self), #file, #line)
            fatalError(log)
        }
        return appName.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }
    
}
