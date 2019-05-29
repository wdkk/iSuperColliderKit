//
// CAIMMetalView.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

#if os(macOS) || (os(iOS) && !arch(x86_64))

import Foundation
import Metal

// Metalライブラリでコードを読み込むのを簡単にするための拡張
public extension MTLLibrary
{
    static func make( with code:String ) -> MTLLibrary? {
        return try? CAIMMetal.device?.makeLibrary( source: code, options:nil )
    }
}

// シェーダオブジェクトクラス
public class CAIMMetalShader
{
    // Metalシェーダ関数オブジェクト
    public private(set) var function:MTLFunction?

    // デフォルトライブラリでシェーダ関数作成
    public init( _ shader_name:String ) {
        guard let lib:MTLLibrary = CAIMMetal.device?.makeDefaultLibrary() else { return }
        function = lib.makeFunction( name: shader_name )
    }
    
    // 外部ライブラリファイルでシェーダ関数作成
    public init( libname:String, shaderName shader_name:String ) {
        let lib_path = Bundle.main.path(forResource: libname, ofType: "metallib")!
        guard let lib:MTLLibrary = try? CAIMMetal.device?.makeLibrary( filepath: lib_path ) else { return }
        function = lib.makeFunction( name: shader_name )
    }
    
    // クラス名指定でバンドル元を指定し(たとえば外部frameworkなど)そこにそこに含まれるdefault.metallibを用いてシェーダ関数作成
    public init( class cls:AnyClass, shaderName shader_name:String ) {
        let bundle = Bundle(for: cls.self )
        guard let lib:MTLLibrary = try? CAIMMetal.device?.makeDefaultLibrary(bundle: bundle) else { return }
        function = lib.makeFunction( name: shader_name )
    }
    
    // クラス名指定でバンドル元を指定し(たとえば外部frameworkなど)そこにそこに含まれるdefault.metallibを用いてシェーダ関数作成
    public init( class cls:AnyClass, libname:String, shaderName shader_name:String ) {
        let lib_path = Bundle(for: cls.self ).path(forResource: libname, ofType: "metallib")!
        guard let lib:MTLLibrary = try? CAIMMetal.device?.makeLibrary( filepath: lib_path ) else { return }
        function = lib.makeFunction( name: shader_name )
    }
    
    // コード文字列でシェーダ関数作成
    public init( code:String, shaderName shader_name:String ) {
        guard let lib:MTLLibrary = try? CAIMMetal.device?.makeLibrary( source: code, options:nil ) else { return }
        function = lib.makeFunction( name: shader_name )
    }
    
    // MTLLibraryでシェーダ関数作成
    public init( mtllib:MTLLibrary, shaderName shader_name:String ) {
        function = mtllib.makeFunction( name: shader_name )
    }
}

#endif
