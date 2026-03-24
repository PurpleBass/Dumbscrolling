import ActivityKit
import WidgetKit
import SwiftUI

struct DumbscrollingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ShameActivityAttributes.self) { context in
            // Lock screen / banner view
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded (long press)
                DynamicIslandExpandedRegion(.leading) {
                    Text(shameEmoji(for: context.state.elapsedSeconds))
                        .font(.system(size: 36))
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formattedTime(context.state.elapsedSeconds))
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 1, green: 0.45, blue: 0.1))
                        Text("DOOMSCROLLING")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(1)
                    }
                    .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ShameTickerView(message: context.state.shameMessage)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                }
            } compactLeading: {
                Text(shameEmoji(for: context.state.elapsedSeconds))
                    .font(.system(size: 16))
            } compactTrailing: {
                Text(formattedTime(context.state.elapsedSeconds))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1, green: 0.45, blue: 0.1))
                    .minimumScaleFactor(0.7)
            } minimal: {
                Text(shameEmoji(for: context.state.elapsedSeconds))
                    .font(.system(size: 14))
            }
            .keylineTint(Color(red: 1, green: 0.4, blue: 0.1))
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<ShameActivityAttributes>) -> some View {
        HStack(spacing: 16) {
            Text(shameEmoji(for: context.state.elapsedSeconds))
                .font(.system(size: 44))

            VStack(alignment: .leading, spacing: 4) {
                Text(formattedTime(context.state.elapsedSeconds))
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(Color(red: 1, green: 0.45, blue: 0.1))

                Text("DOOMSCROLLING SESSION")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .tracking(2)

                ShameTickerView(message: context.state.shameMessage)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color.black)
    }

    private func formattedTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func shameEmoji(for seconds: Int) -> String {
        let emojis = ["😳", "🤦", "😬", "🙈", "💀", "🫠", "😵", "🤡", "🫣"]
        return emojis[(seconds / 8) % emojis.count]
    }
}

// MARK: - Scrolling ticker inside Live Activity

struct ShameTickerView: View {
    let message: String
    @State private var offset: CGFloat = 300

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(red: 0.08, green: 0.04, blue: 0.0))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Text(message + message)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
                    .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.0).opacity(0.9), radius: 3)
                    .fixedSize()
                    .offset(x: offset)
            }
            .frame(height: 22)
            .clipped()
            .onAppear {
                offset = geo.size.width
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    offset = -500
                }
            }
            .onChange(of: message) {
                offset = geo.size.width
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    offset = -500
                }
            }
        }
        .frame(height: 22)
    }
}
