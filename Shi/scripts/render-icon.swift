#!/usr/bin/env swift
import AppKit
import CoreText
import Foundation

// Renders the "拭" app assets:
//   arg1: app-icon master PNG (1024, rounded macOS body + soft drop shadow on transparent canvas)
//   arg2: in-app logo PNG (512, full-bleed white surface; SwiftUI clips the corners)
//
// Concept: clean, minimal, Apple-style. A bright white "porcelain / frosted glass"
// slab, freshly wiped: soft top highlight, a faint diagonal sheen, and an elegant
// ink 拭 optically centered. No black slab, no sparkles, no gradient AI purple.

let dim = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()

func makeContext() -> CGContext {
    guard let ctx = CGContext(
        data: nil,
        width: dim,
        height: dim,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { fatalError("context") }
    ctx.interpolationQuality = .high
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)
    return ctx
}

func srgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: r, green: g, blue: b, alpha: a)
}

// MARK: - Clean white surface

/// Draws the bright porcelain surface + 拭 glyph + faint wipe sheen inside `rect`.
/// Caller is expected to have already clipped to the rounded body.
func drawCleanSurface(_ ctx: CGContext, rect: CGRect) {
    let w = rect.width
    let h = rect.height
    let minX = rect.minX
    let minY = rect.minY

    // 1) Base vertical gradient — near-white, a whisper cooler/heavier at the bottom.
    let base = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            srgb(1.000, 1.000, 1.000),   // top    #FFFFFF
            srgb(0.984, 0.984, 0.980),   // mid    #FBFBFA
            srgb(0.937, 0.941, 0.945)    // bottom #EFF0F1
        ] as CFArray,
        locations: [0, 0.55, 1]
    )!
    ctx.drawLinearGradient(
        base,
        start: CGPoint(x: minX, y: rect.maxY),
        end: CGPoint(x: minX, y: minY),
        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )

    // 2) Soft light pooling from the upper-left — the light source on the glass.
    let hi = CGPoint(x: minX + w * 0.30, y: minY + h * 0.76)
    let highlight = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            srgb(1, 1, 1, 0.70),
            srgb(1, 1, 1, 0.0)
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawRadialGradient(
        highlight,
        startCenter: hi, startRadius: 0,
        endCenter: hi, endRadius: w * 0.75,
        options: []
    )

    // 3) Quiet cool shade in the lower-right so the slab feels rounded, not flat.
    let sh = CGPoint(x: minX + w * 0.80, y: minY + h * 0.20)
    let shade = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            srgb(0.62, 0.66, 0.72, 0.14),
            srgb(0.62, 0.66, 0.72, 0.0)
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawRadialGradient(
        shade,
        startCenter: sh, startRadius: 0,
        endCenter: sh, endRadius: w * 0.70,
        options: []
    )

    // 4) A faint diagonal wipe sheen — a brighter band sweeping upper-left → lower-right.
    ctx.saveGState()
    let bandCenter = CGPoint(x: minX + w * 0.50, y: minY + h * 0.54)
    ctx.translateBy(x: bandCenter.x, y: bandCenter.y)
    ctx.rotate(by: .pi / 4.35)
    ctx.scaleBy(x: 1.0, y: 2.4)
    let band = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            srgb(1, 1, 1, 0.55),
            srgb(1, 1, 1, 0.0)
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawRadialGradient(
        band,
        startCenter: .zero, startRadius: 0,
        endCenter: .zero, endRadius: w * 0.60,
        options: []
    )
    ctx.restoreGState()

    // 5) The 拭 glyph — elegant ink, optically centered, with a whisper of lift.
    drawGlyph(ctx, rect: rect)

    // 6) Glassy bevel — bright top edge, quiet bottom edge.
    let topLight = CGGradient(
        colorsSpace: colorSpace,
        colors: [srgb(1, 1, 1, 0.55), srgb(1, 1, 1, 0.0)] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(
        topLight,
        start: CGPoint(x: minX, y: rect.maxY),
        end: CGPoint(x: minX, y: rect.maxY - h * 0.14),
        options: []
    )
    let bottomShade = CGGradient(
        colorsSpace: colorSpace,
        colors: [srgb(0.55, 0.58, 0.63, 0.10), srgb(0.55, 0.58, 0.63, 0.0)] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(
        bottomShade,
        start: CGPoint(x: minX, y: minY),
        end: CGPoint(x: minX, y: minY + h * 0.16),
        options: []
    )
}

func drawGlyph(_ ctx: CGContext, rect: CGRect) {
    let fontSize = rect.width * 0.53
    let font = NSFont(name: "PingFangSC-Regular", size: fontSize)
        ?? NSFont.systemFont(ofSize: fontSize, weight: .regular)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(srgbRed: 0.161, green: 0.161, blue: 0.176, alpha: 1)
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: "拭", attributes: attrs))
    let bounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds])
    let x = rect.minX + (rect.width - bounds.width) / 2 - bounds.minX
    let y = rect.minY + (rect.height - bounds.height) / 2 - bounds.minY + rect.height * 0.006

    ctx.saveGState()
    ctx.textMatrix = .identity
    ctx.setShadow(offset: CGSize(width: 0, height: -rect.height * 0.004),
                  blur: rect.width * 0.010,
                  color: srgb(0.30, 0.32, 0.38, 0.22))
    ctx.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

// MARK: - Rounded macOS body path

func roundedBodyPath(rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

// MARK: - App icon master (padded body + drop shadow)

func renderAppIcon() -> CGImage {
    let ctx = makeContext()
    let canvas = CGRect(x: 0, y: 0, width: dim, height: dim)
    ctx.clear(canvas)

    // Larger body so the slab matches neighbouring Dock icons (~89% of canvas),
    // while still leaving a little transparent room for the drop shadow.
    let inset: CGFloat = 56
    let body = canvas.insetBy(dx: inset, dy: inset)
    let radius = body.width * 0.2237
    let path = roundedBodyPath(rect: body, radius: radius)

    // Soft ambient drop shadow beneath the white slab.
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14),
                  blur: 30,
                  color: srgb(0.20, 0.22, 0.28, 0.20))
    ctx.addPath(path)
    ctx.setFillColor(srgb(0.98, 0.98, 0.975))
    ctx.fillPath()
    ctx.restoreGState()

    // Surface content, clipped to the body.
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    drawCleanSurface(ctx, rect: body)
    ctx.restoreGState()

    // Hairline rim so the white slab keeps a crisp edge on light backgrounds.
    ctx.saveGState()
    ctx.addPath(path)
    ctx.setStrokeColor(srgb(0, 0, 0, 0.07))
    ctx.setLineWidth(2)
    ctx.strokePath()
    ctx.restoreGState()

    guard let image = ctx.makeImage() else { fatalError("icon image") }
    return image
}

// MARK: - In-app logo (full-bleed white surface; SwiftUI clips the corners)

func renderLogo() -> CGImage {
    let ctx = makeContext()
    let canvas = CGRect(x: 0, y: 0, width: dim, height: dim)
    ctx.clear(canvas)
    let radius = canvas.width * 0.16
    let path = roundedBodyPath(rect: canvas, radius: radius)
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    drawCleanSurface(ctx, rect: canvas)
    ctx.restoreGState()

    // Hairline rim for definition even when shown on white.
    ctx.saveGState()
    ctx.addPath(path)
    ctx.setStrokeColor(srgb(0, 0, 0, 0.06))
    ctx.setLineWidth(3)
    ctx.strokePath()
    ctx.restoreGState()

    guard let image = ctx.makeImage() else { fatalError("logo image") }
    return image
}

func writePNG(_ image: CGImage, to url: URL) {
    let rep = NSBitmapImageRep(cgImage: image)
    rep.size = NSSize(width: dim, height: dim)
    guard let png = rep.representation(using: .png, properties: [:]) else { fatalError("png") }
    try! png.write(to: url)
    print("wrote \(url.path)")
}

let iconURL = URL(fileURLWithPath: CommandLine.arguments[1])
let logoURL = URL(fileURLWithPath: CommandLine.arguments[2])
writePNG(renderAppIcon(), to: iconURL)
writePNG(renderLogo(), to: logoURL)
