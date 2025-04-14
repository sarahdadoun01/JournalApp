//
//  AudioPlaybackView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-08.
//

import SwiftUI
import AVFoundation

struct AudioPlaybackView: View {
    var block: EntryBlock
    var entryID: String?
    @Binding var blocks: [EntryBlock]
    var showTitleAndSlider: Bool = true
    @State private var isRenaming = false
    @State private var newTitle = ""

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var animateWave = false

    @State private var duration: Double = 0
    @State private var currentTime: Double = 0
    @State private var isSeeking = false
    @State private var recordingStartTime: Date? = nil
    @State private var recordingTimer: Timer?
    @State private var showMenu = false

    private var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    private var formattedDuration: String {
        formatTime(duration)
    }

    private var formattedRecordingTime: String {
        if let start = recordingStartTime {
            let elapsed = Date().timeIntervalSince(start)
            return formatTime(elapsed)
        }
        return "00:00"
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
                    HStack(spacing: 12) {
                        Text(block.title.isEmpty ? "Untitled" : block.title)
                            .font(.subheadline)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        WaveformView(isAnimating: $animateWave)
                            .frame(height: 20)

                        if !showTitleAndSlider {
                            Text(formattedRecordingTime)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Menu(content: {
                            Button("Rename", action: {
                                newTitle = block.title
                                isRenaming = true
                            })
                            Button("Delete", role: .destructive, action: {
                                if let id = entryID {
                                    // Call Firebase delete logic here if available
                                    print("🔥 Delete from Firebase: \(block.content)")
                                }
                                    if let index = blocks.firstIndex(where: { $0.id == block.id }) {
                                        blocks.remove(at: index)
                                    }
                                })
                            }, label: {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))
                                    .foregroundColor(.gray)
                            })
                    }

                    if showTitleAndSlider {
                        Text(formattedDate)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }

            if showTitleAndSlider {
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
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(40)
        .onAppear {
            setupPlayer()
            if !showTitleAndSlider {
                startRecordingTimer()
            }
        }
        .onDisappear {
                recordingTimer?.invalidate()
        }
        .renameAlertView(
            isPresented: $isRenaming,
            currentTitle: block.title
        ) { newTitle in
            if let index = blocks.firstIndex(where: { $0.id == block.id }) {
                blocks[index].title = newTitle
            }
        }
        
    }

    private func setupPlayer() {
        guard let url = URL(string: block.content) else { return }
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

        // Observe player status to stop waveform when done
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
            isPlaying = false
            animateWave = false
        }
    }

    private func startRecordingTimer() {
        recordingStartTime = Date()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime += 1
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
        
        let previewBlock = EntryBlock(
            id: UUID(),
            title: "Preview Title",
            type: .audio,
            content: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
        )
        
        VStack(spacing: 20) {
            
            AudioPlaybackView(
                block: previewBlock,
                entryID: nil,
                blocks: .constant([previewBlock]),
                showTitleAndSlider: true
            )
            
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
}
