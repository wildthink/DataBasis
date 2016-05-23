//
//  SimpleCoder.swift
//  DataBasis
//
//  Created by Jason Jobe on 5/21/16.
//  Copyright © 2016 WildThink. All rights reserved.
//
// Thanks to some ideas from
// https://github.com/PartiallyFinite/mappings-swift/blob/develop/Mappings/Mapper.swift
// NSCoder sans relationships
import Cocoa

/**
 These Extensions provide an NSCoder interface for NSDictionary and NSCoder extensions to make
 mapping values to and from an NSCoder easier and cleaner.
 */

public protocol SimpleCoder {

    func map<T>(decode: Bool, inout v: T?, forKey key: String)
    func map<T>(decode: Bool, inout v: T!, forKey key: String)
    func map<T>(decode: Bool, inout v: T, forKey key: String)

    func map (decode: Bool, inout v: Int32, forKey key: String)
    func map (decode: Bool, inout v: Int64, forKey key: String)
    func map (decode: Bool, inout v: Float, forKey key: String)
    func map (decode: Bool, inout v: Double, forKey key: String)

//    func simple_encode<T> (inout v: T, forKey key: String)
//    func simple_decode<T> (inout v: T, forKey key: String)

}

//public extension SimpleCoder {
//    func simple_encode<T> (inout v: T, forKey key: String) {
//        map (false, v: &v, forKey: key)
//    }
//}

/** NSCoder Extensions for SimpleCoder
*/

extension NSCoder: SimpleCoder {}

public extension SimpleCoder where Self: NSCoder {

    public func map<T>(decode: Bool, inout v: T, forKey key: String) {
        if decode {
            v = self.decodeObjectForKey(key) as! T
        }
        else {
            self.encodeObject(v as? AnyObject, forKey: key)
        }
    }

    public func map<T>(decode: Bool, inout v: T!, forKey key: String) {
        var t = v as Optional
        map(decode, v: &t, forKey: key)
        v = t
    }

    public func map<T>(decode: Bool, inout v: T?, forKey key: String) {
        if decode {
            v = self.decodeObjectForKey(key) as? T
        }
        else {
            self.encodeObject(v as? AnyObject, forKey: key)
        }
    }
}

/** NSDictionary Extensions for SimpleCoder
 */

extension NSDictionary: SimpleCoder {}

public extension SimpleCoder where Self: NSDictionary {

    public func map (decode: Bool, inout v: Int32, forKey key: String) {
        var num: NSNumber?
        map(decode, v: &num, forKey: key)
        v = num?.intValue ?? 0
    }

    public func map (decode: Bool, inout v: Int64, forKey key: String) {
        var num: NSNumber?
        map(decode, v: &num, forKey: key)
        v = Int64(num?.integerValue ?? 0)
    }

    public func map (decode: Bool, inout v: Float, forKey key: String) {
        var num: NSNumber?
        map(decode, v: &num, forKey: key)
        v = num?.floatValue ?? 0
    }

    public func map (decode: Bool, inout v: Double, forKey key: String) {
        var num: NSNumber?
        map(decode, v: &num, forKey: key)
        v = num?.doubleValue ?? 0
    }

    public func map<T>(decode: Bool, inout v: T, forKey key: String) {
        if decode {
            v = self.objectForKey(key) as! T
        }
        else {
            Swift.print ("Error in \(#function)")
        }
    }

    public func map<T>(decode: Bool, inout v: T!, forKey key: String) {
        var t = v as Optional
        map(decode, v: &t, forKey: key)
        v = t
    }

    public func map<T>(decode: Bool, inout v: T?, forKey key: String) {
        if decode {
            v = self.objectForKey(key) as? T
        }
        else {
            Swift.print ("Error in \(#function)")
        }
    }
}

public extension SimpleCoder where Self: NSMutableDictionary {

    public func map (decode: Bool, inout v: Int32, forKey key: String) {
        var num: NSNumber?
        map(decode, v: &num, forKey: key)
        v = num?.intValue ?? 0
    }

    public func map<T>(decode: Bool, inout v: T, forKey key: String) {
        if decode {
            v = self.objectForKey(key) as! T
        }
        else {
            self.setObject(v as! AnyObject, forKey:key)
        }
    }

    public func map<T>(decode: Bool, inout v: T!, forKey key: String) {
        var t = v as Optional
        map(decode, v: &t, forKey: key)
        v = t
    }

    public func map<T>(decode: Bool, inout v: T?, forKey key: String) {
        if decode {
            v = self.objectForKey(key) as? T
        }
        else {
            if let v = v {
                self.setObject(v as! AnyObject, forKey:key)
            }
        }
    }

}
