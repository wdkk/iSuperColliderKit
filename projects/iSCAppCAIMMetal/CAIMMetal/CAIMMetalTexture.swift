//
// CAIMMetalTexture.swift
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

public class CAIMMetalTexture {
    public private(set) var metalTexture:MTLTexture?
    
    public init( with path:String ) {
        // テクスチャの読み込み
        let tex_loader_options: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.topLeft]
        let tex_loader:MTKTextureLoader = MTKTextureLoader(device: CAIMMetal.device! )
        
        let ext = URL(fileURLWithPath: path).pathExtension.isEmpty ? "png" : nil
            
        guard let url = Bundle.main.url( forResource: path, withExtension: ext) else {
            print( "Failed to load \(path)" )
            metalTexture = nil
            return
        }
        
        do {
            self.metalTexture = try tex_loader.newTexture( URL: url, options: tex_loader_options )
        }
        catch {
            print( "Catch exception: load texture \(path)" )
        }
    }
    
    public init( cgImage:CGImage ) {
        // テクスチャの読み込み
        let tex_loader_options: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.topLeft]
        let tex_loader:MTKTextureLoader = MTKTextureLoader(device: CAIMMetal.device! )
        
        do {
            self.metalTexture = try tex_loader.newTexture( cgImage: cgImage, options: tex_loader_options )
        }
        catch {
            print( "Catch exception: create texture from CGImage." )
        }
    }
    
    #if LILY
    // Lily画像オブジェクトからの作成
    public init( llImage img:LLImage ) {
        let tex_desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                width: img.width,
                                                                height: img.height,
                                                                mipmapped: false)
        self.metalTexture = CAIMMetal.device?.makeTexture(descriptor: tex_desc)
        
        let reg = MTLRegionMake2D( 0, 0, img.width, img.height )
        let pointer = unsafeBitCast( img.memory, to: UnsafeRawPointer.self )
        self.metalTexture?.replace( region: reg, mipmapLevel: 0, withBytes: pointer, bytesPerRow: img.rowBytes )
    }
    #else
    // CAIM画像オブジェクトからの作成
    init( caimImage img:CAIMImage ) {
        let tex_desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                width: img.width,
                                                                height: img.height,
                                                                mipmapped: false)
        self.metalTexture = CAIMMetal.device?.makeTexture(descriptor: tex_desc)
        
        let reg = MTLRegionMake2D( 0, 0, img.width, img.height )
        let pointer = UnsafeRawPointer(img.memory)
        self.metalTexture?.replace( region: reg, mipmapLevel: 0, withBytes: pointer, bytesPerRow: img.row_bytes )
    }
    #endif
}

#endif
