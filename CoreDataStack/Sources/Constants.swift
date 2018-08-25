//
//  Constants.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 25.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import Foundation

public typealias SetupCompletion = () -> Void

struct SetupFlags: OptionSet {
    public let rawValue: Int
    public init(rawValue:Int) {
        self.rawValue = rawValue
    }
    
    static let none = SetupFlags(rawValue: 0)
    static let base = SetupFlags(rawValue: 1)
    static let mainPSC = SetupFlags(rawValue: 2)
    static let writePSC = SetupFlags(rawValue: 4)
    static let mainMOC = SetupFlags(rawValue: 8)
    
    static let done : SetupFlags = [.base, .mainPSC, .writePSC, .mainMOC]
}
