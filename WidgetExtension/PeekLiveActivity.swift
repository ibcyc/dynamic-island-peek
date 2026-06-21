import ActivityKit
import SwiftUI
import WidgetKit

struct PeekLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PeekAttributes.self) { _ in
            Color.clear
                .frame(height: 0)
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.clear)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    ExpandedPeekView(imageVersion: context.state.imageVersion)
                }
            } compactLeading: {
                IslandImage(imageVersion: context.state.imageVersion, compactImageBase64: context.state.compactImageBase64, size: 28, cornerRadius: 0)
            } compactTrailing: {
                EmptyView()
            } minimal: {
                IslandImage(imageVersion: context.state.imageVersion, compactImageBase64: context.state.compactImageBase64, size: 24, cornerRadius: 0)
            }
        }
    }
}

private struct ExpandedPeekView: View {
    let imageVersion: Int

    var body: some View {
        IslandImage(imageVersion: imageVersion, compactImageBase64: nil, size: 100, cornerRadius: 0)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
            .padding(.vertical, 2)
    }
}

private struct IslandImage: View {
    let imageVersion: Int
    let compactImageBase64: String?
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Group {
            if let image = compactImageBase64.flatMap(PeekShared.image(fromBase64:)) ?? PeekShared.loadImage(preferThumbnail: true) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.22)
                    .foregroundStyle(.white)
                    .background(.pink)
            }
        }
        .id(imageVersion)
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
