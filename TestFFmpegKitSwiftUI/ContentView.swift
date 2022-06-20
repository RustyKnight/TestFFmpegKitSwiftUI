//
//  ContentView.swift
//  TestFFmpegKitSwiftUI
//
//  Created by Shane Whitehead on 19/6/2022.
//

import SwiftUI
import ffmpegkit

struct ContentView: View {
    
    @State private var statusText: String?
    
    @State private var missingInput = false
    @State private var missingOutput = false
    
    @State private var outputSource: URL?
    
    var body: some View {
        VStack {
            Button {
                syncCommand()
            } label: {
                Text("Sync")
            }
            Button {
                asyncCommand()
            } label: {
                Text("Async")
            }
            
            if let outputSource = outputSource {
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([outputSource])
                } label: {
                    Text("Show in finder")
                }
            }
            
            if let statusText = statusText {
                Text(statusText)
            }
        }
        .alert("Missing input", isPresented: $missingInput) {
            Button {
                //
            } label: {
                Text("Ok")
            }
        }
        .alert("Missing output", isPresented: $missingOutput) {
            Button {
                //
            } label: {
                Text("Ok")
            }
        }
        .frame(width: 200, height: 200)
    }
    
    // Change these to something more useful.  The app is setup to allow read/write
    // to the users Download folder, so start there
    let inputFile = "Input.m4v"
    let outputFile = "Output.mp4"

    // This will block the main thread and is a bad idea
    private func syncCommand() {
        outputSource = nil
        guard let inputResource = Bundle.main.url(forResource: "Source", withExtension: "m4v") else {
            missingInput = true
            return
        }
        guard let outputPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            missingOutput = true
            return
        }
        let outputResource = outputPath.appendingPathComponent("Converted.mp4")
        
        // This will never appear
        statusText = "In progress..."
        guard let session = FFmpegKit.execute("-i \"\(inputResource.path)\" -y \"\(outputResource.path)\"") else {
            print("!! Failed to create session")
            return
        }
        let returnCode = session.getReturnCode()
        if ReturnCode.isSuccess(returnCode) {
            statusText = "Success"
            outputSource = outputResource
        } else if ReturnCode.isCancel(returnCode) {
            statusText = "Cancelled"
        } else {
            print("Command failed with state \(FFmpegKitConfig.sessionState(toString: session.getState()) ?? "Unknown") and rc \(returnCode?.description ?? "Unknown").\(session.getFailStackTrace() ?? "Unknown")")
            statusText = "Failed: \(returnCode?.description ?? "Unknown")"
        }
    }

    private func asyncCommand() {
        outputSource = nil
        guard let inputResource = Bundle.main.url(forResource: "Source", withExtension: "m4v") else {
            missingInput = true
            return
        }
        guard let outputPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            missingOutput = true
            return
        }
        let outputResource = outputPath.appendingPathComponent("Converted.mp4")
        statusText = "In progress..."
        FFmpegKit.executeAsync("-i \"\(inputResource.path)\" -y \"\(outputResource.path)\"") { session in
            guard let session = session else {
                print("!! Invalid session")
                statusText = "Invalid session"
                return
            }
            guard let returnCode = session.getReturnCode() else {
                print("!! Invalid return code")
                statusText = "Invalid return code"
                return
            }
            if ReturnCode.isSuccess(returnCode) {
                statusText = "Success \(outputResource.path)"
                outputSource = outputResource
            } else if ReturnCode.isCancel(returnCode) {
                statusText = "Cancelled"
            } else {
                print("Command failed with state \(FFmpegKitConfig.sessionState(toString: session.getState()) ?? "Unknown") and rc \(returnCode.description).\(session.getFailStackTrace() ?? "Unknown")")
                statusText = "Failed: \(returnCode.description)"
            }
        } withLogCallback: { logs in
            guard let logs = logs else { return }
            // CALLED WHEN SESSION PRINTS LOGS
            statusText = logs.getMessage()
        } withStatisticsCallback: { stats in
            guard let stats = stats else { return }
            // CALLED WHEN SESSION GENERATES STATISTICS
            statusText = stats.description
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
