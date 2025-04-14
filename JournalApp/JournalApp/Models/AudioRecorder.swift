//
//  AudioRecorder.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-12.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    static let shared = AudioRecorder()
    
    private var recorder: AVAudioRecorder?

    func startRecording(to url: URL, completion: @escaping (Bool) -> Void) {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.delegate = self
            recorder?.record()
            completion(true)
        } catch {
            print("❌ Failed to start recording:", error)
            completion(false)
        }
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
    }
}
