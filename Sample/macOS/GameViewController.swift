//
//  GameViewController.swift
//  GameSample
//
//  Created by magicien on 2017/08/17.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import SceneKit
import QuartzCore
import GLTFSceneKit

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        //let loader = GLTFLoader(path: "art.scnassets/Box/Box.gltf")!
        //loader.debugPrint()
        var scene: SCNScene
        do {
            let sceneSource = try GLTFSceneSource(named: "art.scnassets/Box/Box.gltf")
            scene = try sceneSource.scene()
        } catch {
            print("\(error.localizedDescription)")
            return
        }
        
        print("childNodes: \(scene.rootNode.childNodes.count)")
        let node0 = scene.rootNode.childNodes[0]
        let node1 = node0.childNodes[0]
        let primitiveNode = node1.childNodes[0]
        let mesh0 = primitiveNode.childNodes[0]
        let geometry = mesh0.geometry!
        let element = geometry.element(at: 0)
        print("===== geometry ====")
        element.data.withUnsafeBytes { (p: UnsafePointer<UInt16>) in
            for i in 0..<element.primitiveCount {
                let i1 = p[i*3 + 0]
                let i2 = p[i*3 + 1]
                let i3 = p[i*3 + 2]
                print("\(i): \(i1), \(i2), \(i3)")
            }
        }
        element.data.withUnsafeBytes { (p: UnsafePointer<Float32>) in
            for i in 0..<10 {
                let i1 = p[i*3 + 0]
                let i2 = p[i*3 + 1]
                let i3 = p[i*3 + 2]
                print("\(i): \(i1), \(i2), \(i3)")
            }
        }
        
        // create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        /*
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(Double.pi)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        ship.addAnimation(animation, forKey: nil)
*/
        
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.black
    }

}
