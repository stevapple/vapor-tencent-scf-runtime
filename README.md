# vapor-tencent-scf-runtime


[![Swift 5.2](https://img.shields.io/static/v1?label=Swift&message=%3e%3d+5.2&color=orange&logo=swift)](https://swift.org/download/)
[![Vapor 4](https://img.shields.io/static/v1?label=Vapor&message=4&color=5AA9E7&logo=vapor)](https://github.com/vapor/vapor)
[![CI](https://img.shields.io/github/workflow/status/stevapple/vapor-tencent-scf-runtime/CI?label=CI&logo=github)](https://github.com/stevapple/vapor-tencent-scf-runtime/actions)
[![codecov](https://img.shields.io/codecov/c/gh/stevapple/vapor-tencent-scf-runtime?label=Codecov&logo=codecov)](https://codecov.io/gh/stevapple/vapor-tencent-scf-runtime)

This library is a forked version of [vapor-aws-lambda-runtime](https://github.com/vapor-community/vapor-aws-lambda-runtime) for [Tencent SCF](https://intl.cloud.tencent.com/product/scf).

Run your Vapor app on Tencent SCF. This package bridges the communication between [`swift-tencent-scf-runtime`](https://github.com/stevapple/swift-tencent-scf-runtime)
and the [Vapor](https://github.com/vapor/vapor) framework. APIGateway requests are transformed into `Vapor.Request`s and `Vapor.Response`s are written back to the APIGateway. This works like SCF [Framework Components](https://github.com/serverless-components/tencent-framework-components).

## Status

**Note: Currently this is nothing more than a proof of concept. Use at your own risk. I would like to hear feedback, if you played with this. Please open a GitHub issues for all open ends, you experience.**

Examples:

- [Hello](examples/Hello/Sources/Hello/main.swift)

If you test anything, please open a PR so that we can document the state of affairs better. A super small example would be even better. I plan to create some integration tests with the examples.

## Usage

Add `vapor-tencent-scf-runtime` and `vapor` as dependencies to your project. For this open your `Package.swift`:

```swift
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    .package(url: "https://github.com/stevapple/vapor-tencent-scf-runtime.git", from: "0.0.1"),
  ]
```

Add `VaporTencentSCFRuntime` as a dependency to your target:

```swift
  targets: [
    .target(name: "Hello", dependencies: [
      .product(name: "Vapor", package: "vapor"),
      .product(name: "VaporTencentSCFRuntime", package: "vapor-tencent-scf-runtime")
    ]),
  ]
```

Create a simple Vapor app.

```swift
import Vapor
import VaporTencentSCFRuntime

let app = Application()

struct Name: Codable {
  let name: String
}

struct Hello: Content {
  let hello: String
}

app.get("hello") { (_) -> Hello in
  Hello(hello: "world")
}

app.post("hello") { req -> Hello in
  let name = try req.content.decode(Name.self)
  return Hello(hello: name.name)
}
```

Next we just need to run the Vapor app. To run in SCF, we need to change the "serve" command. Then we can start the app by calling `app.run()`

```swift
app.servers.use(.scf)

try app.run()
```

## Contributing

Please feel welcome and encouraged to contribute to `vapor-tencent-scf-runtime`. The current version has a long way to go before being ready for production use and help is always welcome.

If you've found a bug, have a suggestion or need help getting started, please open an Issue or a PR. If you use this package, I'd be grateful for sharing your experience.

If you like this project, I'm excited about GitHub stars. 🤓
