# RNP (Requestable Network Protocol)

[![Build Status][build status badge]][build status]
[![codebeat badge][codebeat status badge]][codebeat status]
[![codeclimate badge][codeclimate status badge]][codeclimate status]
<!--[![codecov][codecov status badge]][codecov status]-->
![Platforms][platforms badge]

## Why would I use this?

This library is not meant to be used in isolation, rather it's purpose is to serve as a bridge language between a few different packages that address different aspects of networking on apple platforms.

## Installation

If you're working directly in a Package, add `RNP` to your Package.swift file

```swift
dependencies: [
    .package(url: "https://github.com/JARMourato/RNP.git", .upToNextMajor(from: "1.0.0")),
]
```

If working in an Xcode project select `File->Add Packages...` and search for the package name: `RNP` or the git url:

`https://github.com/JARMourato/RNP.git`

## Contributions

If you feel like something is missing or you want to add any new functionality, please open an issue requesting it and/or submit a pull request with passing tests 🙌

## License

This project is open source and covered by a standard 2-clause BSD license. That means you can use (publicly, commercially and privately), modify and distribute this project's content, as long as you mention João Mourato as the original author of this code and reproduce the LICENSE text inside your app, repository, project or research paper.

## Contact

João ([@_JARMourato](https://twitter.com/_JARMourato))

[build status]: https://github.com/JARMourato/RNP/actions?query=workflow%3ACI
[build status badge]: https://github.com/JARMourato/RNP/workflows/CI/badge.svg
[codebeat status]: https://codebeat.co/projects/github-com-jarmourato-rnp-main
[codebeat status badge]: https://codebeat.co/badges/e2025753-f528-4d7c-be57-666b914d66ea
[codeclimate status]: https://codeclimate.com/github/JARMourato/RNP/maintainability
[codeclimate status badge]: https://api.codeclimate.com/v1/badges/d6cf9e6be375d2b57137/maintainability
<!--[codecov status]: https://codecov.io/gh/JARMourato/RNP-->
<!--[codecov status badge]: -->
[platforms badge]: https://img.shields.io/static/v1?label=Platforms&message=iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20&color=brightgreen
