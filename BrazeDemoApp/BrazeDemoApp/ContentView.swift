import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: IntegrationPlaygroundViewModel

    @State private var userId = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""

    @State private var attributeKey = ""
    @State private var attributeValue = ""

    @State private var eventName = ""
    @State private var eventPropertyKey = ""
    @State private var eventPropertyValue = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    userBox
                    profileBox
                    customAttributeBox
                    customEventBox
                    channelBox
                    logBox
                }
                .padding()
            }
            .navigationTitle("Braze Integration Sandbox")
        }
    }

    private var userBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            header("User Identity")
            Text("Wire this button to Braze's changeUser() call.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            TextField("User ID", text: $userId)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            Button("Submit user") {
                viewModel.changeUser(to: userId)
            }
            .buttonStyle(.borderedProminent)
            .disabled(userId.isEmpty)
        }
        .boxStyle()
    }

    private var profileBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            header("Profile Fields")
            Text("Map these inputs to Braze's standard user profile setters.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            TextField("First name", text: $firstName)
                .textFieldStyle(.roundedBorder)
            TextField("Last name", text: $lastName)
                .textFieldStyle(.roundedBorder)
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            Button("Submit profile details") {
                viewModel.identifyUser(firstName: firstName, lastName: lastName, email: email)
            }
            .buttonStyle(.bordered)
            .disabled(firstName.isEmpty && lastName.isEmpty && email.isEmpty)
        }
        .boxStyle()
    }

    private var customAttributeBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            header("Custom Attributes")
            TextField("Attribute key", text: $attributeKey)
                .textFieldStyle(.roundedBorder)
            TextField("Attribute value", text: $attributeValue)
                .textFieldStyle(.roundedBorder)
            Button("Submit attribute") {
                viewModel.setCustomAttribute(key: attributeKey, value: attributeValue)
            }
            .buttonStyle(.bordered)
            .disabled(attributeKey.isEmpty || attributeValue.isEmpty)
        }
        .boxStyle()
    }

    private var customEventBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            header("Custom Events")
            TextField("Event name", text: $eventName)
                .textFieldStyle(.roundedBorder)
            TextField("Property key (optional)", text: $eventPropertyKey)
                .textFieldStyle(.roundedBorder)
            TextField("Property value (optional)", text: $eventPropertyValue)
                .textFieldStyle(.roundedBorder)
            Button("Submit event") {
                viewModel.logCustomEvent(name: eventName,
                                         propertyKey: eventPropertyKey,
                                         propertyValue: eventPropertyValue)
            }
            .buttonStyle(.bordered)
            .disabled(eventName.isEmpty)
        }
        .boxStyle()
    }

    private var channelBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            header("Communication Channels")
            Text("Hook these taps up to Braze SDK entry points (push, IAM, content cards, flush).")
                .font(.footnote)
                .foregroundStyle(.secondary)
            HStack {
                Button("Register Push") { viewModel.registerForPush() }
                Button("Content Cards") { viewModel.requestContentCards() }
            }
            .buttonStyle(.bordered)
            HStack {
                Button("In-App Message") { viewModel.requestInAppMessage() }
                Button("Flush Data") { viewModel.flushData() }
            }
            .buttonStyle(.bordered)
        }
        .boxStyle()
    }

    private var logBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            header("Activity Log")
            if viewModel.logs.isEmpty {
                Text("As you interact with the controls above, we'll append notes here describing the Braze API you should call.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.logs, id: \.self) { entry in
                        Text(entry)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            Button("Clear log") {
                viewModel.resetLog()
            }
            .buttonStyle(.bordered)
        }
        .boxStyle()
    }

    private func header(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }
}

private struct BoxStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.separator), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

private extension View {
    func boxStyle() -> some View {
        modifier(BoxStyle())
    }
}

#Preview {
    ContentView()
        .environmentObject(IntegrationPlaygroundViewModel())
}
