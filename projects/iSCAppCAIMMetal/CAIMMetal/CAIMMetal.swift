//
//  CAIMMetal.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/14.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

// CAIMMetalで共有利用するdeviceとcommand queueを管理する
// MTLBufferのバッファ確保もこの関数を経由する
class CAIMMetal
{
    private static var _device: MTLDevice!                   // [Reuse] Device
    private static var _command_queue: MTLCommandQueue!      // [Reuse] Command Queue
    
    static var device:MTLDevice! {
        get {
            if(_device == nil) { _device = MTLCreateSystemDefaultDevice() }
            return _device
        }
    }
    
    static var command_queue:MTLCommandQueue! {
        get {
            if(_command_queue == nil) { _command_queue = device.makeCommandQueue() }
            return _command_queue
        }
    }
}

