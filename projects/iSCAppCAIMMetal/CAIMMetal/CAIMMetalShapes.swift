//
//  CAIMMetalShapes.swift
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

// Metal描画プロトコル
public protocol CAIMMetalDrawable
{
    func draw( with encoder:MTLRenderCommandEncoder, index idx:Int )
}

// Metal向け形状メモリクラス
public class CAIMMetalShape<T> : LLAlignedMemory4K<T>, CAIMMetalDrawable, CAIMMetalBufferAllocatable
{
    fileprivate var _buffer:CAIMMetalBufferAllocatable?
    fileprivate var _type:CAIMMetalBufferType
    
    public init( unit:Int, count:Int, type:CAIMMetalBufferType = .alloc ) {
        _type = type
        super.init( unit:unit, count: count )
        _buffer = _type == .alloc ? CAIMMetalAllocatedBuffer( vertice: self ) : CAIMMetalSharedBuffer( vertice: self )
    }
    
    public var metalBuffer:MTLBuffer? {
        if _type == .alloc { ( _buffer as! CAIMMetalAllocatedBuffer).update( vertice: self ) }
        else if _type == .shared { ( _buffer as! CAIMMetalSharedBuffer).update( vertice: self ) }
        return _buffer?.metalBuffer
    }
    
    public var memory:UnsafeMutablePointer<T> {
        return UnsafeMutablePointer<T>( OpaquePointer( self.pointer! ) )
    }
    
    public func draw( with encoder:MTLRenderCommandEncoder, index idx:Int ) {
        if self.metalBuffer == nil { return }
        encoder.setVertexBuffer( self.metalBuffer!, index: idx )
    }
}

// 点メモリクラス
public class CAIMMetalPoints<T> : CAIMMetalShape<T>
{
    public init(count:Int = 0, type:CAIMMetalBufferType = .alloc ) {
        super.init( unit:1, count: count, type: type )
    }
    
    public subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * self.unit ) )
        return UnsafeMutablePointer<T>( opaqueptr )
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder, index idx:Int ) {
        super.draw( with:encoder, index:idx )
        encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: count )
    }
}

public struct CAIMMetalLineVertice<T> {
    public var p1:T, p2:T
    public init( _ p1:T, _ p2:T ) {
        self.p1 = p1; self.p2 = p2
    }
}

// ライン形状メモリクラス
public class CAIMMetalLines<T> : CAIMMetalShape<T>
{
    public init(count:Int = 0, type: CAIMMetalBufferType = .alloc ) {
        super.init( unit: 2, count: count, type: type )
    }
    
    public subscript(idx:Int) -> CAIMMetalLineVertice<T> {
        get {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * self.unit) )
            return UnsafeMutablePointer<CAIMMetalLineVertice<T>>( opaqueptr )[0]
        }
        set {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * self.unit) )
            UnsafeMutablePointer<CAIMMetalLineVertice<T>>( opaqueptr )[0] = newValue
        }
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder, index idx:Int ) {
        super.draw( with:encoder, index: idx )
        encoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: count * self.unit )
    }
}


public struct CAIMMetalTriangleVertice<T> {
    public var p1:T, p2:T, p3:T
    public init( _ p1:T, _ p2:T, _ p3:T ) {
        self.p1 = p1; self.p2 = p2; self.p3 = p3
    }
}

// 三角形メッシュ形状メモリクラス
public class CAIMMetalTriangles<T> : CAIMMetalShape<T>
{
    public init( count:Int = 0, type:CAIMMetalBufferType = .alloc ) {
        super.init( unit:3, count: count, type: type )
    }
    
    public subscript(idx:Int) -> CAIMMetalTriangleVertice<T> {
        get {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * self.unit) )
            return UnsafeMutablePointer<CAIMMetalTriangleVertice<T>>( opaqueptr )[0]
        }
        set {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * self.unit) )
            UnsafeMutablePointer<CAIMMetalTriangleVertice<T>>( opaqueptr )[0] = newValue
        }
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder, index idx:Int ) {
        super.draw( with:encoder, index:idx )
        encoder.drawPrimitives( type: .triangle, vertexStart: 0, vertexCount: count * self.unit )
    }
}

public struct CAIMMetalQuadrangleVertice<T> {
    public var p1:T, p2:T, p3:T, p4:T
    public init( _ p1:T, _ p2:T, _ p3:T, _ p4:T ) {
        self.p1 = p1; self.p2 = p2; self.p3 = p3; self.p4 = p4
    }
}

// 四角形メッシュ形状メモリクラス
public class CAIMMetalQuadrangles<T> : CAIMMetalShape<T>
{
    public init(count:Int = 0, type:CAIMMetalBufferType = .alloc ) {
        super.init( unit: 4, count: count, type: type )
    }
    
    public subscript(idx:Int) -> CAIMMetalQuadrangleVertice<T> {
        get {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * self.unit) )
            return UnsafeMutablePointer<CAIMMetalQuadrangleVertice<T>>( opaqueptr )[0]
        }
        set {
            let opaqueptr = OpaquePointer( self.pointer! + (idx * MemoryLayout<T>.stride * self.unit) )
            UnsafeMutablePointer<CAIMMetalQuadrangleVertice<T>>( opaqueptr )[0] = newValue
        }
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder, index idx:Int ) {
        super.draw( with:encoder, index: idx )
        for i:Int in 0 ..< self.count {
            encoder.drawPrimitives( type: .triangleStrip, vertexStart: i * self.unit, vertexCount: self.unit )
        }
    }
}

// パネル型キューブメモリクラス
public struct CAIMPanelCubeParam
{
    // パネルの向き
    public enum PanelSide {
        case front
        case back
        case left
        case right
        case top
        case bottom
    }
    public var side:PanelSide = .front
    public var pos:Float4 = Float4()
    public var uv:Float2 = Float2()
}

public class CAIMCubes<T> : CAIMMetalShape<T>
{
    public init(count:Int = 0, type:CAIMMetalBufferType = .alloc ) {
        super.init( unit:24, count: count, type: type )
    }
    
    subscript(idx:Int) -> UnsafeMutablePointer<T> {
        let opaqueptr = OpaquePointer(self.pointer! + (idx * MemoryLayout<T>.stride * self.unit))
        return UnsafeMutablePointer<T>(opaqueptr)
    }
    
    public override func draw( with encoder:MTLRenderCommandEncoder, index idx:Int ) {
        super.draw( with:encoder, index:idx )
        
        // パネル1枚ずつ6枚で1キューブを描く
        for j:Int in 0 ..< count {
            for i:Int in 0 ..< 6 {
                encoder.drawPrimitives(type: .triangleStrip, vertexStart: (i * 4) + (j * 24), vertexCount: 4)
            }
        }
    }
    
    public func set(idx:Int, pos:Float3, size:Float, iterator f: (Int,CAIMPanelCubeParam)->T) {
        let cube = self[idx]
        let sz = size / 2.0
        let x = pos.x
        let y = pos.y
        let z = pos.z
        
        let v = [
            // Front
            CAIMPanelCubeParam(side: .front, pos: Float4(-sz+x, sz+y, sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .front, pos: Float4( sz+x, sz+y, sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .front, pos: Float4(-sz+x,-sz+y, sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .front, pos: Float4( sz+x,-sz+y, sz+z, 1.0), uv:Float2(1, 0)),
            // Back
            CAIMPanelCubeParam(side: .back, pos: Float4( sz+x, sz+y,-sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .back, pos: Float4(-sz+x, sz+y,-sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .back, pos: Float4( sz+x,-sz+y,-sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .back, pos: Float4(-sz+x,-sz+y,-sz+z, 1.0), uv:Float2(1, 0)),
            // Left
            CAIMPanelCubeParam(side: .left, pos: Float4(-sz+x, sz+y,-sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .left, pos: Float4(-sz+x, sz+y, sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .left, pos: Float4(-sz+x,-sz+y,-sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .left, pos: Float4(-sz+x,-sz+y, sz+z, 1.0), uv:Float2(1, 0)),
            // Right
            CAIMPanelCubeParam(side: .right, pos: Float4( sz+x, sz+y, sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .right, pos: Float4( sz+x, sz+y,-sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .right, pos: Float4( sz+x,-sz+y, sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .right, pos: Float4( sz+x,-sz+y,-sz+z, 1.0), uv:Float2(1, 0)),
            // Top
            CAIMPanelCubeParam(side: .top, pos: Float4(-sz+x, sz+y,-sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .top, pos: Float4( sz+x, sz+y,-sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .top, pos: Float4(-sz+x, sz+y, sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .top, pos: Float4( sz+x, sz+y, sz+z, 1.0), uv:Float2(1, 0)),
            // Bottom
            CAIMPanelCubeParam(side: .bottom, pos: Float4(-sz+x,-sz+y, sz+z, 1.0), uv:Float2(0, 1)),
            CAIMPanelCubeParam(side: .bottom, pos: Float4( sz+x,-sz+y, sz+z, 1.0), uv:Float2(1, 1)),
            CAIMPanelCubeParam(side: .bottom, pos: Float4(-sz+x,-sz+y,-sz+z, 1.0), uv:Float2(0, 0)),
            CAIMPanelCubeParam(side: .bottom, pos: Float4( sz+x,-sz+y,-sz+z, 1.0), uv:Float2(1, 0)),
            ]
        
        for i:Int in 0 ..< 24 {
            cube[i] = f(i, v[i])
        }
    }
}

#endif
