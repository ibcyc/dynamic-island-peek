import ActivityKit
import Foundation

enum PeekActivityController {
    static func startFreshPeek() async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        await stopPeek(dismissalPolicy: .immediate)

        let attributes = PeekAttributes(title: "Peek")
        let state = PeekAttributes.ContentState(
            startedAt: Date(),
            imageVersion: PeekShared.imageVersion,
            compactImageBase64: PeekShared.compactImageBase64()
        )
        let content = ActivityContent(
            state: state,
            staleDate: nil
        )

        if #available(iOS 16.2, *) {
            _ = try Activity<PeekAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        }
    }

    static func stopPeek(dismissalPolicy: ActivityUIDismissalPolicy = .immediate) async {
        for activity in Activity<PeekAttributes>.activities {
            await activity.end(nil, dismissalPolicy: dismissalPolicy)
        }
    }
}
