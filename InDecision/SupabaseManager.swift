import Foundation
import UIKit
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://mywuofymwhtiprsuqvwr.supabase.co")!,
            supabaseKey: "sb_publishable_Ae_LxBJCvcGpPY-tQCmHsA_Psd51mOs"
        )
    }
    // MARK: - Avatar Loading

    private static let avatarCache = NSCache<NSString, UIImage>()

    /// Looks up a user's avatar_url from the profiles table.
    private func fetchAvatarURL(for userID: UUID) async -> String? {
        struct AvatarRow: Decodable { let avatar_url: String? }

        do {
            let rows: [AvatarRow] = try await client
                .from("profiles")
                .select("avatar_url")
                .eq("id", value: userID.uuidString)
                .limit(1)
                .execute()
                .value

            return rows.first?.avatar_url
        } catch {
            print("❌ Fetching avatar_url failed:", error)
            return nil
        }
    }

    /// Fetches and decodes a user's avatar image by their user ID.
    /// Looks up their avatar_url, then downloads and caches the image in memory.
    func loadAvatarImage(forUser userID: UUID, useCache: Bool = true) async -> UIImage? {
        guard let urlString = await fetchAvatarURL(for: userID) else { return nil }
        return await loadAvatarImage(from: urlString, useCache: useCache)
    }

    /// Fetches and decodes an avatar image from a direct public Storage URL.
    /// Results are cached in memory by URL string, so calling this repeatedly
    /// (e.g. from a list of participant rows) won't refetch the same image.
    func loadAvatarImage(from urlString: String?, useCache: Bool = true) async -> UIImage? {
        guard let urlString, let url = URL(string: urlString) else { return nil }

        let cacheKey = urlString as NSString

        if useCache, let cached = Self.avatarCache.object(forKey: cacheKey) {
            return cached
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                print("❌ Avatar fetch HTTP \(http.statusCode):", String(data: data, encoding: .utf8) ?? "")
                return nil
            }

            guard let image = UIImage(data: data) else {
                print("❌ Avatar data wasn't a decodable image (\(data.count) bytes)")
                return nil
            }

            if useCache {
                Self.avatarCache.setObject(image, forKey: cacheKey)
            }

            return image
        } catch {
            print("❌ Avatar loading failed:", error)
            return nil
        }
    }

    /// Call this right after re-uploading to a path you've fetched before (e.g. upsert to the
    /// same "avatar.jpg" path), otherwise the cache will keep serving the old image.
    func invalidateAvatarCache(for urlString: String) {
        Self.avatarCache.removeObject(forKey: urlString as NSString)
    }
}

