import SwiftUI

struct MainMenuView: View {
  var body: some View {
    NavigationStack {
      List {
        Section("Vision Features") {
          NavigationLink("Face Detection", destination: FaceDetectionView())
          NavigationLink("Barcode Scanning", destination: BarcodeScanningView())
          NavigationLink("Text Recognition", destination: TextRecognitionView())
          NavigationLink("Text Recognition (Chinese)", destination: TextRecognitionChineseView())
          NavigationLink("Text Recognition (Devanagari)", destination: TextRecognitionDevanagariView())
          NavigationLink("Text Recognition (Japanese)", destination: TextRecognitionJapaneseView())
          NavigationLink("Text Recognition (Korean)", destination: TextRecognitionKoreanView())
          NavigationLink("Image Labeling", destination: ImageLabelingView())
          NavigationLink("Image Labeling (Custom)", destination: ImageLabelingCustomView())
          NavigationLink("Object Detection", destination: ObjectDetectionView())
          NavigationLink("Object Detection (Custom)", destination: ObjectDetectionCustomView())
          NavigationLink("Pose Detection", destination: PoseDetectionView())
          NavigationLink("Pose Detection (Accurate)", destination: PoseDetectionAccurateView())
          NavigationLink("Selfie Segmentation", destination: SelfieSegmentationView())
        }

        Section("Language Features") {
          NavigationLink("Language Identification", destination: LanguageIDView())
          NavigationLink("Translation", destination: TranslationView())
          NavigationLink("Smart Reply", destination: SmartReplyView())
        }
      }
      .navigationTitle("ML Kit Demo")
    }
  }
}

#Preview {
  MainMenuView()
}
