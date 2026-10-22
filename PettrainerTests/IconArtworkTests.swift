import SwiftUI
import XCTest
@testable import Pettrainer

/// The app icon artwork is the product's own visual language, not a separate
/// design task: the sit silhouette from `DogPoseGlyph` with the lure treat
/// above the nose (the exact teaching gesture of Step 1), in the app palette.
/// Run deliberately with a sentinel file at `Documents/reicon.flag` inside
/// the app container to emit the master PNG (launchd does not forward host
/// env vars to simulator apps); the checked-in asset in
/// `Assets.xcassets/AppIcon.appiconset` was produced from this render and
/// downscaled with `sips`. Re-run after any pose or palette change.
@MainActor
final class IconArtworkTests: XCTestCase {
    struct IconArtwork: View {
        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0x35795A), Color(hex: 0x1E4A35)],
                    startPoint: .top, endPoint: .bottom
                )
                GlyphCanvas(size: 720) { context in
                    DogPoseGlyph.draw(&context, pose: .sit,
                                      color: SVGColor(hex: 0xF1F3EE),
                                      accent: SVGColor(hex: 0xF1F3EE))
                    // The lure: one treat held above the nose — the dog's
                    // whole job in Step 1, and the icon's whole promise.
                    context.fill(context.circle(88, 16, 6.5), SVGColor(hex: 0xE0A64B))
                }
                .offset(y: -14) // visual centre of the dog sits at y≈52/100
            }
            .frame(width: 1024, height: 1024)
        }
    }

    func testRenderIconMasterIfRequested() throws {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let flag = documents.appendingPathComponent("reicon.flag")
        guard FileManager.default.fileExists(atPath: flag.path) else {
            throw XCTSkip("icon master regeneration not requested")
        }
        let renderer = ImageRenderer(content: IconArtwork())
        renderer.scale = 1
        guard let image = renderer.cgImage else {
            return XCTFail("icon master failed to render")
        }
        XCTAssertEqual(image.width, 1024)
        XCTAssertEqual(image.height, 1024)
        guard let data = UIImage(cgImage: image).pngData() else {
            return XCTFail("PNG encoding failed")
        }
        XCTAssertGreaterThan(data.count, 10_000)
        let url = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent("icon-1024.png")
        try data.write(to: url)
    }
}
