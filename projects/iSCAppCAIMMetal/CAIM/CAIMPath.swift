//
// CAIMPath.swift
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

func CAIMBundle(file_path:String) -> String?
{
    let path:String! = Bundle.main.resourcePath
    return path! + "/" + file_path
}
