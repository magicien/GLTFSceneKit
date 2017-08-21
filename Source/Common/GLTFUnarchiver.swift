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
    private var textures: [SCNMaterialProperty?] = []
    private var images: [Image?] = []
    
    #if !os(watchOS)
        private var workingAnimationGroup: CAAnimationGroup! = nil
    #endif
    
    convenience public init(path: String, extensions: [String:Codable.Type]? = nil) throws {
        var url: URL?
        if let mainPath = Bundle.main.path(forResource: path, ofType: "") {
            url = URL(fileURLWithPath: mainPath)
        } else {
            url = URL(fileURLWithPath: path)
        }
        guard let _url = url else {
            throw URLError(.fileDoesNotExist)
        }
        try self.init(url: _url, extensions: extensions)
    }
    
    convenience public init(url: URL, extensions: [String:Codable.Type]? = nil) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data, extensions: extensions)
        self.directoryPath = url.deletingLastPathComponent()
    }
    
    public init(data: Data, extensions: [String:Codable.Type]? = nil) throws {
        let decoder = JSONDecoder()
        decoder.userInfo[GLTFExtensionCodingUserInfoKey] = extensions
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
        
        if let textures = self.json.textures {
            self.textures = [SCNMaterialProperty?](repeating: nil, count: textures.count)
        }
        
        if let images = self.json.images {
            self.images = [Image?](repeating: nil, count: images.count)
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
        
        guard buffer.count >= glBuffer.byteLength else {
            throw GLTFUnarchiveError.DataInconsistent("loadBuffer: buffer.count < byteLength: \(buffer.count) < \(glBuffer.byteLength)")
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
        var padding = 0
        if let bufferViewIndex = glAccessor.bufferView {
            let bv = try self.loadBufferView(index: bufferViewIndex)
            bufferView = bv
            if let ds = try self.getDataStride(ofBufferViewIndex: bufferViewIndex) {
                guard ds >= dataStride else {
                    throw GLTFUnarchiveError.DataInconsistent("loadVertexAccessor: dataStride is too small: \(ds) < \(dataStride)")
                }
                padding = ds - dataStride
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
        print("padding: \(padding)")
        print("dataOffset + dataStride * vectorCount - padding: \(dataOffset + dataStride * vectorCount - padding)")
        print("==================================================")
        */
        
        #if SEEMS_TO_HAVE_VALIDATE_VERTEX_ATTRIBUTE_BUG
            // Metal validateVertexAttribute function seems to have a bug, so dateOffset must be 0.
            bufferView = bufferView.subdata(in: dataOffset..<dataOffset + dataStride * vectorCount - padding)
            let geometrySource = SCNGeometrySource(data: bufferView, semantic: semantic, vectorCount: vectorCount, usesFloatComponents: usesFloatComponents, componentsPerVector: componentsPerVector, bytesPerComponent: bytesPerComponent, dataOffset: 0, dataStride: dataStride)
        #else
            let geometrySource = SCNGeometrySource(data: bufferView, semantic: semantic, vectorCount: vectorCount, usesFloatComponents: usesFloatComponents, componentsPerVector: componentsPerVector, bytesPerComponent: bytesPerComponent, dataOffset: dataOffset, dataStride: dataStride)
        #endif
        self.accessors[index] = geometrySource
        
        return geometrySource
    }
    
    private func createIndexAccessor(for source: SCNGeometrySource, primitiveMode: Int) throws -> SCNGeometryElement {
        assert(source.semantic == .vertex)
        guard let primitiveType = primitiveTypeMap[primitiveMode] else {
            throw GLTFUnarchiveError.NotSupported("createIndexAccessor: primitve mode \(primitiveMode) is not supported")
        }
        
        if source.vectorCount <= 0xFFFF {
            var indices = [UInt16](repeating: 0, count: source.vectorCount)
            for i in 0..<source.vectorCount {
                indices[i] = UInt16(i)
            }
            let geometryElement = SCNGeometryElement(indices: indices, primitiveType: primitiveType)
            return geometryElement
        }
        
        if source.vectorCount <= 0xFFFFFFFF {
            var indices = [UInt32](repeating: 0, count: source.vectorCount)
            for i in 0..<source.vectorCount {
                indices[i] = UInt32(i)
            }
            let geometryElement = SCNGeometryElement(indices: indices, primitiveType: primitiveType)
            return geometryElement
        }
        
        var indices = [UInt64](repeating: 0, count: source.vectorCount)
        for i in 0..<source.vectorCount {
            indices[i] = UInt64(i)
        }
        let geometryElement = SCNGeometryElement(indices: indices, primitiveType: primitiveType)
        
        return geometryElement
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
    
    private func createNormalSource(for vertexSource: SCNGeometrySource, elements: [SCNGeometryElement]) throws -> SCNGeometrySource {
        let vertexArray = try createVertexArray(from: vertexSource)
        let dummyNormal = SCNVector3()
        var normals = [SCNVector3](repeating: dummyNormal, count: vertexArray.count)
        var counts = [Int](repeating: 0, count: vertexArray.count)
        
        for element in elements {
            if element.primitiveType != .triangles {
                throw GLTFUnarchiveError.NotSupported("createNormalSource: only triangles primitveType is supported: \(element.primitiveType)")
            }
            
            let indexArray = createIndexArray(from: element)
            
            var indexPos = 0
            for _ in 0..<indexArray.count/3 {
                let i0 = indexArray[indexPos]
                let i1 = indexArray[indexPos+1]
                let i2 = indexArray[indexPos+2]
                
                let v0 = vertexArray[i0]
                let v1 = vertexArray[i1]
                let v2 = vertexArray[i2]
                
                let n = createNormal(v0, v1, v2)
                
                normals[i0] = add(normals[i0], n)
                normals[i1] = add(normals[i1], n)
                normals[i2] = add(normals[i2], n)
                
                counts[i0] += 1
                counts[i1] += 1
                counts[i2] += 1
                
                indexPos += 3
            }
        }
        for i in 0..<normals.count {
            if counts[i] != 0 {
                normals[i] = normalize(div(normals[i], CGFloat(counts[i])))
            }
        }
        
        let normalSource = SCNGeometrySource(normals: normals)
        return normalSource
    }
    
    private func loadImage(index: Int) throws -> Image {
        guard index < self.images.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadImage: out of index: \(index) < \(self.images.count)")
        }
        
        if let image = self.images[index] {
            return image
        }
        
        guard let images = self.json.images else {
            throw GLTFUnarchiveError.DataInconsistent("loadImage: images is not defined")
        }
        let glImage = images[index]
        
        var image: Image?
        if let uri = glImage.uri {
            if let base64Str = self.getBase64Str(from: uri) {
                guard let data = Data(base64Encoded: base64Str) else {
                    throw GLTFUnarchiveError.Unknown("loadImage: cannot convert the base64 string to Data")
                }
                image = Image(data: data)
            } else {
                let url = URL(fileURLWithPath: uri, relativeTo: self.directoryPath)
                image = Image(contentsOf: url)
            }
        }
        
        guard let _image = image else {
            throw GLTFUnarchiveError.Unknown("loadImage: image \(index) is not loaded")
        }
        
        self.images[index] = _image
        return _image
    }
    
    private func setSampler(index: Int, to property: SCNMaterialProperty) throws {
        guard let samplers = self.json.samplers else {
            throw GLTFUnarchiveError.DataInconsistent("setSampler: samplers is not defined")
        }
        if index >= samplers.count {
            throw GLTFUnarchiveError.DataInconsistent("setSampler: out of index: \(index) < \(samplers.count)")
        }
        
        let sampler = samplers[index]
        
        if let magFilter = sampler.magFilter {
            guard let filter = filterModeMap[magFilter] else {
                throw GLTFUnarchiveError.NotSupported("setSampler: magFilter \(magFilter) is not supported")
            }
            property.magnificationFilter = filter
        }
        
        if let minFilter = sampler.minFilter {
            switch minFilter {
            case GLTF_NEAREST:
                property.minificationFilter = .nearest
                property.mipFilter = .none
            case GLTF_LINEAR:
                property.minificationFilter = .linear
                property.mipFilter = .none
            case GLTF_NEAREST_MIPMAP_NEAREST:
                property.minificationFilter = .nearest
                property.mipFilter = .nearest
            case GLTF_LINEAR_MIPMAP_NEAREST:
                property.minificationFilter = .linear
                property.mipFilter = .nearest
            case GLTF_NEAREST_MIPMAP_LINEAR:
                property.minificationFilter = .nearest
                property.mipFilter = .linear
            case GLTF_LINEAR_MIPMAP_LINEAR:
                property.minificationFilter = .linear
                property.mipFilter = .linear
            default:
                throw GLTFUnarchiveError.NotSupported("setSampler: minFilter \(minFilter) is not supported")
            }
        }
        
        guard let wrapS = wrapModeMap[sampler.wrapS] else {
            throw GLTFUnarchiveError.NotSupported("setSampler: wrapS \(sampler.wrapS) is not supported")
        }
        property.wrapS = wrapS
        
        guard let wrapT = wrapModeMap[sampler.wrapT] else {
            throw GLTFUnarchiveError.NotSupported("setSampler: wrapT \(sampler.wrapT) is not supported")
        }
        property.wrapT = wrapT
    }
    
    private func loadTexture(index: Int) throws -> SCNMaterialProperty {
        guard index < self.textures.count else {
            throw GLTFUnarchiveError.DataInconsistent("loadTexture: out of index: \(index) < \(self.textures.count)")
        }
        
        if let texture = self.textures[index] {
            return texture
        }
        
        guard let textures = self.json.textures else {
            throw GLTFUnarchiveError.DataInconsistent("loadTexture: textures is not defined")
        }
        let glTexture = textures[index]
        
        guard let sourceIndex = glTexture.source else {
            throw GLTFUnarchiveError.NotSupported("loadTexture: texture without source is not supported")
        }
        let image = try self.loadImage(index: sourceIndex)
        
        let texture = SCNMaterialProperty(contents: image)
        
        // TODO: retain glTexture.name somewhere
        
        if let sampler = glTexture.sampler {
            try self.setSampler(index: sampler, to: texture)
        }
        
        self.textures[index] = texture
        
        return texture
    }
    
    private func setTexture(index: Int, to property: SCNMaterialProperty) throws {
        let texture = try self.loadTexture(index: index)
        guard let contents = texture.contents else {
            throw GLTFUnarchiveError.DataInconsistent("setTexture: contents of texture \(index) is nil")
        }
        
        property.contents = contents
        property.minificationFilter = texture.minificationFilter
        property.magnificationFilter = texture.magnificationFilter
        property.mipFilter = texture.mipFilter
        property.wrapS = texture.wrapS
        property.wrapT = texture.wrapT
        property.intensity = texture.intensity
        property.maxAnisotropy = texture.maxAnisotropy
        property.contentsTransform = texture.contentsTransform
        property.mappingChannel = texture.mappingChannel
        if #available(OSX 10.13, *) {
            property.textureComponents = texture.textureComponents
        } else {
            // Fallback on earlier versions
        }
    }
    
    var defaultMaterial: SCNMaterial {
        get {
            let material = SCNMaterial()
            
            material.lightingModel = .physicallyBased
            material.diffuse.contents = createColor([1.0, 1.0, 1.0, 1.0])
            material.metalness.contents = createGrayColor(white: 1.0)
            material.roughness.contents = createGrayColor(white: 1.0)
            material.isDoubleSided = false
            
            return material
        }
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
            material.diffuse.contents = createColor(pbr.baseColorFactor)
            material.metalness.contents = createGrayColor(white: pbr.metallicFactor)
            material.roughness.contents = createGrayColor(white: pbr.roughnessFactor)
            
            if let baseTexture = pbr.baseColorTexture {
                // TODO: multiply baseColorFactor and the diffuse texture
                try self.setTexture(index: baseTexture.index, to: material.diffuse)
                material.diffuse.mappingChannel = baseTexture.texCoord
            }
            
            if let metallicTexture = pbr.metallicRoughnessTexture {
                // TODO: multiply metalness/roughness and the textures
                try self.setTexture(index: metallicTexture.index, to: material.metalness)
                material.metalness.mappingChannel = metallicTexture.texCoord
                if #available(OSX 10.13, *) {
                    material.metalness.textureComponents = .blue
                } else {
                    // Fallback on earlier versions
                }
                
                try self.setTexture(index: metallicTexture.index, to: material.roughness)
                material.roughness.mappingChannel = metallicTexture.texCoord
                if #available(OSX 10.13, *) {
                    material.roughness.textureComponents = .green
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
        if let normalTexture = glMaterial.normalTexture {
            try self.setTexture(index: normalTexture.index, to: material.normal)
            material.normal.mappingChannel = normalTexture.texCoord
            
            // TODO: - use normalTexture.scale
        }
        
        if let occlusionTexture = glMaterial.occlusionTexture {
            try self.setTexture(index: occlusionTexture.index, to: material.ambientOcclusion)
            material.ambientOcclusion.mappingChannel = occlusionTexture.texCoord
            material.ambientOcclusion.intensity = CGFloat(occlusionTexture.strength * 1000.0) // Is it correct?
        }
        
        if let emissiveTexture = glMaterial.emissiveTexture {
            if material.lightingModel == .physicallyBased {
                try self.setTexture(index: emissiveTexture.index, to: material.selfIllumination)
                material.selfIllumination.mappingChannel = emissiveTexture.texCoord
            } else {
                try self.setTexture(index: emissiveTexture.index, to: material.emission)
                material.emission.mappingChannel = emissiveTexture.texCoord
            }
        }
        
        material.isDoubleSided = glMaterial.doubleSided
        
        // TODO: use glMaterial.alphaCutOff
        // TODO: use glMaterial.alphaMode
        
        glMaterial.didLoad(by: material, unarchiver: self)
        
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
            var vertexSource: SCNGeometrySource?
            var normalSource: SCNGeometrySource?
            for (attribute, accessorIndex) in primitive.attributes {
                if let semantic = attributeMap[attribute] {
                    let accessor = try self.loadVertexAccessor(index: accessorIndex, semantic: semantic)
                    sources.append(accessor)
                    if semantic == .vertex {
                        vertexSource = accessor
                    } else if semantic == .normal {
                        normalSource = accessor
                    }
                } else {
                    // user defined semantic
                    throw GLTFUnarchiveError.NotSupported("loadMesh: user defined semantic is not supported: " + attribute)
                }
            }
            
            var elements = [SCNGeometryElement]()
            if let indexIndex = primitive.indices {
                let accessor = try self.loadIndexAccessor(index: indexIndex, primitiveMode: primitive.mode)
                elements.append(accessor)
            } else if let vertexSource = vertexSource {
                let accessor = try self.createIndexAccessor(for: vertexSource, primitiveMode: primitive.mode)
                elements.append(accessor)
            } else {
                // Should it be error?
            }
            
            if normalSource == nil {
                if let vertexSource = vertexSource {
                    normalSource = try self.createNormalSource(for: vertexSource, elements: elements)
                    sources.append(normalSource!)
                } else {
                    // Should it be error?
                }
            }
            
            let geometry = SCNGeometry(sources: sources, elements: elements)
            primitiveNode.geometry = geometry
            
            if let materialIndex = primitive.material {
                let material = try self.loadMaterial(index: materialIndex)
                geometry.materials = [material]
            } else {
                let material = self.defaultMaterial
                geometry.materials = [material]
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
            scnNode.transform = createMatrix4(matrix)
            if glNode._rotation != nil || glNode._scale != nil || glNode._translation != nil {
                throw GLTFUnarchiveError.DataInconsistent("loadNode: both matrix and rotation/scale/translation are defined")
            }
        } else {
            scnNode.orientation = createVector4(glNode.rotation)
            scnNode.scale = createVector3(glNode.scale)
            scnNode.position = createVector3(glNode.translation)
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

