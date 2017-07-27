//
// CAIMMetalShader.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import Foundation
import Metal

enum CAIMMetalShaderType
{
    case vertex
    case fragment
    case compute
}

// シェーダクラス
class CAIMMetalShader
{
    // シェーダ名
    fileprivate var _shader_name:String?
    var name:String? { return _shader_name }

    fileprivate var _function:MTLFunction?
    var function:MTLFunction { return _function! }
    
    init(_ sh:String) {
        _shader_name = sh
        let library:MTLLibrary? = CAIMMetal.device.newDefaultLibrary()
        _function = library!.makeFunction(name: self.name!)
    }
}

