//
//  MappingsTests.swift
//  MappingsTests
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

import XCTest
import ObjSer
@testable import Mappings

class A : NSObject, NSCoding, InitableSerialisable, Mappable {

    var x: Int = 0
    var y: [String]!

    required init(x: Int, y: [String]) {
        self.x = x
        self.y = y
    }

    func mapWith(mapper: Mapper) {
        mapper.map(&x, forKey: "x")
        mapper.map(&y, forKey: "y")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        do {
            try Mappings.decode(self, with: aDecoder)
        }
        catch {
            return nil
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        Mappings.encode(self, with: aCoder)
    }

    required init(deserialiser des: Deserialiser) throws {
        super.init()
        try Mappings.decode(self, with: des)
    }

    func serialiseWith(ser: Serialiser) {
        Mappings.encode(self, with: ser)
    }

}

class B : NSObject, NSCoding, InitableSerialisable, Mappable {

    var x: Int = 0
    var y: Float?
    var z: [String]!

    required init(x: Int, y: Float, z: [String]) {
        self.x = x
        self.y = y
        self.z = z
    }

    static let migrators: [Migrator -> Void] = [
        { m in
            m.migrateKey("y", toKey: "z")
            m.addValue(7.2 as Float, forKey: "y")
        }
    ]

    func mapWith(mapper: Mapper) {
        mapper.map(&x, forKey: "x")
        mapper.map(&y, forKey: "y")
        mapper.map(&z, forKey: "z")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        guard (try? Mappings.decode(self, with: aDecoder)) != nil else { return nil }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        Mappings.encode(self, with: aCoder)
    }

    required init(deserialiser des: Deserialiser) throws {
        super.init()
        try Mappings.decode(self, with: des)
    }

    func serialiseWith(ser: Serialiser) {
        Mappings.encode(self, with: ser)
    }

}

class C : NSObject, NSCoding, InitableSerialisable, Mappable {

    var y: Int?
    var z: [String]!

    required init(y: Int, z: [String]) {
        self.y = y
        self.z = z
    }

    static let migrators: [Migrator -> Void] = [
        { m in
            m.migrateKey("y", toKey: "z")
            m.addValue(7.2 as Float, forKey: "y")
        },
        { m in
            m.migrateKey("y") { (v: Float?) -> Int? in
                v != nil ? Int(v!) : nil
            }
        }
    ]

    func mapWith(mapper: Mapper) {
        mapper.map(&y, forKey: "y")
        mapper.map(&z, forKey: "z")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        guard (try? Mappings.decode(self, with: aDecoder)) != nil else { return nil }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        Mappings.encode(self, with: aCoder)
    }

    required init(deserialiser des: Deserialiser) throws {
        super.init()
        try Mappings.decode(self, with: des)
    }

    func serialiseWith(ser: Serialiser) {
        Mappings.encode(self, with: ser)
    }

}

struct S {

    var s: String!

}

extension S : InitableSerialisable, Mappable {

    mutating func mapWith(mapper: Mapper) {
        mapper.map(&s, forKey: "string")
    }

    init(deserialiser des: Deserialiser) throws {
        try Mappings.decode(&self, with: des)
    }

    func serialiseWith(ser: Serialiser) {
        Mappings.encode(self, with: ser)
    }

}

class MappingsTests: XCTestCase {

    var a: A!
    
    override func setUp() {
        a = A(x: 5, y: ["aoeu", ";qjkx"])
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func eqAB(b: B) {
        XCTAssertEqual(a.x, b.x)
        XCTAssertEqual(a.y, b.z)
        XCTAssertEqual(7.2, b.y)
    }

    func eqAC(c: C) {
        XCTAssertEqual(a.y, c.z)
        XCTAssertEqual(c.y, 7)
    }

    func eqBC(b: B, c: C) {
        XCTAssertEqual(Int(b.y!), c.y!)
        XCTAssertEqual(b.z, c.z)
    }
    
    func testNSCoding() {
        let dataA = NSKeyedArchiver.archivedDataWithRootObject(a)
        NSKeyedUnarchiver.setClass(B.self, forClassName: "MappingsTests.A")
        let b = NSKeyedUnarchiver.unarchiveObjectWithData(dataA)! as! B
        eqAB(b)
        NSKeyedUnarchiver.setClass(C.self, forClassName: "MappingsTests.A")
        let c = NSKeyedUnarchiver.unarchiveObjectWithData(dataA)! as! C
        eqAC(c)
        let dataB = NSKeyedArchiver.archivedDataWithRootObject(b)
        NSKeyedUnarchiver.setClass(C.self, forClassName: "MappingsTests.B")
        let cc = NSKeyedUnarchiver.unarchiveObjectWithData(dataB)! as! C
        eqBC(b, c: cc)
    }

    func testObjSer() {
        let outA = OutputStream()
        ObjSer.serialise(a, to: outA)
        let b: B = try! ObjSer.deserialiseFrom(InputStream(bytes: outA.bytes))
        eqAB(b)
        let c: C = try! ObjSer.deserialiseFrom(InputStream(bytes: outA.bytes))
        eqAC(c)
        let outB = OutputStream()
        ObjSer.serialise(b, to: outB)
        let cc: C = try! ObjSer.deserialiseFrom(InputStream(bytes: outB.bytes))
        eqBC(b, c: cc)
    }

    func testStruct() {
        let s = S(s: "aoeu")
        let out = OutputStream()
        ObjSer.serialise(s, to: out)
        let t: S = try! ObjSer.deserialiseFrom(InputStream(bytes: out.bytes))
        XCTAssertEqual(s.s, t.s)
    }

}
