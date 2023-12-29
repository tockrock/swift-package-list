//
//  SwiftPackageListPropertyListPlugin.swift
//  SwiftPackageListPropertyListPlugin
//
//  Created by Felix Herrmann on 27.05.23.
//

import Foundation
import PackagePlugin

@main
struct SwiftPackageListPropertyListPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let projectPath = context.package.directory.appending("Package.swift")
        let executable = try context.tool(named: "swift-package-list").path
        let outputPath = context.pluginWorkDirectory
        let outputType = "plist"
        let sourcePackagesPath = try context.sourcePackagesDirectory()
        return [
            .buildCommand(
                displayName: "SwiftPackageListPlugin",
                executable: executable,
                arguments: [
                    projectPath,
                    "--custom-source-packages-path", sourcePackagesPath,
                    "--output-type", outputType,
                    "--output-path", outputPath,
                    "--requires-license",
                ],
                outputFiles: [outputPath.appending("package-list.plist")]
            )
        ]
    }
}

struct SourcePackagesNotFoundError: Error { }

extension PluginContext {
    func sourcePackagesDirectory() throws -> Path {
        var path = pluginWorkDirectory
        while path.lastComponent != "SourcePackages" {
            guard path.string != "/" else {
                throw SourcePackagesNotFoundError()
            }
            path = path.removingLastComponent()
        }
        return path
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftPackageListPropertyListPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let projectPath = context.xcodeProject.directory.appending("\(context.xcodeProject.displayName).xcodeproj")
        let executable = try context.tool(named: "swift-package-list").path
        let outputPath = context.pluginWorkDirectory
        let outputType = "plist"
        let sourcePackagesPath = try context.sourcePackagesDirectory()
        return [
            .buildCommand(
                displayName: "SwiftPackageListPlugin",
                executable: executable,
                arguments: [
                    projectPath,
                    "--custom-source-packages-path", sourcePackagesPath,
                    "--output-type", outputType,
                    "--output-path", outputPath,
                    "--requires-license",
                ],
                outputFiles: [outputPath.appending("package-list.plist")]
            )
        ]
    }
}

extension XcodePluginContext {
    func sourcePackagesDirectory() throws -> Path {
        var path = pluginWorkDirectory
        while path.lastComponent != "SourcePackages" {
            guard path.string != "/" else {
                throw SourcePackagesNotFoundError()
            }
            path = path.removingLastComponent()
        }
        return path
    }
}
#endif
