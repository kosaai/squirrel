//
//  DimeAddTransactionButton.swift
//  Squirrel
//
//  Directly adapted from Dime's centered CustomTabBar add control.
//

import SwiftUI
import UIKit

struct DimeAddTransactionButton: View {
    let shouldPulse: Bool
    let action: () -> Void
    @State private var animate = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.DarkBackground.opacity(0.6))
                .frame(width: 95, height: 68)
                .opacity(animate ? 0 : 1)
                .scaleEffect(animate ? 1 : 0.4)
            RoundedRectangle(cornerRadius: 20.5, style: .continuous)
                .fill(Color.DarkBackground.opacity(0.8))
                .frame(width: 80, height: 53)
                .opacity(animate ? 0 : 1)
                .scaleEffect(animate ? 1 : 0.6)
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(DimeAddTransactionButtonStyle())
            .padding(15)
        }
        .onAppear(perform: updatePulse)
        .onChange(of: shouldPulse) { _ in updatePulse() }
        .accessibilityLabel("Dime Tab Add Transaction")
    }

    private func updatePulse() {
        animate = false
        guard shouldPulse else { return }
        withAnimation(.easeInOut(duration: 1.9).repeatForever(autoreverses: false)) {
            animate = true
        }
    }
}

private struct DimeAddTransactionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color.LightIcon)
            .frame(width: 65, height: 38)
            .background(configuration.isPressed ? Color.SubtitleText : Color.DarkBackground, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}
