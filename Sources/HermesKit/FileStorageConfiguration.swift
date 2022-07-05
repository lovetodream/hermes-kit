//
//  FileStorageConfiguration.swift
//  
//
//  Created by Timo Zacherl on 30.06.22.
//

/// The configuration of a file storage.
public protocol FileStorageConfiguration {
    
    /// Creates a new driver using the ``FileStorages`` object.
    ///
    /// The driver will be stored in that storage.
    func makeDriver(for fileStorages: FileStorages) -> FileStorageDriver
    
}
