//
//  GLTFUnarhiver.swift
//  GLTFSceneKit
//
//  Created by magicien on 2017/08/17.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import SceneKit
import SpriteKit

let glbMagic = 0x46546C67 // "glTF"
let chunkTypeJSON = 0x4E4F534A // "JSON"
let chunkTypeBIN = 0x004E4942 // "BIN"

public class GLTFUnarchiver {
    private var directoryPath: URL? = nil
    private var json: GLTFGlTF! = nil
    private var bin: Data?
    
    private var scene: SCNScene?
    private var scenes: [SCNScene?] = []
    private var nodes: [SCNNode?] = []
    //private var meshes = [SCNGeometry?]()
    private var meshes: [SCNNode?] = []
    private var accessors: [Any?] = []
    private var bufferViews: [Data?] = []
    private var buffers: [Data?] = []
    private var materials: [SCNMaterial?] = []
    
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
        try self.init(url: _url)
    }
    
    convenience public init(url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
        self.directoryPath = url.deletingLastPathComponent()
    }
    
    public init(data: Data) throws {
        let decoder = JSONDecoder()
        var jsonData = data
        
        let magic: UInt32 = data.subdata(in: 0..<4).withUnsafeBytes { $0.pointee }
        if magic == glbMagic {
            let version: UInt32 = data.subdata(in: 4..<8).withUnsafeBytes { $0.pointee }
            if version != 2 {
                throw GLTFUnarchiveError.NotSupported("version \(version) is not supported")
            }
            let length: UInt32 = data.subdata(in: 8..<12).withUnsafeBytes { $0.pointee }
            
            let chunk0Length: UInt32 = data.subdata(in: 12..<16).withUnsafeBytes { $0.pointee }
            let chunk0Type: UInt32 = data.subdata(in: 16..<20).withUnsafeBytes { $0.pointee }
            if chunk0Type != chunkTypeJSON {
                throw GLTFUnarchiveError.NotSupported("chunkType \(chunk0Type) is not supported")
            }
            let chunk0EndPos = 20 + Int(chunk0Length)
            jsonData = data.subdata(in: 20..<chunk0EndPos)
            
            if length > chunk0EndPos {
                let chunk1Length: UInt32 = data.subdata(in: chunk0EndPos..<chunk0EndPos+4).withUnsafeBytes { $0.pointee }
                let chunk1Type: UInt32 = data.subdata(in: chunk0EndPos+4..<chunk0EndPos+8).withUnsafeBytes { $0.pointee }
                if chunk1Type != chunkTypeBIN {
                    throw GLTFUnarchiveError.NotSupported("chunkType \(chunk1Type) is not supported")
                }
                let chunk1EndPos = chunk0EndPos + 8 + Int(chunk1Length)
                self.bin = data.subdata(in: chunk0EndPos+8..<chunk1EndPos)
            }
        }
        
        // just throw the error to the user
        do {
            self.json = try decoder.decode(GLTFGlTF.self, from: jsonData)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("keyNotFound: \(key): \(context)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("typeMismatch: \(type): \(context)")
        } catch DecodingError.valueNotFound(let type, let context) {
            print("valueNotFound: \(type): \(context)")
        }
        
        self.initArrays()
    }
    
    private func initArrays() {
        if let scenes = self.json.scenes {
            self.scenes = [SCNScene?](repeating: nil, count: scenes.count)
        }
        
        if let nodes = self.json.nodes {
            self.nodes = [SCNNode?](repeating: nil, count: nodes.count)
        }
        
        if let meshes = self.json.meshes {
            //self.meshes = [SCNGeometry?](repeating: nil, count: meshes.count)
            self.meshes = [SCNNode?](repeating: nil, count: meshes.count)
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
        
        if let materials = self.json.materials {
            self.materials = [SCNMaterial?](repeating: nil, count: materials.count)
        }
    }
    
    private func getBase64Str(from str: String) -> String? {
        guard str.starts(with: "data:") else { return nil }
        
        let mark = ";base64,"
        guard str.contains(mark) else { return nil }
        guard let base64Str = str.components(separatedBy: mark).last else { return nil }
        
        return base64Str
    }
    
    private func calcPrimitiveCount(ofCount count: Int, primitiveType: SCNGeometryPrimitiveType) -> Int {
        switch primitiveType {
        case .line:
            return count / 2
        case .point:
            return count
        case .polygon:
            // Is it correct?
            return count - 2
        case .triangles:
            return count / 3
        case .triangleStrip:
            return count - 2
        }
    }
    
    private func loadCamera(index: Int) -> SCNCamera {
        
        
        
        
        
        
        
        return SCNCamera()
    }
    
    private func loadBuffer(index: Int) throws -> Data {
        guard index < self.buffers.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadBuffer: out of index: \(index) < \(self.buffers.count)")
        }
        
        if let buffer = self.buffers[index] {
            return buffer
        }
        
        guard let buffers = self.json.buffers else {
            throw GLTFUnarchiveError.DataInconsistent("loadBufferView: buffers is not defined")
        }
        
        let glBuffer = buffers[index]
        
        var _buffer: Data?
        if let uri = glBuffer.uri {
            if let base64Str = self.getBase64Str(from: uri) {
                _buffer = Data(base64Encoded: base64Str)
            } else {
                let url = URL(fileURLWithPath: uri, relativeTo: self.directoryPath)
                _buffer = try Data(contentsOf: url)
            }
        } else {
            _buffer = self.bin
        }
        
        guard let buffer = _buffer else {
            throw GLTFUnarchiveError.Unknown("loadBufferView: buffer \(index) load error")
        }
        
        guard buffer.count == glBuffer.byteLength else {
            throw GLTFUnarchiveError.DataInconsistent("loadBuffer: byteLength does not match: \(buffer.count) != \(glBuffer.byteLength)")
        }
        
        self.buffers[index] = buffer
        return buffer
    }
    
    private func loadBufferView(index: Int, expectedTarget: Int? = nil) throws -> Data {
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
        
        if let expectedTarget = expectedTarget {
            if let target = glBufferView.target {
                guard expectedTarget == target else {
                    throw GLTFUnarchiveError.DataInconsistent("loadBufferView: index \(index): target inconsistent")
                }
            }
        }
        
        let buffer = try self.loadBuffer(index: glBufferView.buffer)
        let bufferView = buffer.subdata(in: glBufferView.byteOffset..<glBufferView.byteOffset + glBufferView.byteLength)
        
        //print("bufferView.count: \(bufferView.count)")
        //print("glBufferView.byteLength: \(glBufferView.byteLength)")
        //print("glBufferView.byteOffset: \(glBufferView.byteOffset)")
        
        self.bufferViews[index] = bufferView
        
        return bufferView
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
    
    private func createIndexData(_ data: Data, offset: Int, size: Int, stride: Int, count: Int) -> Data {
        let dataSize = size * count
        if stride == size {
            if offset == 0 {
                return data
            }
            return data.subdata(in: offset..<offset + dataSize)
        }
        
        var indexData = Data(capacity: dataSize)
        
        data.withUnsafeBytes { (s: UnsafePointer<UInt8>) in
            indexData.withUnsafeMutableBytes { (d: UnsafeMutablePointer<UInt8>) in
                let srcStep = stride - size
                var srcPos = offset
                var dstPos = 0
                for _ in 0..<count {
                    for _ in 0..<size {
                        d[dstPos] = s[srcPos]
                        srcPos += 1
                        dstPos += 1
                    }
                    srcPos += srcStep
                }
            }
        }
        return indexData
    }
    
    private func loadVertexAccessor(index: Int, semantic: SCNGeometrySource.Semantic) throws -> SCNGeometrySource {
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
        
        /*
        print("==================================================")
        print("semantic: \(semantic)")
        print("vectorCount: \(vectorCount)")
        print("usesFloatComponents: \(usesFloatComponents)")
        print("componentsPerVector: \(componentsPerVector)")
        print("bytesPerComponent: \(bytesPerComponent)")
        print("dataOffset: \(dataOffset)")
        print("dataStride: \(dataStride)")
        print("bufferView.count: \(bufferView.count)")
        print("dataOffset + dataStride * vectorCount: \(dataOffset + dataStride * vectorCount)")
        print("==================================================")
        */
        
        #if SEEMS_TO_HAVE_VALIDATE_VERTEX_ATTRIBUTE_BUG
            // Metal validateVertexAttribute function seems to have a bug, so dateOffset must be 0.
            bufferView = bufferView.subdata(in: dataOffset..<dataOffset + dataStride * vectorCount)
            let geometrySource = SCNGeometrySource(data: bufferView, semantic: semantic, vectorCount: vectorCount, usesFloatComponents: usesFloatComponents, componentsPerVector: componentsPerVector, bytesPerComponent: bytesPerComponent, dataOffset: 0, dataStride: dataStride)
        #else
            let geometrySource = SCNGeometrySource(data: bufferView, semantic: semantic, vectorCount: vectorCount, usesFloatComponents: usesFloatComponents, componentsPerVector: componentsPerVector, bytesPerComponent: bytesPerComponent, dataOffset: dataOffset, dataStride: dataStride)
        #endif
        self.accessors[index] = geometrySource
        
        return geometrySource
    }
    
    private func loadIndexAccessor(index: Int, primitiveMode: Int) throws -> SCNGeometryElement {
        guard index < self.accessors.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadIndexAccessor: out of index: \(index) < \(self.accessors.count)")
        }
        
        if let accessor = self.accessors[index] as? SCNGeometryElement {
            return accessor
        }
        if (self.accessors[index] as? SCNGeometrySource) != nil {
            throw GLTFUnarchiveError.DataInconsistent("loadIndexAccessor: the accessor \(index) is defined as SCNGeometrySource")
        }
        
        guard let accessors = self.json.accessors else {
            throw GLTFUnarchiveError.DataInconsistent("loadIndexAccessor: accessors is not defined")
        }
        let glAccessor = accessors[index]
        
        guard let primitiveType = primitiveTypeMap[primitiveMode] else {
            throw GLTFUnarchiveError.NotSupported("loadIndexAccessor: primitve mode \(primitiveMode) is not supported")
        }
        let primitiveCount = self.calcPrimitiveCount(ofCount: glAccessor.count, primitiveType: primitiveType)
        
        guard let usesFloatComponents = usesFloatComponentsMap[glAccessor.componentType] else {
            throw GLTFUnarchiveError.NotSupported("loadIndexAccessor: user defined accessor.componentType is not supported")
        }
        if usesFloatComponents {
            throw GLTFUnarchiveError.DataInconsistent("loadIndexAccessor: cannot use Float for index accessor")
        }
        
        guard let componentsPerVector = componentsPerVectorMap[glAccessor.type] else {
            throw GLTFUnarchiveError.NotSupported("loadIndexAccessor: user defined accessor.type is not supported")
        }
        if componentsPerVector != 1 {
            throw GLTFUnarchiveError.DataInconsistent("loadIndexAccessor: accessor type must be SCALAR")
        }
        
        guard let bytesPerComponent = bytesPerComponentMap[glAccessor.componentType] else {
            throw GLTFUnarchiveError.NotSupported("loadndexIAccessor: user defined accessor.componentType is not supported")
        }
        
        let dataOffset = glAccessor.byteOffset
        
        var bufferView: Data
        var dataStride: Int = bytesPerComponent
        if let bufferViewIndex = glAccessor.bufferView {
            let bv = try self.loadBufferView(index: bufferViewIndex)
            bufferView = bv
            if let ds = try self.getDataStride(ofBufferViewIndex: bufferViewIndex) {
                dataStride = ds
            }
        } else {
            let dataSize = dataStride * glAccessor.count
            bufferView = Data(count: dataSize)
        }
        let data = self.createIndexData(bufferView, offset: dataOffset, size: bytesPerComponent, stride: dataStride, count: glAccessor.count)
        
        let geometryElement = SCNGeometryElement(data: data, primitiveType: primitiveType, primitiveCount: primitiveCount, bytesPerIndex: bytesPerComponent)
        self.accessors[index] = geometryElement
        
        return geometryElement
    }
    
    private func loadMaterial(index: Int) throws -> SCNMaterial {
        guard index < self.materials.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadMaterial: out of index: \(index) < \(self.materials.count)")
        }
        
        if let material = self.materials[index] {
            return material
        }
        
        guard let materials = self.json.materials else {
            throw GLTFUnarchiveError.DataInconsistent("loadMaterials: materials it not defined")
        }
        let glMaterial = materials[index]
        let material = SCNMaterial()
        self.materials[index] = material
        
        if let pbr = glMaterial.pbrMetallicRoughness {
            material.lightingModel = .physicallyBased
            material.diffuse.contents = self.createColor(pbr.baseColorFactor)
            material.metalness.contents = self.createGrayColor(white: pbr.metallicFactor)
            material.roughness.contents = self.createGrayColor(white: pbr.roughnessFactor)
            
            if let baseTexture = pbr.baseColorTexture {
                // TODO: implement
            }
            
            if let metallicTexture = pbr.metallicRoughnessTexture {
                // TODO: implement
            }
        }
            
        return material
    }
    
    private func loadMesh(index: Int) throws -> SCNNode {
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
        let node = SCNNode()
        self.meshes[index] = node
        
        if let name = glMesh.name {
            node.name = name
        }
        
        for primitive in glMesh.primitives {
            let primitiveNode = SCNNode()
            var sources = [SCNGeometrySource]()
            for (attribute, accessorIndex) in primitive.attributes {
                if let semantic = attributeMap[attribute] {
                    let accessor = try self.loadVertexAccessor(index: accessorIndex, semantic: semantic)
                    sources.append(accessor)
                } else {
                    // user defined semantic
                    throw GLTFUnarchiveError.NotSupported("loadMesh: user defined semantic is not supported: " + attribute)
                }
            }
            
            var elements = [SCNGeometryElement]()
            if let indexIndex = primitive.indices {
                let accessor = try self.loadIndexAccessor(index: indexIndex, primitiveMode: primitive.mode)
                elements.append(accessor)
            } else {
                // TODO: define indices
            }
            
            let geometry = SCNGeometry(sources: sources, elements: elements)
            primitiveNode.geometry = geometry
            
            if let materialIndex = primitive.material {
                let material = try self.loadMaterial(index: materialIndex)
                geometry.materials = [material]
            } else {
                // TODO: set default material
            }
            
            node.addChildNode(primitiveNode)
        }
        
        if let weights = glMesh.weights {
            // TODO: set weights
        }
        
        return node
    }
    
    private func loadNode(index: Int) throws -> SCNNode {
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
            //scnNode.geometry = try self.loadMesh(index: mesh)
            let meshNode = try self.loadMesh(index: mesh)
            scnNode.addChildNode(meshNode)
        }
        
        if let matrix = glNode._matrix {
            scnNode.transform = self.createMatrix4(glNode.matrix)
            if glNode._rotation != nil || glNode._scale != nil || glNode._translation != nil {
                throw GLTFUnarchiveError.DataInconsistent("loadNode: both matrix and rotation/scale/translation are defined")
            }
        } else {
            scnNode.orientation = self.createVector4(glNode.rotation)
            scnNode.scale = self.createVector3(glNode.scale)
            scnNode.position = self.createVector3(glNode.translation)
        }
        
        if let skin = glNode.skin {
            // load skin
        }
        if let weights = glNode.weights {
            // load weights
        }
        if let children = glNode.children {
            for child in children {
                let scnChild = try self.loadNode(index: child)
                scnNode.addChildNode(scnChild)
            }
        }
        
        return scnNode
    }
    
    private func createColor(_ color: [Float]) -> SKColor {
        let c: [CGFloat] = color.map { CGFloat($0) }
        assert(c.count >= 4)
        return SKColor.init(red: c[0], green: c[1], blue: c[2], alpha: c[3])
    }
    
    private func createGrayColor(white: Float) -> SKColor {
        return SKColor(white: CGFloat(white), alpha: 1.0)
    }
    
    private func createVector3(_ vector: [Float]) -> SCNVector3 {
        let v: [CGFloat] = vector.map { CGFloat($0) }
        assert(v.count >= 3)
        return SCNVector3(x: v[0], y: v[1], z: v[2])
    }
    
    private func createVector4(_ vector: [Float]) -> SCNVector4 {
        let v: [CGFloat] = vector.map { CGFloat($0) }
        assert(v.count >= 4)
        return SCNVector4(x: v[0], y: v[1], z: v[2], w: v[3])
    }
    
    private func createMatrix4(_ matrix: [Float]) -> SCNMatrix4 {
        let m: [CGFloat] = matrix.map { CGFloat($0) }
        assert(m.count >= 16)
        return SCNMatrix4(
            m11: m[0], m12: m[1], m13: m[2], m14: m[3],
            m21: m[4], m22: m[5], m23: m[6], m24: m[7],
            m31: m[8], m32: m[9], m33: m[10], m34: m[11],
            m41: m[12], m42: m[13], m43: m[14], m44: m[15])
    }
    
    func loadScene() throws -> SCNScene {
        if let sceneIndex = self.json.scene {
            return try self.loadScene(index: sceneIndex)
        }
        return try self.loadScene(index: 0)
    }
    
    private func loadScene(index: Int) throws -> SCNScene {
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
                let scnNode = try self.loadNode(index: node)
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

