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

    mutating func mapWith(mapper: Mapper)

    static var migrators: [Migrator -> Void] { get }

}

extension Mappable {

    public static var migrators: [Migrator -> Void] {
        return []
    }

    /// `migrators.count`
    public final static var mappingVersion: Int {
        return migrators.count
    }

}

public protocol Decoder {

    func decodeForKey<R>(key: String) -> R?

}

public protocol Encoder {

    func encode<T>(v: T, forKey key: String)

}

public final class Mappings {

    public enum DecodeError : ErrorType {
        case NewerVersion(type: Mappable.Type, archiveVersion: Int)
    }

    private static let versionKey = "__mappings_ver"

    /// - Throws: `Mappings.DecodeError`
    @inline(__always)
    public class func decode(v: protocol<Mappable, AnyObject>, with decoder: Decoder) throws {
        var v = v as Mappable
        try _decode(&v, with: decoder)
    }

    /// - Throws: `Mappings.DecodeError`
    @inline(__always)
    public class func decode<T : Mappable>(inout v: T, with decoder: Decoder) throws {
        var tmp = v as Mappable
        try _decode(&tmp, with: decoder)
        v = tmp as! T
    }

    /// - Throws: `Mappings.DecodeError`
    private class func _decode(inout v: Mappable, with decoder: Decoder) throws {
        let archiveVer = decoder.decodeForKey(versionKey) ?? 0
        let currentVer = v.dynamicType.mappingVersion
        guard archiveVer <= currentVer else {
            throw DecodeError.NewerVersion(type: v.dynamicType, archiveVersion: archiveVer)
        }
        let m = Migrator(decoder: decoder)
        for mig in v.dynamicType.migrators[archiveVer..<currentVer] {
            mig(m)
        }
        v.mapWith(Mapper(decoder: decoder, valueMap: m.values))
    }

    @inline(__always)
    public class func encode(v: protocol<Mappable, AnyObject>, with encoder: Encoder) {
        _encode(v, with: encoder)
    }

    @inline(__always)
    public class func encode(v: Mappable, with encoder: Encoder) {
        _encode(v, with: encoder)
    }

    private class func _encode(v: Mappable, with encoder: Encoder) {
        let currentVer = v.dynamicType.mappingVersion
        if currentVer > 0 {
            encoder.encode(currentVer, forKey: versionKey)
        }
        var v = v
        v.mapWith(Mapper(encoder: encoder))
    }

}
