//
//  FileStorageDriver.swift
//  
//
//  Created by Timo Zacherl on 30.06.22.
//

/// A protocol to create a ``FileStorage`` with a given context.
public protocol FileStorageDriver {
    
    /// Creates a ``FileStorage`` with a given context.
    /// - Parameter context: The context used to make the ``FileStorage``.
    /// - Returns: The file storage created using the given context.
    func makeStorage(with context: FileStorageContext) -> FileStorage
    
    /// Gracefully shuts the driver down.
    func shutdown()
    
}
