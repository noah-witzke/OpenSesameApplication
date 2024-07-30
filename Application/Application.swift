import Foundation
import SwiftUI
import CloudKit
import SmackSDK

struct PersonalKey: Identifiable {
    
    var id: String {
        lockID
    }
    
    var lockID: String
    var index: Int
    var label: String
    var color: Color
}

struct Resident: Identifiable {
    
    var id: String {
        userID
    }
    
    var userID: String
    var index: Int
    var firstName: String
    var lastName: String
}

enum ContentViewState {
    case starting
    case registering
    case resting
    case addingKey
    case viewingKey
}

struct ContentView: View {
    var body: some View {
        VStack {
            TopBarView(backend: $_backend, viewState: $_viewState)
            
            ZStack(alignment: .top) {
                KeyDetailView(backend: $_backend, viewState: $_viewState)
                KeyStackView(backend: $_backend, viewState: $_viewState)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
        .background {
            Rectangle()
                .fill(Color(red: 245/255, green: 245/255, blue: 247/255))
                .ignoresSafeArea()
        }
        .onAppear() {
            Task {
                await _handleOnAppear()
            }
        }
        .onChange(of: _viewState) { oldValue, newValue in
            _handleChangeOfViewState(oldValue: oldValue, newValue: newValue)
        }
        .onChange(of: _isAddKeyViewPresented) { oldValue, newValue in
            if newValue == false {
                _viewState = .resting
            }
        }
        .sheet(isPresented: $_isRegisterViewPresented) {
            RegisterView(viewState: $_viewState, backend: $_backend)
                .padding(EdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 25))
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
                
        }
        .sheet(isPresented: $_isAddKeyViewPresented) {
            AddKeyView(backend: $_backend, viewState: $_viewState)
                .padding(EdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 25))
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func _handleOnAppear() async {
        do {
            _backend = try await Backend()
        } catch {
            _viewState = .resting
        }
        
    }
    
    private func _handleChangeOfViewState(oldValue: ContentViewState, newValue: ContentViewState) {
        if newValue == .registering {
            _isRegisterViewPresented = true
        }
        
        if newValue == .addingKey {
            _isAddKeyViewPresented = true
        }
    }
    
    @State private var _backend: Backend? = nil
    @State private var _viewState: ContentViewState = .starting
    @State private var _isRegisterViewPresented: Bool = false
    @State private var _isAddKeyViewPresented: Bool = false
}

struct TopBarView: View {
    var body: some View {
        HStack {
            ZStack {
                Text("Keys")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .opacity(_keysOpacity)
                    .blur(radius: _keysBlurRadius)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Button {
                    viewState = .resting
                } label: {
                    Text("Done")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundStyle(.black)
                        .opacity(_doneOpacity)
                        .blur(radius: _doneBlurRadius)
                }
                .disabled(_doneDisabled)
            }
            
            Spacer()
            
            ZStack {
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 18)
                        .opacity(_keyDetailsOpacity)
                        .blur(radius: _keyDetailsBlurRadius)
                }
                .disabled(_keyDetailsDisabled)
                
                Button {
                    viewState = .addingKey
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundStyle(.black)
                        .frame(width: 25, height: 25)
                        .opacity(_addKeyOpacity)
                        .blur(radius: _addkeyBlurRadius)
                }
                .disabled(_addKeyDisabled)
            }
        }
        .padding(EdgeInsets(top: _topPadding, leading: 0, bottom: _bottomPadding, trailing: 0))
        .onChange(of: viewState) { oldValue, newValue in
            _handleViewStateChange(oldValue: oldValue, newValue: newValue)
        }
    }
    
    @Binding var backend: Backend?
    @Binding var viewState: ContentViewState
    
    private func _handleViewStateChange(oldValue: ContentViewState, newValue: ContentViewState) {
        if newValue == .resting {
            _animateToRestingState()
        }
        
        if newValue == .viewingKey {
            _animateToKeyViewingState()
        }
    }
    
    private func _animateToRestingState() {
        _addKeyDisabled = false
        _doneDisabled = true
        _keyDetailsDisabled = true
        
        withAnimation(.snappy(duration: 0.7)) {
            _topPadding = 40
            _bottomPadding = 40
        }
        
        withAnimation(.smooth(duration: 0.5)) {
            _doneOpacity = 0.5
            _doneBlurRadius = 8
            
            _keyDetailsOpacity = 0.5
            _keyDetailsBlurRadius = 8
            
            _keysOpacity = 0.5
            _addKeyOpacity = 0.5
        }
        
        withAnimation(.smooth(duration: 0.5).delay(0.2)) {
            _doneOpacity = 0
            _keyDetailsOpacity = 0
            
            _keysOpacity = 1
            _keysBlurRadius = 0
            
            _addKeyOpacity = 1
            _addkeyBlurRadius = 0
        }
    }
    
    private func _animateToKeyViewingState() {
        _addKeyDisabled = true
        _doneDisabled = false
        _keyDetailsDisabled = false
        
        withAnimation(.snappy(duration: 0.7)) {
            _topPadding = 15
            _bottomPadding = 15
        }
        
        withAnimation(.smooth(duration: 0.5)) {
            _keysOpacity = 0.5
            _keysBlurRadius = 8
            
            _addKeyOpacity = 0.5
            _addkeyBlurRadius = 8
            
            _doneOpacity = 0.5
            _keyDetailsOpacity = 0.5
        }
        
        withAnimation(.smooth(duration: 0.5).delay(0.2)) {
            _keysOpacity = 0
            _addKeyOpacity = 0
            
            _doneOpacity = 1
            _doneBlurRadius = 0
            
            _keyDetailsOpacity = 1
            _keyDetailsBlurRadius = 0
        }
    }
    
    @State private var _keysOpacity: CGFloat = 1
    @State private var _keysBlurRadius: CGFloat = 0
    @State private var _doneOpacity: CGFloat = 0
    @State private var _doneBlurRadius: CGFloat = 6
    @State private var _doneDisabled: Bool = true
    @State private var _addKeyOpacity: CGFloat = 1
    @State private var _addkeyBlurRadius: CGFloat = 0
    @State private var _addKeyDisabled: Bool = false
    @State private var _keyDetailsOpacity: CGFloat = 0
    @State private var _keyDetailsBlurRadius: CGFloat = 6
    @State private var _keyDetailsDisabled: Bool = true
    @State private var _topPadding: CGFloat = 40
    @State private var _bottomPadding: CGFloat = 40
}

struct KeyStackView: View {
    init(backend: Binding<Backend?>, viewState: Binding<ContentViewState>) {
        self._backend = backend
        self._viewState = viewState
        
        _logger = DebugPrinter()
        _delegate = InfineonDelegate()

        let config = SmackConfig(logging: CombinedLogger(debugPrinter: _logger), delegate: _delegate)
        let client = SmackClient(config: config)
        let target = SmackTarget.device(client: client)
        _mailboxApi = MailboxApi(target: target, config: config)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(_keys) { key in
                    KeyView(key: key)
                        .offset(
                            x: _keyOffsets[key.index].width,
                            y: _keyOffsets[key.index].height)
                        .zIndex(Double(_keyIndices[key.index]))
                }
                .coordinateSpace(name: "keystack")
                .onAppear {
                    _viewSize = geometry.size
                }
                .onChange(of: geometry.size) { oldValue, newValue in
                    _viewSize = newValue
                }
                .onChange(of: viewState) { oldValue, newValue in
                    _handleViewStateChange(oldValue: oldValue, newValue: newValue)
                }
                .gesture(SpatialTapGesture(coordinateSpace: .named("keystack"))
                    .onEnded { value in
                        _handleSpatialTapEnded(value: value)
                    }
                    .exclusively(before: LongPressGesture()
                        .sequenced(before: DragGesture(coordinateSpace: .named("keystack")))
                        .onChanged { value in
                            _handleLongPressDragChanged(value: value)
                        }
                        .onEnded { value in
                            _handleLongPressDragEnded(value: value)
                        }
                    )
                )
            }
        }
    }
    
    @Binding var backend: Backend?
    @Binding var viewState: ContentViewState
    
    private func _handleViewStateChange(oldValue: ContentViewState, newValue: ContentViewState) {
        switch newValue {
        case .resting, .addingKey:
            _animateToRestingState()
        case .viewingKey:
            _animateToViewingKeyState()
        default:
            return
        }
    }
    
    private func _handleSpatialTapEnded(value: SpatialTapGesture.Value) {
        var cutOffHeights: [CGFloat] = []
        for i in 1..<_keys.count {
            cutOffHeights.append(keyOffset*CGFloat(i))
        }
        cutOffHeights.append(cutOffHeights.last! + keyHeight)
        
        for i in 0..<cutOffHeights.count {
            if value.location.y < cutOffHeights[i] {
                _selectedKeyIndex = i
                break
            }
        }
        viewState = .viewingKey
        _unlock()
    }
    
    private func _handleLongPressDragChanged(value: SequenceGesture<LongPressGesture, DragGesture>.Value) {
        
        if _keys.isEmpty {
            return
        }
        
        let location: CGPoint
        let translation: CGSize
        
        switch value {
        case .first(true):
            return
        case .second(true, let v):
            if v == nil {
                return
            }
            location = v!.location
            translation = v!.translation
        default:
            return
        }
        
        var cutOffHeights: [CGFloat] = []
        for i in 1..<_keys.count {
            cutOffHeights.append(keyOffset*CGFloat(i))
        }
        cutOffHeights.append(cutOffHeights.last! + keyHeight)
        
        if _dragging == false {
            _dragging = true
            for i in 0..<cutOffHeights.count {
                if location.y < cutOffHeights[i] {
                    _selectedKeyIndex = i
                    break
                }
            }
        }
        
        withAnimation {
            _keyOffsets[_selectedKeyIndex!].width = translation.width
            _keyOffsets[_selectedKeyIndex!].height = keyOffset*CGFloat(_selectedKeyIndex!) + translation.height
        }
        
        var currentRegion: Int =  _keys.count - 1
        
        for i in 0..<cutOffHeights.count {
            if keyOffset*CGFloat(_selectedKeyIndex!) + translation.height < cutOffHeights[i] {
                currentRegion = i
                break
            }
        }
        
        _keyIndices[_selectedKeyIndex!] = currentRegion
        
        withAnimation(.bouncy(duration: 0.35)) {
            if currentRegion < _selectedKeyIndex! {
                for i in 0..<_selectedKeyIndex! {
                    if i < currentRegion {
                        _keyOffsets[i].height = keyOffset*CGFloat(i)
                        _keyIndices[i] = i
                    } else {
                        _keyOffsets[i].height = keyOffset*CGFloat(i) + keyOffset
                        _keyIndices[i] = i + 1
                    }
                }
            }
            
            if currentRegion == _selectedKeyIndex! {
                for i in 0..<_keys.count {
                    if i == _selectedKeyIndex! {
                        //_keyOffsets[i].height = keyOffset*CGFloat(i) + translation.height
                    } else {
                        _keyOffsets[i].height = keyOffset*CGFloat(i)
                    }
                    _keyIndices[i] = i
                }
            }
            
            if currentRegion > _selectedKeyIndex! {
                for i in _selectedKeyIndex! + 1..<_keys.count {
                    if i > currentRegion {
                        _keyOffsets[i].height = keyOffset*CGFloat(i)
                        _keyIndices[i] = i
                    } else {
                        _keyOffsets[i].height = keyOffset*CGFloat(i) - keyOffset
                        _keyIndices[i] = i - 1
                    }
                }
            }
        }
    }
    
    private func _getCardIndex(atLocation location: CGPoint) -> Int? {
        nil
    }
    
    private func _handleLongPressDragEnded(value: SequenceGesture<LongPressGesture, DragGesture>.Value) {
        _animateToRestingState()
        _dragging = false
    }
    
    private func _animateToRestingState() {
        withAnimation(.bouncy(duration: 0.35)) {
            for i in 0..<_keys.count {
                _keyOffsets[i] = CGSize(width: 0, height: CGFloat(_keyIndices[i])*keyOffset)
            }
        }
    }
    
    private func _animateToViewingKeyState() {
        withAnimation(.bouncy(duration: 0.35)) {
            for i in 0..<_keys.count {
                if i == _selectedKeyIndex {
                    _keyOffsets[i] = .zero
                    continue
                }
                _keyOffsets[i] = CGSize(width: 0, height: _viewSize.height + 100)
            }
        }
    }
    
    private func _unlock() -> Void {
        _mailboxApi.readWord(index: 1) { result in
            switch result {
            case .success(let bytes):
                if bytes == [0xA5, 0x5B, 0x00, 0xB5] {
                    _mailboxApi.writeWord(index: 2, word: [0x12, 0x34, 0x43, 0x21]) { result in
                        switch result {
                        case .success(_):
                            _harvest()
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func _harvest() -> Void {
        _mailboxApi.readWord(index: 5) { result in
            switch result {
            case .success(let bytes):
                print(bytes)
                _harvest()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private let keyOffset: CGFloat = 50
    private let keyHeight: CGFloat = 240
    private let _logger: Logger
    private let _delegate: SmackDelegate
    private let _mailboxApi: MailboxApi
    
    @State private var _dragging: Bool = false
    @State private var _selectedKeyIndex: Int? = nil
    @State private var _viewSize: CGSize = .zero
    @State private var _region: Int = 0
    
    @State private var _keyOffsets: [CGSize] = [
        CGSize(width: 0, height: 0*50),
        CGSize(width: 0, height: 1*50),
        CGSize(width: 0, height: 2*50),
        CGSize(width: 0, height: 3*50),
        CGSize(width: 0, height: 4*50)
    ]
    
    @State private var _keyIndices: [Int] = [
        0, 1, 2, 3, 4
    ]
    
    @State private var _keys: [PersonalKey] = [
        PersonalKey(lockID: "000000", index: 0, label: "Prototype 0", color: .blue),
        PersonalKey(lockID: "000001", index: 1, label: "Prototype 1", color: .black),
        PersonalKey(lockID: "000002", index: 2, label: "Prototype 2", color: .green),
        PersonalKey(lockID: "000003", index: 3, label: "Prototype 3", color: .gray),
        PersonalKey(lockID: "000004", index: 4, label: "Prototype 4", color: .purple)
    ]
}

struct RegisterView: View {
    enum ViewState {
        case resting
        case registering
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("Register")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 25, trailing: 0))
                Spacer()
                Button {
                    Task {
                        await register()
                    }
                } label: {
                    Text("Next")
                        .fontWeight(.bold)
//                    switch viewState {
//                    case .resting:
//                        Text("Next")
//                            .fontWeight(.bold)
//                    case .registering:
//                        ProgressView()
//                            .frame(width: 18, height: 18)
//                    }
                }
            }
            
            Grid(alignment: .leading) {
                GridRow {
                    Text("First Name")
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                    TextField("Required", text: $_firstName)
                }
                
                Divider()
                
                GridRow {
                    Text("Last Name")
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                    TextField("Required", text: $_lastName)
                }
                
                Divider()
                
                GridRow {
                    Text("Email")
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                    TextField("Required", text: $_email)
                }
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
            .background {
                RoundedRectangle(cornerRadius: 15.0)
                    .fill(Color(red: 245.0/255.0, green: 245.0/255.0, blue: 247.0/255.0))
            }
        }
    }
    
    func register() async {
        
    }
    
    @Binding var viewState: ContentViewState
    @Binding var backend: Backend?
    
    @State private var _firstName: String = ""
    @State private var _lastName: String = ""
    @State private var _email: String = ""
}


struct AddKeyView: View {
    enum ViewState {
        case resting
        case loading
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("Add Key")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 25, trailing: 0))
                Spacer()
                Button {
                    viewState = .resting
                } label: {
                    Text("Next")
                        .fontWeight(.bold)

                }
            }

            Grid(alignment: .leading) {
                GridRow {
                    Text("Serial Number")
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                    TextField("Required", text: $_lockID)
                }
                
                Divider()
                
                GridRow {
                    Text("Label")
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                    TextField("Required", text: $_lockLabel)
                }
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
            .background {
                RoundedRectangle(cornerRadius: 15.0)
                    .fill(Color(red: 245.0/255.0, green: 245.0/255.0, blue: 247.0/255.0))
            }
        }
    }
    
    func addKey() async {
    }
    
    @Binding var backend: Backend?
    @Binding var viewState: ContentViewState
    
    @State private var _lockID: String = ""
    @State private var _lockLabel: String = ""
}

struct KeyView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(key.color)
            VStack(alignment: .leading) {
                Text(key.label)
                    .foregroundStyle(.white)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                
                Spacer()
                
                Grid(alignment: .leading) {
                    GridRow {
                        Text("Owner")
                            .foregroundStyle(.white)
                            .font(.system(size: 12, weight: .semibold, design: .default))
                        
                        Text("Noah Witzke")
                            .foregroundStyle(.white)
                            .font(.system(size: 12, weight: .light, design: .default))
                    }
                    
                    GridRow {
                        Text("Serial Number")
                            .foregroundStyle(.white)
                            .font(.system(size: 12, weight: .semibold, design: .default))
                        
                        Text(key.lockID)
                            .foregroundStyle(.white)
                            .font(.system(size: 12, weight: .light, design: .default))
                    }
                }
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        }
        .frame(height: 240)
        .shadow(radius: 2)
    }
    
    @State var key: PersonalKey
}

struct KeyDetailView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Residents")
                .font(.system(size: 20, weight: .bold, design: .default))
                .frame(height: 40, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(height: 18 + 4*36)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(_residents) { resident in
                            HStack {
                                Text("\(resident.firstName) \(resident.lastName)")
                                    .font(.system(size: 16, weight: .regular))
                                    .frame(height: 36, alignment: .leading)
                                Spacer()
                                Button {
                                    print("action")
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.green)
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 16))
                }
            }
        }

        .onChange(of: viewState) { oldValue, newValue in
            _handleViewStateChange(oldValue: oldValue, newValue: newValue)
        }
        .opacity(_opacity)
        .padding(EdgeInsets(top: 275, leading: 0, bottom: 0, trailing: 0))
    }
    
    @State private var _email: String = ""
    
    @Binding var backend: Backend?
    @Binding var viewState: ContentViewState
    
    private func _handleViewStateChange(oldValue: ContentViewState, newValue: ContentViewState) {
        switch newValue {
        case .viewingKey:
            _animateToViewingState()
        default:
            _animateToRestingState()
        }
    }
    
    private func _animateToViewingState() {
        withAnimation(.easeInOut(duration: 0.8)) {
            _opacity = 1
        }
    }
    
    private func _animateToRestingState() {
        withAnimation {
            _opacity = 0
        }
    }
    
    @State private var _opacity: CGFloat = 0
    
    @State private var _residents: [Resident] = [
        Resident(userID: "0", index: 0, firstName: "Noah", lastName: "Witzke"),
        Resident(userID: "1", index: 1, firstName: "Keval", lastName: "Tripathi"),
        Resident(userID: "2", index: 2, firstName: "Alastair", lastName: "Correya"),
        Resident(userID: "3", index: 3, firstName: "Atharva", lastName: "Bhalerao"),
    ]
    
    @State private var _height: CGFloat = 15
}

enum BackendError: Error {
    case error
}

struct Backend {
    init() async throws {
        _container = CKContainer(identifier: "iCloud.OpenSesame.ApplicationBackend")
        _publicDatabase = _container.publicCloudDatabase
        _privateDatabase = _container.privateCloudDatabase
        
        if let userID = try await _container.fetchUserRecordID() {
            _userID = userID.recordName
            return
        }
        
        throw BackendError.error
    }
    
    private let _container: CKContainer
    private let _publicDatabase: CKDatabase
    private let _privateDatabase: CKDatabase
    private let _userID: String
}

extension CKContainer {
    func fetchUserRecordID() async throws -> CKRecord.ID? {
        try await withCheckedThrowingContinuation { continuation in
            fetchUserRecordID { recordID, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: recordID)
            }
        }
    }
    
    func fetchShareParticipant(withUserRecordID recordID: CKRecord.ID) async throws -> CKShare.Participant {
        try await withCheckedThrowingContinuation { continuation in
            fetchShareParticipant(withUserRecordID: recordID) { participant, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: participant!)
            }
        }
    }
    
    func fetchShareParticipant(withEmailAddress emailAddress: String) async throws -> CKShare.Participant {
        try await withCheckedThrowingContinuation { continuation in
            fetchShareParticipant(withEmailAddress: emailAddress) { participant, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: participant!)
            }
        }
    }
    
    func fetchShareParticipant(withPhoneNumber phoneNumber: String) async throws -> CKShare.Participant {
        try await withCheckedThrowingContinuation { continuation in
            fetchShareParticipant(withPhoneNumber: phoneNumber) { participant, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: participant!)
            }
        }
    }
    
    func accountStatus() async throws -> CKAccountStatus {
        try await withCheckedThrowingContinuation { continuation in
            accountStatus { accountStatus, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: accountStatus)
            }
        }
    }
}


extension CKDatabase {
    func fetchRecord(withID recordID: CKRecord.ID) async throws -> CKRecord {
        try await withCheckedThrowingContinuation { continuation in
            fetch(withRecordID: recordID) { record, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: record!)
            }
        }
    }
}

@main struct Application: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class InfineonDelegate: SmackDelegate {
    func onConnect(tag: any SmackSDK.NfcTagApi) {
        print("Connected")
    }

    func onDisconnect(message: String?) {
        print("Disconnected")
    }
}
