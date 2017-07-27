//
// CAIMGeometric.swift
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

struct Vec2 {
    var x: Float32
    var y: Float32
    init(_ x:Float32=0.0, _ y:Float32=0.0) { self.x = x; self.y = y }
}

struct Vec3 {
    var x: Float32
    var y: Float32
    var z: Float32
    init(_ x:Float32=0.0, _ y:Float32=0.0, _ z:Float32=0.0) { self.x = x; self.y = y; self.z = z }
}

struct Vec4 {
    var x: Float32
    var y: Float32
    var z: Float32
    var w: Float32
    init(_ x:Float32=0.0, _ y:Float32=0.0, _ z:Float32=0.0, _ w:Float32=1.0) { self.x = x; self.y = y; self.z = z; self.w = w }
}

struct Size2 {
    var w: Int32
    var h: Int32
    init(_ wid:Int32=0, _ hgt:Int32=0) { self.w = wid; self.h = hgt }
}

struct Matrix4x4 {
    var X: Vec4
    var Y: Vec4
    var Z: Vec4
    var W: Vec4
    
    // ピクセル座標系変換行列
    static func pixelProjection(wid:Int, hgt:Int) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = Matrix4x4()
        vp_mat.X.x =  2.0 / Float32(wid)
        vp_mat.Y.y = -2.0 / Float32(hgt)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    
    // ピクセル座標系変換行列
    static func pixelProjection(wid:CGFloat, hgt:CGFloat) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = Matrix4x4()
        vp_mat.X.x =  2.0 / Float32(wid)
        vp_mat.Y.y = -2.0 / Float32(hgt)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    
    // ピクセル座標系変換行列
    static func pixelProjection(_ size:CGSize) -> Matrix4x4 {
        var vp_mat:Matrix4x4 = Matrix4x4()
        vp_mat.X.x =  2.0 / Float32(size.width)
        vp_mat.Y.y = -2.0 / Float32(size.height)
        vp_mat.W.x = -1.0
        vp_mat.W.y =  1.0
        return vp_mat
    }
    
    
    // 単位行列
    init() {
        X = Vec4(1, 0, 0, 0)
        Y = Vec4(0, 1, 0, 0)
        Z = Vec4(0, 0, 1, 0)
        W = Vec4(0, 0, 0, 1)
    }
    
    static func rotationAboutAxis(axis: Vec4, byAngle angle: Float32) -> Matrix4x4 {
        var mat:Matrix4x4 = Matrix4x4()
        
        let c:Float32 = cos(angle)
        let s:Float32 = sin(angle)
        
        mat.X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        mat.X.y = axis.x * axis.y * (1 - c) - axis.z * s
        mat.X.z = axis.x * axis.z * (1 - c) + axis.y * s
        
        mat.Y.x = axis.x * axis.y * (1 - c) + axis.z * s
        mat.Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c
        mat.Y.z = axis.y * axis.z * (1 - c) - axis.x * s
        
        mat.Z.x = axis.x * axis.z * (1 - c) - axis.y * s
        mat.Z.y = axis.y * axis.z * (1 - c) + axis.x * s
        mat.Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c
        
        return mat
    }
    
    static func perspectiveProjection(aspect: Float32, fieldOfViewY: Float32, near: Float32, far: Float32) -> Matrix4x4 {
        var mat:Matrix4x4 = Matrix4x4()
        
        let fov_radians:Float32 = fieldOfViewY * Float32(Double.pi / 180.0)
        
        let y_scale:Float32 = 1 / tan(fov_radians * 0.5)
        let x_scale:Float32 = y_scale / aspect
        let z_range:Float32 = far - near
        let z_scale:Float32 = -(far + near) / z_range
        let wz_scale:Float32 = -2 * far * near / z_range
        
        mat.X.x = x_scale
        mat.Y.y = y_scale
        mat.Z.z = z_scale
        mat.Z.w = -1
        mat.W.z = wz_scale
        
        return mat
    }
}

func * (left: Matrix4x4, right:Matrix4x4) -> Matrix4x4 {
    var mat:Matrix4x4 = Matrix4x4()
    
    mat.X.x = left.X.x * right.X.x
    mat.X.y = left.X.y * right.Y.x
    mat.X.z = left.X.z * right.Z.x
    mat.X.w = left.X.w * right.W.x
    
    mat.Y.x = left.Y.x * right.X.y
    mat.Y.y = left.Y.y * right.Y.y
    mat.Y.z = left.Y.z * right.Z.y
    mat.Y.w = left.Y.w * right.W.y
    
    mat.Z.x = left.Z.x * right.X.z
    mat.Z.y = left.Z.y * right.Y.z
    mat.Z.z = left.Z.z * right.Z.z
    mat.Z.w = left.Z.w * right.W.z
    
    mat.W.x = left.W.x * right.X.w
    mat.W.y = left.W.y * right.Y.w
    mat.W.z = left.W.z * right.Z.w
    mat.W.w = left.W.w * right.W.w
    
    return mat
}

struct CAIMPoint<T:Initializable>
{
    var v0:T = T()
}

struct CAIMLine<T:Initializable>
{
    var v0:T = T(), v1:T = T()
}

struct CAIMTriangle<T:Initializable>
{
    var v0:T = T(), v1:T = T(), v2:T = T()
}

struct CAIMQuadrangle<T:Initializable>
{
    var v0:T = T(), v1:T = T(), v2:T = T(), v3:T = T()
}
