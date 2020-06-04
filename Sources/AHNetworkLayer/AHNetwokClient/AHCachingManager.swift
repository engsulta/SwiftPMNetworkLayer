//
//  AHCachingManager.swift
//  AHSuperNetwork
//
//  Created by Ahmed Sultan on 5/30/20.
//

import Foundation

class AHCachingManager {
    static let shared = AHCachingManager()
    
    func write(into fileName: String, data: Data) throws {
        
        try? FileManager.default.createDirectory(at: FileManager.savedResponseDirectory, withIntermediateDirectories: true)
        let fileURL = FileManager.savedResponseDirectory.appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }

    func readData(from fileName: String) -> Data? {
        let fileURL = FileManager.savedResponseDirectory.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }
    
}

public extension FileManager {
    static var documentDirectoryURL: URL {
        return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static var cachesDirectory: URL {
        return `default`.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    static var applicationSupportDirectory: URL {
        return `default`.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
    static var savedResponseDirectory = URL(
        fileURLWithPath: "Saved Responses",
        relativeTo: cachesDirectory
    )
}
