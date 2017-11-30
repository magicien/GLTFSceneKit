Pod::Spec.new do |s|
  s.name = "GLTFSceneKit"
  s.version = "0.1.2"
  s.summary = "glTF loader for SceneKit"
  s.homepage = "https://github.com/magicien/GLTFSceneKit"
  s.license = "MIT"
  s.author = "magicien"
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  s.source = { :git => "https://github.com/magicien/GLTFSceneKit.git", :tag => "v#{s.version}" }
  s.source_files = "Source/**/*.swift"
  s.resources = "Source/**/*.shader"
  s.requires_arc = true
  s.pod_target_xcconfig = {
    "SWIFT_VERSION" => "4.0",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS" => "SEEMS_TO_HAVE_VALIDATE_VERTEX_ATTRIBUTE_BUG SEEMS_TO_HAVE_PNG_LOADING_BUG"
  }
end
