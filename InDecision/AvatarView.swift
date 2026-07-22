//
//  AvatarView.swift
//  InDecision
//
//  Created by Jacob Gellard on 21/7/2026.
//

import SwiftUI

struct AvatarView: View {
    let userID: UUID?
    var size: CGFloat = 40
    var placeholderColor: Color = .white.opacity(0.9)

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(placeholderColor)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .task(id: userID) {
            guard let userID else {
                image = nil
                return
            }
            image = await SupabaseManager.shared.loadAvatarImage(forUser: userID)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AvatarView(userID: nil, size: 60)
        AvatarView(userID: UUID(), size: 60)
    }
    .padding()
    .background(Color.teal)
}
