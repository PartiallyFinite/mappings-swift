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

extension NSCoder : Decoder {

    public func decodeForKey<R>(key: String) -> R? {
        func decode() -> Any? {
            switch R.self {
            case is Bool.Type: return decodeBoolForKey(key)
            case is Int.Type: return decodeIntegerForKey(key)
            case is Int32.Type: return decodeInt32ForKey(key)
            case is Int64.Type: return decodeInt64ForKey(key)
            case is Float.Type: return decodeFloatForKey(key)
            case is Double.Type: return decodeDoubleForKey(key)
            default:
                if let v = decodeObjectForKey(key) {
                    if let v = v as? R {
                        return v
                    }
                    fatalError("Type mismatch: value \(v) is not of expected type \(R.self).")
                }
                return nil
            }
        }
        if containsValueForKey(key), let v = decode() {
            return (v as! R)
        }
        return nil
    }

}

extension NSCoder : Encoder {

    public func encode<T>(v: T, forKey key: String) {
        switch T.self {
        case is Bool.Type: encodeBool(v as! Bool, forKey: key)
        case is Int.Type: encodeInteger(v as! Int, forKey: key)
        case is Int32.Type: encodeInt32(v as! Int32, forKey: key)
        case is Int64.Type: encodeInt64(v as! Int64, forKey: key)
        case is Float.Type: encodeFloat(v as! Float, forKey: key)
        case is Double.Type: encodeDouble(v as! Double, forKey: key)
        case is String.Type: encodeObject(v as! String, forKey: key)
        default:
            if let v = v as? AnyObject {
                encodeObject(v, forKey: key)
            }
            else {
                fatalError("Unsupported type \(T.self).")
            }
        }
    }
    
}
