import SwiftUI
import MLImage
import MLKitObjectDetection
import MLKitVision

enum ObjectDetectionMode: String, CaseIterable, Identifiable {
  case singleNoClassifier = "Single, No Labels"
  case singleWithClassifier = "Single, With Labels"
  case multipleNoClassifier = "Multiple, No Labels"
  case multipleWithClassifier = "Multiple, With Labels"

  var id: String { rawValue }
}

struct ObjectDetectionView: View {
  @State private var objects: [Object] = []
  @State private var selectedMode: ObjectDetectionMode = .singleWithClassifier

  var body: some View {
    VStack {
      Picker("Mode", selection: $selectedMode) {
        ForEach(ObjectDetectionMode.allCases) { mode in
          Text(mode.rawValue).tag(mode)
        }
      }
      .pickerStyle(.segmented)

      BaseDetectionView(
        title: "Object Detection",
        sampleImages: ["bird", "beach", "liberty"],
        detectionHandler: detectObjects,
        resultView: {
          ScrollView {
            VStack(alignment: .leading) {
              Text("Detected \(objects.count) object(s)")
                .font(.headline)

              ForEach(objects.enumerated().map { $0 }, id: \.offset) { index, object in
                VStack(alignment: .leading) {
                  Text("Object \(index + 1)")
                    .font(.subheadline)
                    .bold()

                  Text("Frame: \(object.frame.debugDescription)")
                    .font(.caption)

                  if let trackingID = object.trackingID {
                    Text("Tracking ID: \(trackingID)")
                      .font(.caption)
                  }

                  if !object.labels.isEmpty {
                    Text("Labels:")
                      .font(.caption)
                      .bold()

                    ForEach(object.labels.enumerated().map { $0 }, id: \.offset) { _, label in
                      Text("  • \(label.text) (\(label.confidence, format: .percent.precision(.fractionLength(2))))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                  }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 8))
              }
            }
          }
        }
      )
    }
  }

  private func detectObjects(image: UIImage) async throws {
    let options = ObjectDetectorOptions()

    switch selectedMode {
    case .singleNoClassifier:
      options.detectorMode = .singleImage
      options.shouldEnableClassification = false
    case .singleWithClassifier:
      options.detectorMode = .singleImage
      options.shouldEnableClassification = true
    case .multipleNoClassifier:
      options.detectorMode = .singleImage
      options.shouldEnableMultipleObjects = true
      options.shouldEnableClassification = false
    case .multipleWithClassifier:
      options.detectorMode = .singleImage
      options.shouldEnableMultipleObjects = true
      options.shouldEnableClassification = true
    }

    let detector = ObjectDetector.objectDetector(options: options)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    objects = try await detector.process(visionImage)
  }
}

#Preview {
  NavigationStack {
    ObjectDetectionView()
  }
}
