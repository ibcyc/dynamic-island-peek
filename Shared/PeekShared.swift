import ActivityKit
import Foundation
import SwiftUI
import UIKit

enum PeekShared {
    private static let appGroupID = "group.com.example.DynamicIslandPeek"
    private static let imageFileName = "peek-image.jpg"
    private static let thumbnailFileName = "peek-thumbnail.jpg"
    private static let imageVersionKey = "peek-image-version"

    private static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    private static var imageURL: URL? {
        containerURL?.appendingPathComponent(imageFileName)
    }

    private static var thumbnailURL: URL? {
        containerURL?.appendingPathComponent(thumbnailFileName)
    }

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static var imageVersion: Int {
        defaults?.integer(forKey: imageVersionKey) ?? 0
    }

    @discardableResult
    static func save(image: UIImage) throws -> Int {
        guard let imageURL, let thumbnailURL else {
            throw PeekError.missingAppGroup
        }

        guard
            let fullImage = image.jpegData(compressionQuality: 0.88),
            let thumbnail = image
                .resizedToFit(size: CGSize(width: 320, height: 320), backgroundColor: .black)
                .jpegData(compressionQuality: 0.78)
        else {
            throw PeekError.encodingFailed
        }

        try fullImage.write(to: imageURL, options: [.atomic])
        try thumbnail.write(to: thumbnailURL, options: [.atomic])
        makeReadableForLiveActivity(imageURL)
        makeReadableForLiveActivity(thumbnailURL)

        let nextVersion = imageVersion + 1
        defaults?.set(nextVersion, forKey: imageVersionKey)
        return nextVersion
    }

    static func loadImage(preferThumbnail: Bool = true) -> UIImage? {
        let urls = preferThumbnail
            ? [thumbnailURL, imageURL]
            : [imageURL, thumbnailURL]

        return urls
            .compactMap { $0 }
            .lazy
            .compactMap { try? Data(contentsOf: $0) }
            .compactMap(UIImage.init(data:))
            .first
    }

    static func compactImageBase64() -> String? {
        loadImage(preferThumbnail: true)?
            .resizedToFit(size: CGSize(width: 64, height: 64), backgroundColor: .black)
            .jpegData(compressionQuality: 0.55)?
            .base64EncodedString()
    }

    static func image(fromBase64 base64: String?) -> UIImage? {
        guard let base64, let data = Data(base64Encoded: base64) else {
            return nil
        }

        return UIImage(data: data)
    }

    private static func makeReadableForLiveActivity(_ url: URL) {
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.none],
            ofItemAtPath: url.path
        )
    }
}

enum PeekError: LocalizedError {
    case missingAppGroup
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .missingAppGroup:
            return "App Group container is unavailable. Check the App Group ID in Xcode."
        case .encodingFailed:
            return "The selected image could not be encoded."
        }
    }
}

nonisolated struct PeekAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var startedAt: Date
        var imageVersion: Int
        var compactImageBase64: String?
    }

    var title: String
}

extension UIImage {
    func resizedToFit(size: CGSize, backgroundColor: UIColor = .black) -> UIImage {
        let scale = min(size.width / self.size.width, size.height / self.size.height)
        let scaledSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        let origin = CGPoint(
            x: (size.width - scaledSize.width) / 2,
            y: (size.height - scaledSize.height) / 2
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            draw(in: CGRect(origin: origin, size: scaledSize))
        }
    }
}
