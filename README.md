# GLTFSceneKit
glTF loader for SceneKit

![ScreenShot](https://raw.githubusercontent.com/magicien/GLTFSceneKit/master/screenshot.png)

## Installation
### Using [CocoaPods](http://cocoapods.org/)

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'GLTFSceneKit'
```

### Manually

Download **GLTFSceneKit_vX.X.X.zip** from [Releases](https://github.com/magicien/GLTFSceneKit/releases/latest).

## Usage

### Swift
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

### Objective-C
```
@import GLTFSceneKit;

GLTFSceneSource *source = [[GLTFSceneSource alloc] initWithURL:url options:nil];
NSError *error;
SCNScene *scene = [source sceneWithOptions:nil error:&error];
if (error != nil) {
  NSLog(@"%@", error);
  return;
}
```

## See also

[GLTFQuickLook](https://github.com/magicien/GLTFQuickLook) - QuickLook plugin for glTF files
