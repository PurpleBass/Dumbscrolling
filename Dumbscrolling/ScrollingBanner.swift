import SwiftUI

struct ScrollingBanner: View {
    let text: String
    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                // Background — retro amber/orange like old LED signs
                Rectangle()
                    .fill(Color(red: 0.08, green: 0.05, blue: 0.0))

                // The scrolling text layer
                Text(text + text)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0))
                    .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.0).opacity(0.8), radius: 4)
                    .fixedSize()
                    .background(
                        GeometryReader { tg in
                            Color.clear.onAppear {
                                textWidth = tg.size.width / 2
                                containerWidth = w
                                offset = w
                            }
                        }
                    )
                    .offset(x: offset)
            }
            .clipped()
            .onChange(of: text) { _ in
                offset = w
                startScrolling(width: w)
            }
            .onAppear {
                startScrolling(width: w)
            }
        }
        .frame(height: 28)
        .overlay(
            // Scanline effect
            VStack(spacing: 2) {
                ForEach(0..<14, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.15))
                        .frame(height: 1)
                    Spacer()
                }
            }
        )
        .overlay(
            // LED dot grid
            Canvas { context, size in
                let dotSpacing: CGFloat = 4
                for x in stride(from: 0, through: size.width, by: dotSpacing) {
                    for y in stride(from: 0, through: size.height, by: dotSpacing) {
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                            with: .color(.black.opacity(0.25))
                        )
                    }
                }
            }
        )
    }

    private func startScrolling(width: CGFloat) {
        guard textWidth > 0 else { return }
        withAnimation(.linear(duration: Double(textWidth + width) / 60)) {
            offset = -textWidth
        }
    }
}
