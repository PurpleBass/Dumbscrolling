import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var session = ShameSession()
    @StateObject private var camera = CameraManager()
    @StateObject private var appSelection = AppSelectionManager.shared
    @State private var cameraAuthorized = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var showAppPicker = false

    private let shameEmojis = ["😳", "🤦", "😬", "🙈", "💀", "🫠", "😵", "🤡", "🫣"]
    @State private var emojiIndex = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Top: Dynamic Island mock + camera preview ──
                dynamicIslandSection

                Spacer().frame(height: 24)

                // ── Scrolling banner ──
                ScrollingBanner(text: session.currentShameMessage)
                    .padding(.horizontal, 0)

                Spacer().frame(height: 24)

                // ── Camera selfie box ──
                cameraBox

                Spacer().frame(height: 24)

                // ── Timer ──
                timerSection

                Spacer().frame(height: 24)

                // ── App triggers ──
                appTriggerSection

                Spacer()

                // ── Start / Stop ──
                controlButton

                Spacer().frame(height: 40)
            }
        }
        .onAppear { requestCamera() }
        .sheet(isPresented: $showAppPicker) {
            AppPickerView(manager: appSelection)
        }
    }

    // MARK: - Subviews

    private var dynamicIslandSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .frame(width: 126, height: 37)
                .overlay(
                    HStack(spacing: 6) {
                        Text(shameEmojis[emojiIndex])
                            .font(.system(size: 18))
                            .scaleEffect(pulseScale)
                            .onAppear { startEmojiPulse() }
                        if session.isActive {
                            Text(session.formattedTime)
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                )
                .shadow(color: .white.opacity(0.05), radius: 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    private var cameraBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.07))
                .frame(width: 220, height: 280)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            session.isActive
                                ? Color(red: 1, green: 0.3, blue: 0.1)
                                : Color(white: 0.2),
                            lineWidth: 2
                        )
                )

            if cameraAuthorized {
                CameraPreviewView(session: camera.session)
                    .frame(width: 216, height: 276)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                VStack(spacing: 8) {
                    Text("😳")
                        .font(.system(size: 60))
                    Text("Allow camera access\nto see your shame")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }

            if session.isActive {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("LIVE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .padding(10)
                    }
                }
                .frame(width: 216, height: 276)
            }
        }
    }

    private var timerSection: some View {
        VStack(spacing: 4) {
            Text(session.formattedTime)
                .font(.system(size: 64, weight: .black, design: .monospaced))
                .foregroundColor(session.isActive ? Color(red: 1, green: 0.35, blue: 0.1) : .white.opacity(0.3))
                .shadow(color: session.isActive ? Color(red: 1, green: 0.3, blue: 0.0).opacity(0.6) : .clear, radius: 12)

            Text(session.isActive ? "TIME WASTED" : "READY TO SHAME YOU")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .tracking(3)
        }
    }

    private var appTriggerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("SHAME TRIGGERS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .tracking(3)
                Spacer()
                if appSelection.selectedAppCount > 0 {
                    Text("\(appSelection.selectedAppCount) APP\(appSelection.selectedAppCount == 1 ? "" : "S")")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 1, green: 0.6, blue: 0.0))
                }
            }
            .padding(.horizontal, 32)

            Button {
                Task {
                    if !appSelection.isAuthorized {
                        await appSelection.requestAuthorization()
                    }
                    if appSelection.isAuthorized {
                        showAppPicker = true
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: appSelection.selectedAppCount > 0 ? "apps.iphone" : "plus.circle")
                        .font(.system(size: 13, weight: .bold))
                    Text(appSelection.selectedAppCount > 0 ? "EDIT APPS" : "SELECT APPS")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(white: 0.75))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if appSelection.selectedAppCount > 0 {
                Text("Camera will appear in Dynamic Island when you open these apps")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color(white: 0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }

    private var controlButton: some View {
        Button {
            if session.isActive {
                session.stop()
                camera.stop()
            } else {
                session.start()
                camera.start()
                camera.startPiP()
                Task { await LiveActivityManager.shared.start() }
                cycleEmoji()
            }
        } label: {
            Text(session.isActive ? "STOP THE SHAME" : "START SHAME SESSION")
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .tracking(1)
                .foregroundColor(.black)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    session.isActive
                        ? Color(red: 1, green: 0.3, blue: 0.1)
                        : Color(red: 1, green: 0.6, blue: 0.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Helpers

    private func requestCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
            camera.start()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraAuthorized = granted
                    if granted { camera.start() }
                }
            }
        default: break
        }
    }

    private func startEmojiPulse() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
    }

    private func cycleEmoji() {
        Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { t in
            guard session.isActive else { t.invalidate(); return }
            emojiIndex = (emojiIndex + 1) % shameEmojis.count
        }
    }
}
