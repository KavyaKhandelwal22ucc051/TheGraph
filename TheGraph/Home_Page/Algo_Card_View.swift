

import SwiftUI

struct Algo_Card_View: View {
    @EnvironmentObject var model: CarouselViewModel
        var card: Algo_Card
        var animation: Namespace.ID
        
        var body: some View {
            VStack {
                Text("Graph Algorithm")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .padding(.top, 10)
                    .matchedGeometryEffect(id: "Date-\(card.id)", in: animation)

                HStack {
                    Text(card.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 250, alignment: .leading)
                        .padding()
                        .matchedGeometryEffect(id: "Title-\(card.id)", in: animation)

                    Spacer(minLength: 0)
                }

                Spacer(minLength: 0)

                HStack {
                    Spacer(minLength: 0)

                    if !model.showContent {
                        Text("Read more")

                        Image(systemName: "arrow.right")
                    }
                }
                .foregroundColor(Color.white.opacity(0.9))
                .padding(30)
            }
            .frame(maxWidth: 800, maxHeight: 1500)
            .background(
                card.cardColor
                    .cornerRadius(25)
                    .matchedGeometryEffect(id: "bgColor-\(card.id)", in: animation)
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    model.selectedCard = card
                    model.showCard.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeIn) {
                            model.showContent.toggle()
                        }
                    }
                }
            }
        }
}

struct Algo_Card_View_Previews: PreviewProvider {
    @Namespace static var animation

    static var previews: some View {
        // Sample card
        let sampleCard = Algo_Card(
            cardColor: .blue,
            title: "Breadth First Search",
            description: "A graph traversal algorithm that explores all neighbors before going deeper."
        )

        // Sample model
        let model = CarouselViewModel()
        model.selectedCard = sampleCard
        model.showContent = false

        return Algo_Card_View(card: sampleCard, animation: animation)
            .environmentObject(model)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

