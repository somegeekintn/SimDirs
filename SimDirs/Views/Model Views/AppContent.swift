//
//  AppContent.swift
//  SimDirs
//
//  Created by Casey Fleser on 6/21/22.
//

import SwiftUI

extension SimApp {
    public var content : some View { AppContent(app: self) }

    var isLaunched  : Bool {
        get { state.isOn }
        set { toggleLaunchState() }
    }
}

extension SimApp.State: ToggleDescriptor {
    var titleKey    : LocalizedStringKey { isOn ? "Terminate" : "Launch" }
    var text        : String { isOn ? "Launched" : "Terminated" }
    var image       : Image { Image(systemName: "power.circle") }
}

struct AppContent: View {
    // https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html
    
    @ObservedObject var app     : SimApp
    @State var validJSON        = true
    @State var jsonErrMsg       = ""
    @State var jsonText         : String = """
        {
            "aps" : {
                "alert": "Push from SimDirs",
                "sound": "chime",
                "badge": 1
            }
        }
        """
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ContentHeader("Paths")
            Group {
                PathRow(title: "Bundle Path", path: app.bundlePath)
                if let sandboxPath = app.sandboxPath {
                    PathRow(title: "Sandbox Path", path: sandboxPath)
                }
                else {
                    Text("Sandbox Path: <unknown>")
                }
            }
            .font(.subheadline)
            .lineLimit(1)

            ContentHeader("Actions")
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    DescriptiveToggle(app.state, isOn: $app.isLaunched, subtitled: false)
                        .frame(width: 58)
                }
                .environment(\.isEnabled, app.device?.isBooted == true)
                
                HStack {
                    Button(action: pushJSON) {
                        Text("Push")
                            .fontWeight(.semibold)
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.systemIcon("bell.badge"))
                    .disabled(!validJSON)
                    .frame(width: 58)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("JSON payload:")
                                .font(.subheadline)
                                .padding(.leading, 8)
                            Text(jsonErrMsg.isEmpty ? "Valid" : jsonErrMsg)
                                .font(.subheadline)
                                .foregroundColor(jsonErrMsg.isEmpty ? .green : .red)
                        }
                        TextEditor(text: $jsonText)
                            .font(.system(size: 11, design: .monospaced))
                            .frame(height: 96)
                            .border(.black)
                    }
                }
            }
        }
        .onAppear { app.discoverState() }
        .onChange(of: jsonText, perform: validateJSON)
    }
    
    func pushJSON() {
        guard let jsonData = jsonText.data(using: .utf8), let device = app.device else { return }

        do {
            if var payload = try JSONSerialization.jsonObject(with: jsonData) as? [String : Any] {
                let jsonData    : Data
                
                payload["Simulator Target Bundle"] = app.bundleID
                jsonData = try JSONSerialization.data(withJSONObject: payload)
                
                device.sendPushNotification(payload: jsonData)
            }
        }
        catch { // <thinking face>
            print("Error attempting to create push payload: \(error)")
        }
    }
    
    func validateJSON(_ json: String) {
        guard let jsonData = json.data(using: .utf8) else { return }
        
        do {
            let obj = try JSONSerialization.jsonObject(with: jsonData)
            
            if obj as? [String : Any] == nil {
                jsonErrMsg = "Root expected to be dictionary"
                validJSON = false
            }
            else {
                jsonErrMsg = ""
                validJSON = true
            }
        }
        catch {
            let nsError = (error as NSError)

            jsonErrMsg = nsError.userInfo[NSDebugDescriptionErrorKey] as? String ?? nsError.localizedDescription
            validJSON = false
        }
    }
}

extension NSTextView {
    // gross (see: https://stackoverflow.com/questions/66721935/swiftui-how-to-disable-the-smart-quotes-in-texteditor)
    open override var frame: CGRect {
        didSet {
            self.isAutomaticQuoteSubstitutionEnabled = false
        }
    }
}

struct AppContent_Previews: PreviewProvider {
    static var apps     = SimModel().apps
    
    static var previews: some View {
        AppContent(app: apps[0])
        AppContent(app: apps.randomElement() ?? apps[1])
    }
}
