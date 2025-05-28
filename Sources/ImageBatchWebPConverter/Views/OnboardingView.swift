import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentStep = 0
    
    let onboardingSteps = [
        OnboardingStep(
            image: "photo.stack.fill",
            title: "Welcome to WebP Converter",
            description: "The smartest way to optimize your images for the web",
            color: .blue
        ),
        OnboardingStep(
            image: "sparkles",
            title: "AI-Powered Optimization",
            description: "Our smart algorithm analyzes each image to find the perfect balance between quality and file size",
            color: .purple
        ),
        OnboardingStep(
            image: "speedometer",
            title: "Files or Folders",
            description: "Drop individual files or entire folders - choose exactly what you want to convert",
            color: .orange
        ),
        OnboardingStep(
            image: "arrow.left.arrow.right",
            title: "Compare Results",
            description: "See side-by-side comparisons to ensure perfect quality",
            color: .green
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Skip button in top right
            HStack {
                Spacer()
                Button("Skip") {
                    hasSeenOnboarding = true
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .padding()
            }
            
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<onboardingSteps.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .animation(.easeInOut, value: currentStep)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            // Content
            TabView(selection: $currentStep) {
                ForEach(0..<onboardingSteps.count, id: \.self) { index in
                    OnboardingStepView(step: onboardingSteps[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.automatic)
            
            // Navigation buttons
            HStack(spacing: 20) {
                if currentStep > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                if currentStep < onboardingSteps.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        hasSeenOnboarding = true
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(30)
        }
        .frame(width: 600, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct OnboardingStep {
    let image: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingStepView: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            if #available(macOS 14.0, *) {
                Image(systemName: step.image)
                    .font(.system(size: 80))
                    .foregroundStyle(step.color.gradient)
                    .symbolEffect(.bounce, value: step.image)
            } else {
                Image(systemName: step.image)
                    .font(.system(size: 80))
                    .foregroundStyle(step.color.gradient)
            }
            
            // Title
            Text(step.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Description
            Text(step.description)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            Spacer()
        }
        .padding()
    }
} 