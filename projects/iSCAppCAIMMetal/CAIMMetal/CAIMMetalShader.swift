//
//  CAIMMetalShader.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/13.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation

// シェーダベースクラス
class CAIMMetalShader
{
    var shader_name:String?
    var buf:[String:CAIMMetalBuffer] = [String:CAIMMetalBuffer]()
    
    // subscript ["event-key"] accessor
    subscript(key:String) -> CAIMMetalBuffer {
        get { return buf[key]! }
        set(new_value) { buf[key] = new_value }
    }
    
    init(_ sh:String)
    {
        shader_name = sh
    }
    
    func attach(enc:MTLRenderCommandEncoder) {}
}

// 頂点シェーダ
class CAIMMetalVertexShader : CAIMMetalShader
{
    override func attach(enc:MTLRenderCommandEncoder)
    {
        for (_, cmb) in buf
        {
            enc.setVertexBuffer(cmb.buf, offset: 0, atIndex: cmb.idx)
        }
    }
}

// フラグメントシェーダ
class CAIMMetalFragmentShader : CAIMMetalShader
{
    override func attach(enc:MTLRenderCommandEncoder)
    {
        for (_, cmb) in buf
        {
            enc.setFragmentBuffer(cmb.buf, offset: 0, atIndex: cmb.idx)
        }
    }
}

// コンピュートシェーダ
class CAIMMetalComputeShader : CAIMMetalShader
{
    internal override func attach(enc: MTLRenderCommandEncoder) { /* プライベートでclose */ }
    
    func attach(enc:MTLComputeCommandEncoder)
    {
        for (_, cmb) in buf
        {
            enc.setBuffer(cmb.buf, offset: 0, atIndex: cmb.idx)
        }
    }
}