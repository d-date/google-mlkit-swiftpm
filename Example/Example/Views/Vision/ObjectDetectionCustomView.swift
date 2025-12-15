import SwiftUI
import MLImage
import MLKitObjectDetectionCustom
import MLKitObjectDetectionCommon
import MLKitCommon
import MLKitVision

struct ObjectDetectionCustomView: View {
  @State private var objects: [Object] = []
  @State private var selectedMode: ObjectDetectionMode = .singleWithClassifier
  @State private var modelLoadError: String?

  var body: some View {
    VStack {
      Picker("Mode", selection: $selectedMode) {
        ForEach(ObjectDetectionMode.allCases) { mode in
          Text(mode.rawValue).tag(mode)
        }
      }
      .pickerStyle(.segmented)

      BaseDetectionView(
        title: "Object Detection (Custom)",
        sampleImages: ["bird"],
        detectionHandler: detectObjects,
        resultView: {
          ScrollView {
            VStack(alignment: .leading) {
              if let error = modelLoadError {
                Text("Model Error: \(error)")
                  .foregroundStyle(.red)
                  .font(.caption)
              }

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
    guard let modelPath = Bundle.main.path(forResource: "bird", ofType: "tflite") else {
      modelLoadError = "bird.tflite not found in bundle"
      throw NSError(domain: "ObjectDetectionCustom", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found"])
    }

    let localModel = LocalModel(path: modelPath)
    let options = CustomObjectDetectorOptions(localModel: localModel)

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
    modelLoadError = nil
  }
}

#Preview {
  NavigationStack {
    ObjectDetectionCustomView()
  }
}
