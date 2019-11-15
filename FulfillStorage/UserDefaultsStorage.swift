//
//  UserDefaultsStorage.swift
//  FulfillStorage
//
//  Created by 周 軼飛 on 2019/11/14.
//  Copyright © 2019 ZHOU. All rights reserved.
//

import UIKit

final class UserDefaultsStorage {

    static func udSaveData(unit: DataAllocator.Unit, size: Int, frequency: Int? = nil) {
        let data = DataAllocator.allocateMemory(of: size, unit: unit)
        let keyName = "\(size)\(unit)" + (frequency?.description ?? "0")
        UserDefaults.standard.set(data, forKey: keyName)
    }

}
