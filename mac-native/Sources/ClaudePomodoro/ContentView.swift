import SwiftUI

private let cream = Color(red: 0xFD/255, green: 0xF6/255, blue: 0xEC/255)
private let orange = Color(red: 0xD9/255, green: 0x77/255, blue: 0x57/255)
private let darkOrange = Color(red: 0xB0/255, green: 0x65/255, blue: 0x45/255)

struct ContentView: View {
    @EnvironmentObject var model: TimerModel
    @State private var customInput: String = ""

    var body: some View {
        VStack(spacing: 0) {
            titlebar
            mascot
            Text(model.phaseLabel)
                .font(.system(size: 11))
                .foregroundColor(darkOrange)
                .textCase(.lowercase)
                .padding(.bottom, 2)
            Text(model.formatted)
                .font(.system(size: 42, weight: .bold, design: .monospaced))
                .foregroundColor(orange)
                .padding(.bottom, 10)
            durations
            buttons
            Text("sessions: \(model.sessions)")
                .font(.system(size: 10))
                .foregroundColor(darkOrange.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cream)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(orange, lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var titlebar: some View {
        HStack {
            Text("claude pomodoro")
                .font(.system(size: 11))
                .foregroundColor(darkOrange)
            Spacer()
            Button(model.pinned ? "pinned" : "pin") {
                model.togglePin()
            }
            .buttonStyle(.plain)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(model.pinned ? orange : darkOrange.opacity(0.45))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(model.pinned ? orange.opacity(0.18) : .clear)
            .cornerRadius(4)
            Button("–") {
                NSApplication.shared.keyWindow?.miniaturize(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(darkOrange)
            .frame(width: 18, height: 18)
            Button("×") {
                NSApplication.shared.keyWindow?.close()
            }
            .buttonStyle(.plain)
            .foregroundColor(darkOrange)
            .frame(width: 18, height: 18)
        }
        .frame(height: 22)
        .padding(.bottom, 4)
    }

    private var mascot: some View {
        AnimatedGIFView(name: model.mascotName)
            .frame(width: 140, height: 140)
            .padding(.top, 6)
            .padding(.bottom, 4)
    }

    private var durations: some View {
        HStack(spacing: 4) {
            ForEach([5, 15, 25], id: \.self) { min in
                Button("\(min)") {
                    guard !model.running else { return }
                    customInput = ""
                    model.setWorkMinutes(min, fromPreset: true)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(model.selectedPreset == min ? cream : orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(model.selectedPreset == min ? orange : cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(orange, lineWidth: 1.5)
                )
                .opacity(model.running ? 0.4 : 1.0)
                .disabled(model.running)
            }
            TextField("min", text: $customInput)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(orange)
                .frame(width: 60, height: 22)
                .background(cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(orange, lineWidth: 1.5)
                )
                .disabled(model.running)
                .onChange(of: customInput) { newValue in
                    guard !model.running else { return }
                    if let n = Int(newValue), (1...180).contains(n) {
                        model.setWorkMinutes(n, fromPreset: false)
                    }
                }
        }
        .padding(.bottom, 8)
    }

    private var buttons: some View {
        HStack(spacing: 8) {
            Button(model.running ? "pause" : "start") {
                model.toggle()
            }
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(cream)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(orange)
            .cornerRadius(8)

            Button("reset") {
                model.reset()
            }
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(orange)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(cream)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(orange, lineWidth: 2)
            )
        }
        .padding(.bottom, 10)
    }
}
