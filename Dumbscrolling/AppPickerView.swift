import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @ObservedObject var manager: AppSelectionManager
    @State private var tempSelection: FamilyActivitySelection
    @Environment(\.dismiss) private var dismiss

    init(manager: AppSelectionManager) {
        self.manager = manager
        _tempSelection = State(initialValue: manager.selection)
    }

    var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $tempSelection)
                .navigationTitle("DOOMSCROLLING APPS")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .font(.system(size: 13, design: .monospaced))
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            manager.saveSelection(tempSelection)
                            dismiss()
                        }
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                    }
                }
        }
    }
}
