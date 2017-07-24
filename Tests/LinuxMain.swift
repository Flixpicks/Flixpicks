#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    // AppTests
    testCase(RouteTests.allTests),
    testCase(UserControllerTests.allTests),
    testCase(MovieControllerTests.allTests),
    testCase(ShowControllerTests.allTests),
    testCase(SeasonControllerTests.allTests),
    testCase(EpisodeControllerTests.allTests)
])

#endif
