import Camera
import SwiftUI
import PhotosUI
import MLImage
import MLKitFaceDetection
import MLKitBarcodeScanning
import MLKitVision
import MLKitCommon

struct ContentView: View {

  @State var selectedDetection: DetectorPickerContent = .detectFaceOnDevice
  @State var selectedPhoto: PhotosPickerItem?
  @State var selectedPhotoData: Data?
  @State var detectedFaces: [Face] = []
  @State var detectedBarcode: [Barcode] = []

  var image: UIImage? {
    if let selectedPhotoData {
      return .init(data: selectedPhotoData)
    }
    return nil
  }

  var body: some View {
    NavigationView {
      VStack {
        toolbar()
        if let selectedPhotoData, let image = UIImage(data: selectedPhotoData) {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
        } else {
          Rectangle()
            .foregroundColor(.white)
            .aspectRatio(1, contentMode: .fit)
        }
        bottomToolbar()
        Picker("Detector", selection: $selectedDetection) {
          ForEach(DetectorPickerContent.allCases) { content in
            Text(content.description)
          }
        }
        .pickerStyle(.automatic)
        .onChange(of: selectedPhoto) { newItem in
          Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self) {
              selectedPhotoData = data
            }
          }
        }
      }
    }
  }

  @ViewBuilder func toolbar() -> some View {
    HStack {
      Spacer()
      PhotosPicker(selection: $selectedPhoto, photoLibrary: .shared()) {
        Label("", systemImage: "photo.fill.on.rectangle.fill")
          .padding()
      }
      Spacer()
      Button{

      } label: {
        Label("", systemImage: "camera.fill")
          .padding()
      }
      Spacer()
      Button {

      } label: {
        Label("", systemImage: "video.fill")
          .padding()
      }
      Spacer()
    }
    .padding()
  }

  @ViewBuilder func bottomToolbar() -> some View {
    HStack {
      Spacer()
      Button {
        if let image {
          Task {
            await detect(image: image)
          }
        }
      } label: {
        Text("Detect")
      }
      Spacer()
      Button {

      } label: {
        Text("Next Image")
      }
      Spacer()
    }
    .padding()
  }

  func detect(image: UIImage) async {
    do {
      switch selectedDetection {
        case .detectFaceOnDevice:
          self.detectedFaces = try await detectFaces(image: image)
          print(detectedFaces)
        case .detectBarcodeOnDevice:
          self.detectedBarcode = try await detectBarcodes(image: image)
          print(detectedBarcode)
        default:
          break
      }
    } catch {
      print(error)
    }
  }

  /// Detects barcodes on the specified image and draws a frame around the detected barcodes using
  /// On-Device barcode API.
  ///
  /// - Parameter image: The image.
  func detectBarcodes(image: UIImage) async throws -> [Barcode] {
    // Define the options for a barcode detector.
    let format = BarcodeFormat.all
    let barcodeOptions = BarcodeScannerOptions(formats: format)

    // Create a barcode scanner.
    let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)

    // Initialize a `VisionImage` object with the given `UIImage`.
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    return try await barcodeScanner.process(visionImage)
  }

  /// Detects faces on the specified image and draws a frame around the detected faces using
  /// On-Device face eAPI.
  ///
  /// - Parameter image: The image.
  func detectFaces(image: UIImage) async throws -> [Face] {

    // Create a face detector with options.
    let options = FaceDetectorOptions()
    options.landmarkMode = .all
    options.classificationMode = .all
    options.performanceMode = .accurate
    options.contourMode = .all
    let faceDetector = FaceDetector.faceDetector(options: options)

    // Initialize a `VisionImage` object with the given `UIImage`.
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation

    return try await faceDetector.process(visionImage)
  }
}

private enum Constants {
  static let images = [
    "grace_hopper.jpg", "image_has_text.jpg", "chinese_sparse.png", "chinese.png",
    "devanagari_sparse.png", "devanagari.png", "japanese_sparse.png", "japanese.png",
    "korean_sparse.png", "korean.png", "barcode_128.png", "qr_code.jpg", "beach.jpg", "liberty.jpg",
    "bird.jpg",
  ]

  static let detectionNoResultsMessage = "No results returned."
  static let failedToDetectObjectsMessage = "Failed to detect objects in image."
  static let localModelFile = (name: "bird", type: "tflite")
  static let labelConfidenceThreshold = 0.75
  static let smallDotRadius: CGFloat = 5.0
  static let largeDotRadius: CGFloat = 10.0
  static let lineColor = UIColor.yellow.cgColor
  static let lineWidth: CGFloat = 3.0
  static let fillColor = UIColor.clear.cgColor
  static let segmentationMaskAlpha: CGFloat = 0.5
}

enum DetectorPickerContent: Int, Identifiable, CaseIterable, CustomStringConvertible {
  var id: Int { rawValue }

  case detectFaceOnDevice = 0

  case
  detectTextOnDevice,
  detectTextChineseOnDevice,
  detectTextDevanagariOnDevice,
  detectTextJapaneseOnDevice,
  detectTextKoreanOnDevice,
  detectBarcodeOnDevice,
  detectImageLabelsOnDevice,
  detectImageLabelsCustomOnDevice,
  detectObjectsProminentNoClassifier,
  detectObjectsProminentWithClassifier,
  detectObjectsMultipleNoClassifier,
  detectObjectsMultipleWithClassifier,
  detectObjectsCustomProminentNoClassifier,
  detectObjectsCustomProminentWithClassifier,
  detectObjectsCustomMultipleNoClassifier,
  detectObjectsCustomMultipleWithClassifier,
  detectPose,
  detectPoseAccurate,
  detectSegmentationMaskSelfie

  var description: String {
    switch self {
      case .detectFaceOnDevice:
        return "Face Detection"
      case .detectTextOnDevice:
        return "Text Recognition"
      case .detectTextChineseOnDevice:
        return "Text Recognition Chinese"
      case .detectTextDevanagariOnDevice:
        return "Text Recognition Devanagari"
      case .detectTextJapaneseOnDevice:
        return "Text Recognition Japanese"
      case .detectTextKoreanOnDevice:
        return "Text Recognition Korean"
      case .detectBarcodeOnDevice:
        return "Barcode Scanning"
      case .detectImageLabelsOnDevice:
        return "Image Labeling"
      case .detectImageLabelsCustomOnDevice:
        return "Image Labeling Custom"
      case .detectObjectsProminentNoClassifier:
        return "ODT, single, no labeling"
      case .detectObjectsProminentWithClassifier:
        return "ODT, single, labeling"
      case .detectObjectsMultipleNoClassifier:
        return "ODT, multiple, no labeling"
      case .detectObjectsMultipleWithClassifier:
        return "ODT, multiple, labeling"
      case .detectObjectsCustomProminentNoClassifier:
        return "ODT, custom, single, no labeling"
      case .detectObjectsCustomProminentWithClassifier:
        return "ODT, custom, single, labeling"
      case .detectObjectsCustomMultipleNoClassifier:
        return "ODT, custom, multiple, no labeling"
      case .detectObjectsCustomMultipleWithClassifier:
        return "ODT, custom, multiple, labeling"
      case .detectPose:
        return "Pose Detection"
      case .detectPoseAccurate:
        return "Pose Detection, accurate"
      case .detectSegmentationMaskSelfie:
        return "Selfie Segmentation"
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
