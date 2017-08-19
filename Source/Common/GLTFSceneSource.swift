//
//  GLTFSceneSource.swift
//  GLTFSceneKit
//
//  Created by magicien on 2017/08/17.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import SceneKit

public class GLTFSceneSource : SCNSceneSource {
    private var loader: GLTFUnarchiver! = nil
    
    public override init() {
        super.init()
    }
    
    public override convenience init(url: URL, options: [SCNSceneSource.LoadingOption : Any]? = nil) {
        self.init()
    }
    
    public override convenience init(data: Data, options: [SCNSceneSource.LoadingOption : Any]? = nil) {
        self.init()
        do {
            let loader = try GLTFUnarchiver(data: data)
            self.loader = loader
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    public convenience init(path: String, options: [SCNSceneSource.LoadingOption : Any]? = nil) throws {
        self.init()
        
        /*
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        if data == nil {
            print("data is nil... (\(path))")
            return nil
        } else {
            var opt: [SCNSceneSource.LoadingOption: Any]
            if options != nil {
                opt = options!
            } else {
                opt = [:]
            }
            
            if opt[.assetDirectoryURLs] == nil {
                opt[.assetDirectoryURLs] = [URL(fileURLWithPath: self.directoryPath)]
            }
            self.loadData(data!, options: opt)
        }
 */
        let loader = try GLTFUnarchiver(path: path)
        self.loader = loader
    }
    
    public convenience init(named name: String, options: [SCNSceneSource.LoadingOption : Any]? = nil) throws {
        let filePath = Bundle.main.path(forResource: name, ofType: nil)
        guard let path = filePath else {
            throw URLError(.fileDoesNotExist)
        }
        try self.init(path: path, options: options)
    }
    
    public override func scene(options: [SCNSceneSource.LoadingOption : Any]? = nil) throws -> SCNScene {
        return try self.loader.loadScene()
    }
}
