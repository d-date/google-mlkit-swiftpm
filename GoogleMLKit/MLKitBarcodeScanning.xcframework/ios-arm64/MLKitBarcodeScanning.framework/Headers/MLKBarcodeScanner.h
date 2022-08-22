#import <Foundation/Foundation.h>

@class MLKBarcode;
@class MLKBarcodeScannerOptions;

@protocol MLKCompatibleImage;

NS_ASSUME_NONNULL_BEGIN

/**
 * A block containing an array of barcodes or `nil` if there's an error.
 *
 * @param barcodes Array of barcodes scanned in the image or `nil` if there was an error.
 * @param error The error or `nil`.
 */
typedef void (^MLKBarcodeScanningCallback)(NSArray<MLKBarcode *> *_Nullable barcodes,
                                           NSError *_Nullable error)
    NS_SWIFT_NAME(BarcodeScanningCallback);

/** A barcode scanner that scans barcodes in an image. */
NS_SWIFT_NAME(BarcodeScanner)
@interface MLKBarcodeScanner : NSObject

/**
 * Returns a barcode scanner with the given options.
 *
 * @param options Options containing barcode scanner configuration.
 * @return A barcode scanner configured with the given options.
 */
+ (instancetype)barcodeScannerWithOptions:(MLKBarcodeScannerOptions *)options
    NS_SWIFT_NAME(barcodeScanner(options:));

/**
 * Returns a barcode scanner with the default options.
 *
 * @return A barcode scanner configured with the default options.
 */
+ (instancetype)barcodeScanner NS_SWIFT_NAME(barcodeScanner());

/** Unavailable. Use the class methods. */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Processes the given image for barcode scanning.
 *
 * @param image The image to process.
 * @param completion Handler to call back on the main queue with barcodes scanned or error.
 */

- (void)processImage:(id<MLKCompatibleImage>)image
          completion:(MLKBarcodeScanningCallback)completion
    NS_SWIFT_NAME(process(_:completion:));

/**
 * Returns barcode results in the given image or `nil` if there was an error. The barcode scanning
 * is performed synchronously on the calling thread.
 *
 * @discussion It is advised to call this method off the main thread to avoid blocking the UI. As a
 *     result, an `NSException` is raised if this method is called on the main thread.
 * @param image The image to get results in.
 * @param error An optional error parameter populated when there is an error getting results.
 * @return Array of barcode results in the given image or `nil` if there was an error.
 */

- (nullable NSArray<MLKBarcode *> *)resultsInImage:(id<MLKCompatibleImage>)image
                                             error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
