import TencentSCFEvents
import TencentSCFRuntime
import Vapor

// MARK: Application + CloudFuntion

public extension Application {
    var scf: CloudFuntion {
        .init(application: self)
    }

    struct CloudFuntion {
        public let application: Application
    }
}

public extension Application.Servers.Provider {
    static var scf: Self {
        .init {
            $0.servers.use { $0.scf.server.shared }
        }
    }
}

// MARK: Application + CloudFuntion + Server

public extension Application.CloudFuntion {
    var server: Server {
        .init(application: application)
    }

    struct Server {
        let application: Application

        public var shared: SCFServer {
            if let existing = application.storage[Key.self] {
                return existing
            } else {
                let new = SCFServer(
                    application: application,
                    responder: application.responder.current,
                    configuration: self.configuration,
                    on: self.application.eventLoopGroup
                )
                self.application.storage[Key.self] = new
                return new
            }
        }

        struct Key: StorageKey {
            typealias Value = SCFServer
        }

        public var configuration: SCFServer.Configuration {
            get {
                self.application.storage[ConfigurationKey.self] ?? .init(
                    logger: self.application.logger
                )
            }
            nonmutating set {
                if self.application.storage.contains(Key.self) {
                    self.application.logger.warning("Cannot modify server configuration after server has been used.")
                } else {
                    self.application.storage[ConfigurationKey.self] = newValue
                }
            }
        }

        struct ConfigurationKey: StorageKey {
            typealias Value = SCFServer.Configuration
        }
    }
}

// MARK: SCFServer

public class SCFServer: Server {
    public struct Configuration {
        var logger: Logger

        init(logger: Logger) {
            self.logger = logger
        }
    }

    private let application: Application
    private let responder: Responder
    private let configuration: Configuration
    private let eventLoop: EventLoop
    private var scfLifecycle: SCF.Lifecycle

    init(application: Application,
         responder: Responder,
         configuration: Configuration,
         on eventLoopGroup: EventLoopGroup)
    {
        self.application = application
        self.responder = responder
        self.configuration = configuration

        self.eventLoop = eventLoopGroup.next()

        let handler = APIGatewayHandler(application: application, responder: responder)

        self.scfLifecycle = SCF.Lifecycle(
            eventLoop: self.eventLoop,
            logger: self.application.logger
        ) {
            $0.eventLoop.makeSucceededFuture(handler)
        }
    }

    public func start(hostname _: String?, port _: Int?) throws {
        self.eventLoop.execute {
            _ = self.scfLifecycle.start()
        }

        self.scfLifecycle.shutdownFuture.whenComplete { _ in
            DispatchQueue(label: "shutdown").async {
                self.application.shutdown()
            }
        }
    }

    public var onShutdown: EventLoopFuture<Void> {
        self.scfLifecycle.shutdownFuture.map { _ in }
    }

    public func shutdown() {
        // this should only be executed after someone has called `app.shutdown()`
        // on SCF the ones calling should always be us!
        // If we have called shutdown, the SCF server already is shutdown.
        // That means, we have nothing to do here.
    }
}
