//
//  DeliveryEarningsStyle.swift
//  Squirrel
//

import SwiftUI

enum DeliveryEarningsStyle {
    static let accent = Color(red: 0.03, green: 0.62, blue: 0.67)
    static let fieldBackground = Color(uiColor: .tertiarySystemFill)
    static let workCardBackground = Color(uiColor: .secondarySystemFill)
}

extension View {
    @ViewBuilder
    func deliveryEarningsGlassSurface(cornerRadius: CGFloat = 21) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        if #available(iOS 26.0, *) {
            glassEffect(.regular.tint(DeliveryEarningsStyle.accent.opacity(0.05)), in: shape)
        } else {
            background(.thinMaterial, in: shape)
                .overlay {
                    shape.stroke(Color.primary.opacity(0.08), lineWidth: 1)
                }
        }
    }
}
