//
//  AudioRecorderUploader.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//


import SwiftUI
import AVFoundation

class AudioRecorderUploader: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession?
    private var audioFileURL: URL?
    private var shouldUploadOnFinish = false

    
    @Published var isRecording = false
    @Published var isUploading = false
    @Published var isPlaying = false
    @Published var serverResponse: String?
    @Published var errorMessage: String?
    @Published var progressScore: Double?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default,options: [.defaultToSpeaker, .allowBluetooth])
            try recordingSession?.setActive(true)
        } catch {
            errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    // For playing response audio
    func togglePlayback() {
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    private func startRecording() {
        print("DEBUG: Attempting to start recording...")
        
        // Check microphone permission
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            print("DEBUG: Microphone permission undetermined")
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                print("DEBUG: Microphone permission granted: \(granted)")
            }
        case .denied:
            print("DEBUG: Microphone permission denied")
            errorMessage = "Microphone access denied. Please enable it in Settings."
            return
        case .granted:
            print("DEBUG: Microphone permission already granted")
        @unknown default:
            print("DEBUG: Unknown microphone permission status")
        }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(Date().timeIntervalSince1970).wav")
        audioFileURL = audioFilename
        print("DEBUG: Audio file URL: \(audioFilename.path)")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            let prepareSuccess = audioRecorder?.prepareToRecord() ?? false
            print("DEBUG: Prepare to record success: \(prepareSuccess)")
            
            let recordingSuccess = audioRecorder?.record() ?? false
            print("DEBUG: Recording started success: \(recordingSuccess)")
            
            if recordingSuccess {
                isRecording = true
                print("DEBUG: Recording started successfully")
            } else {
                print("DEBUG: Failed to start recording")
                errorMessage = "Failed to start recording"
            }
        } catch {
            print("DEBUG: Recording error: \(error.localizedDescription)")
            errorMessage = "Could not start recording: \(error.localizedDescription)"
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        uploadRecording()
    }
    
    // Update your uploadRecording method's response handling:
    private func uploadRecording() {
        guard let audioFileURL = audioFileURL else {
            errorMessage = "No audio file to upload"
            return
        }
        
        // Prevent multiple simultaneous uploads
        guard !isUploading else {
            print("DEBUG: Upload already in progress, skipping")
            return
        }
        
        isUploading = true
        print("Starting upload...")
        
        let uploadURL = URL(string: "http://10.228.255.195:8000/butterask")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.wav\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/wave\r\n\r\n".data(using: .utf8)!)
        
        do {
            let audioData = try Data(contentsOf: audioFileURL)
            data.append(audioData)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = data
            
            Task {
                do {
                    let (responseData, _) = try await URLSession.shared.data(for: request)
                    try await handleServerResponse(responseData)
                } catch {
                    await MainActor.run {
                        self.errorMessage = "Error: \(error.localizedDescription)"
                        self.isUploading = false
                    }
                }
            }
        } catch {
            errorMessage = "Failed to prepare audio: \(error.localizedDescription)"
            isUploading = false
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func handleServerResponse(_ responseData: Data) async throws {
        print("Starting to handle server response...")
        print("DEBUG: Full JSON Response: \(String(describing: try? JSONSerialization.jsonObject(with: responseData)))")
        
        // First try to decode the response as JSON
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            print("Failed to parse JSON response")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
        }
        
        // Extract text, audio, and progress score from response
        guard let textResponse = jsonResponse["text"] as? String,
              let audioBase64 = jsonResponse["audio"] as? String,
              let progressScore = jsonResponse["progress"] as? Double else {
            print("Missing required fields in response")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing required fields in response"])
        }
        
        // Decode audio data
        guard let audioData = Data(base64Encoded: audioBase64) else {
            print("Failed to decode audio data")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid audio data"])
        }
        
        // Save audio file
        let responseAudioURL = getDocumentsDirectory().appendingPathComponent("response_\(Date().timeIntervalSince1970).wav")
        try audioData.write(to: responseAudioURL)
        print("Saved audio file to: \(responseAudioURL.path)")
        
        // Setup audio player
        let player = try AVAudioPlayer(contentsOf: responseAudioURL)
        player.delegate = self
        player.prepareToPlay()
        
        // Update UI on main thread and start playing
        await MainActor.run {
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            } catch {
                print("Failed to override audio output to speaker: \(error)")
            }
            self.audioPlayer = player
            self.serverResponse = textResponse
            self.progressScore = progressScore
            self.isUploading = false
            self.isPlaying = true  // Set playing state to true
            self.audioPlayer?.play() // Start playing immediately
            print("Successfully processed server response and started playback")
        }
    }}


extension AudioRecorderUploader: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("DEBUG: audioRecorderDidFinishRecording called, successfully: \(flag)")
        if !flag {
            errorMessage = "Recording failed"
            return
        }
        
        if shouldUploadOnFinish {
            print("DEBUG: Starting upload from delegate")
            uploadRecording()
            shouldUploadOnFinish = false
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}

extension AudioRecorderUploader {
    func stopAndClearPlayback() {
        // Stop any playing audio
        if isPlaying {
            audioPlayer?.stop()
            audioPlayer = nil
            isPlaying = false
        }
        
        // Reset states
        isUploading = false
        errorMessage = nil
    }
}
