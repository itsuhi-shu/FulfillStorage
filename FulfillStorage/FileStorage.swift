//
//  FileStorage.swift
//  FulfillStorage
//
//  Created by 周 軼飛 on 2019/11/14.
//  Copyright © 2019 ZHOU. All rights reserved.
//

import UIKit

final class FileStorage {

    static func fileStorage(data: [UInt8], namePrefix: String, nameSuffix: String) throws -> String {
        let content = Data(bytes: data, count: data.count)
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileName = namePrefix + "_filestorage_" + nameSuffix
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        try content.write(to: fileURL)
        return fileName
    }

    static func fileStorage(unit: DataAllocator.Unit, size: Int, frequency: Int? = nil) throws {
        let data = DataAllocator.allocateMemory(of: size, unit: unit)
        let fileName = try fileStorage(
            data: data,
            namePrefix: "\(size)\(unit)",
            nameSuffix: frequency?.description ?? "0"
        )
        print("file saved: \(fileName)")
    }

}
