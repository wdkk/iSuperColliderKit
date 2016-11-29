//
//  MyView.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/13.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import UIKit

class MyMetalView: CAIMMetalView
{
    // Metal Render
    var renderer:CAIMMetalRenderer!
    var pl:CAIMMetalPipeline!
    var vsh:CAIMMetalVertexShader!
    var fsh:CAIMMetalFragmentShader!

    var particles:ParticleManager = ParticleManager(metal_idx:0, max_size: 200)
    var s_time:UInt = 0
    
    override init(frame:CGRect)
    {
        super.init(frame:frame)
        
        self.ev_touches_began = touchBegan
        self.ev_touches_ended = touchEnded
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override func buildResources()
    {
        //// レンダラの作成 //////////////////////////////////
        renderer = CAIMMetalRenderer()
        //// シェーダの作成 ////
        vsh = CAIMMetalVertexShader("vertexShader")
        fsh = CAIMMetalFragmentShader("fragmentShader")
        //// シェーダを指定してパイプラインの作成 ////
        pl = CAIMMetalPipeline(vsh:self.vsh, fsh: self.fsh)
        ///////////////////////////////////////////////////

        // 画像データ
        let sc:CGFloat = UIScreen.main.scale
        let wid:Int = Int(self.bounds.width * sc)
        let hgt:Int = Int(self.bounds.height * sc)
        
        for i in 0 ..< particles.count
        {
            particles[i] = genParticle(life: randomFloat())
        }
        
        //// 頂点シェーダ用メモリのマップ ////
        // 頂点バッファの作成
        vsh["vertices"] = particles.metal_buf
        // ユニフォームバッファの作成
        vsh["uniform"] = CAIMMetalBuffer(1, length: MemoryLayout<Matrix4x4>.size )
      
        // 座標値の更新
        var mat:Matrix4x4 = Matrix4x4()
        mat.X.x = 2.0 / Float32(wid)
        mat.Y.y = 2.0 / Float32(hgt)
        mat.W.x = -1.0
        mat.W.y = -1.0
        vsh["uniform"].update([mat], length: MemoryLayout<Matrix4x4>.size )
        
        s_time = UInt(CAIMNow())
    }
    
    func genParticle(life:Float32=1.0) -> Particle
    {
        // 画像データ
        let sc:CGFloat = UIScreen.main.scale
        let wid:Int = Int(self.bounds.width * sc)
        let hgt:Int = Int(self.bounds.height * sc)
        
        var p:Particle = Particle()
        p.color = Color32( r:randomFloat(), g:randomFloat(), b:randomFloat(), a:1.0)
        p.pos = Vec2(x: randomFloat(wid), y: randomFloat(hgt) )
        p.radius = (randomFloat(60.0) + 20.0) * Float32(sc)
        p.life = life
        p.enable = true
        
        return p
    }
    
    func updateParticles()
    {
        let n_time:UInt = UInt(CAIMNow())
        let dt:UInt = n_time - s_time
        for i:Int in 0 ..< particles.count
        {
            particles[i].life -= 0.3 * Float32(dt)/1000.0
            if(particles[i].life <= 0.0) {
                particles[i] = genParticle()
                continue
            }
        }
        s_time = n_time
        
        particles.update()
    }
    
    override func draw()
    {
        // 描画先Viewを指定(=self)して、レンダラ準備
        let _ = renderer.ready(view: self)
     
        updateParticles()
        
        // verticesの更新
        vsh["vertices"].update(particles.memory, length: particles.mem_size)
        
        // 指定したパイプラインで描画実行、描画の詳細な命令はdrawMesh関数で指定
        renderer.render(pl: pl, draw:drawMesh)
    }
    
    func drawMesh(cmd:MTLRenderCommandEncoder)
    {
        particles.render(cmd: cmd)
    }
    
    func touchBegan(view:CAIMView)
    {
        iSC.interpret("a = {SinOsc.ar()}.play")
        print("began")
    }
    
    func touchEnded(view:CAIMView)
    {
        iSC.interpret("a.free")
        print("ended")
    }
}
