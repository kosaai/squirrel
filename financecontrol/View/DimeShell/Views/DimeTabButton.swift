//
//  DimeTabButton.swift
//  Squirrel
//
//  Directly adapted from TabButton and BouncyButton in Dime CustomTabBar.swift.
//

import SwiftUI

struct DimeBouncyButtonStyle: ButtonStyle {
    let duration: Double
    let scale: Double

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: duration), value: configuration.isPressed)
    }
}

struct DimeTabButton: View {
    let destination: DimeTabDestination
    let isAvailable: Bool
    @Binding var selection: DimeTabDestination

    var body: some View {
        Button {
            DispatchQueue.main.async {
                guard isAvailable else { return }
                selection = destination
            }
        } label: {
            Image(destination.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 28, maxHeight: 28)
                .animation(.easeInOut(duration: 0.3), value: selection)
                .frame(maxWidth: .infinity)
                .foregroundColor(selection == destination ? Color.DarkIcon : Color.GreyIcon)
        }
        .buttonStyle(DimeBouncyButtonStyle(duration: 0.3, scale: 0.6))
        .accessibilityHint(isAvailable ? "" : "Dime Tab Unavailable")
        .accessibilityLabel(destination.accessibilityLabel)
        .accessibilityAddTraits(selection == destination ? [.isButton, .isSelected] : .isButton)
    }
}
