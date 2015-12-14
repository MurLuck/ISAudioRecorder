//
//  ISAudioRecorderViewControllerDelegate.swift
//  TextVoice
//
//  Created by VSquare on 07/12/2015.
//  Copyright © 2015 VSquare. All rights reserved.
//

import Foundation
protocol ISAudioRecorderViewDelegate{
    func ISAudioRecorderViewWillDismiss(fileName:String,audioDuration:Int)
}