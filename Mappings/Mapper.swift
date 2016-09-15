//
//  Mapper.swift
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

public final class Mapper {

    private enum State {
        case encoding(Encoder)
        case decoding(Decoder, values: Dictionary<String, Getter>)
    }

    private let state: State

    init(decoder: Decoder, valueMap: Dictionary<String, Getter>) {
        state = .decoding(decoder, values: valueMap)
    }

    init(encoder: Encoder) {
        state = .encoding(encoder)
    }

    private func decode<T>(forKey key: String, decoder: Decoder, values: Dictionary<String, Getter>) -> T? {
        if let getter = values[key] {
            return getter.get()
        }
        return decoder.decode(forKey: key)
    }

    public func map<T>(_ v: inout T, forKey key: String) {
        switch state {
        case .encoding(let enc):
            enc.encode(v, forKey: key)
        case .decoding(let dec, let values):
            guard let vv: T = decode(forKey: key, decoder: dec, values: values) else {
                // TODO: do something more sensible
                fatalError()
            }
            v = vv
        }
    }

    public func map<T>(_ v: inout T!, forKey key: String) {
        var t = v as Optional
        map(&t, forKey: key)
        v = t
    }

    public func map<T>(_ v: inout T?, forKey key: String) {
        switch state {
        case .encoding(let enc):
            if let v = v {
                enc.encode(v, forKey: key)
            }
        case .decoding(let dec, let values):
            v = decode(forKey: key, decoder: dec, values: values)
        }
    }

}
