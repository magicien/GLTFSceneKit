//
//  GLTFLoader.swift
//  glTFTest2
//
//  Created by magicien on 2017/08/17.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import Foundation

public class GLTFLoader {
    var json: GLTFGlTF?
    
    convenience public init?(path: String) {
        var url: URL?
        if let mainPath = Bundle.main.path(forResource: path, ofType: "") {
            url = URL(fileURLWithPath: mainPath)
        } else {
            url = URL(fileURLWithPath: path)
        }
        guard let _url = url else { return nil }
        
        var data: Data?
        do {
            data = try Data(contentsOf: _url)
        } catch {
            return nil
        }
        guard let _data = data else { return nil }
        
        self.init(data: _data)
    }
    
    public init(data: Data) {
        let decoder = JSONDecoder()
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
    }
    
    public func debugPrint() {
        print(self.json)
    }
}
