//
//  FileStorageContext.swift
//  
//
//  Created by Timo Zacherl on 30.06.22.
//

import NIO
import Logging

/// The file storage context object.
public struct FileStorageContext {
    
    /// The configuration for ``FileStorageContext``.
    public let configuration: FileStorageConfiguration
    
    /// The logger used by ``FileStorageContext``.
    public let logger: Logger
    
    /// The event loop used by ``FileStorageContext``.
    public let eventLoop: EventLoop
    
    
    /// A publicly available initializer for ``FileStorageContext``.
    /// - Parameters:
    ///   - configuration: The configuration for ``FileStorageContext``.
    ///   - logger: The logger used by ``FileStorageContext``.
    ///   - eventLoop: The event loop used by ``FileStorageContext``.
    public init(configuration: FileStorageConfiguration,
                logger: Logger,
                eventLoop: EventLoop) {
        self.configuration = configuration
        self.logger = logger
        self.eventLoop = eventLoop
    }
    
}
