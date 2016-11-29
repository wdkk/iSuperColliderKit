//
//  CAIMMetalBuffer.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/13.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation
import Metal

class CAIMMetalBuffer
{
    var idx:Int = 0
    var buf:MTLBuffer? = nil
    
    init(_ idx:Int, buf:UnsafeRawPointer, length:Int)
    {
        self.idx = idx
        self.buf = self.alloc(buf, length: length)
    }

    init(_ idx:Int, nocopy:UnsafeMutableRawPointer, length:Int)
    {
        self.idx = idx
        self.buf = self.alloc(nocopy, length: length)
    }
    
    init(_ idx:Int, length:Int)
    {
        self.idx = idx
        self.buf = self.alloc(length)
    }
    
    func update(_ mem:UnsafeRawPointer, length:Int)
    {
        memcpy( self.buf!.contents(), mem, length )
    }
    
    private func alloc(_ buf:UnsafeRawPointer, length:Int) -> MTLBuffer
    {
        return CAIMMetal.device.makeBuffer(bytes: buf, length: length, options: .storageModeShared )
    }
    
    private func alloc(_ length:Int) -> MTLBuffer
    {
        return CAIMMetal.device.makeBuffer(length: length, options: .storageModeShared )
    }
    
    private func nocopy(_ buf:UnsafeMutableRawPointer, length:Int) -> MTLBuffer
    {
        return CAIMMetal.device.makeBuffer(bytesNoCopy: buf, length: length, options: .storageModeShared, deallocator: nil)
    }
}

