//
// CAIMMetalVertexFormatter.swift
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

import MetalKit
import Metal

private let memAlignment:[MTLVertexFormat:Int] = [
    .char : 1,
    .char2 : 2,
    .char3 : 4,
    .char4 : 4,
    .uchar : 1,
    .uchar2 : 2,
    .uchar3 : 4,
    .uchar4 : 4,
    .short : 2,
    .short2 : 4,
    .short3 : 8,
    .short4 : 8,
    .ushort : 2,
    .ushort2 : 4,
    .ushort3 : 8,
    .ushort4 : 8,
    .int : 4,
    .int2 : 8,
    .int3 : 16,
    .int4 : 16,
    .uint : 4,
    .uint2 : 8,
    .uint3 : 16,
    .uint4 : 16,
    .float : 4,
    .float2 : 8,
    .float3 : 16,
    .float4 : 16
]

public protocol CAIMMetalVertexFormatter {
    static func makeVertexDescriptor(at index:Int, formats fmts:[MTLVertexFormat]) -> MTLVertexDescriptor
    static func vertexDescriptor(at idx:Int) -> MTLVertexDescriptor
}

public extension CAIMMetalVertexFormatter {
    static func makeVertexDescriptor(at index:Int, formats fmts:[MTLVertexFormat]) -> MTLVertexDescriptor {
        let desc = MTLVertexDescriptor()
        if(fmts.count == 0) { return desc }
        
        let stride = MemoryLayout<Self>.stride
        
        var ptr:Int = 0
        desc.attributes[0].format = fmts[0]
        desc.attributes[0].offset = ptr
        desc.attributes[0].bufferIndex = 0
        ptr += memAlignment[fmts[0]]!
        
        for i:Int in 1 ..< fmts.count {
            let fmt = fmts[i]
            let alignment = memAlignment[fmt]!
            
            let mod = ptr % alignment
            if(mod > 0) { ptr += (alignment - mod) }
            
            desc.attributes[i].format = fmt
            desc.attributes[i].offset = ptr
            desc.attributes[i].bufferIndex = 0
            
            ptr += alignment
        }
        
        desc.layouts[index].stride = stride
        desc.layouts[index].stepRate = 1
        
        return desc
    }
}

#endif
