#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Options for specifying the barcode formats that the library can detect. */
typedef NS_OPTIONS(NSInteger, MLKBarcodeFormat) {
  /** Unknown format. */
  MLKBarcodeFormatUnknown = 0,
  /** All format. */
  MLKBarcodeFormatAll = 0xFFFF,
  /** Code-128 detection. */
  MLKBarcodeFormatCode128 = 0x0001,
  /** Code-39 detection. */
  MLKBarcodeFormatCode39 = 0x0002,
  /** Code-93 detection. */
  MLKBarcodeFormatCode93 = 0x0004,
  /** Codabar detection. */
  MLKBarcodeFormatCodaBar = 0x0008,
  /** Data Matrix detection. */
  MLKBarcodeFormatDataMatrix = 0x0010,
  /** EAN-13 detection. */
  MLKBarcodeFormatEAN13 = 0x0020,
  /** EAN-8 detection. */
  MLKBarcodeFormatEAN8 = 0x0040,
  /** ITF detection. */
  MLKBarcodeFormatITF = 0x0080,
  /** QR Code detection. */
  MLKBarcodeFormatQRCode = 0x0100,
  /** UPC-A detection. */
  MLKBarcodeFormatUPCA = 0x0200,
  /** UPC-E detection. */
  MLKBarcodeFormatUPCE = 0x0400,
  /** PDF-417 detection. */
  MLKBarcodeFormatPDF417 = 0x0800,
  /** Aztec code detection. */
  MLKBarcodeFormatAztec = 0x1000,
} NS_SWIFT_NAME(BarcodeFormat);

/** Options for specifying a barcode scanner. */
NS_SWIFT_NAME(BarcodeScannerOptions)
@interface MLKBarcodeScannerOptions : NSObject

/**
 * The barcode formats detected in an image. Note that the detection time will increase for each
 * additional format that is specified.
 */
@property(nonatomic, readonly) MLKBarcodeFormat formats;

/**
 * Initializes an instance that scans all supported barcode formats.
 *
 * @return A new instance of barcode scanner options.
 */
- (instancetype)init;

/**
 * Initializes an instance with the given barcode formats to look for.
 *
 * @param formats The barcode formats to initialize the barcode scanner options.
 * @return A new instance of barcode scanner options.
 */
- (instancetype)initWithFormats:(MLKBarcodeFormat)formats NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
