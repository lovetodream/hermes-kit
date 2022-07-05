//
//  FileStorageID.swift
//  
//
//  Created by Timo Zacherl on 30.06.22.
//

/// A hashable and codable File Storage Identifier object.
public struct FileStorageID: Hashable, Codable {
    
    /// A string representation of the identifier
    public let string: String
    
    /// Initializes a File Storage Identifier with the given string.
    /// - Parameter string: The string identifier.
    public init(_ string: String) {
        self.string = string
    }
    
}
