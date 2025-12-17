import SwiftUI
import PhotosUI
import MLImage

struct BaseDetectionView<Content: View>: View {
  let title: String
  let sampleImages: [String]
  let detectionHandler: (UIImage) async throws -> Void
  let resultView: () -> Content

  @State private var selectedPhoto: PhotosPickerItem?
  @State private var selectedImage: UIImage?
  @State private var currentImageIndex = 0
  @State private var isDetecting = false
  @State private var errorMessage: String?
  @State private var showCamera = false

  var body: some View {
    VStack {
      ZStack {
        if let image = selectedImage {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
        } else {
          Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(Text("No Image Selected"))
        }
      }
      .frame(maxHeight: 400)

      resultView()

      if let errorMessage {
        Text(errorMessage)
          .foregroundStyle(.red)
      }

      Spacer()

      HStack {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
          Image(systemName: "photo.fill")
            .font(.title2)
        }

        Button {
          showCamera = true
        } label: {
          Image(systemName: "camera.fill")
            .font(.title2)
        }

        Button {
          loadPreviousSampleImage()
        } label: {
          Image(systemName: "chevron.left")
            .font(.title2)
        }

        Button {
          loadNextSampleImage()
        } label: {
          Image(systemName: "chevron.right")
            .font(.title2)
        }

        Spacer()

        Button {
          Task {
            await detectImage()
          }
        } label: {
          if isDetecting {
            ProgressView()
          } else {
            Text("Detect")
              .bold()
          }
        }
        .disabled(selectedImage == nil || isDetecting)
      }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: selectedPhoto) { _, newItem in
      Task {
        if let data = try? await newItem?.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
          selectedImage = image
        }
      }
    }
    .onAppear {
      loadSampleImage(at: 0)
    }
    .sheet(isPresented: $showCamera) {
      CameraView { image in
        selectedImage = image
        showCamera = false
      }
    }
  }

  private func loadSampleImage(at index: Int) {
    guard !sampleImages.isEmpty, index < sampleImages.count else { return }
    if let image = UIImage(named: sampleImages[index]) {
      selectedImage = image
    }
  }

  private func loadNextSampleImage() {
    currentImageIndex = (currentImageIndex + 1) % sampleImages.count
    loadSampleImage(at: currentImageIndex)
  }

  private func loadPreviousSampleImage() {
    currentImageIndex = (currentImageIndex - 1 + sampleImages.count) % sampleImages.count
    loadSampleImage(at: currentImageIndex)
  }

  private func detectImage() async {
    guard let image = selectedImage else { return }
    isDetecting = true
    errorMessage = nil

    do {
      try await detectionHandler(image)
    } catch {
      errorMessage = "Detection failed: \(error.localizedDescription)"
    }

    isDetecting = false
  }
}
