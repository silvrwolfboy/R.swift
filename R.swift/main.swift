//
//  main.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 11-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

let defaultFileManager = NSFileManager.defaultManager()
let findAllAssetsFolderURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { $0.isDirectory && $0.absoluteString!.pathExtension == "xcassets" }
let findAllNibURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && $0.absoluteString!.pathExtension == "xib" }
let findAllStoryboardURLsInDirectory = filterDirectoryContentsRecursively(defaultFileManager) { !$0.isDirectory && $0.absoluteString!.pathExtension == "storyboard" }

inputDirectories(NSProcessInfo.processInfo())
  .each { directory in

    // Get/parse all resources into our domain objects
    let assetFolders = findAllAssetsFolderURLsInDirectory(url: directory)
      .map { AssetFolder(url: $0, fileManager: defaultFileManager) }

    let storyboards = findAllStoryboardURLsInDirectory(url: directory)
      .map { Storyboard(url: $0) }

    let nibs = findAllNibURLsInDirectory(url: directory)
      .map { Nib(url: $0) }

    // Generate
    let structs = [
      imageStructFromAssetFolders(assetFolders),
      segueStructFromStoryboards(storyboards),
      storyboardStructFromStoryboards(storyboards),
      nibStructFromNibs(nibs),
    ]

    let functions = [
      validateAllFunctionWithStoryboards(storyboards),
    ]

    // Write out the code
    let resourceStruct = Struct(name: "R", vars: [], functions: functions, structs: structs, lowercaseFirstCharacter: false)
    writeResourceFile(Header + resourceStruct.description, toFolderURL: directory)
  }
