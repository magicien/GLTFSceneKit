//
//  GLTFLoader.swift
//  glTFTest2
//
//  Created by Yuki OHNO on 2017/08/16.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import Foundation

class GLTFLoader {
    private var json: GLTFGlTF?
    
    convenience init?(path: String) {
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
    
    init(data: Data) {
        let decoder = JSONDecoder()
        do {
            self.json = try decoder.decode(GLTFGlTF.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("keyNotFound: \(key): \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("typeMismatch: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            print("valueNotFound: \(context.debugDescription)")
        } catch {
            print("\(error.localizedDescription)")
        }
        print(self.json)
    }
}
