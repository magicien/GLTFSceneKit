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
    @IBOutlet weak var openFileButton: NSButton!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        var scene: SCNScene
        do {
            let sceneSource = try GLTFSceneSource(named: "art.scnassets/Box/glTF/Box.gltf")
            scene = try sceneSource.scene()
        } catch {
            print("\(error.localizedDescription)")
            return
        }
        
        self.setScene(scene)
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.black
    }
    
    func setScene(_ scene: SCNScene) {
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
        
        // set the scene to the view
        self.gameView!.scene = scene
    }
    
    @IBAction func openFileButtonClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["gltf", "glb"]
        openPanel.message = "choose glTF file"
        openPanel.begin { (response) in
            if response == .OK {
                guard let url = openPanel.url else { return }
                do {
                    let sceneSource = GLTFSceneSource(url: url)
                    let scene = try sceneSource.scene()
                    self.setScene(scene)
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
}
