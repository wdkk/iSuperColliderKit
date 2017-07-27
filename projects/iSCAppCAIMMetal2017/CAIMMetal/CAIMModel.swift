//
// CAIMModel.swift
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


class CAIMModel
{
    fileprivate var _parent:CAIMModel?
    
    var shape:CAIMShape<Any>?
    
    var _matrix:Matrix4x4 = Matrix4x4()
    var matrix:Matrix4x4 {
        return _parent != nil ? _parent!.matrix * _matrix : _matrix
    }
    
    init(_ parent:CAIMModel? = nil) {
        _parent = parent
    }
    
}
