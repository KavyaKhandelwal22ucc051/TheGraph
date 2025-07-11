

import SwiftUI

struct Showdown: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Congratulations! 🎉")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            Text("You've reached the end of the journey.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("We hope you learned something new and had fun!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.yellow)
                .padding()

            Button(action: {
                // Add your restart or navigation logic here
            }) {
                Text("Restart")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color("cream").edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    Showdown()
}
