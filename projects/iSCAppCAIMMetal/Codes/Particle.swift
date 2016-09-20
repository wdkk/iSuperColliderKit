//
//  Particle.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/16.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation

struct Particle
{
    var pos:Vec2 = Vec2(x: 0, y: 0)
    var color:Color32 = Color32()
    var radius:Float32 = 0.0
    var life:Float32 = 1.0
    var enable:Bool = false
    
    func genVertex() -> [VertexColor]
    {
        // 6頂点=三角形ポリゴンx2を準備
        var vs:[VertexColor] = [VertexColor](repeating: VertexColor(), count:6)
        
        // Particleのパラメータに合わせて計算
        let cx:Float32 = pos.x
        let cy:Float32 = pos.y
        let r:Float32 = radius * (1.0-life)
        var c:Color32 = color
        c.a *= life
        
        // [機械的処理] Metal 板ポリMesh向けに値を作成
        vs[0].pos = Vec4(x: cx-r, y: cy-r, z: 0.0, w: 1.0)
        vs[1].pos = Vec4(x: cx+r, y: cy-r, z: 0.0, w: 1.0)
        vs[2].pos = Vec4(x: cx-r, y: cy+r, z: 0.0, w: 1.0)
        vs[3].pos = Vec4(x: cx+r, y: cy+r, z: 0.0, w: 1.0)
        vs[4].pos = Vec4(x: cx-r, y: cy+r, z: 0.0, w: 1.0)
        vs[5].pos = Vec4(x: cx+r, y: cy-r, z: 0.0, w: 1.0)
        
        vs[0].uv = Vec2(x: -1, y: -1)
        vs[1].uv = Vec2(x:  1, y: -1)
        vs[2].uv = Vec2(x: -1, y:  1)
        vs[3].uv = Vec2(x:  1, y:  1)
        vs[4].uv = Vec2(x: -1, y:  1)
        vs[5].uv = Vec2(x:  1, y: -1)
        
        vs[0].color = c
        vs[1].color = c
        vs[2].color = c
        vs[3].color = c
        vs[4].color = c
        vs[5].color = c
        
        return vs
    }
}

class ParticleManager
{
    private var parts:[Particle]!
    private var vertices:CMemory<VertexColor>!
    private var active_count:Int = 0
    
    var metal_buf:CAIMMetalBuffer!
    
    var count:Int { return parts.count }
    var memory:UnsafeMutablePointer<VertexColor> { return vertices.mem! }
    var mem_size:Int { return vertices.mem_size }
    
    // subscript [n] accessor
    subscript(idx:Int) -> Particle {
        get { return parts[idx] }
        set(new_value) { parts[idx] = new_value }
    }
    
    init(metal_idx:Int, max_size: Int)
    {
        vertices = CMemory<VertexColor>(size: max_size * 6)
        parts = [Particle](repeating:Particle(), count:max_size)
        metal_buf = CAIMMetalBuffer(metal_idx, length: mem_size)
    }
    
    deinit
    {
        metal_buf = nil
        parts.removeAll()
        vertices = nil
    }
    
    func update()
    {
        var i:Int = 0
        for p:Particle in parts
        {
            if(!p.enable) { continue }
            let vs:[VertexColor] = p.genVertex()
            vertices.set(idx: i, array: vs)
            i += vs.count
        }
        
        active_count = i
    }
    
    func render(cmd:MTLRenderCommandEncoder)
    {
        cmd.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: active_count)
    }
    
}
