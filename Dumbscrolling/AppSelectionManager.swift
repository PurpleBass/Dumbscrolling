import FamilyControls
import Combine

@MainActor
class AppSelectionManager: ObservableObject {
    static let shared = AppSelectionManager()

    @Published var isAuthorized = false
    @Published var selection = FamilyActivitySelection()

    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    private let selectionKey = "savedAppSelection"

    init() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        loadSelection()
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            print("Screen Time authorization failed: \(error)")
        }
    }

    func saveSelection(_ newSelection: FamilyActivitySelection) {
        selection = newSelection
        if let data = try? encoder.encode(newSelection) {
            UserDefaults.standard.set(data, forKey: selectionKey)
        }
    }

    var selectedAppCount: Int {
        selection.applications.count
    }

    private func loadSelection() {
        guard let data = UserDefaults.standard.data(forKey: selectionKey),
              let saved = try? decoder.decode(FamilyActivitySelection.self, from: data) else { return }
        selection = saved
    }
}
