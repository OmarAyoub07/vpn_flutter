import NetworkExtension
import WireGuardKit

class PacketTunnelProvider: NEPacketTunnelProvider {
    private lazy var adapter = WireGuardAdapter(with: self) { logLevel, message in
        NSLog("WireGuard[\(logLevel)]: \(message)")
    }

    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        guard let proto = protocolConfiguration as? NETunnelProviderProtocol,
              let wgConfig = proto.providerConfiguration?["wgQuickConfig"] as? String else {
            completionHandler(NSError(domain: "VPNExtension", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing wgQuickConfig"]))
            return
        }

        do {
            let tunnelConfig = try TunnelConfiguration(fromWgQuickConfig: wgConfig)
            adapter.start(tunnelConfiguration: tunnelConfig) { error in
                completionHandler(error)
            }
        } catch {
            completionHandler(error)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        adapter.stop { _ in completionHandler() }
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        completionHandler?(nil)
    }
}
