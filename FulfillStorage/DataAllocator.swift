//
//  DataAllocator.swift
//  FulfillStorage
//
//  Created by 周 軼飛 on 2019/11/14.
//  Copyright © 2019 ZHOU. All rights reserved.
//

import UIKit

struct DataAllocator {

    enum Unit: Int, CustomStringConvertible {
        case bits = 0
        case bytes
        case kilobytes
        case megabytes
        case gigabytes

        var description: String {
            switch self {
            case .bits:
                return "bits"
            case .bytes:
                return "bytes"
            case .kilobytes:
                return "kilobytes"
            case .megabytes:
                return "megabytes"
            case .gigabytes:
                return "gigabytes"
            @unknown default:
                return "unknown"
            }
        }
    }

    private(set) var unit: Unit

    init(unit: Unit) {
        self.unit = unit
    }

    func allocateMemory(of size: Int) -> [UInt8] {
        let buffer = [UInt8](repeating: 0,
                             count: DataAllocator.size(of: size,
                                                       from: unit,
                                                       to: .bytes))
        return buffer
    }

    static func allocateMemory(of size: Int, unit: Unit) -> [UInt8] {
        let allocator = DataAllocator(unit: unit)
        return allocator.allocateMemory(of: size)
    }

    static func size(of size: Int, from fromUnit: Unit, to toUnit: Unit) -> Int {
        let (oprt, multiplier) = conversion(from: fromUnit, to: toUnit)
        return oprt(size, multiplier)
    }

    static func conversion(from fromUnit: Unit, to toUnit: Unit) -> (operator: (Int, Int) -> Int, multiplier: Int) {
        switch fromUnit.rawValue {
        case 0...toUnit.rawValue:
            return (/, multiplier(from: toUnit, to: fromUnit))
        case (toUnit.rawValue + 1)...:
            return (*, multiplier(from: fromUnit, to: toUnit))
        default:
            assertionFailure("unable to convert from \(fromUnit) to \(toUnit)")
            return (*, 1)
        }
    }

    private static func multiplier(from fromUnit: Unit, to toUnit: Unit) -> Int {
        if fromUnit == toUnit { return 1 }
        guard fromUnit.rawValue > toUnit.rawValue,
            let lowerUnit = Unit(rawValue: fromUnit.rawValue - 1) else {
                assertionFailure("unable to get multiplier from \(fromUnit) to \(toUnit)")
                return 1
        }
        return 1024 * multiplier(from: lowerUnit, to: toUnit)
    }
}
