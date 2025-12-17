import SwiftUI
import MLImage
import MLKitFaceDetection
import MLKitVision

struct FaceDetectionView: View {
  @State private var faces: [Face] = []

  var body: some View {
    BaseDetectionView(
      title: "Face Detection",
      sampleImages: ["grace_hopper"],
      detectionHandler: detectFaces,
      resultView: {
        ScrollView {
          VStack(alignment: .leading) {
            Text("Detected \(faces.count) face(s)")
              .font(.headline)

            ForEach(faces.enumerated().map { $0 }, id: \.offset) { index, face in
              VStack(alignment: .leading) {
                Text("Face \(index + 1)")
                  .font(.subheadline)
                  .bold()

                Text("Frame: \(face.frame.debugDescription)")
                  .font(.caption)

                if face.hasSmilingProbability {
                  Text("Smiling: \(face.smilingProbability, format: .percent.precision(.fractionLength(0)))")
                    .font(.caption)
                }

                if face.hasLeftEyeOpenProbability {
                  Text("Left Eye Open: \(face.leftEyeOpenProbability, format: .percent.precision(.fractionLength(0)))")
                    .font(.caption)
                }

                if face.hasRightEyeOpenProbability {
                  Text("Right Eye Open: \(face.rightEyeOpenProbability, format: .percent.precision(.fractionLength(0)))")
                    .font(.caption)
                }

                if face.hasHeadEulerAngleY {
                  Text("Head Y Angle: \(face.headEulerAngleY, format: .number.precision(.fractionLength(2)))°")
                    .font(.caption)
                }
              }
              .padding()
              .background(Color.gray.opacity(0.1))
              .clipShape(.rect(cornerRadius: 8))
            }
          }
        }
      }
    )
  }

  private func detectFaces(image: UIImage) async throws {
    let options = FaceDetectorOptions()
    options.landmarkMode = .all
    options.classificationMode = .all
    options.performanceMode = .accurate
    options.contourMode = .all

    let faceDetector = FaceDetector.faceDetector(options: options)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    faces = try await faceDetector.process(visionImage)
  }
}

#Preview {
  NavigationStack {
    FaceDetectionView()
  }
}
