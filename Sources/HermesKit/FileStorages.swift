//
//  FileStorages.swift
//  
//
//  Created by Timo Zacherl on 30.06.22.
//

import NIO
import NIOConcurrencyHelpers
import Logging

/// A final class to store a set of ``FileStorageDriver``'s, configurations and identifiers. It also provides access to them.
public final class FileStorages {
    
    /// A non-blocking reference to File IO.
    public let fileIO: NonBlockingFileIO
    
    // MARK: - private
    
    /// The identifier of the default ``FileStorageDriver``.
    private var defaultID: FileStorageID?
    
    /// A pair of file storage identifiers and their corresponding configurations.
    private var configurations: [FileStorageID: FileStorageConfiguration]
    
    /// A pair of file storage identifiers and their corresponding configurations.
    private var drivers: [FileStorageID: FileStorageDriver]
    
    /// A lock to synchronize filesystem access across multiple threads.
    private var lock: Lock
    
    /// It returns an existing configuration for an identifier if one exists.
    /// - Parameter id: The file storage identifier to get the file storage configuration.
    /// - Returns: The file storage configuration for the given identifier.
    /// - Throws: A fatal error if no ``FileStorageConfiguration`` is registered with the provided id.
    private func requireConfiguration(for id: FileStorageID) -> FileStorageConfiguration {
        guard let configuration = configurations[id] else {
            fatalError("No file storage configuration registered for '\(id)'.")
        }
        return configuration
    }
    
    /// Returns the default ``FileStorageID`` if it exists.
    /// - Returns: The default file storage id.
    /// - Throws: A fatal error if no default ``FileStorageID`` is configured.
    private func requireDefaultID() -> FileStorageID {
        guard let id = defaultID else {
            fatalError("No default file storage configured.")
        }
        return id
    }
    
    // MARK: - public API
    
    /// Returns a set of file storage identifiers stored in the given instance of ``FileStorages``.
    /// - Returns: A set of file storage identifiers.
    public func ids() -> Set<FileStorageID> {
        return self.lock.withLock {
            Set(self.configurations.keys)
        }
    }
    
    /// Initializes a ``FileStorages`` object with the provided non-blocking file IO.
    /// - Parameter fileIO: The non-blocking file IO.
    public init(fileIO: NonBlockingFileIO) {
        self.fileIO = fileIO
        self.configurations = .init()
        self.drivers = .init()
        self.lock = .init()
    }
    
    /// Registers a file storage configuration using a factory object with a file storage id, which can optionally be marked as the default driver.
    /// - Parameters:
    ///   - factory: The configuration factory used to make the configuration.
    ///   - id: The file storage identifier for the configuration.
    ///   - isDefault: Indicates if the configuration should be the default one from now on.
    public func use(_ factory: FileStorageConfigurationFactory, as id: FileStorageID, isDefault: Bool = false) {
        use(factory.make(), as: id, isDefault: isDefault)
    }
    
    /// Registers a file storage configuration with a file storage id, which can optionally be marked as the default driver.
    /// - Parameters:
    ///   - config: The configuration to save.
    ///   - id: The file storage identifier for the configuration.
    ///   - isDefault: Indicates if the configuration should be the default one from now on.
    public func use(_ config: FileStorageConfiguration, as id: FileStorageID, isDefault: Bool = false) {
        lock.lock()
        defer { lock.unlock() }
        configurations[id] = config
        if isDefault {
            defaultID = id
        }
    }
    
    /// Makes a specific file storage configuration the default one.
    /// - Parameter id: The identifier for the configuration which should be marked as default.
    public func `default`(to id: FileStorageID) {
        lock.lock()
        defer { lock.unlock() }
        defaultID = id
    }
    
    /// Returns the file storage configuration for the given identifier if available.
    /// - Parameter id: The identifier for the configuration you want to get, if you provide non, the default identifier will be used.
    /// - Returns: The file storage configuration if available.
    /// - Throws: It might throw a fatal error inside ``requireDefaultID`` if no id is provided and the default id is not set.
    public func configuration(for id: FileStorageID? = nil) -> FileStorageConfiguration? {
        lock.lock()
        defer { lock.unlock() }
        return configurations[id ?? requireDefaultID()]
    }
    
    /// Returns a file storage for a given identifier using a logger and an event loop object.
    /// - Parameters:
    ///   - id: The identifier for the file storage you want to get.
    ///   - logger: The logger you want to use, well to log the process on.
    ///   - eventLoop: The event loop used to create the context for the storage.
    /// - Returns: A file storage made using an existing or new driver with the newly created context.
    public func fileStorage(_ id: FileStorageID? = nil, logger: Logger, on eventLoop: EventLoop) -> FileStorage? {
        lock.lock()
        defer { lock.unlock() }
        let id = id ?? requireDefaultID()
        var logger = logger
        logger[metadataKey: "file-storage-id"] = .string(id.string)
        let configuration = requireConfiguration(for: id)
        let context = FileStorageContext(configuration: configuration, logger: logger, eventLoop: eventLoop)
        let driver: FileStorageDriver
        if let existingDriver = drivers[id] {
            driver = existingDriver
        } else {
            let newDriver = configuration.makeDriver(for: self)
            drivers[id] = newDriver
            driver = newDriver
        }
        return driver.makeStorage(with: context)
    }
    
    /// Reinitializes a file storage driver for a given identifier.
    /// - Parameter id: The id of the file storage driver.
    public func reinitialize(_ id: FileStorageID? = nil) {
        lock.lock()
        defer { lock.unlock() }
        let id = id ?? requireDefaultID()
        if let driver = drivers[id] {
            drivers[id] = nil
            driver.shutdown()
        }
    }
    
    /// Shuts the instance and all its drivers down.
    public func shutdown() {
        lock.lock()
        defer { lock.unlock() }
        for driver in drivers.values {
            driver.shutdown()
        }
        drivers = .init()
    }
    
}
