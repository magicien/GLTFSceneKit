//
//  GameViewController.swift
//  GLTFSceneKitSampler
//
//  Created by magicien on 2017/08/26.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GLTFSceneKit

class GameViewController: UIViewController {
    
    var gameView: SCNView? {
        get { return self.view as? SCNView }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var scene: SCNScene
        do {
            let sceneSource = try GLTFSceneSource(named: "art.scnassets/Box/glTF/Box.gltf")
            scene = try sceneSource.scene()
        } catch {
            print("\(error.localizedDescription)")
            return
        }
        
        self.setScene(scene)
        
        self.gameView!.autoenablesDefaultLighting = true
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = UIColor.gray
    }
    
    func setScene(_ scene: SCNScene) {
        // update camera names
        /*
        self.cameraNodes = scene.rootNode.childNodes(passingTest: { (node, finish) -> Bool in
            return node.camera != nil
        })
        
        // set the scene to the view
        self.gameView!.scene = scene
        
        // set the camera menu
        self.cameraSelect.menu?.removeAllItems()
        if self.cameraNodes.count > 0 {
            self.cameraSelect.removeAllItems()
            let titles = self.cameraNodes.map { $0.camera?.name ?? "untitled" }
            for title in titles {
                self.cameraSelect.menu?.addItem(withTitle: title, action: nil, keyEquivalent: "")
            }
            self.gameView!.pointOfView = self.cameraNodes[0]
        }
        
        let defaultCameraItem = NSMenuItem(title: "SCNViewFreeCamera", action: nil, keyEquivalent: "")
        defaultCameraItem.tag = self.defaultCameraTag
        defaultCameraItem.isEnabled = false
        self.cameraSelect.menu?.addItem(defaultCameraItem)
        
        self.cameraSelect.autoenablesItems = false
         */
        
        // set the scene to the view
        self.gameView!.scene = scene        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
