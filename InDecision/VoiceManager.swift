import Foundation
import AVFoundation
import Supabase
import Combine // 👉 Fixes the ObservableObject error

class VoiceManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var currentRecordingURL: URL?
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Recording Logic
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            // 👉 iOS 17+ updated permission request
            AVAudioApplication.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self?.record()
                    }
                }
            }
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func record() {
        let fileName = "\(UUID().uuidString).m4a"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        self.currentRecordingURL = fileURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecordingAndReturnURL() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        return currentRecordingURL
    }
    
    // MARK: - Review Functions
    func playJustRecordedSound() {
        guard let url = currentRecordingURL else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play recorded sound: \(error)")
        }
    }
    
    func discardRecording() {
        guard let url = currentRecordingURL else { return }
        try? FileManager.default.removeItem(at: url)
        currentRecordingURL = nil
        audioPlayer?.stop()
    }
    
    // MARK: - Supabase Upload (1-to-1 User Linked)
        func uploadFinishedRecording(fileURL: URL, userID: UUID) async {
            // 👇 Name the file after the user so it ALWAYS overwrites their old one
            let fileName = "\(userID.uuidString).m4a"
            
            do {
                let audioData = try Data(contentsOf: fileURL)
                
                // 1. Upload to Storage with UPSERT enabled (overwrites old file)
                try await SupabaseManager.shared.client.storage
                    .from("join_sounds")
                    .upload(
                        fileName,
                        data: audioData,
                        options: FileOptions(contentType: "audio/m4a", upsert: true) // 👈 Upsert is true
                    )
                
                // 2. Upsert into Database
                struct SoundRecord: Encodable {
                    let file_path: String
                    let user_id: UUID
                }
                
                // Upsert will update the row if user_id already exists, or insert if new
                try await SupabaseManager.shared.client
                    .from("sounds_table")
                    .upsert(SoundRecord(file_path: fileName, user_id: userID))
                    .execute()
                    
                print("Sound successfully saved to profile!")
            } catch {
                print("Failed to upload sound: \(error)")
            }
        }
        
        // MARK: - Check & Delete Existing Sounds
        func checkUserHasSound(userID: UUID) async -> Bool {
            do {
                // See if a row exists for this user
                let response: [String: String] = try await SupabaseManager.shared.client
                    .from("sounds_table")
                    .select("file_path")
                    .eq("user_id", value: userID.uuidString)
                    .execute()
                    .value
                
                return !response.isEmpty
            } catch {
                return false
            }
        }
        
        func deleteUserSound(userID: UUID) async {
            let fileName = "\(userID.uuidString).m4a"
            do {
                // 1. Delete from storage
                try await SupabaseManager.shared.client.storage
                    .from("join_sounds")
                    .remove(paths: [fileName])
                
                // 2. Delete from database
                try await SupabaseManager.shared.client
                    .from("sounds_table")
                    .delete()
                    .eq("user_id", value: userID.uuidString)
                    .execute()
                    
                print("Sound successfully deleted.")
            } catch {
                print("Failed to delete sound: \(error)")
            }
        }
    
    // MARK: - Supabase Download (Call on app launch)
    func fetchRandomSoundForSession() async {
        do {
            struct FetchedSound: Decodable {
                let file_path: String
            }
            
            let sounds: [FetchedSound] = try await SupabaseManager.shared.client
                .from("sounds_table")
                .select("file_path")
                .execute()
                .value
            
            guard let randomSound = sounds.randomElement() else {
                print("No sounds found in database.")
                return
            }
            
            let audioData = try await SupabaseManager.shared.client.storage
                .from("join_sounds")
                .download(path: randomSound.file_path)
            
            let localURL = getDocumentsDirectory().appendingPathComponent("session_join_sound.m4a")
            try audioData.write(to: localURL)
            
            print("Session sound downloaded and ready!")
            
        } catch {
            print("Failed to fetch session sound: \(error)")
        }
    }
    
    // MARK: - Playback Logic
    func playSessionSound() {
        let localURL = getDocumentsDirectory().appendingPathComponent("session_join_sound.m4a")
        guard FileManager.default.fileExists(atPath: localURL.path) else {
            print("Session sound not found on device.")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: localURL)
            audioPlayer?.play()
        } catch {
            print("Could not play sound: \(error)")
        }
    }
}
