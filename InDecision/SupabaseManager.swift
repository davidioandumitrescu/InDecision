
//
//  SupabaseManager.swift
//  InDecision
//
//  Created by Jacob Gellard on 16/7/2026.
//

import Foundation
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
}


