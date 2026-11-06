// Direct migration of Dime's SettingsRowView and ToggleRow visual language.
import SwiftUI

struct DimeSettingsRow: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    var detail: String? = nil
    var showsChevron = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(color, in: RoundedRectangle(cornerRadius: 6, style: .continuous))

            Text(title)
                .font(.system(.body, design: .rounded).weight(.medium))
                .lineLimit(1)
                .foregroundColor(Color.PrimaryText)

            Spacer()

            if let detail {
                Text(detail)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Color.DarkIcon.opacity(0.6))
                    .lineLimit(1)
                    .layoutPriority(1)
            }

            if showsChevron {
                Image(systemName: "chevron.forward")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color.DarkIcon.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

struct DimeSettingsToggleRow: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(color, in: RoundedRectangle(cornerRadius: 6, style: .continuous))

            Text(title)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundColor(Color.PrimaryText)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DimeSettingsSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .foregroundColor(Color.SubtitleText)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 13) {
                content
            }
            .padding(10)
            .background(Color.SettingsBackground, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 25)
    }
}
