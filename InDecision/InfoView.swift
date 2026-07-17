import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text("About Bloop")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible spacer frame to ensure perfect title centering
                    Spacer()
                        .frame(width: 50, height: 50)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // MARK: - INTRO SECTION
                VStack(spacing: 12) {
                    Text("Welcome to Bloop 👋")
                        .font(.title3)
                        .bold()
                    
                    Text("An app where you can try new things and meet new people!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 32)
                        
                        Text("Whether you have a **solid event** in mind with a set date, time and location.")
                            .font(.subheadline)
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                            .frame(width: 32)
                        
                        Text("Or if you just have an **idea**!")
                            .font(.subheadline)
                    }
                    
                    Divider()
                    
                    Text("Bloop helps you find people to connect with.")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Try creating a proposal")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("You don’t need to finalize your event just yet! Simply create a proposal of something you would like to try:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Examples List
                    VStack(alignment: .leading, spacing: 12) {
                        ExampleRow(icon: "cup.and.saucer.fill", text: "Ask someone to teach you baking")
                        ExampleRow(icon: "bicycle", text: "Ask someone to take you mountain biking")
                        ExampleRow(icon: "book.fill", text: "Or maybe ask someone to come listen to your life story")
                    }
                    .padding(.vertical, 8)
                    
                    Text("Just make a proposal, and wait for people to message you about it! You can figure out all the nitty-gritty details once people have signed up.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // MARK: - OUTRO
                VStack(spacing: 12) {
                    Text("We want this app to help people try new things and to learn from one another!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                    
                    Text("Have fun,\n**InDecision**")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        // Use a very light off-white background so the pure white cards pop
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // Sub-view for the bullet points to keep code clean
    struct ExampleRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(text)
                    .font(.subheadline)
                    .bold()
            }
        }
    }
}

#Preview {
    InfoView()
}
