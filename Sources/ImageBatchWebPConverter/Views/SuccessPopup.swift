import SwiftUI

struct SuccessPopup: View {
    let imagesCount: Int
    let totalSaved: Int64
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.green)
            }
            
            // Success message
            VStack(spacing: 8) {
                Text("Conversion Complete!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(imagesCount) images processed")
                    .foregroundColor(.secondary)
                
                Text("Total space saved: \(Double(totalSaved).formatFileSize())")
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            
            // Dismiss button
            Button("Done") {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top)
        }
        .padding(30)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1
                opacity = 1
            }
        }
    }
} 