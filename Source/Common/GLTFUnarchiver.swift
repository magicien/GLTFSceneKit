//
//  GLTFUnarhiver.swift
//  GLTFSceneKit
//
//  Created by magicien on 2017/08/17.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import SceneKit

public class GLTFUnarchiver {
    private var json: GLTFGlTF! = nil
    
    private var scene: SCNScene?
    private var scenes = [SCNScene?]()
    private var nodes = [SCNNode?]()
    private var meshes = [SCNGeometry?]()
    private var accessors = [Any?]()
    private var bufferViews = [Data?]()
    private var buffers = [Data?]()
    private var materials = [SCNMaterial?]()
    
    #if !os(watchOS)
        private var workingAnimationGroup: CAAnimationGroup! = nil
    #endif
    
    convenience public init(path: String) throws {
        var url: URL?
        if let mainPath = Bundle.main.path(forResource: path, ofType: "") {
            url = URL(fileURLWithPath: mainPath)
        } else {
            url = URL(fileURLWithPath: path)
        }
        guard let _url = url else {
            throw URLError(.fileDoesNotExist)
        }
        
        let data = try Data(contentsOf: _url)
        try self.init(data: data)
    }
    
    public init(data: Data) throws {
        let decoder = JSONDecoder()
        /*
        do {
            self.json = try decoder.decode(GLTFGlTF.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("keyNotFound: \(key): \(context.debugDescription)")
            return
        } catch DecodingError.typeMismatch(let type, let context) {
            print("typeMismatch: \(context.debugDescription)")
            return
        } catch DecodingError.valueNotFound(let type, let context) {
            print("valueNotFound: \(context.debugDescription)")
            return
        } catch {
            print("\(error.localizedDescription)")
            return
        }
         */
        
        // just throw the error to the user
        self.json = try decoder.decode(GLTFGlTF.self, from: data)
        
        try self.loadScenes()
    }
    
    private func loadData(options: [SCNSceneSource.LoadingOption : Any]? = nil) throws {
        self.initArrays()
        try self.loadScenes()
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
    
    private func loadCamera(index: Int) -> SCNCamera {
        return SCNCamera()
    }
    
    private func loadBufferView(index: Int) throws -> Data {
        guard index < self.bufferViews.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadBufferView: out of index: \(index) < \(self.bufferViews.count)")
        }
        
        if let bufferView = self.bufferViews[index] {
            return bufferView
        }
        
        guard let bufferViews = self.json.bufferViews else {
            throw GLTFUnarchiveError.DataInconsistent("loadBufferView: bufferViews is not defined")
        }
        let glBufferView = bufferViews[index]
        
        
        
        
        let data = Data()
        return data
    }
    
    private func getDataStride(ofBufferViewIndex index: Int) throws -> Int? {
        guard let bufferViews = self.json.bufferViews else {
            throw GLTFUnarchiveError.DataInconsistent("getDataStride: bufferViews is not defined")
        }
        guard index < bufferViews.count else {
            throw GLTFUnarchiveError.DataInconsistent("getDataStride: out of index: \(index) < \(bufferViews.count)")
        }
        
        // it could be nil because it is not required.
        guard let stride = bufferViews[index].byteStride else { return nil }
        
        return stride
    }
    
    private func loadVertexAccessor(index: Int, semantic: SCNGeometrySource.Semantic) throws -> SCNGeometrySource? {
        guard index < self.accessors.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadVertexAccessor: out of index: \(index) < \(self.accessors.count)")
        }
        
        if let accessor = self.accessors[index] as? SCNGeometrySource {
            return accessor
        }
        if (self.accessors[index] as? SCNGeometryElement) != nil {
            throw GLTFUnarchiveError.DataInconsistent("loadVertexAccessor: the accessor \(index) is defined as SCNGeometryElement")
        }
        
        guard let accessors = self.json.accessors else {
            throw GLTFUnarchiveError.DataInconsistent("loadVertexAccessor: accessors is not defined")
        }
        let glAccessor = accessors[index]
        
        let vectorCount = glAccessor.count
        guard let usesFloatComponents = usesFloatComponentsMap[glAccessor.componentType] else {
            throw GLTFUnarchiveError.NotSupported("loadVertexAccessor: user defined accessor.componentType is not supported")
        }
        guard let componentsPerVector = componentsPerVectorMap[glAccessor.type] else {
            throw GLTFUnarchiveError.NotSupported("loadVertexAccessor: user defined accessor.type is not supported")
        }
        guard let bytesPerComponent = bytesPerComponentMap[glAccessor.componentType] else {
            throw GLTFUnarchiveError.NotSupported("loadVertexAccessor: user defined accessor.componentType is not supported")
        }
        let dataOffset = glAccessor.byteOffset
        
        var bufferView: Data
        var dataStride: Int = bytesPerComponent * componentsPerVector
        if let bufferViewIndex = glAccessor.bufferView {
            let bv = try self.loadBufferView(index: bufferViewIndex)
            bufferView = bv
            if let ds = try self.getDataStride(ofBufferViewIndex: bufferViewIndex) {
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
    
    private func loadMesh(index: Int) throws -> SCNGeometry? {
        guard index < self.meshes.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadMesh: out of index: \(index) < \(self.meshes.count)")
        }
        
        if let mesh = self.meshes[index] {
            return mesh
        }
        
        guard let meshes = self.json.meshes else {
            throw GLTFUnarchiveError.DataInconsistent("loadMesh: meshes it not defined")
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
                    let accessor = try self.loadVertexAccessor(index: accessorIndex, semantic: semantic)
                    
                    
                    
                    
                    
                } else {
                    // user defined semantic
                    throw GLTFUnarchiveError.NotSupported("loadMesh: user defined semantic is not supported: " + attribute)
                }
            }
        }
        if let weights = glMesh.weights {
        }
        
        return geometry
    }
    
    private func loadNode(index: Int) throws -> SCNNode? {
        guard index < self.nodes.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadNode: out of index: \(index) < \(self.nodes.count)")
        }
        
        if let node = self.nodes[index] {
            return node
        }
        
        guard let nodes = self.json.nodes else {
            throw GLTFUnarchiveError.DataInconsistent("loadNode: nodes is not defined")
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
            scnNode.geometry = try self.loadMesh(index: mesh)
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
                let scnChild = try self.loadNode(index: child)!
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
    
    func loadScene() throws -> SCNScene? {
        return try self.loadScene(index: 0)
    }
    
    private func loadScene(index: Int) throws -> SCNScene? {
        guard index < self.scenes.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadScene: out of index: \(index) < \(self.scenes.count)")
        }
        
        if let scene = self.scenes[index] {
            return scene
        }
        
        guard let scenes = self.json.scenes else {
            throw GLTFUnarchiveError.DataInconsistent("loadScene: scenes is not defined")
        }
        let glScene = scenes[index]
        let scnScene = SCNScene()
        
        if let name = glScene.name {
            scnScene.setValue(name, forKey: "name")
        }
        if let nodes = glScene.nodes {
            for node in nodes {
                let scnNode = try self.loadNode(index: node)!
                scnScene.rootNode.addChildNode(scnNode)
            }
        }
        
        self.scenes[index] = scnScene
        return scnScene
    }
    
    func loadScenes() throws {
        guard let scenes = self.json.scenes else { return }
        for index in 0..<scenes.count {
            _ = try self.loadScene(index: index)
        }
    }
}
