import Foundation

public enum BarcodeSymbology: Int16, Codable {
    case aztec = 1
    case code39
    case code39Checksum
    case code39FullASCII
    case code39FullASCIIChecksum
    case code93
    case code93i
    case code128
    case dataMatrix
    case ean8
    case ean13
    case i2of5
    case i2of5Checksum
    case itf14
    case pdf417
    case qr
    case upce
    case codabar
    case gs1DataBar
    case gs1DataBarExpanded
    case gs1DataBarLimited
    case microPDF417
    case microQR
}
