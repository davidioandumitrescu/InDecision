import SwiftUI
import AVFoundation
import Combine

struct RecordButtonView: View {
    @EnvironmentObject var voiceManager: VoiceManager
    @EnvironmentObject var authManager: AuthManager // 👈 Need this for the UserID
    var btnPurple: Color
    
    enum RecordingState {
        case idle, recording, reviewing, uploading
    }
    
    @State private var currentState: RecordingState = .idle
    @State private var recordedURL: URL? = nil
    @State private var hasExistingSound: Bool = false // 👈 Tracks if they already have one
    
    var body: some View {
        VStack(spacing: 16) {
            
            // 👉 Show badge if they have a sound on file
            if hasExistingSound && currentState == .idle {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("You have a custom sound active!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.4))
                .clipShape(Capsule())
            }
            
            switch currentState {
            case .idle, .recording:
                Button(action: {}) {
                    Image(systemName: currentState == .recording ? "mic.fill" : "mic")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(currentState == .recording ? Color.red : Color.black.opacity(0.3))
                        .clipShape(Circle())
                        .scaleEffect(currentState == .recording ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentState)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if currentState != .recording {
                                currentState = .recording
                                voiceManager.startRecording()
                            }
                        }
                        .onEnded { _ in
                            currentState = .reviewing
                            recordedURL = voiceManager.stopRecordingAndReturnURL()
                        }
                )
                
                Text(currentState == .recording ? "Release to Review" : (hasExistingSound ? "Hold to Overwrite" : "Hold to Record"))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                // 👉 Explicit Delete Button if they want to remove it entirely
                if hasExistingSound && currentState == .idle {
                    Button("Remove Sound") {
                        Task {
                            if let uid = authManager.userID {
                                await voiceManager.deleteUserSound(userID: uid)
                                hasExistingSound = false
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
                }
                
            case .reviewing:
                HStack(spacing: 24) {
                    // Discard
                    Button(action: {
                        voiceManager.discardRecording()
                        withAnimation { currentState = .idle }
                    }) {
                        Image(systemName: "trash.fill")
                            // ... your existing styling ...
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    // Play
                    Button(action: {
                        voiceManager.playJustRecordedSound()
                    }) {
                        Image(systemName: "play.fill")
                            // ... your existing styling ...
                            .frame(width: 70, height: 70)
                            .background(btnPurple)
                            .clipShape(Circle())
                    }
                    
                    // Confirm & Upload
                    Button(action: {
                        guard let url = recordedURL, let uid = authManager.userID else { return }
                        currentState = .uploading
                        Task {
                            // 👈 Pass the UserID into the upload function
                            await voiceManager.uploadFinishedRecording(fileURL: url, userID: uid)
                            hasExistingSound = true
                            withAnimation { currentState = .idle }
                        }
                    }) {
                        Image(systemName: "arrow.up")
                            // ... your existing styling ...
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                
                Text(hasExistingSound ? "Upload to replace old sound" : "Listen, discard, or upload!")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
            case .uploading:
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Saving to profile...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(height: 80)
            }
        }
        // 👉 Check if they have a sound when the view appears
        .task {
            if let uid = authManager.userID {
                hasExistingSound = await voiceManager.checkUserHasSound(userID: uid)
            }
        }
    }
}
