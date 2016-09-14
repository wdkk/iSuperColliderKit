//
//  CAIMMetalGeometric.swift
//  ios_caim01
//
//  Created by kengo on 2016/02/02.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation

struct Vec2 {
    var x: Float32
    var y: Float32
}

struct Vec3 {
    var x: Float32
    var y: Float32
    var z: Float32
}

struct Vec4
{
    var x: Float32
    var y: Float32
    var z: Float32
    var w: Float32
}

struct Size2
{
    var wid: Int32
    var hgt: Int32
}

struct Matrix4x4
{
    var X: Vec4
    var Y: Vec4
    var Z: Vec4
    var W: Vec4
    
    init()
    {
        X = Vec4(x: 1, y: 0, z: 0, w: 0)
        Y = Vec4(x: 0, y: 1, z: 0, w: 0)
        Z = Vec4(x: 0, y: 0, z: 1, w: 0)
        W = Vec4(x: 0, y: 0, z: 0, w: 1)
    }
    
    static func rotationAboutAxis(axis: Vec4, byAngle angle: Float32) -> Matrix4x4
    {
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
    
    static func perspectiveProjection(aspect: Float32, fieldOfViewY: Float32, near: Float32, far: Float32) -> Matrix4x4
    {
        var mat:Matrix4x4 = Matrix4x4()
        
        let fov_radians:Float32 = fieldOfViewY * Float32(M_PI / 180.0)
        
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

struct TexCoord
{
    var u: Float32
    var v: Float32
}

struct Color32
{
    var r:Float32 = 0
    var g:Float32 = 0
    var b:Float32 = 0
    var a:Float32 = 0
}

struct Vertex
{
    var position: Vec4
    var uv: Vec2
}

struct VertexColor
{
    var pos:Vec4 = Vec4(x: 0, y: 0, z: 0, w: 0)
    var color:Color32 = Color32()
    var uv:Vec2 = Vec2(x:0, y:0)
}