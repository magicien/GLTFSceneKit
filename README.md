# GLTFSceneKit
glTF loader for SceneKit

## Installation
### Using [CocoaPods](http://cocoapods.org/)

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'GLTFSceneKit'
```

## Usage

```
import GLTFSceneKit

var scene: SCNScene
do {
  let sceneSource = try GLTFSceneSource(named: "art.scnassets/Box/glTF/Box.gltf")
  scene = try sceneSource.scene()
} catch {
  print("\(error.localizedDescription)")
  return
}
```

## See also

[GLTFQuickLook](https://github.com/magicien/GLTFQuickLook) - QuickLook plugin for glTF files
