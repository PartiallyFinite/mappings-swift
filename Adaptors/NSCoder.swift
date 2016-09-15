//
//  NSCoder.swift
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

import Mappings
import Foundation

extension NSCoder : Decoder {

    public func decode<R>(forKey key: String) -> R? {
        func decode() -> Any? {
            switch R.self {
            case is Bool.Type: return decodeBool(forKey: key)
            case is Int.Type: return decodeInteger(forKey: key)
            case is Int32.Type: return decodeInt32(forKey: key)
            case is Int64.Type: return decodeInt64(forKey: key)
            case is Float.Type: return decodeFloat(forKey: key)
            case is Double.Type: return decodeDouble(forKey: key)
            default:
                if let v = decodeObject(forKey: key) {
                    if let v = v as? R {
                        return v
                    }
                    fatalError("Type mismatch: value \(v) is not of expected type \(R.self).")
                }
                return nil
            }
        }
        if containsValue(forKey: key), let v = decode() {
            return (v as! R)
        }
        return nil
    }

}

extension NSCoder : Encoder {

    public func encode<T>(_ v: T, forKey key: String) {
        switch T.self {
        case is Bool.Type: self.encode(v as! Bool, forKey: key)
        case is Int.Type: self.encode(v as! Int, forKey: key)
        case is Int32.Type: self.encode(v as! Int32, forKey: key)
        case is Int64.Type: self.encode(v as! Int64, forKey: key)
        case is Float.Type: self.encode(v as! Float, forKey: key)
        case is Double.Type: self.encode(v as! Double, forKey: key)
        case is String.Type: self.encode(v as! String, forKey: key)
        default:
            (self.encode as (Any?, String) -> Void)(v, key)
        }
    }
    
}
