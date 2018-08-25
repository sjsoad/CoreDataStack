//
//  FileManager.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 25.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import Foundation

extension FileManager {
    
    var documentDirectoryURL: URL {
        guard let documentsURL = urls(for: .documentDirectory, in: .userDomainMask).first else {
            let log = String(format: "E | %@:%@/%@ Could not fetch Documents directory",
                             String(describing: self), #file, #line)
            fatalError(log)
        }
        return documentsURL
    }
    
}
