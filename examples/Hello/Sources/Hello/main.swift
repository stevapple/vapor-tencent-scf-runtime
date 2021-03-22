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

app.servers.use(.scf)
try app.run()
