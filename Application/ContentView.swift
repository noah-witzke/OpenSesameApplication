import CoreNFC
import SwiftUI
import SmackSDK


struct ContentView: View {
    init() {
        _logger = DebugPrinter()
        _delegate = InfineonDelegate()
        _key = [Byte](repeating: Byte(), count: 16)
        
        let config = SmackConfig(logging: CombinedLogger(debugPrinter: _logger), delegate: _delegate)
        let client = SmackClient(config: config)
        let target = SmackTarget.device(client: client)
        _mailboxApi = MailboxApi(target: target, config: config)
    }
    
    var body: some View {
        VStack {
            Button("Unlock") {
                _mailboxApi.readWord(index: 1) { result in
                    switch result {
                    case .success(let bytes):
                        _s2 = bytes.string!
                        
                        if bytes == [0xA5, 0x5B, 0x00, 0xB5] {
                            _mailboxApi.writeWord(index: 2, word: [0x12, 0x34, 0x43, 0x21]) { result in
                                switch result {
                                case .success(_):
                                    _harvest()
//                                        _mailboxApi.readWord(index: 3) { result in
//                                            switch result {
//                                            case .success(let bytes):
//                                                if bytes == [0x00, 0x00, 0x00, 0x00] {
//                                                    print("charging")
//                                                }
//                                                
//                                                if bytes == [0x55, 0x55, 0x55, 0x55] {
//                                                    print("success")
//                                                    _harvest()
//                                                }
//                                                
//                                                if bytes == [0x99, 0x99, 0x99, 0x99] {
//                                                    print("failure")
//                                                }
//                                            case .failure(let error):
//                                                _errorMessage = error.localizedDescription
//                                            }
//                                        }

                                case .failure(let error):
                                    _errorMessage = error.localizedDescription
                                }
                            }
                        }
                    case .failure(let error):
                        _errorMessage = error.localizedDescription
                    }
                }
            }
            Text("return value: \(_s2)")
            
            Spacer()
            
            Text(_errorMessage)
        }
        .padding()
    }
    
    private func _harvest() {
        _mailboxApi.readWord(index: 5) { result in
            switch result {
            case .success(let bytes):
                print(bytes)
                _harvest()
            case .failure(let error):
                _errorMessage = error.localizedDescription
            }
        }
    }
    
    private let _logger: Logger
    private let _delegate: InfineonDelegate
    private let _key: LockKey
    private let _mailboxApi: MailboxApi
    
    @State private var _s0: String = ""
    @State private var _s1: String = ""
    @State private var _s2: String = ""
    @State private var _s3: String = ""
    @State private var _s4: String = ""
    @State private var _s5: String = ""
    @State private var _errorMessage: String = ""
}


class InfineonDelegate: SmackDelegate {
    func onConnect(tag: any SmackSDK.NfcTagApi) {
        print("Connected")
    }
    
    func onDisconnect(message: String?) {
        print("Disconnected")
    }
}


//extension MailboxApi {
//    func writeWord(index: Int, word: [Byte]) async throws -> [Byte] {
//        try await withCheckedThrowingContinuation { continuation in
//
//        }
//    }
//    
//    func readWord(index: Int) async throws -> [Byte] {
//        try await withCheckedThrowingContinuation { continuation in
//            readWord(index: index) { result in
//                switch result {
//                case .success(let bytes):
//                    continuation.resume(returning: bytes)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//    
//    func readDataPoint(dataPoint: any DataPoint) async throws -> [Byte] {
//        try await withCheckedThrowingContinuation { continuation in
//            readDataPoint(dataPoint: dataPoint) { result in
//                switch result {
//                case .success(let bytes):
//                    continuation.resume(returning: bytes)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//    
//    func callAppFunction(index: Byte, data: [Byte]) async throws -> [[Byte]] {
//        try await withCheckedThrowingContinuation { continuation in
//            callAppFunction(index: index, data: data) { result in
//                switch result {
//                case .success(let bytes):
//                    continuation.resume(returning: bytes)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//}
