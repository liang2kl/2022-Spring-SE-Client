//
//  HomeView.swift
//  Client
//
//  Created by liang2kl on 2022/4/9.
//

import SwiftUI
import ConfigService
import Defaults
import Combine

struct HomeView: View {
    @StateObject private var store = HomeViewModel()
    @State private var isResponseHidden = true
    @Environment(\.colorScheme) private var colorScheme

    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: store.data?.layout.columns ?? 0)
    }
    
    var body: some View {
        ScrollView {
            if let data = store.data {
                Spacer(minLength: 10).fixedSize()
                
                if data.sections.isEmpty {
                    Text("No Content")
                        .foregroundColor(.secondary)
                }
                
                ForEach(data.sections, id: \.name) { section in
                    VStack(alignment: .leading) {
                        Text(section.data.displayName)
                            .fontWeight(.bold)
                            .font(.system(size: 27 * data.layout.fontScale, design: .serif))
                        
                        LazyVGrid(columns: columns, spacing: 10 * data.layout.fontScale) {
                            
                            ForEach(section.data.entries, id: \.title) { entry in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.title)
                                        .fontWeight(.semibold)
                                        .font(.system(size: 18 * data.layout.fontScale, design: .serif))
                                    Text(entry.description)
                                        .font(.system(size: 12 * data.layout.fontScale, design: .serif))
                                }
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .clipShape(RoundedRectangle(
                                    cornerRadius: 10 * data.layout.fontScale, style: .continuous
                                ))
                                .shadow(radius: 10)
                            }
                        }
                    }
                    
                }
                .padding()
            }
            
        }
        .topSafeAreaInset {
            HStack {
                Text("Websocket")
                    .font(.headline)
                
                if store.pushServiceConnecting {
                    ProgressView()
                        .padding(.leading, 3)
                } else {
                    let imageName = store.connectedToPushService ?
                    "checkmark.circle" : "xmark.circle"
                    let color: Color = store.connectedToPushService ?
                        .green : .red
                    
                    Image(systemName: imageName)
                        .foregroundColor(color)
                }
                
                Spacer()
                
                if let date = store.latestUpdateTime {
                    (
                        Text("Updated: ").bold() +
                        Text(date)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .blurBackground()
            .animation(.default, value: store.latestUpdateTime)
            .animation(.default, value: store.pushServiceConnecting)

        }
        .bottomSafeAreaInset {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Parameter Control")
                        .font(.headline)
                        .onTapGesture { withAnimation {
                            isResponseHidden.toggle()
                        }}
                    Spacer()
                    Button("Refresh") {
                        store.fetchConfig(cached: false)
                    }
                    .disabled(store.isLoading)
                }
                .padding(.bottom)
                
                HStack {
                    Text("user_age")
                        .font(.system(.body, design: .monospaced))

                    Picker("age", selection: $store.age) {
                        Text("21")
                            .tag(21)
                        Text("50")
                            .tag(50)
                        Text("70")
                            .tag(70)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.bottom)
                .disabled(store.isLoading)
                
                HStack {
                    Text("sections")
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                    Toggle("life", isOn: $store.includeLife)
                        .padding(.horizontal)
                        .fixedSize()
                    Toggle("sports", isOn: $store.includeSports)
                        .fixedSize()
                }
                .padding(.bottom)
                .disabled(store.isLoading)

                if !isResponseHidden {
                    Text(store.isLoading ? "Loading..." : "Response")
                        .font(.headline)
                        .padding(.bottom)
                    ScrollView {
                        HStack {
                            Text(store.displayedString ?? "")
                                .font(.system(.footnote, design: .monospaced))
                                .padding(.bottom)
                            Spacer()
                        }
                    }
                }
                
            }
            .padding([.horizontal, .top])
            .frame(maxHeight: 300)
            .fixedSize(horizontal: false, vertical: true)
            .blurBackground()
        }
        .background(Color(
            colorScheme == .dark ?
                UIColor.secondarySystemBackground :
                UIColor.systemBackground
        ))
        .multilineTextAlignment(.leading)
        .onChange(of: store.age) { _ in
            store.fetchConfig()
        }
        .onChange(of: store.includeLife) { _ in
            store.fetchConfig()
        }
        .onChange(of: store.includeSports) { _ in
            store.fetchConfig()
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var data: LayoutConfigRequestResponse?
    @Published var displayedString: String?
    @Published var age: Int = 21
    @Published var isLoading = false
    @Published var pushServiceConnecting = false
    @Published var includeSports = true
    @Published var includeLife = true
    @Published var connectedToPushService = false
    @Published var latestUpdateTime: String?
    
    var updateNum = 0
    
    var pushService: PushService
    
    var configIDCancellable: AnyCancellable!
    
    init() {
        // setup push service
        pushService = try! PushService(for: LayoutConfigRequest.self)
        setupPushService()
        
        pushServiceConnecting = true
        pushService.connect()
        
        // Listen for config id change notification
        configIDCancellable = NotificationCenter.default.publisher(for: .configDidChangeNotification)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main) // Wait for 1s
            .sink { [unowned self] _ in
                pushService.disconnect()
                // Just create a new one
                pushService = try! PushService(for: LayoutConfigRequest.self)
                setupPushService()
                pushServiceConnecting = true
                pushService.connect()
            }

        // request for config
        fetchConfig()
        
    }
    
    deinit {
        pushService.disconnect()
    }
    
    private func setupPushService() {
        pushService.onReceive = { [self] response in
            latestUpdateTime = "\(response.updateTime)"
            updateNum += 1
            let num = updateNum
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if num == self.updateNum {
                    self.latestUpdateTime = nil
                }
            }
            // no cache on update
            self.fetchConfig(cached: false)
        }
        
        pushService.onConnect = { [self] in
            self.pushServiceConnecting = false
            self.connectedToPushService = true
            ToastManager.shared.showSuccess(title: "Connected to push service")
        }
        
        pushService.onDisconnect = { [self] in
            self.pushServiceConnecting = false
            self.connectedToPushService = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                [unowned self] in
                guard !self.pushService.isConnected else { return }
                self.pushServiceConnecting = true
                self.pushService.connect()
            }
            
            ToastManager.shared.showError(title: "Disconnected to push service")
        }
        
        pushService.onError = { error in
            ToastManager.shared.showError(title: "Push service", message: error.description)
        }
    }
    
    func fetchConfig(cached: Bool = true) {
        withAnimation {
            self.isLoading = true
        }
        
        var sections = [String]()
        if includeLife {
            sections.append("life")
        }
        if includeSports {
            sections.append("sports")
        }

        let request = LayoutConfigRequest(
            parameter: .init(userAge: age, sections: sections)
        )
        
        try! request.fetch { result in
            DispatchQueue.main.async { withAnimation {
                self.isLoading = false
            }}

            switch result {
            case .failure(let error):
                ToastManager.shared.showError(title: "\(error.description)")

            case .success(let config):
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                encoder.outputFormatting = .prettyPrinted
                let data = try! encoder.encode(config)
                DispatchQueue.main.async { withAnimation {
                    self.data = config
                    self.displayedString = String(data: data, encoding: .utf8)
                }}
                ToastManager.shared.showSuccess(title: "Config fetched successfully")
            }
        }
    }
}
