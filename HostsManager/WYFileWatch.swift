//
//  FileWatch.swift
//  Authorization
//
//  Created by wenyou on 2017/4/27.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

// https://github.com/soh335/FileWatch
public class WYFileWatch {
    // wrap FSEventStreamEventFlags as  OptionSetType
    public struct EventFlag: OptionSet {
        public let rawValue: FSEventStreamEventFlags

        public init(rawValue: FSEventStreamEventFlags) {
            self.rawValue = rawValue
        }

        public static let None                  = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagNone))
        public static let MustScanSubDirs       = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagMustScanSubDirs))
        public static let UserDropped           = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagUserDropped))
        public static let KernelDropped         = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagKernelDropped))
        public static let EventIdsWrapped       = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagEventIdsWrapped))
        public static let HistoryDone           = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagHistoryDone))
        public static let RootChanged           = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagRootChanged))
        public static let Mount                 = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagMount))
        public static let Unmount               = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagUnmount))
        public static let ItemCreated           = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated))
        public static let ItemRemoved           = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved))
        public static let ItemInodeMetaMod      = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemInodeMetaMod))
        public static let ItemRenamed           = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed))
        public static let ItemModified          = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified))
        public static let ItemFinderInfoMod     = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemFinderInfoMod))
        public static let ItemChangeOwner       = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemChangeOwner))
        public static let ItemXattrMod          = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemXattrMod))
        public static let ItemIsFile            = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsFile))
        public static let ItemIsDir             = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsDir))
        public static let ItemIsSymlink         = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsSymlink))
        public static let OwnEvent              = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagOwnEvent))
        public static let ItemIsHardlink        = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsHardlink))
        public static let ItemIsLastHardlink    = EventFlag(rawValue: FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsLastHardlink))
    }

    // wrap FSEventStreamCreateFlags as OptionSetType
    public struct CreateFlag: OptionSet {
        public let rawValue: FSEventStreamCreateFlags

        public init(rawValue: FSEventStreamCreateFlags) {
            self.rawValue = rawValue
        }

        public static let None          = CreateFlag(rawValue: FSEventStreamCreateFlags(kFSEventStreamCreateFlagNone))
        public static let UseCFTypes    = CreateFlag(rawValue: FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes))
        public static let NoDefer       = CreateFlag(rawValue: FSEventStreamCreateFlags(kFSEventStreamCreateFlagNoDefer))
        public static let WatchRoot     = CreateFlag(rawValue: FSEventStreamCreateFlags(kFSEventStreamCreateFlagWatchRoot))
        public static let IgnoreSelf    = CreateFlag(rawValue: FSEventStreamCreateFlags(kFSEventStreamCreateFlagIgnoreSelf))
        public static let FileEvents    = CreateFlag(rawValue: FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents))
        public static let MarkSelf      = CreateFlag(rawValue: FSEventStreamCreateFlags(kFSEventStreamCreateFlagMarkSelf))
    }

    public struct Event {
        public let path: String
        public let flag: EventFlag
        public let eventID: FSEventStreamEventId
    }

    public enum Error: Swift.Error {
        case startFailed
        case streamCreateFailed
        case notContainUseCFTypes
    }

    public typealias EventHandler = (Event) -> Void

    open let eventHandler: EventHandler
    private var eventStream: FSEventStreamRef?

    public init(paths: [String], createFlag: CreateFlag, runLoop: RunLoop, latency: CFTimeInterval, eventHandler: @escaping EventHandler) throws {
        self.eventHandler = eventHandler

        var ctx = FSEventStreamContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)

        if !createFlag.contains(.UseCFTypes) {
            throw Error.notContainUseCFTypes
        }

        guard let eventStream = FSEventStreamCreate(kCFAllocatorDefault,
                                                    WYFileWatch.StreamCallback,
                                                    &ctx,
                                                    paths as CFArray,
                                                    FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
                                                    latency,
                                                    createFlag.rawValue) else {
            throw Error.streamCreateFailed
        }

        FSEventStreamScheduleWithRunLoop(eventStream, runLoop.getCFRunLoop(), CFRunLoopMode.defaultMode.rawValue)
        if !FSEventStreamStart(eventStream) {
            throw Error.startFailed
        }

        self.eventStream = eventStream
        NSLog("init over")
    }

    deinit {
        guard let eventStream = self.eventStream else {
            return
        }
        FSEventStreamStop(eventStream)
        FSEventStreamInvalidate(eventStream)
        FSEventStreamRelease(eventStream)
        self.eventStream = nil
    }

    private static let StreamCallback: FSEventStreamCallback = {(
        streamRef: ConstFSEventStreamRef,
        clientCallBackInfo: UnsafeMutableRawPointer?,
        numEvents: Int,
        eventPaths: UnsafeMutableRawPointer,
        eventFlags: UnsafePointer<FSEventStreamEventFlags>?,
        eventIds: UnsafePointer<FSEventStreamEventId>?) -> Void in
        let `self` = unsafeBitCast(clientCallBackInfo, to: WYFileWatch.self)
        guard let eventPathArray = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] else {
            return
        }
        var eventFlagArray = Array(UnsafeBufferPointer(start: eventFlags, count: numEvents))
        var eventIdArray   = Array(UnsafeBufferPointer(start: eventIds, count: numEvents))

        for i in 0 ..< numEvents {
            let path = eventPathArray[i]
            let flag = eventFlagArray[i]
            let eventID = eventIdArray[i]
            let event = Event(path: path, flag: EventFlag(rawValue: flag), eventID: eventID)
            self.eventHandler(event)
        }
    }
}
