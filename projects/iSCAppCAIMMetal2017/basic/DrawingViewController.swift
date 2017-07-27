//
// DrawingViewController.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import UIKit

// バッファID番号
let ID_VERTEX:Int     = 0
let ID_PROJECTION:Int = 1

// 1頂点情報の構造体
struct VertexInfo : Initializable {
    var pos:Vec4 = Vec4()
    var uv:Vec2 = Vec2()
    var rgba:CAIMColor = CAIMColor()
}

// パーティクル情報
struct Particle {
    var pos:Vec2 = Vec2()               // xy座標
    var radius:Float = 0.0              // 半径
    var rgba:CAIMColor = CAIMColor()    // パーティクル色
    var life:Float = 0.0                // パーティクルの生存係数(1.0~0.0)
}

// CAIM-Metalを使うビューコントローラ
class DrawingViewController : CAIMMetalViewController
{
    private var pl_circle:CAIMMetalRenderPipeline?
    
    // GPU:バッファ
    private var mat_buf:CAIMMetalBuffer?            // 行列バッファ
    private var circle_quads_buf:CAIMMetalBuffer?   // 頂点バッファ(円を描く四角形)

    // CPU:形状メモリ
    private var circle_quads = CAIMQuadrangles<VertexInfo>()    // 円用メモリ
    
    // パーティクル情報配列
    private var circle_parts = [Particle]()     // 円用パーティクル情報

    // 円描画シェーダの準備関数
    private func setupCircleEffect() {
        // シェーダを指定してパイプラインの作成
        pl_circle = CAIMMetalRenderPipeline(vertname:"vert2d", fragname:"fragCircleCosCurve")
        pl_circle?.blend_type = .alpha_blend
        
        // (GPUバッファ)頂点バッファ(四角形)の作成
        circle_quads_buf = CAIMMetalBuffer(vertice:circle_quads)
    }
    
    // パーティクルを生成する関数
    private func genParticle(pos:CGPoint, color:CAIMColor, radius:Float) -> Particle {
        var p:Particle = Particle()
        p.pos = Vec2(Float32(pos.x), Float32(pos.y))
        p.rgba = color
        p.radius = radius
        p.life = 1.0        // ライフを1.0から開始
        return p
    }
    
    // パーティクルのライフの更新
    private func updateLife(in particles:inout [Particle]) {
        // パーティクル情報の更新
        for i:Int in 0 ..< particles.count {
            // パーティクルのライフを減らす(60FPSで1.5秒間保つようにする)
            particles[i].life -= 1.0 / (1.5 * 60.0)
            // ライフが0は下回らないようにする
            particles[i].life = max(0.0, circle_parts[i].life)
        }
    }
    
    // ライフが0のパーティクルを捨てる
    private func trashParticles(in particles:inout [Particle]) {
        // 配列を後ろからスキャンしながら、lifeが0になったものを配列から外していく
        for i:Int in (0 ..< particles.count).reversed() {
            if(particles[i].life <= 0.0) {
                particles.remove(at: i)
            }
        }
    }
    
    // 円情報からCPUメモリの更新、GPUメモリに転送
    private func genCirclesBuffer(particles:[Particle]) {
        // パーティクル配列からCPUメモリの作成(particles -> circle_quads)
        circle_quads.resize(count: particles.count)
        let p_circle_quads = circle_quads.pointer
        for i:Int in 0 ..< circle_quads.count {
            // パーティクル情報を展開する
            let p:Particle = particles[i]
            let x:Float = p.pos.x                   // x座標
            let y:Float = p.pos.y                   // y座標
            let r:Float = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba:CAIMColor = p.rgba             // 色
            rgba.A *= p.life                        // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形頂点v0
            p_circle_quads[i].v0.pos  = Vec4(x-r, y-r, 0, 1)
            p_circle_quads[i].v0.uv   = Vec2(-1.0, -1.0)
            p_circle_quads[i].v0.rgba = rgba
            // 四角形頂点v1
            p_circle_quads[i].v1.pos  = Vec4(x+r, y-r, 0, 1)
            p_circle_quads[i].v1.uv   = Vec2(1.0, -1.0)
            p_circle_quads[i].v1.rgba = rgba
            // 四角形頂点v2
            p_circle_quads[i].v2.pos  = Vec4(x-r, y+r, 0, 1)
            p_circle_quads[i].v2.uv   = Vec2(-1.0, 1.0)
            p_circle_quads[i].v2.rgba = rgba
            // 四角形頂点v3
            p_circle_quads[i].v3.pos  = Vec4(x+r, y+r, 0, 1)
            p_circle_quads[i].v3.uv   = Vec2(1.0, 1.0)
            p_circle_quads[i].v3.rgba = rgba
        }
        
        // GPUバッファの内容を更新(circle_quads -> circle_quads_buf)
        circle_quads_buf?.update(vertice: circle_quads)
    }
    
    // 円の描画
    private func drawCircles(renderer:CAIMMetalRenderer) {
        // パイプライン(シェーダ)の切り替え
        renderer.use(pl_circle)
        // 使用するバッファと番号をリンクする
        renderer.link(circle_quads_buf!, to:.vertex, at:ID_VERTEX)
        renderer.link(mat_buf!, to:.vertex, at:ID_PROJECTION)
        // GPU描画実行(quadsを渡すと四角形を描く)
        renderer.draw(circle_quads)
    }
    
    // 準備関数
    override func setup() {
        // (GPUバッファ)ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat_buf = CAIMMetalBuffer(Matrix4x4.pixelProjection(CAIMScreenPixel))
        // 円描画シェーダの準備
        setupCircleEffect()
    }
    
    // 繰り返し処理関数
    override func update(renderer:CAIMMetalRenderer) {
        // タッチ位置にパーティクル発生
        for pos:CGPoint in touch_pos {
            // 新しいパーティクルを生成
            let p = genParticle(pos: pos,
                                color: CAIMColor(R: CAIMRandom(), G: CAIMRandom(), B: CAIMRandom(), A: CAIMRandom()),
                                radius: CAIMRandom(120.0) + 60.0)
            // パーティクルを追加
            circle_parts.append(p)
        }
        
        // 円パーティクルのライフの更新
        updateLife(in: &circle_parts)
        
        // 不要な円パーティクルの削除
        trashParticles(in: &circle_parts)
        
        // パーティクルがない場合処理しない
        if(circle_parts.count > 0) {
            // 円パーティクルからGPUバッファを生成
            genCirclesBuffer(particles:circle_parts)
            // 円の描画
            drawCircles(renderer: renderer)
        }
    }
}
