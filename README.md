# SwiftPackageList

[![Version](https://img.shields.io/github/v/release/FelixHerrmann/swift-package-list)](https://github.com/FelixHerrmann/swift-package-list/releases)
[![License](https://img.shields.io/github/license/FelixHerrmann/swift-package-list)](https://github.com/FelixHerrmann/swift-package-list/blob/master/LICENSE)
[![Tweet](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2FFelixHerrmann%2Fswift-package-list)](https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2FFelixHerrmann%2Fswift-package-list)

A command-line tool to generate a JSON, PLIST or Settings.bundle file with all used SPM-dependencies of an Xcode project or workspace.

This includes all the `Package.resolved` informations and the license from the checkouts.
Additionally there is a Swift Package to read the generated `package-list.json` or `package-list.plist` from the application's bundle
with a top-level function or pre-build UI.


## Command-Line Tool

### Installation

#### Using [Mint](https://github.com/yonaskolb/mint):

```shell
mint install FelixHerrmann/swift-package-list
```

#### Installing from source:

Clone or download this repository and run `make install`, `make update` or `make uninstall` (with sudo if required).

### Usage

Open the terminal and run `swift-package-list <project-path>` with the path to the `.xcodeproj` or `.xcworkspace` file you want to generate the list from.

In addition to that you can specify the following options:

| Option                                        | Description                                                                                                              |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| -d, --derived-data-path \<derived-data-path\> | The path to your DerivedData-folder. (default: ~/Library/Developer/Xcode/DerivedData)                                    |
| -o, --output-path \<output-path\>             | The path where the package-list file will be stored. (default: ~/Desktop)                                                |
| -f, --file-type \<file-type\>                 | The file type of the generated package-list file. Available options are json, plist and settings-bundle. (default: json) |
| --requires-license                            | Will skip the packages without a license-file.                                                                           |
| --version                                     | Show the version.                                                                                                        |
| -h, --help                                    | Show help information.                                                                                                   |

### Run Script Phase

You can easily set up a Run Script Phase in your target of your Xcode project to keep the `package-list.json` up to date automatically:

1. open the corresponding target and click on the plus under the *Build Phases* section
2. select *New Run Script Phase* and add the following script into the code box:
```shell
if command -v swift-package-list &> /dev/null; then
    OUTPUT_PATH=$SOURCE_ROOT/$TARGETNAME
    swift-package-list $PROJECT_FILE_PATH --output-path "$OUTPUT_PATH" --requires-license
else
    echo "warning: swift-package-list not installed"
fi
```
3. optionally you can rename the Phase by double-clicking on the title
4. build your project (cmd + b)
5. right-click on the targets-folder in the sidebar and select *Add Files to "\<project-name\>"*
6. select `package-list.json` in the Finder-window

The `package-list.json`-file will be updated now on every build and can be opened from the bundle in your app.
You can do that manually or use the package for that (as follows).

#### Xcode Workspace (CocoaPods)

If you have an Xcode workspace instead of a standard Xcode project everything works exactly the same,
you just need a slightly modified script for the Run Script Phase:
```shell
if command -v swift-package-list &> /dev/null; then
    OUTPUT_PATH=$SOURCE_ROOT/$TARGETNAME
    WORKSPACE_FILE_PATH=${PROJECT_FILE_PATH%.xcodeproj}.xcworkspace
    swift-package-list $WORKSPACE_FILE_PATH --output-path "$OUTPUT_PATH" --requires-license
else
    echo "warning: swift-package-list not installed"
fi
```

### Settings Bundle

You can also generate a `Settings.bundle` file to show the acknowledgements in the Settings app. This works slightly different
than the other file types, because a Settings Bundle is a collection of several files and might already exist in your app. 
Just specify `--file-type settings-bundle` on the command execution.

**Important:** The `Root.plist` and `Root.strings` files will (unlike the other files) only be created if they not already exists,
otherwise it would remove exisiting configurations. Make sure you set up the `Acknowledgements.plist` correctly as a Child Pane as shown below:

```xml
<dict>
    <key>Type</key>
    <string>PSChildPaneSpecifier</string>
    <key>Title</key>
    <string>Acknowledgements</string>
    <key>File</key>
    <string>Acknowledgements</string>
</dict>
```

For more information on how to set up and use a Settings Bundle, take a look at Apple's [documentation](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html).


## Swift Package

Load `package-list.json` or `package-list.plist` from the bundle with a single function call or use the pre-build UI components.

### Requirements

- macOS 10.10+
- iOS 9.0+
- tvOS 9.0+
- watchOS 2.0+

### Usage

Add the package to your project as shown [here](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app).

It contains 3 libraries; `SwiftPackageList`/`SwiftPackageListObjc` for loading the Data in Swift and Objective-C 
and `SwiftPackageListUI` to get an iOS Settings-like user interface.

#### SwiftPackageList

```swift
import SwiftPackageList

do {
    let packages = try packageList()
    // use packages
} catch PackageListError.noPackageList {
    print("There is no package-list file")
} catch {
    print(error)
}
```

#### SwiftPackageListObjc

```objc
@import SwiftPackageListObjc;

NSError *error;
NSArray<SPLPackage *> *packages = SPLPackageList(&error);
if (packages) {
    // use packages
} else {
    if (error.code == SPLErrorNoPackageList) {
        NSLog(@"There is no package-list file");
    } else {
        NSLog(@"%@", error);
    }
}
```

#### SwiftPackageListUI

```swift
import SwiftPackageListUI

let acknowledgmentsViewController = SPLAcknowledgmentsTableViewController()
acknowledgmentsViewController.canOpenRepositoryLink = true
navigationController.pushViewController(acknowledgmentsViewController, animated: true)
```

```swift
import SwiftPackageListUI

var body: some View {
    NavigationView {
        AcknowledgmentsList()
    }
}
```

> It is currently localized in English and German.


## License

SwiftPackageList is available under the MIT license. See the [LICENSE](https://github.com/FelixHerrmann/swift-package-list/blob/master/LICENSE) file for more info.
