import BrazeKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var manager: BrazeManager

    @State private var pendingUserId: String = ""
    @State private var customEventName: String = "demo_event"
    @State private var attributeKey: String = "favorite_color"
    @State private var attributeValue: String = "indigo"
    @State private var purchaseAmount: String = "9.99"

    var body: some View {
        NavigationStack {
            Form {
                Section("SDK") {
                    LabeledContent("Current user") {
                        Text(manager.currentUserId)
                    }
                    Text(manager.lastOperationStatus.isEmpty ? "Ready" : manager.lastOperationStatus)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if manager.isPushAuthorized {
                        Label("Push notifications enabled", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button("Request push permissions") {
                            Task { await manager.requestPushAuthorization() }
                        }
                    }
                }

                Section("Change User") {
                    TextField("User Id", text: $pendingUserId)
                        .textInputAutocapitalization(.never)
                    Button("Apply user") {
                        manager.changeUser(to: pendingUserId)
                    }
                    .disabled(pendingUserId.isEmpty)
                }

                Section("Custom Data") {
                    TextField("Event name", text: $customEventName)
                    Button("Log custom event") {
                        manager.logCustomEvent(name: customEventName, properties: ["source": "demo", "timestamp": Date().timeIntervalSince1970])
                    }
                    TextField("Attribute key", text: $attributeKey)
                    TextField("Attribute value", text: $attributeValue)
                    Button("Update attribute") {
                        manager.updateCustomAttribute(key: attributeKey, value: attributeValue)
                    }
                }

                Section("Revenue") {
                    TextField("Amount", text: $purchaseAmount)
                        .keyboardType(.decimalPad)
                    Button("Log purchase") {
                        let amount = Double(purchaseAmount) ?? 0
                        manager.logPurchase(productIdentifier: "demo_product", currency: "USD", price: amount)
                    }
                }

                Section("Braze Channels") {
                    Button("Trigger in-app message sync") {
                        manager.triggerInAppMessageSync()
                    }
                    Button("Refresh content cards") {
                        manager.refreshContentCards()
                    }
                    Button("Flush data to Braze") {
                        manager.flushNow()
                    }
                }

                Section("Content Cards") {
                    if manager.contentCards.isEmpty {
                        Text("No content cards yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(manager.contentCards, id: \.id) { card in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.displayTitle)
                                    .font(.headline)
                                if let detail = card.displayDetail {
                                    Text(detail)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                }
                                if let url = card.clickAction?.url {
                                    Text(url.absoluteString)
                                        .font(.caption2)
                                        .foregroundStyle(.blue)
                                }
                                Text(card.extrasSummary)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Braze Demo")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BrazeManager.shared)
}

private extension Braze.ContentCard {
    var displayTitle: String {
        switch self {
        case .classic(let classic):
            return classic.title ?? "Classic card"
        case .captionedImage(let captioned):
            return captioned.title ?? "Captioned image"
        case .imageOnly:
            return "Image card"
        case .control:
            return "Control card"
        @unknown default:
            return "Braze content card"
        }
    }

    var displayDetail: String? {
        switch self {
        case .classic(let classic):
            return classic.description
        case .captionedImage(let captioned):
            return captioned.description
        case .imageOnly(let imageOnly):
            return imageOnly.image?.absoluteString
        case .control:
            return "Control group placeholder"
        @unknown default:
            return nil
        }
    }

    var extrasSummary: String {
        if extras.isEmpty {
            return "No extras attached"
        }
        return extras
            .map { \"\\($0.key)=\\($0.value)\" }
            .sorted()
            .joined(separator: \", \")
    }
}
