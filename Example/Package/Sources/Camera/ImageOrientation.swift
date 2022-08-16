import UIKit
import AVFoundation.AVCaptureDevice

func imageOrientation(
  deviceOrientation: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position
) -> UIImage.Orientation {
  switch deviceOrientation {
    case .portrait:
      return cameraPosition == .front ? .leftMirrored : .right
    case .landscapeLeft:
      return cameraPosition == .front ? .downMirrored : .up
    case .portraitUpsideDown:
      return cameraPosition == .front ? .rightMirrored : .left
    case .landscapeRight:
      return cameraPosition == .front ? .upMirrored : .down
    case .faceDown, .faceUp, .unknown:
      return .up
    @unknown default:
      fatalError()
  }
}
