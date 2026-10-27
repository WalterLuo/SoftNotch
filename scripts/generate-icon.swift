import AppKit
import Foundation

// Original vector geometry for SoftNotch; no upstream artwork is used.
let destination = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
let image = NSImage(size: NSSize(width: 1024, height: 1024))
image.lockFocus()
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: 1024, height: 1024).fill()
let outer = NSBezierPath(roundedRect: NSRect(x: 72, y: 72, width: 880, height: 880), xRadius: 196, yRadius: 196)
NSColor(calibratedRed: 0.08, green: 0.11, blue: 0.14, alpha: 1).setFill()
outer.fill()
// A single continuous aqua ribbon forms an S beneath the inset notch.
let ribbon = NSBezierPath()
ribbon.move(to: NSPoint(x: 681, y: 649))
ribbon.curve(to: NSPoint(x: 379, y: 631), controlPoint1: NSPoint(x: 588, y: 742), controlPoint2: NSPoint(x: 370, y: 747))
ribbon.curve(to: NSPoint(x: 642, y: 446), controlPoint1: NSPoint(x: 386, y: 535), controlPoint2: NSPoint(x: 647, y: 545))
ribbon.curve(to: NSPoint(x: 338, y: 362), controlPoint1: NSPoint(x: 637, y: 308), controlPoint2: NSPoint(x: 432, y: 275))
ribbon.lineWidth = 82
ribbon.lineCapStyle = .round
ribbon.lineJoinStyle = .round
NSColor(calibratedRed: 0.40, green: 0.91, blue: 0.80, alpha: 1).setStroke()
ribbon.stroke()
NSColor(calibratedRed: 0.025, green: 0.035, blue: 0.045, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 366, y: 837, width: 292, height: 72), xRadius: 30, yRadius: 30).fill()
image.unlockFocus()
let source = NSBitmapImageRep(data: image.tiffRepresentation!)!.cgImage!
var entries: [[String: String]] = []
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let px = size * scale
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current!.cgContext.interpolationQuality = .high
        NSGraphicsContext.current!.cgContext.draw(source, in: CGRect(x: 0, y: 0, width: px, height: px))
        NSGraphicsContext.restoreGraphicsState()
        let name = "softnotch-\(size)@\(scale)x.png"
        try bitmap.representation(using: .png, properties: [:])!.write(to: destination.appendingPathComponent(name))
        entries.append(["filename": name, "idiom": "mac", "scale": "\(scale)x", "size": "\(size)x\(size)"])
    }
}
let data = try JSONSerialization.data(withJSONObject: ["images": entries, "info": ["author": "xcode", "version": 1]], options: [.prettyPrinted, .sortedKeys])
try data.write(to: destination.appendingPathComponent("Contents.json"))
print("Generated all 10 SoftNotch macOS icon sizes.")
