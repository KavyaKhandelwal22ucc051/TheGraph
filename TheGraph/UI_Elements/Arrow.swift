

import SwiftUI

struct Arrow: View {
    let next: Bool
    
    var body: some View {
        Image(next ? "right" : "left")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundColor(.blue)
    }
}

// Preview for testing
struct Arrow_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Arrow(next: false)
            Arrow(next: true)
        }
    }
}
