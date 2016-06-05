//
//  EID.swift
//  DataBasis
//
//  Created by Jason Jobe on 4/17/16.
//  Copyright © 2016 WildThink. All rights reserved.
//

import Foundation

public struct EID64: Comparable
{
    var type: UInt32
    var ident: UInt32

    init (type: UInt32, id: UInt32) {
        self.type = type
        self.ident = id
    }

    init (_ int64: Int64) {
        type = UInt32(int64 >> 32)
        ident =  UInt32((int64 << 32) >> 32)
    }

    var int64: Int64 {
        get { return (Int64(type) << 32) | Int64(ident) }
    }

    var uint64: UInt64 {
        get { return (UInt64(type) << 32) | UInt64(ident) }
    }

    var min_instance_id: Int64 { return Int64(type) }
    var max_instance_id: Int64 { return Int64(type + UInt32.max) }
}

public func == (e1: EID64, e2: EID64) -> Bool { return e1.int64 == e2.int64 }
public func < (lhs: EID64, rhs: EID64) -> Bool {
    return lhs.uint64 < rhs.uint64
}

public struct EID32: Comparable
{
    var type: UInt16
    var ident: UInt16

    init (type: UInt16, id: UInt16) {
        self.type = type
        self.ident = id
    }

    init (_ int32: UInt32) {
        type = UInt16(int32 >> 16)
        ident =  UInt16((int32 << 16) >> 16)
    }

    var uint32: UInt32 {
        get { return (UInt32(type) << 16) | UInt32(ident) }
    }

    var int32: Int32 {
        get { return (Int32(type) << 16) | Int32(ident) }
    }

    var min_instance_id: Int32 { return Int32(type) }
    var max_instance_id: Int32 { return Int32(type + UInt16.max) }
}

public func == (e1: EID32, e2: EID32) -> Bool { return e1.int32 == e2.int32 }
public func < (lhs: EID32, rhs: EID32) -> Bool {
    return lhs.uint32 < rhs.uint32
}

extension Int64 {
    var hiBits: Int32 {
        get { return Int32((self >> 32)) }
    }
    func clearHi() -> Int64 {
        return (self & 0x00000000FFFFFFFF)
    }
    var loBits: UInt32 {
        get { return UInt32(self & 0x00000000FFFFFFFF) }
    }
}
