import SwiftUI
import MLImage
import MLKitPoseDetection
import MLKitVision

struct PoseDetectionView: View {
  @State private var poses: [Pose] = []

  var body: some View {
    BaseDetectionView(
      title: "Pose Detection",
      sampleImages: ["grace_hopper", "beach"],
      detectionHandler: detectPoses,
      resultView: {
        ScrollView {
          VStack(alignment: .leading) {
            Text("Detected \(poses.count) pose(s)")
              .font(.headline)

            ForEach(poses.enumerated().map { $0 }, id: \.offset) { index, pose in
              VStack(alignment: .leading) {
                Text("Pose \(index + 1)")
                  .font(.subheadline)
                  .bold()

                Text("Landmarks: \(pose.landmarks.count)")
                  .font(.caption)

                ForEach(pose.landmarks.enumerated().map { $0 }, id: \.offset) { _, landmark in
                  if landmark.inFrameLikelihood > 0.5 {
                    Text("  • \(landmarkName(landmark.type)): (\(Int(landmark.position.x)), \(Int(landmark.position.y)))")
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

  private func detectPoses(image: UIImage) async throws {
    let options = PoseDetectorOptions()
    options.detectorMode = .singleImage

    let detector = PoseDetector.poseDetector(options: options)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    poses = try await detector.process(visionImage)
  }

  private func landmarkName(_ type: PoseLandmarkType) -> String {
    switch type {
    case .nose: return "Nose"
    case .leftEyeInner: return "Left Eye Inner"
    case .leftEye: return "Left Eye"
    case .leftEyeOuter: return "Left Eye Outer"
    case .rightEyeInner: return "Right Eye Inner"
    case .rightEye: return "Right Eye"
    case .rightEyeOuter: return "Right Eye Outer"
    case .leftEar: return "Left Ear"
    case .rightEar: return "Right Ear"
    case .mouthLeft: return "Mouth Left"
    case .mouthRight: return "Mouth Right"
    case .leftShoulder: return "Left Shoulder"
    case .rightShoulder: return "Right Shoulder"
    case .leftElbow: return "Left Elbow"
    case .rightElbow: return "Right Elbow"
    case .leftWrist: return "Left Wrist"
    case .rightWrist: return "Right Wrist"
    case .leftPinkyFinger: return "Left Pinky"
    case .rightPinkyFinger: return "Right Pinky"
    case .leftIndexFinger: return "Left Index"
    case .rightIndexFinger: return "Right Index"
    case .leftThumb: return "Left Thumb"
    case .rightThumb: return "Right Thumb"
    case .leftHip: return "Left Hip"
    case .rightHip: return "Right Hip"
    case .leftKnee: return "Left Knee"
    case .rightKnee: return "Right Knee"
    case .leftAnkle: return "Left Ankle"
    case .rightAnkle: return "Right Ankle"
    case .leftHeel: return "Left Heel"
    case .rightHeel: return "Right Heel"
    case .leftToe: return "Left Toe"
    case .rightToe: return "Right Toe"
    default: return "Unknown"
    }
  }
}

#Preview {
  NavigationStack {
    PoseDetectionView()
  }
}
