//
//  Mappings.swift
//  Mappings
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Greg Omelaenko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

public protocol Mappable {

    mutating func map(with mapper: Mapper)

    static var migrators: [(Migrator) -> Void] { get }

}

extension Mappable {

    public static var migrators: [(Migrator) -> Void] {
        return []
    }

    /// `migrators.count`
    public final static var mappingVersion: Int {
        return migrators.count
    }

}

public protocol Decoder {

    func decode<R>(forKey key: String) -> R?

}

public protocol Encoder {

    func encode<T>(_ v: T, forKey key: String)

}

public final class Mappings {

    public enum DecodeError : Error {
        case newerVersion(type: Mappable.Type, archiveVersion: Int)
    }

    fileprivate static let versionKey = "__mappings_ver"

    /// - Throws: `Mappings.DecodeError`
    @inline(__always)
    public class func decode(_ v: Mappable & AnyObject, with decoder: Decoder) throws {
        var v = v as Mappable
        try _decode(&v, with: decoder)
    }

    /// - Throws: `Mappings.DecodeError`
    @inline(__always)
    public class func decode<T : Mappable>(_ v: inout T, with decoder: Decoder) throws {
        var tmp = v as Mappable
        try _decode(&tmp, with: decoder)
        v = tmp as! T
    }

    /// - Throws: `Mappings.DecodeError`
    fileprivate class func _decode(_ v: inout Mappable, with decoder: Decoder) throws {
        let archiveVer = decoder.decode(forKey: versionKey) ?? 0
        let currentVer = type(of: v).mappingVersion
        guard archiveVer <= currentVer else {
            throw DecodeError.newerVersion(type: type(of: v), archiveVersion: archiveVer)
        }
        let m = Migrator(decoder: decoder)
        for mig in type(of: v).migrators[archiveVer..<currentVer] {
            mig(m)
        }
        v.map(with: Mapper(decoder: decoder, valueMap: m.values))
    }

    @inline(__always)
    public class func encode(_ v: Mappable & AnyObject, with encoder: Encoder) {
        _encode(v, with: encoder)
    }

    @inline(__always)
    public class func encode(_ v: Mappable, with encoder: Encoder) {
        _encode(v, with: encoder)
    }

    fileprivate class func _encode(_ v: Mappable, with encoder: Encoder) {
        let currentVer = type(of: v).mappingVersion
        if currentVer > 0 {
            encoder.encode(currentVer, forKey: versionKey)
        }
        var v = v
        v.map(with: Mapper(encoder: encoder))
    }

}
