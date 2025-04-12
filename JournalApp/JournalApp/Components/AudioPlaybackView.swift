//
//  AudioPlaybackView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-08.
//

import SwiftUI
import AVFoundation

struct AudioPlaybackView: View {
    let audioFileName: String

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var animateWave = false

    @State private var duration: Double = 0
    @State private var currentTime: Double = 0
    @State private var isSeeking = false

    private var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    private var formattedDuration: String {
        formatTime(duration)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(audioFileName)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .font(.subheadline)

                    Text(formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            WaveformView(isAnimating: $animateWave)
                .frame(height: 20)

            Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                isSeeking = editing
                if !editing {
                    seekToTime(currentTime)
                }
            })

            HStack {
                Text(formattedCurrentTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text(formattedDuration)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            setupPlayer()
        }
    }

    private func setupPlayer() {
        guard let url = URL(string: audioFileName) else { return }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Observe duration
        playerItem.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            DispatchQueue.main.async {
                let seconds = CMTimeGetSeconds(playerItem.asset.duration)
                if !seconds.isNaN {
                    duration = seconds
                }
            }
        }

        // Update currentTime every 0.1s
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { time in
            if !isSeeking {
                currentTime = CMTimeGetSeconds(time)
            }
        }
    }

    private func togglePlayback() {
        guard let player = player else { return }

        if isPlaying {
            player.pause()
            animateWave = false
        } else {
            player.play()
            animateWave = true
        }

        isPlaying.toggle()
    }

    private func seekToTime(_ time: Double) {
        let newTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: newTime)
    }

    private func formatTime(_ time: Double) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%01d:%02d", mins, secs)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}


struct AudioPlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AudioPlaybackView(audioFileName: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

