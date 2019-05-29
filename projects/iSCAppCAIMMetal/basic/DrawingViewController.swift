//
// DrawingViewController.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import Metal
import simd
import QuartzCore

// 頂点情報の構造体
struct Vertex {
    var pos:Float2  = Float2()
    var uv:Float2   = Float2()
    var rgba:Float4 = Float4()
}

// パーティクル情報
struct Particle {
    var pos:Float2 = Float2()           // xy座標
    var radius:Float = 0.0              // 半径
    var rgba:CAIMColor = CAIMColor()    // パーティクル色
    var life:Float = 0.0                // パーティクルの生存係数(1.0~0.0)
}

class DrawingViewController : CAIMViewController
{
    private var metal_view:CAIMMetalView?                   // Metalビュー
    private var pipeline_circle:CAIMMetalRenderPipeline = CAIMMetalRenderPipeline()  // Metalレンダパイプライン
    private var mat:Matrix4x4 = .identity                        // 変換行列
    private var circles = CAIMMetalQuadrangles<Vertex>()         // 円用４頂点メッシュ群
    
    // パーティクル情報配列
    private var circle_parts = [Particle]()     // 円用パーティクル情報
    
    // 準備関数
    override func setup() {
        super.setup()
        
        iSC.setup()
        iSC.interpret("s.boot")
        
        // Metalを使うビューを作成してViewControllerに追加
        metal_view = CAIMMetalView( frame: view.bounds )
        self.view.addSubview( metal_view! )
        
        // ピクセルプロジェクション行列バッファの作成(画面サイズに合わせる)
        mat = Matrix4x4.pixelProjection( metal_view!.pixelBounds.size )
        
        // 円描画の準備
        setupCircleEffect()
        
        // metal_view上のタッチ開始時の処理として、touchPressedOnView関数を指定
        metal_view?.touchPressed = self.touchPressedOnView
        // metal_view上のタッチ移動時の処理として、touchMovedOnView関数を指定
        metal_view?.touchMoved = self.touchMovedOnView
        // metal_view上のタッチ終了時の処理として、touchReleasedOnView関数を指定
        metal_view?.touchReleased = self.touchReleasedOnView
    }
    
    // 円描画シェーダの準備関数
    private func setupCircleEffect() {
        // パイプラインの作成
        pipeline_circle.make {
            // シェーダを指定
            $0.vertexShader = CAIMMetalShader( "vert2d" )
            $0.fragmentShader = CAIMMetalShader( "fragCircleCosCurve" )
        }
    }
    
    // パーティクルを生成する関数
    private func genParticle( pos:CGPoint, color:CAIMColor, radius:Float ) -> Particle {
        var p = Particle()
        p.pos = Float2(Float(pos.x), Float(pos.y))
        p.rgba = color
        p.radius = radius
        p.life = 1.0        // ライフを1.0から開始
        return p
    }
    
    // パーティクルのライフの更新
    private func updateLife( in particles:inout [Particle] ) {
        // パーティクル情報の更新
        for i in 0 ..< particles.count {
            // パーティクルのライフを減らす(60FPSで1.5秒間保つようにする)
            particles[i].life -= 1.0 / (1.5 * 60.0)
        }
    }
    
    // ライフが0のパーティクルを捨てる
    private func trashParticles( in particles:inout [Particle] ) {
        // 配列を後ろからスキャンしながら、lifeが0になったものを配列から外していく
        for i in (0 ..< particles.count).reversed() {
            if particles[i].life <= 0.0 {
                particles.remove(at: i)
            }
        }
    }
    
    // 円のパーティクル情報から頂点メッシュ情報を更新
    private func genCirclesMesh( particles:[Particle] ) {
        // パーティクルの数に合わせてメッシュの数をリサイズする
        circles.resize( count: particles.count )
        for i:Int in 0 ..< circles.count {
            // パーティクル情報を展開して、メッシュ情報を作る材料にする
            let p:Particle = particles[i]
            let x:Float = p.pos.x                   // x座標
            let y:Float = p.pos.y                   // y座標
            let r:Float = p.radius * (1.0 - p.life) // 半径(ライフが短いと半径が大きくなるようにする)
            var rgba:CAIMColor = p.rgba             // 色
            rgba.A *= p.life                        // アルファ値の計算(ライフが短いと薄くなるようにする)
            
            // 四角形メッシュi個目の頂点1
            circles[i].p1 = Vertex( pos:Float2( x-r, y-r ), uv:Float2( -1.0, -1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点2
            circles[i].p2 = Vertex( pos:Float2( x+r, y-r ), uv:Float2( 1.0, -1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点3
            circles[i].p3 = Vertex( pos:Float2( x-r, y+r ), uv:Float2( -1.0, 1.0 ), rgba:rgba.float4 )
            // 四角形メッシュi個目の頂点4
            circles[i].p4 = Vertex( pos:Float2( x+r, y+r ), uv:Float2( 1.0, 1.0 ), rgba:rgba.float4 )
        }
    }
    
    // 繰り返し処理関数
    override func update() {
        super.update()
        
        // タッチ位置にパーティクル発生
        for pos in metal_view!.touchPixelPos {
            // 新しいパーティクルを生成
            let p = genParticle(pos: pos,
                                color: CAIMColor(CAIM.random(), CAIM.random(), CAIM.random(), CAIM.random()),
                                radius: CAIM.random(120.0) + 60.0)
            // パーティクルを追加
            circle_parts.append( p )
        }
        
        // 円パーティクルのライフの更新
        updateLife( in: &circle_parts )
        // 不要な円パーティクルの削除
        trashParticles( in: &circle_parts )
        
        // パーティクル情報がない場合のみ描画処理を実行
        if circle_parts.count > 0 {
            // パーティクル情報からメッシュ情報を更新
            genCirclesMesh( particles:circle_parts )
            // MetalViewのレンダリングを実行
            metal_view?.execute( renderFunc: self.render )
        }
    }
    
    // Metalで実際に描画を指示する関数
    func render( encoder:MTLRenderCommandEncoder ) {
        // 準備したpipeline_circleを使って、描画を開始(クロージャの$0は引数省略表記。$0 = encoder)
        encoder.use( pipeline_circle ) {
            // 頂点シェーダのバッファ1番に行列matをセット
            $0.setVertexBuffer( mat, index: 1 )
            // 円描画用の四角形データ群の頂点をバッファ0番にセットし描画を実行
            $0.drawShape( circles, index: 0 )
        }
    }
    
    func touchPressedOnView() {
        iSC.interpret("a = {SinOsc.ar()}.play")
    }
    
    func touchMovedOnView() {
        
    }
    
    func touchReleasedOnView() {
        iSC.interpret("a.free")
    }
}
