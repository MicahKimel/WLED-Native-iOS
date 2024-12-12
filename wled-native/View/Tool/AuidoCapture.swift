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
    
    @Published var minIntensity: Float = 0.7
    @Published var isScreenAudio: Bool = true
    @Published var updateTime: Float = 0.25
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    // How many Colors to Send
    @Published var ColorCount: Int = 1
    
    // Default First Color Red
    @Published var rgbValuesNow1: [Int64] = [255, 0, 0]
    @Published var rgbValuesLow1: [Int64] = [255, 0, 0]
    @Published var rgbValuesHigh1: [Int64] = [255, 0, 0]
    
    // Default Second Color Green
    @Published var rgbValuesNow2: [Int64] = [255, 0, 0]
    @Published var rgbValuesLow2: [Int64] = [0, 255, 0]
    @Published var rgbValuesHigh2: [Int64] = [0, 255, 0]
    
    // Default Third Color Blue
    @Published var rgbValuesNow3: [Int64] = [255, 0, 0]
    @Published var rgbValuesLow3: [Int64] = [0, 0, 255]
    @Published var rgbValuesHigh3: [Int64] = [0, 0, 255]
    
    override init() {
        super.init()
        setupAudioRecorder()
    }
    
    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            if isScreenAudio {
                try audioSession.setCategory(
                    .playAndRecord, // Use .record if you don't need playback
                    options: [.mixWithOthers, .defaultToSpeaker] // Screen input
                )
            } else {
                // Mic audio
                try audioSession.setCategory(
                    .playAndRecord, // Use .record if you don't need playback
                    mode: .default // Mic Input
                )
            }
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
        if number < self.minIntensity {
            return 0
        }
        let minInput: Float = self.minIntensity
        let maxInput: Float = 1.0
        let minOutput: Float = 1.0
        let maxOutput: Float = 255.0

        let normalizedInput = (number - minInput) / (maxInput - minInput)
        let expandedValue = normalizedInput * (maxOutput - minOutput) + minOutput
        
        // To Debug
        print(Int64(expandedValue))
        // Set Now Colors
        self.rgbValuesNow1 = interpolateColor(fromColor: rgbValuesLow1, toColor: rgbValuesHigh1, factor: CGFloat(expandedValue))
        self.rgbValuesNow2 = interpolateColor(fromColor: rgbValuesLow2, toColor: rgbValuesHigh2, factor: CGFloat(expandedValue))
        self.rgbValuesNow3 = interpolateColor(fromColor: rgbValuesLow3, toColor: rgbValuesHigh3, factor: CGFloat(expandedValue))
        
        return Int64(expandedValue)
    }
    
    func interpolateColor(fromColor: [Int64], toColor: [Int64], factor: CGFloat) -> [Int64] {
        let r = CGFloat(fromColor[0]) + CGFloat(toColor[0] - fromColor[0]) * factor
        let g = CGFloat(fromColor[1]) + CGFloat(toColor[1] - fromColor[1]) * factor
        let b = CGFloat(fromColor[2]) + CGFloat(toColor[2] - fromColor[2]) * factor

        return [Int64(r/255), Int64(g/255), Int64(b/255)]
    }
    
    deinit {
        stopMeasuring()
    }
}
