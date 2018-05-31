import Foundation
@testable import xcodeproj
import XCTest

final class PBXNativeTargetSpec: XCTestCase {
    var subject: PBXNativeTarget!

    override func setUp() {
        super.setUp()
        subject = PBXNativeTarget(name: "name",
                                  buildConfigurationList: PBXObjectReference("list"),
                                  buildPhases: [PBXObjectReference("phase")],
                                  buildRules: [PBXObjectReference("rule")],
                                  dependencies: [PBXObjectReference("dependency")],
                                  productInstallPath: "/usr/local/bin",
                                  productName: "productname",
                                  productReference: PBXObjectReference("productreference"),
                                  productType: .application)
    }

    func test_isa_returnsTheCorrectValue() {
        XCTAssertEqual(PBXNativeTarget.isa, "PBXNativeTarget")
    }

    func test_init_failsWhenNameIsMissing() {
        var dictionary = testDictionary()
        dictionary.removeValue(forKey: "name")
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        let decoder = XcodeprojJSONDecoder()
        do {
            _ = try decoder.decode(PBXNativeTarget.self, from: data)
            XCTAssertTrue(false, "Expected to throw an error but it didn't")
        } catch {}
    }

    private func testDictionary() -> [String: Any] {
        return [
            "buildConfigurationList": "test",
            "buildPhases": ["phase"],
            "buildRules": ["rule"],
            "dependencies": ["dependency"],
            "name": "name",
            "productInstallPath": "/usr/local/bin",
        ]
    }

    func test_addDependency() throws {
        let objects = PBXObjects(objects: [:])
        let configurationList = objects.addObject(XCConfigurationList(buildConfigurationsReferences: []))
        let mainGroup = objects.addObject(PBXGroup())
        let project = PBXProject(name: "Project",
                                 buildConfigurationList: configurationList,
                                 compatibilityVersion: "0",
                                 mainGroup: mainGroup)
        objects.addObject(project)
        let target = PBXNativeTarget(name: "Target")
        let dependency = PBXNativeTarget(name: "Dependency")
        objects.addObject(target)
        objects.addObject(dependency)
        _ = try target.addDependency(target: dependency)
        let targetDependency: PBXTargetDependency? = try target.dependencies.first?.object()
        XCTAssertEqual(targetDependency?.name, "Dependency")
        XCTAssertEqual(targetDependency?.target, dependency.reference)
        let containerItemProxy: PBXContainerItemProxy? = try targetDependency?.targetProxy?.object()
        XCTAssertEqual(containerItemProxy?.containerPortal, project.reference)
        XCTAssertEqual(containerItemProxy?.remoteGlobalID, dependency.reference)
        XCTAssertEqual(containerItemProxy?.proxyType, .nativeTarget)
        XCTAssertEqual(containerItemProxy?.remoteInfo, "Dependency")
    }
}