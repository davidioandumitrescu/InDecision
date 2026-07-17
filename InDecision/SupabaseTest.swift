//
//  SupabaseTest.swift
//  InDecision
//
//  Created by Jacob Gellard on 16/7/2026.
//
import SwiftUI
import Supabase

func testConnection() async {
    do {
        let response = try await SupabaseManager.shared.client
            .from("events")
            .select()
            .execute()

        print(String(data: response.data, encoding: .utf8) ?? "")
        
    } catch {
        print(error)
    }
}

private func addEvent(event: DetailedEvent) async {
    do {

        try await SupabaseManager.shared.client
            .from("events")
            .insert(event)
            .execute()

        print("Event uploaded!")

    } catch {
        print("Upload failed:", error)
    }
}

struct SupaBaseView: View {
    var body: some View {
        VStack{
            Text("See all experiences!")
            Button {
                Task {
                    //await addEvent()
                }
            } label: {
                Text("Hello")
            }
            Button {
                Task {
                    await testConnection()
                }
            } label: {
                Text("Test")
            }
        }
    }
}
   
#Preview{
    SupaBaseView()
}
