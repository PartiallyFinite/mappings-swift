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

struct Getter {

    fileprivate enum State {
        case key(key: String, decoder: Decoder)
        case ready(get: () -> Any?)
    }
    fileprivate var state: State
    fileprivate var transformers = ContiguousArray<(Any?) -> Any?>()

    fileprivate init(key: String, decoder: Decoder) {
        state = .key(key: key, decoder: decoder)
    }

    fileprivate init<V>(value: V) {
        state = .ready(get: { value })
    }

    fileprivate mutating func addTransformer<From, To>(_ f: @escaping (From?) -> To?) {
        if case .key(let key, let decoder) = state {
            state = .ready(get: {
                decoder.decode(forKey: key) as From?
            })
        }
        transformers.append { v in
            f(v as! From?)
        }
    }

    func get<T>() -> T? {
        switch state {
        case .key(key: let key, decoder: let decoder):
            assert(transformers.isEmpty, "Getter should not have any transformers if initial type is unresolved.")
            return decoder.decode(forKey: key) as T?
        case .ready(get: let getter):
            return transformers.reduce(getter()) { (v, f) in f(v) } as! T?
        }
    }

}

public final class Migrator {

    fileprivate let decoder: Decoder

    fileprivate(set) var values = Dictionary<String, Getter>()

    init(decoder: Decoder) {
        self.decoder = decoder
    }

    @available(*, unavailable, renamed: "add(value:forKey:)")
    public func addValue<V>(_ v: V, forKey key: String) { fatalError() }

    /// Add value `v` for `key`. If a value already exists for `key`, it is overwritten.
    public func add<V>(value v: V, forKey key: String) {
        values[key] = Getter(value: v)
    }

    fileprivate func getter(forKey key: String) -> Getter {
        return values[key] ?? Getter(key: key, decoder: decoder)
    }

    @available(*, unavailable, renamed: "migrate(key:toKey:transformer:)")
    public func migrateKey<From, To>(_ key: String, toKey: String? = nil, transformer: (From?) -> To?) {}

    /// Transform the value for `key` using `transformer`, storing it in `toKey`, or `key` if not provided.
    public func migrate<From, To>(key: String, toKey: String? = nil, transformer: @escaping (From?) -> To?) {
        let toKey = toKey ?? key
        var g = getter(forKey: key)
        values[key] = nil
        g.addTransformer(transformer)
        values[toKey] = g
    }

    @available(*, unavailable, renamed: "migrate(key:toKey:)")
    public func migrateKey(_ key: String, toKey: String) {}

    /// Migrate the value for `key` to `toKey`.
    public func migrate(key: String, toKey: String) {
        precondition(key != toKey, "Cannot migrate from key '\(key)' to itself.")
        values[toKey] = getter(forKey: key)
        values[key] = nil
    }

}
