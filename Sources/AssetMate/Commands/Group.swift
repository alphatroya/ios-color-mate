//
// AssetMate
// 2021 Alexey Korolev <alphatroya@gmail.com>
//

import ArgumentParser
import Foundation

struct Group: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Group all color assets in the separate folder"
    )

    @Option(name: .shortAndLong, help: "Name for a color folder")
    var folder: String = "Colors"

    @Option(name: .shortAndLong, help: "Path to the Assets.xcassets folder")
    var asset: Asset?

    @Flag(name: .shortAndLong, help: "Enable verbose logging")
    var verbose: Bool = false

    func run() throws {
        let manager = FileManager.default
        let config = try load(asset)
        let contents = try manager.contentsOfDirectory(atPath: config.asset)
        let inputFiles = contents.filter { $0.hasSuffix(".colorset") }
        guard !inputFiles.isEmpty else {
            throw CleanExit.message("Assets folder doesn't contain any color assets, aborting command")
        }
        let originFolder = URL(fileURLWithPath: config.asset)
        let newFolder = originFolder.appendingPathComponent(folder)
        try manager.createDirectory(at: newFolder, withIntermediateDirectories: true)
        for file in inputFiles {
            if verbose {
                print("Moving \(file)")
            }
            try manager.moveItem(at: originFolder.appendingPathComponent(file), to: newFolder.appendingPathComponent(file))
        }
    }
}

extension Group: AssetConfigLoader {}
