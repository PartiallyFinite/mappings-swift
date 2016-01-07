//
//  Migrator.swift
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

public final class Migrator {

    private let decoder: Decoder

    private(set) var values = Dictionary<String, Void -> Any?>()

    init(decoder: Decoder) {
        self.decoder = decoder
    }

    /// Add value `v` for `key`. If a value already exists for `key`, it is overwritten.
    public func addValue<V>(v: V, forKey key: String) {
        values[key] = { v }
    }

    private func getterForKey<V>(key: String) -> (Void -> V?) {
        if let g = values[key] { return g as! (Void -> V?) }
        return {
            self.decoder.decodeForKey(key) as V?
        }
    }

    /// Transform the value for `key` using `transformer`, storing it in `toKey`, or `key` if not provided.
    public func migrateKey<From, To>(key: String, toKey: String? = nil, transformer: From -> To) {
        let toKey = toKey ?? key
        let getter = getterForKey(key) as (Void -> From?)
        values[key] = nil
        values[toKey] = {
            if let v = getter() {
                return Optional(transformer(v))
            }
            return nil
        }
    }

    /// Migrate the value for `key` to `toKey`.
    public func migrateKey(key: String, toKey: String) {
        precondition(key != toKey, "Cannot migrate from key '\(key)' to itself.")
        values[toKey] = getterForKey(key)
        values[key] = nil
    }

}
