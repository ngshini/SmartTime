//
//  FocusView.swift
//  SmartTime
//

import SwiftUI
import Combine

/// Pomodoro đơn giản + báo thức học tập/làm việc.
struct FocusView: View {
    @State private var totalSeconds = 25 * 60
    @State private var remaining = 25 * 60
    @State private var isRunning = false
    @State private var selectedMinutes = 25

    private let presets = [15, 25, 45, 50]
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var progress: Double {
        totalSeconds == 0 ? 0 : Double(totalSeconds - remaining) / Double(totalSeconds)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                ZStack {
                    Circle().stroke(.quaternary, lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppTheme.brandGradient,
                                style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.3), value: progress)
                    Text(timeString)
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                .frame(width: 240, height: 240)

                if !isRunning {
                    Picker("Thời lượng", selection: $selectedMinutes) {
                        ForEach(presets, id: \.self) { Text("\($0)′").tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedMinutes) { _, new in
                        totalSeconds = new * 60
                        remaining = new * 60
                    }
                }

                HStack(spacing: 20) {
                    Button(isRunning ? "Tạm dừng" : "Bắt đầu") { isRunning.toggle() }
                        .buttonStyle(.borderedProminent)
                    Button("Đặt lại") { reset() }
                        .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Tập trung")
            .onReceive(timer) { _ in tick() }
        }
    }

    private var timeString: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    private func tick() {
        guard isRunning else { return }
        if remaining > 0 {
            remaining -= 1
        } else {
            isRunning = false
            notifyDone()
        }
    }

    private func reset() {
        isRunning = false
        remaining = totalSeconds
    }

    private func notifyDone() {
        let reminder = ReminderItem(title: "Hết phiên tập trung",
                                    body: "Bạn đã hoàn thành \(selectedMinutes) phút tập trung.",
                                    fireDate: Date().addingTimeInterval(1),
                                    isAlarm: true)
        NotificationService.shared.schedule(reminder)
    }
}

#Preview { FocusView() }
