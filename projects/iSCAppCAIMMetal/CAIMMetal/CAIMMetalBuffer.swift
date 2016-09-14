//
//  CAIMMetalBuffer.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/13.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation

class CAIMMetalBuffer
{
    var idx:Int = 0
    var buf:MTLBuffer? = nil
    
    init(_ idx:Int, buf:UnsafePointer<Void>, length:Int)
    {
        self.idx = idx
        self.buf = self.alloc(buf, length: length)
    }

    init(_ idx:Int, nocopy:UnsafeMutablePointer<Void>, length:Int)
    {
        self.idx = idx
        self.buf = self.alloc(nocopy, length: length)
    }
    
    init(_ idx:Int, length:Int)
    {
        self.idx = idx
        self.buf = self.alloc(length)
    }
    
    func update(mem:UnsafePointer<Void>, length:Int)
    {
        memcpy( self.buf!.contents(), mem, length )
    }
    
    private func alloc(buf:UnsafePointer<Void>, length:Int) -> MTLBuffer
    {
        return CAIMMetal.device.newBufferWithBytes(buf, length: length, options: .OptionCPUCacheModeDefault)
    }
    
    private func alloc(length:Int) -> MTLBuffer
    {
        return CAIMMetal.device.newBufferWithLength(length, options: .OptionCPUCacheModeDefault)
    }
    
    private func nocopy(buf:UnsafeMutablePointer<Void>, length:Int) -> MTLBuffer
    {
        return CAIMMetal.device.newBufferWithBytesNoCopy(buf, length: length, options: .OptionCPUCacheModeDefault, deallocator: nil)
    }
}

