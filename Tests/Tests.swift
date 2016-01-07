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
@testable import Mappings

class A : NSObject, NSCoding, Mappable {

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
        guard (try? Mappings.decode(self, with: aDecoder)) != nil else { return nil }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        Mappings.encode(self, with: aCoder)
    }

    override class func classForKeyedUnarchiver() -> AnyClass {
        return B.self
    }

}

class B : NSObject, NSCoding, Mappable {

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
    
}

class MappingsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testA() {
        let a = A(x: 5, y: ["aoeu", ";qjkx"])
        let data = NSKeyedArchiver.archivedDataWithRootObject(a)
        let b = NSKeyedUnarchiver.unarchiveObjectWithData(data)! as! B
        XCTAssertEqual(a.x, b.x)
        XCTAssertEqual(a.y, b.z)
        XCTAssertEqual(7.2, b.y)
    }

}
