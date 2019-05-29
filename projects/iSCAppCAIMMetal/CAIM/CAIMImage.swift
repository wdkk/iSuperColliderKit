//
// CAIMImage.swift
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
import UIKit

enum CAIMDepth : Int
{
    case bit8  = 8
    case bit16 = 16
    case float = 32
}

// C言語実装のCAIMImageをSwiftで使いやすくしたクラス
class CAIMImage
{
    var memory:CAIMBytePtr       // pixel memory first address
    var matrix:CAIMColorMatrix   // 2d(need to cast CAIMColorMatrix series)
    var width:Int
    var height:Int
    var depth:CAIMDepth
    var channel:Int
    var row_bytes:Int
    var memory_size:Int
    var scale:Float             // scaling(retina or non retina)
    
    init( width:Int, height:Int, depth:CAIMDepth = .float ) {
        self.width   = width
        self.height  = height
        self.channel = 4
        self.depth   = depth
        self.row_bytes   = width * self.channel * self.depth.rawValue / 8
        
        var all_size  = row_bytes * height
        // iOS Metal Shared Memory need 4096 bytes alignment.
        let mod       = all_size % 4096
        all_size += ( mod > 0 ? 4096 - mod : 0 )
        
        self.memory_size = all_size
        self.scale       = Float( UIScreen.main.scale )
        
        self.memory      = CAIMBytePtr( OpaquePointer( malloc( all_size ) ) )
        self.matrix      = CAIMColorMatrix( OpaquePointer( malloc( height * MemoryLayout<CAIMColorPtr>.stride ) ) )
        
        treatArray()
    }
    
    convenience init( size:CGSize, depth:CAIMDepth = .float ) {
        self.init( width: Int(size.width), height: Int(size.height), depth: depth )
    }
    
    convenience init( path:String, depth:CAIMDepth = .float ) {
        self.init( width: 1, height: 1, depth:depth )
        loadFile( path )
    }
    
    fileprivate convenience init( clone_src:CAIMImage ) {
        self.init( width: clone_src.width, height: clone_src.height, depth:clone_src.depth )
        copy( clone_src )
    }
    
    deinit {
        free( self.matrix )
        free( self.memory )
    }
    
    func copy( _ img_src:CAIMImage ) {
        resize( img_src.width, img_src.height )
        self.scale = img_src.scale
        memcpy( self.memory, img_src.memory, self.row_bytes * self.height )
    }
    
    func resize( _ wid:Int, _ hgt:Int ) {
        if( self.width == wid && self.height == hgt ) { return }
        
        free( self.memory )
        free( self.matrix )
        
        self.width   = wid
        self.height  = hgt
        self.channel = 4
        self.row_bytes  = wid * self.channel * self.depth.rawValue / 8
        
        var all_size  = row_bytes * hgt
        // iOS Metal Shared Memory need 4096 bytes alignment.
        let mod       = all_size % 4096
        all_size += ( mod > 0 ? 4096 - mod : 0 )
        
        self.memory_size = all_size
        self.scale       = Float( UIScreen.main.scale )
        
        self.memory      = CAIMBytePtr( OpaquePointer( malloc( all_size ) ) )
        self.matrix      = CAIMColorMatrix( OpaquePointer( malloc( hgt * MemoryLayout<CAIMColorPtr>.stride ) ) )
        
        treatArray()
    }
    
    @discardableResult
    func loadFile( _ path:String ) -> Bool {
        let ui_img = UIImage( contentsOfFile: path )
        if( ui_img == nil ) { return false }
            
        // get CGImage into ui_img.
        let img_ref = ui_img!.cgImage
        // get Data Provider
        let data_prov = img_ref!.dataProvider
        // get Data Reference
        let data_ref = data_prov?.data
        // get pixel buffer
        let buffer = CFDataGetBytePtr( data_ref )!
        
        let row_bytes = img_ref!.bytesPerRow
        let wid = Int( ui_img!.size.width )
        let hgt = Int( ui_img!.size.height )
        
        // resize CAIMImage data.
        resize( wid, hgt )
        
        let mat = self.matrix
        
        for y in 0 ..< hgt {
            for x in 0 ..< wid {
                mat[y][x].R = Float(buffer[x * 4 + y * row_bytes]) / 255.0
                mat[y][x].G = Float(buffer[x * 4 + y * row_bytes + 1]) / 255.0
                mat[y][x].B = Float(buffer[x * 4 + y * row_bytes + 2]) / 255.0
                mat[y][x].A = Float(buffer[x * 4 + y * row_bytes + 3]) / 255.0
            }
        }
        
        return true
    }
    
    func fillColor( _ c:CAIMColor ) {
        var color = c
        memsetex( self.memory, &color, MemoryLayout<CAIMColor>.stride, self.width * self.height )
    }
    
    private func treatArray() {
        let step = width * self.channel * MemoryLayout<Float>.stride
        
        let mat = self.matrix
        for y in 0 ..< height {
            mat[y] = CAIMColorPtr( OpaquePointer( memory + (y * step) ) )
        }
    }
}

// 高速なmemset
// https://www16.atwiki.jp/projectpn/pages/36.html
@discardableResult
fileprivate func memsetex( _ dst:UnsafeMutableRawPointer, _ src:UnsafeMutableRawPointer, _ nmemb:size_t, _ size:size_t )
-> UnsafeMutableRawPointer? {
    if( size == 0 ) { return nil }
    if( size == 1 ) {
        memcpy( dst, src, nmemb )
    }
    else {
        let half = size / 2
        memsetex( dst, src, nmemb, half )
        memcpy( dst + half * nmemb, dst, half * nmemb )
        if( size % 2 == 1 ) {
            memcpy( dst + (size - 1) * nmemb, src, nmemb )
        }
    }
    return dst
}

