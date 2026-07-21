import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    
    // Theme Colors matching the rest of the app
    private let bgTeal = Color(red: 0.05, green: 0.78, blue: 0.67)
    private let accentGreen = Color(red: 0.20, green: 0.80, blue: 0.35)
    
    var body: some View {
        ZStack {
            // 1. Background Layers
            bgTeal.ignoresSafeArea()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        accentGreen.frame(width: 130, height: 70)
                        accentGreen.frame(width: 250, height: 70)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            // 2. Scrollable Content
            ScrollView {
                VStack(spacing: 24) {
                    // Header Bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                         
                        Spacer()
                         
                        Text("About Bloop")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                         
                        Spacer()
                         
                        // Invisible spacer for balance
                        Spacer().frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                     
                    // MARK: - INTRO SECTION
                    VStack(spacing: 12) {
                        Text("Welcome to Bloop 👋")
                            .font(.title3.bold())
                            .foregroundColor(.black)
                     
                        Text("An app where you can try new things and meet new people!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 24)
                     
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.title2)
                                .foregroundColor(bgTeal)
                                .frame(width: 32)
                          
                            Text("Whether you have a **solid event** in mind with a set date, time and location.")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.8))
                        }
                          
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .frame(width: 32)
                          
                            Text("Or if you just have an **idea**!")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.8))
                        }
                          
                        Divider()
                          
                        Text("Bloop helps you find people to connect with.")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Try creating a proposal")
                            .font(.headline)
                            .foregroundColor(.black)
                          
                        Text("You don’t need to finalize your event just yet! Simply create a proposal of something you would like to try:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                          
                        // Examples List
                        VStack(alignment: .leading, spacing: 12) {
                            ExampleRow(icon: "cup.and.saucer.fill", text: "Ask someone to teach you baking", tint: bgTeal)
                            ExampleRow(icon: "bicycle", text: "Ask someone to take you mountain biking", tint: bgTeal)
                            ExampleRow(icon: "book.fill", text: "Or maybe ask someone to come listen to your life story", tint: bgTeal)
                        }
                        .padding(.vertical, 8)
                          
                        Text("Just make a proposal, and wait for people to message you about it! You can figure out all the nitty-gritty details once people have signed up.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 24)
                     
                    // MARK: - OUTRO
                    VStack(spacing: 12) {
                        Text("We want this app to help people try new things and to learn from one another!")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 32)
                          
                        Text("Have fun,\n**InDecision**")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 60)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
     
    // Sub-view for the bullet points to keep code clean
    struct ExampleRow: View {
        let icon: String
        let text: String
        let tint: Color
          
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                    .frame(width: 24)
                Text(text)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.black.opacity(0.8))
            }
        }
    }
}
