import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    private let backgroundColor = Color(red: 0.035, green: 0.035, blue: 0.045)
    private let previewSize: CGFloat = 260

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                title

                Spacer(minLength: 0)
                imagePreview
                controls
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
        }
        .task {
            selectedImage = PeekShared.loadImage(preferThumbnail: false)
        }
        .onChange(of: selectedItem) { _, item in
            Task {
                await load(item: item)
            }
        }
    }

    private var currentImage: UIImage? {
        selectedImage ?? PeekShared.loadImage(preferThumbnail: false)
    }

    private var title: some View {
        Text("PEEK")
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.top, 18)
    }

    private var controls: some View {
        HStack(spacing: 28) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                CircleButton(color: .blue, systemImage: "photo")
            }

            Button {
                Task { await startPeek() }
            } label: {
                CircleButton(color: .green, systemImage: "play.fill")
            }
            .disabled(currentImage == nil)
            .opacity(currentImage == nil ? 0.35 : 1)

            Button {
                Task { await stopPeek() }
            } label: {
                CircleButton(color: .red, systemImage: "stop.fill")
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 34)
    }

    @ViewBuilder
    private var imagePreview: some View {
        if let currentImage {
            Image(uiImage: currentImage)
                .resizable()
                .scaledToFit()
                .frame(width: previewSize, height: previewSize)
                .background(Color.white.opacity(0.04))
        } else {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(width: previewSize, height: previewSize)
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(.white.opacity(0.22))
                }
        }
    }

    private func load(item: PhotosPickerItem?) async {
        guard
            let item,
            let data = try? await item.loadTransferable(type: Data.self),
            let image = UIImage(data: data),
            (try? PeekShared.save(image: image)) != nil
        else {
            return
        }

        selectedImage = image
    }

    private func startPeek() async {
        try? await PeekActivityController.startFreshPeek()
    }

    private func stopPeek() async {
        await PeekActivityController.stopPeek()
    }
}

private struct CircleButton: View {
    let color: Color
    let systemImage: String

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 62, height: 62)
            .overlay {
                Image(systemName: systemImage)
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(.white)
            }
    }
}
