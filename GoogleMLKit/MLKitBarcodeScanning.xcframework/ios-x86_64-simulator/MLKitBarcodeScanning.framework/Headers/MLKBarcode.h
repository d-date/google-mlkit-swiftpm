#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "MLKBarcodeScannerOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @enum BarcodeValueType
 * Barcode's value format. For example, TEXT, PRODUCT, URL, etc.
 */
typedef NSInteger MLKBarcodeValueType NS_TYPED_ENUM NS_SWIFT_NAME(BarcodeValueType);
/** Unknown Barcode value types.  */
static const MLKBarcodeValueType MLKBarcodeValueTypeUnknown = 0;
/** Barcode value type for contact info. */
static const MLKBarcodeValueType MLKBarcodeValueTypeContactInfo = 1;
/** Barcode value type for email addresses. */
static const MLKBarcodeValueType MLKBarcodeValueTypeEmail = 2;
/** Barcode value type for ISBNs. */
static const MLKBarcodeValueType MLKBarcodeValueTypeISBN = 3;
/** Barcode value type for phone numbers. */
static const MLKBarcodeValueType MLKBarcodeValueTypePhone = 4;
/** Barcode value type for product codes. */
static const MLKBarcodeValueType MLKBarcodeValueTypeProduct = 5;
/** Barcode value type for SMS details. */
static const MLKBarcodeValueType MLKBarcodeValueTypeSMS = 6;
/** Barcode value type for plain text. */
static const MLKBarcodeValueType MLKBarcodeValueTypeText = 7;
/** Barcode value type for URLs/bookmarks. */
static const MLKBarcodeValueType MLKBarcodeValueTypeURL = 8;
/** Barcode value type for Wi-Fi access point details. */
static const MLKBarcodeValueType MLKBarcodeValueTypeWiFi = 9;
/** Barcode value type for geographic coordinates. */
static const MLKBarcodeValueType MLKBarcodeValueTypeGeographicCoordinates = 10;
/** Barcode value type for calendar events. */
static const MLKBarcodeValueType MLKBarcodeValueTypeCalendarEvent = 11;
/** Barcode value type for driver's license data. */
static const MLKBarcodeValueType MLKBarcodeValueTypeDriversLicense = 12;

/**
 * @enum BarcodeAddressType
 * Address type.
 */
typedef NSInteger MLKBarcodeAddressType NS_TYPED_ENUM NS_SWIFT_NAME(BarcodeAddressType);
/** Barcode unknown address type. */
static const MLKBarcodeAddressType MLKBarcodeAddressTypeUnknown = 0;
/** Barcode work address type. */
static const MLKBarcodeAddressType MLKBarcodeAddressTypeWork = 1;
/** Barcode home address type. */
static const MLKBarcodeAddressType MLKBarcodeAddressTypeHome = 2;

/**
 * @enum BarcodeEmailType
 * Email type for BarcodeEmail.
 */
typedef NSInteger MLKBarcodeEmailType NS_TYPED_ENUM NS_SWIFT_NAME(BarcodeEmailType);
/** Unknown email type. */
static const MLKBarcodeEmailType MLKBarcodeEmailTypeUnknown = 0;
/** Barcode work email type. */
static const MLKBarcodeEmailType MLKBarcodeEmailTypeWork = 1;
/** Barcode home email type. */
static const MLKBarcodeEmailType MLKBarcodeEmailTypeHome = 2;

/**
 * @enum BarcodePhoneType
 * Phone type for BarcodePhone.
 */
typedef NSInteger MLKBarcodePhoneType NS_TYPED_ENUM NS_SWIFT_NAME(BarcodePhoneType);
/** Unknown phone type. */
static const MLKBarcodePhoneType MLKBarcodePhoneTypeUnknown = 0;
/** Barcode work phone type. */
static const MLKBarcodePhoneType MLKBarcodePhoneTypeWork = 1;
/** Barcode home phone type. */
static const MLKBarcodePhoneType MLKBarcodePhoneTypeHome = 2;
/** Barcode fax phone type. */
static const MLKBarcodePhoneType MLKBarcodePhoneTypeFax = 3;
/** Barcode mobile phone type. */
static const MLKBarcodePhoneType MLKBarcodePhoneTypeMobile = 4;

/**
 * @enum BarcodeWiFiEncryptionType
 * Wi-Fi encryption type for BarcodeWiFi.
 */
typedef NSInteger MLKBarcodeWiFiEncryptionType
    NS_TYPED_ENUM NS_SWIFT_NAME(BarcodeWiFiEncryptionType);
/** Barcode unknown Wi-Fi encryption type. */
static const MLKBarcodeWiFiEncryptionType MLKBarcodeWiFiEncryptionTypeUnknown = 0;
/** Barcode open Wi-Fi encryption type. */
static const MLKBarcodeWiFiEncryptionType MLKBarcodeWiFiEncryptionTypeOpen = 1;
/** Barcode WPA Wi-Fi encryption type. */
static const MLKBarcodeWiFiEncryptionType MLKBarcodeWiFiEncryptionTypeWPA = 2;
/** Barcode WEP Wi-Fi encryption type. */
static const MLKBarcodeWiFiEncryptionType MLKBarcodeWiFiEncryptionTypeWEP = 3;

/** An address. */
NS_SWIFT_NAME(BarcodeAddress)
@interface MLKBarcodeAddress : NSObject

/**
 * Formatted address, containing multiple lines when appropriate.
 *
 * The parsing of address formats is quite limited. Typically all address information will appear on
 * the first address line. To handle addresses better, it is recommended to parse the raw data. The
 * raw data is available in `Barcode`'s `rawValue` property.
 */
@property(nonatomic, readonly, nullable) NSArray<NSString *> *addressLines;

/** Address type. */
@property(nonatomic, readonly) MLKBarcodeAddressType type;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** A calendar event extracted from a QR code. */
NS_SWIFT_NAME(BarcodeCalendarEvent)
@interface MLKBarcodeCalendarEvent : NSObject

/** Calendar event description. */
@property(nonatomic, readonly, nullable) NSString *eventDescription;

/** Calendar event location. */
@property(nonatomic, readonly, nullable) NSString *location;

/** Calendar event organizer. */
@property(nonatomic, readonly, nullable) NSString *organizer;

/** Calendar event status. */
@property(nonatomic, readonly, nullable) NSString *status;

/** Calendar event summary. */
@property(nonatomic, readonly, nullable) NSString *summary;

/** Calendar event start date. */
@property(nonatomic, readonly, nullable) NSDate *start;

/** Calendar event end date. */
@property(nonatomic, readonly, nullable) NSDate *end;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * A driver's license or ID card data representation.
 *
 * An ANSI driver's license contains more fields than are represented by this class. The `Barcode`'s
 * `rawValue` property can be used to access the other fields.
 */
NS_SWIFT_NAME(BarcodeDriverLicense)
@interface MLKBarcodeDriverLicense : NSObject

/** Holder's first name. */
@property(nonatomic, readonly, nullable) NSString *firstName;

/** Holder's middle name. */
@property(nonatomic, readonly, nullable) NSString *middleName;

/** Holder's last name. */
@property(nonatomic, readonly, nullable) NSString *lastName;

/** Holder's gender. 1 is male and 2 is female. */
@property(nonatomic, readonly, nullable) NSString *gender;

/** City of the holder's address. */
@property(nonatomic, readonly, nullable) NSString *addressCity;

/** State of the holder's address. */
@property(nonatomic, readonly, nullable) NSString *addressState;

/** Street of the holder's address. */
@property(nonatomic, readonly, nullable) NSString *addressStreet;

/** Zipcode of the holder's address. */
@property(nonatomic, readonly, nullable) NSString *addressZip;

/** Holder's birthday. The date format depends on the issuing country. */
@property(nonatomic, readonly, nullable) NSString *birthDate;

/** `DL` for driver's licenses, `ID` for ID cards. */
@property(nonatomic, readonly, nullable) NSString *documentType;

/** Driver's license ID number. */
@property(nonatomic, readonly, nullable) NSString *licenseNumber;

/** Driver's license expiration date. The date format depends on the issuing country. */
@property(nonatomic, readonly, nullable) NSString *expiryDate;

/** The date format depends on the issuing country. */
@property(nonatomic, readonly, nullable) NSString *issuingDate;

/** The country in which the DL/ID was issued. */
@property(nonatomic, readonly, nullable) NSString *issuingCountry;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** An email message from a 'MAILTO:' or similar QR Code type. */
NS_SWIFT_NAME(BarcodeEmail)
@interface MLKBarcodeEmail : NSObject

/** Email message address. */
@property(nonatomic, readonly, nullable) NSString *address;

/** Email message body. */
@property(nonatomic, readonly, nullable) NSString *body;

/** Email message subject. */
@property(nonatomic, readonly, nullable) NSString *subject;

/** Email message type. */
@property(nonatomic, readonly) MLKBarcodeEmailType type;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** GPS coordinates from a `GEO:` or similar QR Code type data. */
NS_SWIFT_NAME(BarcodeGeoPoint)
@interface MLKBarcodeGeoPoint : NSObject
/** A location latitude. */
@property(nonatomic, readonly) double latitude;

/** A location longitude. */
@property(nonatomic, readonly) double longitude;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** A person's name, both formatted as individual name components. */
NS_SWIFT_NAME(BarcodePersonName)
@interface MLKBarcodePersonName : NSObject

/** Properly formatted name. */
@property(nonatomic, readonly, nullable) NSString *formattedName;

/** First name. */
@property(nonatomic, readonly, nullable) NSString *first;

/** Last name. */
@property(nonatomic, readonly, nullable) NSString *last;

/** Middle name. */
@property(nonatomic, readonly, nullable) NSString *middle;

/** Name prefix. */
@property(nonatomic, readonly, nullable) NSString *prefix;

/**
 * Designates a text string to be set as the kana name in the phonebook.
 * Used for Japanese contacts.
 */
@property(nonatomic, readonly, nullable) NSString *pronunciation;

/** Name suffix. */
@property(nonatomic, readonly, nullable) NSString *suffix;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** A phone number from a `TEL:` or similar QR Code type. */
NS_SWIFT_NAME(BarcodePhone)
@interface MLKBarcodePhone : NSObject

/** Phone number. */
@property(nonatomic, readonly, nullable) NSString *number;

/** Phone number type. */
@property(nonatomic, readonly) MLKBarcodePhoneType type;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** An SMS message from an `SMS:` or similar QR Code type. */
NS_SWIFT_NAME(BarcodeSMS)
@interface MLKBarcodeSMS : NSObject

/** An SMS message body. */
@property(nonatomic, readonly, nullable) NSString *message;

/** An SMS message phone number. */
@property(nonatomic, readonly, nullable) NSString *phoneNumber;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** A URL and title from a 'MEBKM:' or similar QR Code type. */
NS_SWIFT_NAME(BarcodeURLBookmark)
@interface MLKBarcodeURLBookmark : NSObject

/** A URL bookmark title. */
@property(nonatomic, readonly, nullable) NSString *title;

/** A URL bookmark url. */
@property(nonatomic, readonly, nullable) NSString *url;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** Wi-Fi network parameters from a `WIFI:` or similar QR Code type. */
NS_SWIFT_NAME(BarcodeWifi)
@interface MLKBarcodeWiFi : NSObject

/** A Wi-Fi access point SSID. */
@property(nonatomic, readonly, nullable) NSString *ssid;

/** A Wi-Fi access point password. */
@property(nonatomic, readonly, nullable) NSString *password;

/** A Wi-Fi access point encryption type. */
@property(nonatomic, readonly) MLKBarcodeWiFiEncryptionType type;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * A person's or organization's business card. This may come from different underlying formats
 * including `VCARD` and `MECARD`.
 *
 * This object represents a simplified view of possible business cards. If you require lossless
 * access to the information in the barcode, you should parse the raw data yourself. To access the
 * raw data, use the `Barcode`'s `rawValue` property.
 */
NS_SWIFT_NAME(BarcodeContactInfo)
@interface MLKBarcodeContactInfo : NSObject

/** Person's or organization's addresses. */
@property(nonatomic, readonly, nullable) NSArray<MLKBarcodeAddress *> *addresses;

/** Contact emails. */
@property(nonatomic, readonly, nullable) NSArray<MLKBarcodeEmail *> *emails;

/** A person's name. */
@property(nonatomic, readonly, nullable) MLKBarcodePersonName *name;

/** Contact phone numbers. */
@property(nonatomic, readonly, nullable) NSArray<MLKBarcodePhone *> *phones;

/** Contact URLs. */
@property(nonatomic, readonly, nullable) NSArray<NSString *> *urls;

/** A job title. */
@property(nonatomic, readonly, nullable) NSString *jobTitle;

/** A business organization. */
@property(nonatomic, readonly, nullable) NSString *organization;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

/** A barcode in an image. */
NS_SWIFT_NAME(Barcode)
@interface MLKBarcode : NSObject

/**
 * The rectangle that holds the discovered barcode relative to the detected image in the view
 * coordinate system.
 */
@property(nonatomic, readonly) CGRect frame;

/**
 * A barcode value as it was encoded in the barcode. Structured values are not parsed, for example:
 * 'MEBKM:TITLE:Google;URL:https://www.google.com;;'. Does not include the supplemental value.
 *
 * @discussion It's only available when the barcode is encoded in the UTF-8 format, and for non-UTF8
 *     barcodes use `rawData` instead.
 */
@property(nonatomic, readonly, nullable) NSString *rawValue;

/** Raw data stored in barcode. */
@property(nonatomic, readonly, nullable) NSData *rawData;

/**
 * A barcode value in a user-friendly format. May omit some of the information encoded in the
 * barcode. For example, in the case above the display value might be 'https://www.google.com'.
 * If `valueType == .text`, this field will be equal to `rawValue`. This value may be multiline, for
 * example, when line breaks are encoded into the original TEXT barcode value. May include the
 * supplement value.
 */
@property(nonatomic, readonly, nullable) NSString *displayValue;

/**
 * A barcode format; for example, EAN_13. Note that if the format is not in the list, `.unknown`
 * would be returned.
 */
@property(nonatomic, readonly) MLKBarcodeFormat format;

/**
 * The four corner points of the barcode, in clockwise order starting with the top left relative to
 * the detected image in the view coordinate system. These are `CGPoints` wrapped in `NSValues`. Due
 * to the possible perspective distortions, this is not necessarily a rectangle.
 */
@property(nonatomic, readonly, nullable) NSArray<NSValue *> *cornerPoints;

/**
 * A type of the barcode value. For example, TEXT, PRODUCT, URL, etc. Note that if the type is not
 * in the list, `.unknown` would be returned.
 */
@property(nonatomic, readonly) MLKBarcodeValueType valueType;

/**
 * An email message from a `MAILTO:` or similar QR Code type. This property is only set if
 * `valueType` is `.email`.
 */
@property(nonatomic, readonly, nullable) MLKBarcodeEmail *email;

/**
 * A phone number from a 'TEL:' or similar QR Code type. This property is only set if `valueType` is
 * `.phone`.
 */
@property(nonatomic, readonly, nullable) MLKBarcodePhone *phone;

/**
 * An SMS message from an 'SMS:' or similar QR Code type. This property is only set if `valueType`
 * is `.sms`.
 */
@property(nonatomic, readonly, nullable) MLKBarcodeSMS *sms;

/**
 * A URL and title from a 'MEBKM:' or similar QR Code type. This property is only set if `valueType`
 * is `.url`.
 */
@property(nonatomic, readonly, nullable) MLKBarcodeURLBookmark *URL;

/**
 * Wi-Fi network parameters from a 'WIFI:' or similar QR Code type. This property is only set if
 * `valueType` is `.wifi`.
 */
@property(nonatomic, readonly, nullable) MLKBarcodeWiFi *wifi;

/**
 * GPS coordinates from a `GEO:` or similar QR Code type. This property is only set if `valueType`
 * is `.geo`.
 */
@property(nonatomic, readonly, nullable) MLKBarcodeGeoPoint *geoPoint;

/**
 * A person's or organization's business card. For example a VCARD. This property is only set if
 * `valueType` is `.contactInfo`.
 */
@property(nonatomic, readonly, nullable) MLKBarcodeContactInfo *contactInfo;

/**
 * A calendar event extracted from a QR Code. This property is only set if `valueType` is
 * `.calendarEvent`.
 */
@property(nonatomic, readonly, nullable) MLKBarcodeCalendarEvent *calendarEvent;

/** A driver's license or ID card. This property is only set if `valueType` is `.driverLicense`. */
@property(nonatomic, readonly, nullable) MLKBarcodeDriverLicense *driverLicense;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
