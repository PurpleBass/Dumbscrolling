import AVFoundation
import AVKit
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    @Published var isRunning = false
    let session = AVCaptureSession()
    private var pipController: AVPictureInPictureController?
    private var pipVC: AVPictureInPictureVideoCallViewController?
    private var pipSourceView: UIView?

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .medium

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        session.commitConfiguration()
    }

    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async { self?.isRunning = true }
        }
    }

    func stop() {
        guard session.isRunning else { return }
        stopPiP()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async { self?.isRunning = false }
        }
    }

    func setupPiP() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }

        // Build the PiP view controller and embed camera preview into it
        let vc = AVPictureInPictureVideoCallViewController()
        vc.preferredContentSize = CGSize(width: 108, height: 144)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = CGRect(origin: .zero, size: CGSize(width: 108, height: 144))
        previewLayer.connection?.isVideoMirrored = true
        vc.view.layer.addSublayer(previewLayer)

        // Source view must live in the window hierarchy
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let sourceView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sourceView.alpha = 0
        window.addSubview(sourceView)
        pipSourceView = sourceView

        let contentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: sourceView,
            contentViewController: vc
        )
        pipController = AVPictureInPictureController(contentSource: contentSource)
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        pipVC = vc
    }

    func startPiP() {
        if pipController == nil { setupPiP() }
        pipController?.startPictureInPicture()
    }

    func stopPiP() {
        pipController?.stopPictureInPicture()
        pipSourceView?.removeFromSuperview()
        pipSourceView = nil
        pipController = nil
        pipVC = nil
    }
}
