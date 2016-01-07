# Mappings

**Warning: this is a development version, and has not been sufficiently tested to be considered safe for production use.**

[![GitHub license](https://img.shields.io/github/license/PartiallyFinite/mappings-swift.svg)](https://github.com/PartiallyFinite/mappings-swift/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/PartiallyFinite/mappings-swift.svg)](https://github.com/PartiallyFinite/mappings-swift/releases)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

`NSCoding`-style keyed serialisation APIs provide great flexibility with their separate encode and decode functions, which is often unnecessary and results in duplicated code in simple objects. It is also complex to correctly handle versioning in these objects.

Mappings aims to address both of these problems, by providing a mapping API that combines the encode and decode functions into one, and a simple object versioning system.

## Usage

To use Mappings, simply add conformance to the `Mappable` protocol in addition to the serialisation protocol you use. Then, implement `mapWith`, and replace your implementations of your encoding and decoding functions with calls to `Mappings.encode` and `Mappings.decode`, respectively:

```swift
class A : NSObject, NSCoding, Mappable {

    var x: Int = 0
    var y: [String]!

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

}
```

Now, say the properties of class `A` from the previous example change as follows:

```swift
var x: Int = 0
var y: Float?
var z: [String]!
```

Simply update the `mapWith` function to correctly reflect the new properties:

```swift
func mapWith(mapper: Mapper) {
    mapper.map(&x, forKey: "x")
    mapper.map(&y, forKey: "y")
    mapper.map(&z, forKey: "z")
}
```

And, add a `migrators` property to the class, defining the migration from the old properties to the new:

```swift
static let migrators: [Migrator -> Void] = [
    { m in
        m.migrateKey("y", toKey: "z")
        m.addValue(7.2 as Float, forKey: "y")
    }
]
```

That's it! Mappings will automatically detect an outdated mapping during decoding, and apply the necessary migrations.

If the properties of the class change again:

```swift
var y: Int?
var z: [String]!
```

Add another migrator to the `migrators` property:

```swift
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
```

Notice that the previous migrator is not changed or removed — if an archive containing the original version object is decoded, both migrators will be applied in sequence. **Never remove old migrators** since object versioning is based on the count of the `migrators` array.

Note also that there is no migration necessary for the deleted `x` property — it will silently disappear when the object is encoded with the new mapping.

## Installation

1. Install the framework:

    ### Using Carthage

    [Carthage](https://github.com/Carthage/Carthage) is a simple, decentralised dependency manager. Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

    ```
    github "PartiallyFinite/mappings-swift" "develop"
    ```

    Run `carthage update`.

    ### Manually

    Download or clone the repository, and drag Mappings.xcodeproj into your project. In your target settings, add the relevant framework (Mappings iOS or Mac) to Target Dependencies in the Build Phases tab.

2. Add the relevant framework (Mappings iOS or Mac) from Carthage/Build to the Embedded Binaries section in your target.

3. Add the adaptors you need to your project: find the files for the serialisation APIs you use in Mappings/Adaptors (located in Carthage/Checkouts if you used Carthage), and add them to your project and application target. If the API you are using does not have an adaptor, you can [write your own](#creating-custom-adaptors).

## Creating custom adaptors

If an adaptor does not exist for the serialisation API you are using, it is relatively simple to write one. See the provided adaptors for [ObjSer](Adaptors/ObjSer.swift) and [NSCoding](Adaptors/NSCoder.swift) for a reference.

If you write your own adaptor, please add it to the Adaptors folder under a descriptive name and submit a [pull request](https://github.com/PartiallyFinite/mappings-swift/pull/new/develop).

