import XCTest
final class SonosUITests: XCTestCase {
    @MainActor func testFixturePlayback() {
        let app = XCUIApplication(); app.launch()
        XCTAssertTrue(app.staticTexts["Living Room"].waitForExistence(timeout: 5))
        app.buttons["Play"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Command sent."].waitForExistence(timeout: 5))
        app.buttons["Pause"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Command sent."].exists)
    }
}
