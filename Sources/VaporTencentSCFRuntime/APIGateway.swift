import ExtrasBase64
import NIO
import NIOHTTP1
import TencentSCFEvents
import TencentSCFRuntimeCore
import Vapor

// MARK: - Handler -

struct APIGatewayHandler: EventLoopSCFHandler {
    typealias In = APIGateway.Request<String>
    typealias Out = APIGateway.Response

    private let application: Application
    private let responder: Responder

    init(application: Application, responder: Responder) {
        self.application = application
        self.responder = responder
    }

    public func handle(context: SCF.Context, event: APIGateway.Request<String>)
        -> EventLoopFuture<APIGateway.Response>
    {
        let vaporRequest: Vapor.Request
        do {
            vaporRequest = try Vapor.Request(req: event, in: context, for: self.application)
        } catch {
            return context.eventLoop.makeFailedFuture(error)
        }

        return self.responder.respond(to: vaporRequest)
            .map { APIGateway.Response(response: $0) }
    }
}

// MARK: - Request -

extension Vapor.Request {
    private static let bufferAllocator = ByteBufferAllocator()

    convenience init(req: APIGateway.Request<String>, in ctx: SCF.Context, for application: Application) throws {
        var buffer: NIO.ByteBuffer?
        if let string = req.body {
            let bytes = try string.base64decoded()
            buffer = Vapor.Request.bufferAllocator.buffer(capacity: bytes.count)
            buffer!.writeBytes(bytes)
        }

        var nioHeaders = NIOHTTP1.HTTPHeaders()
        req.headers.forEach { key, value in
            nioHeaders.add(name: key, value: value)
        }

        self.init(
            application: application,
            method: NIOHTTP1.HTTPMethod(rawValue: req.httpMethod.rawValue),
            url: Vapor.URI(path: req.path),
            version: HTTPVersion(major: 1, minor: 1),
            headers: nioHeaders,
            collectedBody: buffer,
            remoteAddress: nil,
            logger: ctx.logger,
            on: ctx.eventLoop
        )

        storage[APIGateway.Request] = req
    }
}

extension APIGateway.Request: Vapor.StorageKey {
    public typealias Value = APIGateway.Request<T>
}

// MARK: - Response -

extension APIGateway.Response {
    init(response: Vapor.Response) {
        var _headers = [String: [String]]()
        response.headers.forEach { name, value in
            var values = _headers[name] ?? [String]()
            values.append(value)
            _headers[name] = values
        }
        let headers = _headers.mapValues { $0.joined(separator: ";") }

        if let string = response.body.string {
            self = APIGateway.Response(
                statusCode: .init(code: response.status.code),
                headers: headers,
                body: .string(string)
            )
        } else if var buffer = response.body.buffer {
            let data = buffer.readData(length: buffer.readableBytes)!
            self = APIGateway.Response(
                statusCode: .init(code: response.status.code),
                headers: headers,
                body: .data(data)
            )
        } else {
            self = APIGateway.Response(
                statusCode: .init(code: response.status.code),
                headers: headers
            )
        }
    }
}
