//
//  FileStorage.swift
//  
//
//  Created by Timo Zacherl on 28.06.22.
//

import Foundation

/// - Important: Drivers must implement this.
public protocol FileStorage {
    
    /// The context of the filesystem
    var context: FileStorageContext { get }
    
    /// Resolves the given key and returns a full url.
    /// - Parameter key: Provide the key you want to resolve.
    /// - Returns: The url at which the resource lives.
    func resolve(key: String) -> String
    
    func upload(key: String, data: Data) async throws -> String
    
    func getData(forKey source: String) async throws -> Data?
    
    func copy(fromKey source: String, to destination: String) async throws -> String
    
    func move(fromKey source: String, to destination: String) async throws -> String
    
    func createDirectory(atKey location: String) async throws
    
    func list(contentAtKey location: String) async throws -> [String]
    
    func delete(atKey location: String) async throws
    
    func exists(atKey location: String) async -> Bool
    
}
