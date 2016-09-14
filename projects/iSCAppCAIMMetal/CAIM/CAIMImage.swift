//
// CAIMImage.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import Foundation

class CAIMImage
{
    private var img:CAIMImageCPtr = nil
 
    var width:Int { return CAIMImageWidth(img) }
    var height:Int { return CAIMImageHeight(img) }
    var memory:CAIMMemory { return CAIMImageMemory(img) }
    var memory_size:Int { return CAIMImageMemorySize(img) }
    var matrix:CAIMColorMatrix { return CAIMImageMatrix(img) }
    var matrix8:CAIMColor8Matrix { return CAIMImageMatrix8(img) }
    var depth:CAIMDepth { return CAIMImageDepth(img) }
    var scale:Float { return Float(CAIMImageRetinaScale(img)) }
    
    init(wid:Int, hgt:Int, depth:CAIMDepth = CAIMDepth.float)
    {
        img = CAIMImageCreate(wid, hgt, depth)
    }
    
    init(path:String, depth:CAIMDepth = CAIMDepth.float)
    {
        img = CAIMImageCreateWithFile(path, depth)
    }
    
    private init(img_clone:CAIMImageCPtr)
    {
        img = CAIMImageClone(img_clone)
    }
    
    deinit
    {
        CAIMImageRelease(img)
    }
    
    func clone(img_src:CAIMImage) -> CAIMImage
    {
        return CAIMImage(img_clone: img_src.img)
    }
    
    func copy(img_src:CAIMImage)
    {
        CAIMImageCopy(img_src.img, self.img)
    }
    
    func resize(wid:Int, hgt:Int)
    {
        CAIMImageResize(img, wid, hgt)
    }
    
    func loadFile(path:String) -> Bool
    {
        return (CAIMImageLoadFile(img, path) == 1)
    }
    
    func saveToAlbum() -> Bool
    {
        return (CAIMImageSaveFileToAlbum(img) == 1)
    }    
}