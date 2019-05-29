//
// CAIMMetalGeometrics.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import Foundation
import CoreGraphics
import Metal
import simd

// Int2(8バイト)
public struct Int2 : CAIMMetalBufferAllocatable {
    public private(set) var vectorInt2:vector_int2
    public var x:Int32 { get { return vectorInt2.x } set { vectorInt2.x = newValue } }
    public var y:Int32 { get { return vectorInt2.y } set { vectorInt2.y = newValue } }
    public init( _ x:Int32 = 0, _ y:Int32 = 0 ) { vectorInt2 = [x, y] }
    public init( _ vec:vector_int2 ) { vectorInt2 = vec }
    public static var zero:Int2 { return Int2() }
}
// vector_int2拡張
public extension vector_int2 {
    var int2:Int2 { return Int2( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Int2, _ right:Int2 ) -> Int2 {
    return Int2( left.vectorInt2 &+ right.vectorInt2 )
}
public func - ( _ left:Int2, _ right:Int2 ) -> Int2 {
    return Int2( left.vectorInt2 &- right.vectorInt2 )
}
public func * ( _ left:Int2, _ right:Int2 ) -> Int2 {
    return Int2( left.vectorInt2 &* right.vectorInt2 )
}
public func / ( _ left:Int2, _ right:Int2 ) -> Int2 {
    return Int2( left.vectorInt2 / right.vectorInt2 )
}

// Int3(16バイト)
public struct Int3 : CAIMMetalBufferAllocatable {
    public private(set) var vectorInt3:vector_int3
    public var x:Int32 { get { return vectorInt3.x } set { vectorInt3.x = newValue } }
    public var y:Int32 { get { return vectorInt3.y } set { vectorInt3.y = newValue } }
    public var z:Int32 { get { return vectorInt3.z } set { vectorInt3.z = newValue } }
    public init( _ x:Int32 = 0, _ y:Int32 = 0, _ z:Int32 = 0 ) { vectorInt3 = [x, y, z] }
    public init( _ vec:vector_int3 ) { vectorInt3 = vec }
    public static var zero:Int3 { return Int3() }
}
// vector_int3拡張
public extension vector_int3 {
    var int3:Int3 { return Int3( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Int3, _ right:Int3 ) -> Int3 {
    return Int3( left.vectorInt3 &+ right.vectorInt3 )
}
public func - ( _ left:Int3, _ right:Int3 ) -> Int3 {
    return Int3( left.vectorInt3 &- right.vectorInt3 )
}
public func * ( _ left:Int3, _ right:Int3 ) -> Int3 {
    return Int3( left.vectorInt3 &* right.vectorInt3 )
}
public func / ( _ left:Int3, _ right:Int3 ) -> Int3 {
    return Int3( left.vectorInt3 / right.vectorInt3 )
}

// Int4(16バイト)
public struct Int4 : CAIMMetalBufferAllocatable {
    public private(set) var vectorInt4:vector_int4
    public var x:Int32 { get { return vectorInt4.x } set { vectorInt4.x = newValue } }
    public var y:Int32 { get { return vectorInt4.y } set { vectorInt4.y = newValue } }
    public var z:Int32 { get { return vectorInt4.z } set { vectorInt4.z = newValue } }
    public var w:Int32 { get { return vectorInt4.w } set { vectorInt4.w = newValue } }
    public init( _ x:Int32 = 0, _ y:Int32 = 0, _ z:Int32 = 0, _ w:Int32 = 0 ) { vectorInt4 = [x, y, z, w] }
    public init( _ vec:vector_int4 ) { vectorInt4 = vec }
    public static var zero:Int4 { return Int4() }
}
// vector_int3拡張
public extension vector_int4 {
    var int4:Int4 { return Int4( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Int4, _ right:Int4 ) -> Int4 {
    return Int4( left.vectorInt4 &+ right.vectorInt4 )
}
public func - ( _ left:Int4, _ right:Int4 ) -> Int4 {
    return Int4( left.vectorInt4 &- right.vectorInt4 )
}
public func * ( _ left:Int4, _ right:Int4 ) -> Int4 {
    return Int4( left.vectorInt4 &* right.vectorInt4 )
}
public func / ( _ left:Int4, _ right:Int4 ) -> Int4 {
    return Int4( left.vectorInt4 / right.vectorInt4 )
}

// Size2(8バイト)
public typealias Size2 = Int2
extension Size2 {
    public var width:Int32  { get { return self.x } set { self.x = newValue } }
    public var height:Int32 { get { return self.y } set { self.y = newValue } }
}
// Size3(16バイト)
public typealias Size3 = Int3
extension Size3 {
    public var width:Int32  { get { return self.x } set { self.x = newValue } }
    public var height:Int32 { get { return self.y } set { self.y = newValue } }
    public var depth:Int32  { get { return self.z } set { self.z = newValue } }
}

// Float2(8バイト)
public struct Float2 : CAIMMetalBufferAllocatable {
    public private(set) var vectorFloat2:vector_float2
    public var x:Float { get { return vectorFloat2.x } set { vectorFloat2.x = newValue } }
    public var y:Float { get { return vectorFloat2.y } set { vectorFloat2.y = newValue } }
    public init( _ x:Float=0.0, _ y:Float=0.0 ) { vectorFloat2 = [x, y] }
    public init( _ vec:vector_float2 ) { vectorFloat2 = vec }
    public static var zero:Float2 { return Float2() }
    public var normalize:Float2 { return simd_normalize( vectorFloat2 ).float2 }
}
// vector_float2拡張
public extension vector_float2 {
    var float2:Float2 { return Float2( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Float2, _ right:Float2 ) -> Float2 {
    return Float2( left.vectorFloat2 + right.vectorFloat2 )
}
public func - ( _ left:Float2, _ right:Float2 ) -> Float2 {
    return Float2( left.vectorFloat2 - right.vectorFloat2 )
}
public func * ( _ left:Float2, _ right:Float2 ) -> Float2 {
    return Float2( left.vectorFloat2 * right.vectorFloat2 )
}
public func / ( _ left:Float2, _ right:Float2 ) -> Float2 {
    return Float2( left.vectorFloat2 / right.vectorFloat2 )
}
public func * ( _ left:Float2, _ right:Float ) -> Float2 {
    return Float2( left.vectorFloat2 * right )
}
public func / ( _ left:Float2, _ right:Float ) -> Float2 {
    return Float2( left.vectorFloat2 / right )
}

// Float3(16バイト)
public struct Float3 : CAIMMetalBufferAllocatable {
    public private(set) var vectorFloat3:vector_float3
    public var x:Float { get { return vectorFloat3.x } set { vectorFloat3.x = newValue } }
    public var y:Float { get { return vectorFloat3.y } set { vectorFloat3.y = newValue } }
    public var z:Float { get { return vectorFloat3.z } set { vectorFloat3.z = newValue } }
    public init( _ x:Float=0.0, _ y:Float=0.0, _ z:Float=0.0 ) { vectorFloat3 = [x, y, z] }
    public init( _ vec:vector_float3 ) { vectorFloat3 = vec }
    public static var zero:Float3 { return Float3() }
    public var normalize:Float3 { return simd_normalize( vectorFloat3 ).float3 }
}
// vector_float3拡張
public extension vector_float3 {
    var float3:Float3 { return Float3( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Float3, _ right:Float3 ) -> Float3 {
    return Float3( left.vectorFloat3 + right.vectorFloat3 )
}
public func - ( _ left:Float3, _ right:Float3 ) -> Float3 {
    return Float3( left.vectorFloat3 - right.vectorFloat3 )
}
public func * ( _ left:Float3, _ right:Float3 ) -> Float3 {
    return Float3( left.vectorFloat3 * right.vectorFloat3 )
}
public func / ( _ left:Float3, _ right:Float3 ) -> Float3 {
    return Float3( left.vectorFloat3 / right.vectorFloat3 )
}
public func * ( _ left:Float3, _ right:Float ) -> Float3 {
    return Float3( left.vectorFloat3 * right )
}
public func / ( _ left:Float3, _ right:Float ) -> Float3 {
    return Float3( left.vectorFloat3 / right )
}

// Float4(16バイト)
public struct Float4 : CAIMMetalBufferAllocatable {
    public private(set) var vectorFloat4:vector_float4
    public var x:Float { get { return vectorFloat4.x } set { vectorFloat4.x = newValue } }
    public var y:Float { get { return vectorFloat4.y } set { vectorFloat4.y = newValue } }
    public var z:Float { get { return vectorFloat4.z } set { vectorFloat4.z = newValue } }
    public var w:Float { get { return vectorFloat4.w } set { vectorFloat4.w = newValue } }
    public init( _ x:Float=0.0, _ y:Float=0.0, _ z:Float=0.0, _ w:Float=0.0 ) { vectorFloat4 = [x, y, z, w] }
    public init( _ vec:vector_float4 ) { vectorFloat4 = vec }
    public static var zero:Float4 { return Float4() }
    public var normalize:Float4 { return simd_normalize( vectorFloat4 ).float4 }
}
// vector_float4拡張
public extension vector_float4 {
    var float4:Float4 { return Float4( self ) }
}
// 演算子オーバーロード
public func + ( _ left:Float4, _ right:Float4 ) -> Float4 {
    return Float4( left.vectorFloat4 + right.vectorFloat4 )
}
public func - ( _ left:Float4, _ right:Float4 ) -> Float4 {
    return Float4( left.vectorFloat4 - right.vectorFloat4 )
}
public func * ( _ left:Float4, _ right:Float4 ) -> Float4 {
    return Float4( left.vectorFloat4 * right.vectorFloat4 )
}
public func / ( _ left:Float4, _ right:Float4 ) -> Float4 {
    return Float4( left.vectorFloat4 / right.vectorFloat4 )
}
public func * ( _ left:Float4, _ right:Float ) -> Float4 {
    return Float4( left.vectorFloat4 * right )
}
public func / ( _ left:Float4, _ right:Float ) -> Float4 {
    return Float4( left.vectorFloat4 / right )
}

// 3x3行列(48バイト)
public struct Matrix3x3 : CAIMMetalBufferAllocatable {
    public private(set) var matrixFloat3x3:matrix_float3x3
    
    public var X:Float3 { get { return matrixFloat3x3.columns.0.float3 } set { matrixFloat3x3.columns.0 = newValue.vectorFloat3 } }
    public var Y:Float3 { get { return matrixFloat3x3.columns.1.float3 } set { matrixFloat3x3.columns.1 = newValue.vectorFloat3 } }
    public var Z:Float3 { get { return matrixFloat3x3.columns.2.float3 } set { matrixFloat3x3.columns.2 = newValue.vectorFloat3 } }
   
    public init() {
        matrixFloat3x3 = matrix_float3x3( 0.0 )
    }
    public init( _ columns:[float3] ) {
        matrixFloat3x3 = matrix_float3x3( columns )
    }
    public init( _ vector:matrix_float3x3 ) {
        matrixFloat3x3 = vector
    }
    
    // 単位行列
    public static var identity:Matrix3x3 {
         return Matrix3x3([
            [ 1.0, 0.0, 0.0 ],
            [ 0.0, 1.0, 0.0 ],
            [ 0.0, 0.0, 1.0 ]
        ])
    }
}
// matrix_float3x3拡張
public extension matrix_float3x3 {
    var matrix3x3:Matrix3x3 { return Matrix3x3( self ) }
}

// 演算子オーバーロード
public func + ( _ left:Matrix3x3, _ right:Matrix3x3 ) -> Matrix3x3 {
    return Matrix3x3( left.matrixFloat3x3 + right.matrixFloat3x3 )
}

public func - ( _ left:Matrix3x3, _ right:Matrix3x3 ) -> Matrix3x3 {
    return Matrix3x3( left.matrixFloat3x3 - right.matrixFloat3x3 )
}

public func * ( _ left:Matrix3x3, _ right:Matrix3x3 ) -> Matrix3x3 {
    return Matrix3x3( left.matrixFloat3x3 * right.matrixFloat3x3 )
}
public func * ( _ left:Matrix3x3, _ right:Float3 ) -> Float3 {
    return Float3( left.matrixFloat3x3 * right.vectorFloat3 )
}
public func * ( _ left:Matrix3x3, _ right:matrix_float3x3 ) -> Matrix3x3 {
    return Matrix3x3( left.matrixFloat3x3 * right )
}
public func * ( _ left:matrix_float3x3, _ right:Matrix3x3 ) -> Matrix3x3 {
    return Matrix3x3( left * right.matrixFloat3x3 )
}
// 4x4行列(64バイト)
public struct Matrix4x4 : CAIMMetalBufferAllocatable {
    public private(set) var matrixFloat4x4:matrix_float4x4
    
    public var X:Float4 { get { return matrixFloat4x4.columns.0.float4 } set { matrixFloat4x4.columns.0 = newValue.vectorFloat4 } }
    public var Y:Float4 { get { return matrixFloat4x4.columns.1.float4 } set { matrixFloat4x4.columns.1 = newValue.vectorFloat4 } }
    public var Z:Float4 { get { return matrixFloat4x4.columns.2.float4 } set { matrixFloat4x4.columns.2 = newValue.vectorFloat4 } }
    public var W:Float4 { get { return matrixFloat4x4.columns.3.float4 } set { matrixFloat4x4.columns.3 = newValue.vectorFloat4 } }

    public init() {
        matrixFloat4x4 = matrix_float4x4( 0.0 )
    }
    public init( _ columns:[float4] ) {
        matrixFloat4x4 = matrix_float4x4( columns )
    }
    public init( _ vector:matrix_float4x4 ) {
        matrixFloat4x4 = vector
    }
    
    // 単位行列
    public static var identity:Matrix4x4 {
        return Matrix4x4( [
            [ 1.0, 0.0, 0.0, 0.0 ],
            [ 0.0, 1.0, 0.0, 0.0 ],
            [ 0.0, 0.0, 1.0, 0.0 ],
            [ 0.0, 0.0, 0.0, 1.0 ]
        ])
    }

    // 平行移動
    public static func translate(_ x:Float, _ y:Float, _ z:Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        mat.W.x = x
        mat.W.y = y
        mat.W.z = z
        return mat
    }
    
    // 拡大縮小
    public static func scale(_ x:Float, _ y:Float, _ z:Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        mat.X.x = x
        mat.Y.y = y
        mat.Z.z = z
        return mat
    }
    
    // 回転(三軸同時)
    public static func rotate(axis: Float4, byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let c:Float = cos(angle)
        let s:Float = sin(angle)
        
        mat.X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        mat.Y.x = axis.x * axis.y * (1 - c) - axis.z * s
        mat.Z.x = axis.x * axis.z * (1 - c) + axis.y * s
        
        mat.X.y = axis.x * axis.y * (1 - c) + axis.z * s
        mat.Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c
        mat.Z.y = axis.y * axis.z * (1 - c) - axis.x * s
        
        mat.X.z = axis.x * axis.z * (1 - c) - axis.y * s
        mat.Y.z = axis.y * axis.z * (1 - c) + axis.x * s
        mat.Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c
        
        return mat
    }
    
    public static func rotateX(byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let cosv:Float = cos(angle)
        let sinv:Float = sin(angle)
        
        mat.Y.y = cosv
        mat.Z.y = -sinv
        mat.Y.z = sinv
        mat.Z.z = cosv
        
        return mat
    }
    
    public static func rotateY(byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let cosv:Float = cos(angle)
        let sinv:Float = sin(angle)
        
        mat.X.x = cosv
        mat.Z.x = sinv
        mat.X.z = -sinv
        mat.Z.z = cosv
        
        return mat
    }
    
    public static func rotateZ(byAngle angle: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        let cosv:Float = cos(angle)
        let sinv:Float = sin(angle)
        
        mat.X.x = cosv
        mat.Y.x = -sinv
        mat.X.y = sinv
        mat.Y.y = cosv
        
        return mat
    }
    
    // ピクセル座標系変換行列
    public static func pixelProjection(wid:Int, hgt:Int) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = .identity
        vp_mat.X.x =  2.0 / Float(wid)
        vp_mat.Y.y = -2.0 / Float(hgt)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    public static func pixelProjection(wid:CGFloat, hgt:CGFloat) -> Matrix4x4 {
        return pixelProjection(wid: Int(wid), hgt: Int(hgt))
    }
    public static func pixelProjection(wid:Float, hgt:Float) -> Matrix4x4 {
        return pixelProjection(wid: Int(wid), hgt: Int(hgt))
    }
    public static func pixelProjection(_ size:CGSize) -> Matrix4x4 {
        return pixelProjection(wid: Int(size.width), hgt: Int(size.height))
    }
    
    public static func ortho(left l: Float, right r: Float, bottom b: Float, top t: Float, near n: Float, far f: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = .identity
        
        mat.X.x = 2.0 / (r-l)
        mat.W.x = (r+l) / (r-l)
        mat.Y.y = 2.0 / (t-b)
        mat.W.y = (t+b) / (t-b)
        mat.Z.z = -2.0 / (f-n)
        mat.W.z = (f+n) / (f-n)
        
        return mat
    }
    
    public static func ortho2d(wid:Float, hgt:Float) -> Matrix4x4 {
        return ortho(left: 0, right: wid, bottom: hgt, top: 0, near: -1, far: 1)
    }
    
    // 透視投影変換行列(手前:Z軸正方向)
    public static func perspective(aspect: Float, fieldOfViewY: Float, near: Float, far: Float) -> Matrix4x4 {
        var mat:Matrix4x4 = Matrix4x4()
        
        let fov_radians:Float = fieldOfViewY * Float(Double.pi / 180.0)
        
        let y_scale:Float = 1 / tan(fov_radians * 0.5)
        let x_scale:Float = y_scale / aspect
        let z_range:Float = far - near
        let z_scale:Float = -(far + near) / z_range
        let wz_scale:Float = -2 * far * near / z_range
        
        mat.X.x = x_scale
        mat.Y.y = y_scale
        mat.Z.z = z_scale
        mat.Z.w = -1.0
        mat.W.z = wz_scale
        mat.W.w = 0.0
        
        return mat
    }
}
// matrix_float4x4拡張
public extension matrix_float4x4 {
    var matrix4x4:Matrix4x4 { return Matrix4x4( self ) }
}

// 演算子オーバーロード
public func + ( _ left:Matrix4x4, _ right:Matrix4x4 ) -> Matrix4x4 {
    return Matrix4x4( left.matrixFloat4x4 + right.matrixFloat4x4 )
}
public func - ( _ left:Matrix4x4, _ right:Matrix4x4 ) -> Matrix4x4 {
    return Matrix4x4( left.matrixFloat4x4 - right.matrixFloat4x4 )
}
public func * ( _ left:Matrix4x4, _ right:Matrix4x4 ) -> Matrix4x4 {
    return Matrix4x4( left.matrixFloat4x4 * right.matrixFloat4x4 )
}
public func * ( _ left:Matrix4x4, _ right:Float4 ) -> Float4 {
    return Float4( left.matrixFloat4x4 * right.vectorFloat4 )
}
public func * ( _ left:Matrix4x4, _ right:matrix_float4x4 ) -> Matrix4x4 {
    return Matrix4x4( left.matrixFloat4x4 * right )
}
public func * ( _ left:matrix_float4x4, _ right:Matrix4x4 ) -> Matrix4x4 {
    return Matrix4x4( left * right.matrixFloat4x4 )
}
