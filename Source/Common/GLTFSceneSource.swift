//
//  GLTFSceneSource.swift
//  GLTFSceneKit
//
//  Created by magicien on 2017/08/17.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import SceneKit

let attributeMap: [String: SCNGeometrySource.Semantic] = [
    "POSITION": SCNGeometrySource.Semantic.vertex,
    "NORMAL": SCNGeometrySource.Semantic.normal,
    "TANGENT": SCNGeometrySource.Semantic.tangent,
    "TEXCOORD_0": SCNGeometrySource.Semantic.texcoord,
    "TEXCOORD_1": SCNGeometrySource.Semantic.texcoord,
    "COLOR_0": SCNGeometrySource.Semantic.color,
    "JOINTS_0": SCNGeometrySource.Semantic.boneIndices,
    "WEIGHTS_0": SCNGeometrySource.Semantic.boneWeights
]

let GLTF_BYTE = Int(GL_BYTE)
let GLTF_UNSIGNED_BYTE = Int(GL_UNSIGNED_BYTE)
let GLTF_SHORT = Int(GL_SHORT)
let GLTF_UNSIGNED_SHORT = Int(GL_UNSIGNED_SHORT)
let GLTF_UNSIGNED_INT = Int(GL_UNSIGNED_INT)
let GLTF_FLOAT = Int(GL_FLOAT)

let usesFloatComponentsMap: [Int: Bool] = [
    GLTF_BYTE: false,
    GLTF_UNSIGNED_BYTE: false,
    GLTF_SHORT: false,
    GLTF_UNSIGNED_SHORT: false,
    GLTF_UNSIGNED_INT: false,
    GLTF_FLOAT: true
]

let bytesPerComponentMap: [Int: Int] = [
    GLTF_BYTE: 1,
    GLTF_UNSIGNED_BYTE: 1,
    GLTF_SHORT: 2,
    GLTF_UNSIGNED_SHORT: 2,
    GLTF_UNSIGNED_INT: 4,
    GLTF_FLOAT: 4
]

let componentsPerVectorMap: [String: Int] = [
    "SCALAR": 1,
    "VEC2": 2,
    "VEC3": 3,
    "VEC4": 4,
    "MAT2": 4,
    "MAT3": 9,
    "MAT4": 16
]

public class GLTFSceneSource : SCNSceneSource {
    private var directoryPath: String! = nil
    private var loader: GLTFLoader! = nil
    private var json: GLTFGlTF! = nil
    
    private var scene: SCNScene?
    private var scenes = [SCNScene?]()
    private var nodes = [SCNNode?]()
    private var meshes = [SCNGeometry?]()
    private var accessors = [Any?]()
    private var bufferViews = [Data?]()
    private var buffers = [Data?]()
    private var materials = [SCNMaterial?]()
    
    //private var workingScene: SCNScene! = nil
    //private var workingNode: SCNNode! = nil
    
    #if !os(watchOS)
        private var workingAnimationGroup: CAAnimationGroup! = nil
    #endif
    
    public override init() {
        super.init()
    }
    
    public override convenience init?(url: URL, options: [SCNSceneSource.LoadingOption : Any]? = nil) {
        self.init()
    }
    
    public override convenience init?(data: Data, options: [SCNSceneSource.LoadingOption : Any]? = nil) {
        self.init()
        let loader = GLTFLoader(data: data)
        self.loader = loader
        
        self.loadData(options: options)
    }
    
    public convenience init?(path: String, options: [SCNSceneSource.LoadingOption : Any]? = nil) {
        self.init()
        self.directoryPath = (path as NSString).deletingLastPathComponent
        
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
        guard let loader = GLTFLoader(path: path) else { return nil }
        self.loader = loader
        
        self.loadData(options: options)
    }
    
    public convenience init?(named name: String, options: [SCNSceneSource.LoadingOption : Any]? = nil) {
        let filePath = Bundle.main.path(forResource: name, ofType: nil)
        guard let path = filePath else {
            print("error: file \(name) not found.")
            return nil
        }
        self.init(path: path, options: options)
    }
    
    open func getScene() -> SCNScene? {
        if(self.scenes.count > 0){
            return self.scenes[0]
        }
        return nil
    }
    
    private func loadData(options: [SCNSceneSource.LoadingOption : Any]? = nil) {
        guard let json = self.loader.json else { return }
        self.json = json
        
        self.initArrays()
        
        self.loadScenes()
    }
    
    private func initArrays() {
        if let scenes = self.json.scenes {
            self.scenes = [SCNScene?](repeating: nil, count: scenes.count)
        }
        
        if let nodes = self.json.nodes {
            self.nodes = [SCNNode?](repeating: nil, count: nodes.count)
        }
        
        if let meshes = self.json.meshes {
            self.meshes = [SCNGeometry?](repeating: nil, count: meshes.count)
        }
        
        if let accessors = self.json.accessors {
            self.accessors = [Any?](repeating: nil, count: accessors.count)
        }
        
        if let bufferViews = self.json.bufferViews {
            self.bufferViews = [Data?](repeating: nil, count: bufferViews.count)
        }
        
        if let buffers = self.json.buffers {
            self.buffers = [Data?](repeating: nil, count: buffers.count)
        }
    }
    
    private func loadCamera(index: Int) -> SCNCamera? {
        return nil
    }
    
    private func loadBufferView(index: Int) -> Data? {
        if index >= self.bufferViews.count {
            print("loadBufferView error: out of index: \(index) >= \(self.bufferViews.count)")
            return nil
        }
        
        if let bufferView = self.bufferViews[index] {
            return bufferView
        }
        
        guard let bufferViews = self.json.bufferViews else {
            print("loadBufferView error: bufferViews is not defined")
            return nil
        }
        let glBufferView = bufferViews[index]
        
        let data = Data()
        return data
    }
    
    private func getDataStride(ofBufferViewIndex index: Int) -> Int? {
        guard let bufferViews = self.json.bufferViews else {
            print("getDataStride error: bufferViews is not defined")
            return nil
        }
        guard index < bufferViews.count else {
            print("getDataStride error: out of index: \(index) >= \(bufferViews.count)")
            return nil
        }
        
        // it could be nil because it is not required.
        guard let stride = bufferViews[index].byteStride else { return nil }
        
        return stride
    }
    
    private func loadVertexAccessor(index: Int, semantic: SCNGeometrySource.Semantic) -> SCNGeometrySource? {
        if index >= self.accessors.count {
            print("loadVertexAccessor error: out of index: \(index) >= \(self.accessors.count)")
            return nil
        }
        
        if let accessor = self.accessors[index] as? SCNGeometrySource {
            return accessor
        }
        if let accessor = self.accessors[index] as? SCNGeometryElement {
            print("loadVertexAccessor error: the accessor is defined as SCNGeometryElement")
            return nil
        }
        
        guard let accessors = self.json.accessors else {
            print("loadVertexAccessor error: accessors is not defined")
            return nil
        }
        let glAccessor = accessors[index]
        
        let vectorCount = glAccessor.count
        guard let usesFloatComponents = usesFloatComponentsMap[glAccessor.componentType] else {
            print("loadVertexAccessor error: user defined accessor.componentType is not supported")
            return nil
        }
        guard let componentsPerVector = componentsPerVectorMap[glAccessor.type] else {
            print("loadVertexAccessor error: user defined accessor.type is not supported")
            return nil
        }
        guard let bytesPerComponent = bytesPerComponentMap[glAccessor.componentType] else {
            print("loadVertexAccessor error: user defined accessor.componentType is not supported")
            return nil
        }
        let dataOffset = glAccessor.byteOffset
        
        var bufferView: Data
        var dataStride: Int = bytesPerComponent * componentsPerVector
        if let bufferViewIndex = glAccessor.bufferView {
            guard let bv = self.loadBufferView(index: bufferViewIndex) else { return nil }
            bufferView = bv
            if let ds = self.getDataStride(ofBufferViewIndex: bufferViewIndex) {
                dataStride = ds
            }
        } else {
            let dataSize = dataStride * vectorCount
            bufferView = Data(count: dataSize)
        }
        
        let geometrySource = SCNGeometrySource(data: bufferView, semantic: semantic, vectorCount: vectorCount, usesFloatComponents: usesFloatComponents, componentsPerVector: componentsPerVector, bytesPerComponent: bytesPerComponent, dataOffset: dataOffset, dataStride: dataStride)
        self.accessors[index] = geometrySource
        
        return geometrySource
    }
    
    private func loadIndexAccessor(index: Int) -> SCNGeometryElement? {
        return nil
    }
    
    private func loadMesh(index: Int) -> SCNGeometry? {
        if index >= self.meshes.count {
            print("loadMesh error: out of index: \(index) >= \(self.meshes.count)")
            return nil
        }
        
        if let mesh = self.meshes[index] {
            return mesh
        }
        
        guard let meshes = self.json.meshes else {
            print("loadMesh error: meshes it not defined")
            return nil
        }
        let glMesh = meshes[index]
        let geometry = SCNGeometry()
        self.meshes[index] = geometry
        
        if let name = glMesh.name {
            geometry.name = name
        }
        for primitive in glMesh.primitives {
            for (attribute, accessorIndex) in primitive.attributes {
                if let semantic = attributeMap[attribute] {
                    let accessor = self.loadVertexAccessor(index: accessorIndex, semantic: semantic)
                } else {
                    // user defined semantic
                    print("user defined semantic is not supported: " + attribute)
                }
            }
        }
        if let weights = glMesh.weights {
        }
        
        return geometry
    }
    
    private func loadNode(index: Int) -> SCNNode? {
        if index >= self.nodes.count {
            print("loadNode error: out of index: \(index) >= \(self.nodes.count)")
            return nil
        }
        
        if let node = self.nodes[index] {
            return node
        }
        
        guard let nodes = self.json.nodes else {
            print("loadNode error: nodes is not defined")
            return nil
        }
        let glNode = nodes[index]
        let scnNode = SCNNode()
        self.nodes[index] = scnNode
        
        if let name = glNode.name {
            scnNode.name = name
        }
        if let camera = glNode.camera {
            scnNode.camera = self.loadCamera(index: camera)
        }
        if let mesh = glNode.mesh {
            scnNode.geometry = self.loadMesh(index: mesh)
        }
        //scnNode.transform = self.createMatrix(glNode.matrix)
        //glNode.rotation
        //glNode.scale
        //glNode.translation
        if let skin = glNode.skin {
            // load skin
        }
        if let weights = glNode.weights {
            // load weights
        }
        if let children = glNode.children {
            for child in children {
                let scnChild = self.loadNode(index: child)!
                scnNode.addChildNode(scnChild)
            }
        }
        
        return scnNode
    }
    
    private func createMatrix(_ matrix: [Float]) -> SCNMatrix4 {
        let m: [CGFloat] = matrix.map { CGFloat($0) }
        return SCNMatrix4(
            m11: m[0], m12: m[1], m13: m[2], m14: m[3],
            m21: m[4], m22: m[5], m23: m[6], m24: m[7],
            m31: m[8], m32: m[9], m33: m[10], m34: m[11],
            m41: m[12], m42: m[13], m43: m[14], m44: m[15])
    }
    
    private func loadScene(index: Int) -> SCNScene? {
        if index >= self.scenes.count {
            print("loadScene error: out of index: \(index) >= \(self.scenes.count)")
            return nil
        }
        
        if let scene = self.scenes[index] {
            return scene
        }
        
        guard let scenes = self.json.scenes else {
            print("loadScene error: scenes is not defined")
            return nil
        }
        let glScene = scenes[index]
        let scnScene = SCNScene()
        
        if let name = glScene.name {
            scnScene.setValue(name, forKey: "name")
        }
        if let nodes = glScene.nodes {
            for node in nodes {
                let scnNode = self.loadNode(index: node)!
                scnScene.rootNode.addChildNode(scnNode)
            }
        }
        
        self.scenes[index] = scnScene
        return scnScene
    }
    
    private func loadScenes() {
        guard let scenes = self.json.scenes else { return }
        for index in 0..<scenes.count {
            self.loadScene(index: index)
        }
    }
}
