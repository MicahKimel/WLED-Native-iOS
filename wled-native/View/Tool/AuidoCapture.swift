//
//  AuidoCapture.swift
//  wled-native
//
//  Created by Micah Kimel on 12/6/24.
//

import Foundation
import AVFoundation

class AudioIntensityManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var audioIntensity: Int64 = 0
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    override init() {
        super.init()
        setupAudioRecorder()
    }
    
    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setCategory(
                .playAndRecord, // Use .record if you don't need playback
                options: [.mixWithOthers, .defaultToSpeaker]
            )
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("audioRecording.m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up audio recorder: \(error)")
        }
    }
    
    func startMeasuring() {
        audioRecorder?.record()
        
        // Update audio intensity every 0.1 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.audioRecorder?.updateMeters()
            
            // Convert decibel value to normalized intensity (0-1 range)
            if let power = self?.audioRecorder?.averagePower(forChannel: 0) {
                // Assuming typical range of -160 to 0 decibels
                let normalizedIntensity = max(0, min(1, (power + 160) / 160))
                let audioIntensity = self?.expandNumber(number: normalizedIntensity) ?? 0
                print(audioIntensity)
                self?.audioIntensity = audioIntensity
            }
        }
    }
    
    func stopMeasuring() {
        audioRecorder?.stop()
        timer?.invalidate()
        self.audioIntensity = 0
    }
    
    func expandNumber(number: Float) -> Int64 {
        
        print(number)
        if number < 0.7 {
            return 0
        }
        let minInput: Float = 0.7
        let maxInput: Float = 1.0
        let minOutput: Float = 1.0
        let maxOutput: Float = 255.0

        let normalizedInput = (number - minInput) / (maxInput - minInput)
        let expandedValue = normalizedInput * (maxOutput - minOutput) + minOutput
        
        print(Int64(expandedValue))
        return Int64(expandedValue)
    }
    
    deinit {
        stopMeasuring()
    }
}
