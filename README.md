# Mappings

[![GitHub license](https://img.shields.io/github/license/PartiallyFinite/mappings-swift.svg)](https://github.com/PartiallyFinite/mappings-swift/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/PartiallyFinite/mappings-swift.svg)](https://github.com/PartiallyFinite/mappings-swift/releases)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Versioned mapping adaptor for NSCoder and similar APIs.

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

3. Add the adaptor you need to your project: find the file(s) you need in Mappings/Adaptors (located in Carthage/Checkouts if you used Carthage), and add them to your project and application target.

