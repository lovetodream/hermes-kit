//
//  FileStorageConfigurationFactory.swift
//  
//
//  Created by Timo Zacherl on 30.06.22.
//

/// A factory to make a ``FileStorageConfiguration``.
public struct FileStorageConfigurationFactory {
    
    /// Creates a new ``FileStorageConfiguration`` object.
    public let make: () -> FileStorageConfiguration
    
    /// Initializes the ``FileStorageConfigurationFactory`` with the provided make closure.
    /// - Parameter make: The closure executing on ``make``.
    public init(make: @escaping () -> FileStorageConfiguration) {
        self.make = make
    }
    
}
