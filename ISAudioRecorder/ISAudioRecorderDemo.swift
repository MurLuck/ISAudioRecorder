//
//  ViewController.swift
//  ISAudioRecorder
//
//  Created by VSquare on 14/12/2015.
//  Copyright © 2015 IgorSokolovsky. All rights reserved.
//

import UIKit
import AVFoundation

class ISAudioRecorderDemo: UIViewController,ISAudioRecorderViewDelegate {
    
    var audioPlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openRecordController(sender: UIButton) {
        let rvc = ISAudioRecorderViewController()
        rvc.blurEffectType = UIBlurEffectStyle.Light
       // rvc.recorderLimitTime = 40
        rvc.prepareViewForLoading(self)
        rvc.recorderDelegate = self
    }
    
    
    @IBAction func playAudio(sender: AnyObject) {
        if audioPlayer != nil && !audioPlayer.playing{
            audioPlayer.play()
        }else if audioPlayer != nil && audioPlayer.playing{
            audioPlayer.stop()
        }else{
            print("Damn Man thers a problem need to learn Swift beter ")
        }
    }
    
    func ISAudioRecorderViewWillDismiss(fileName: String, audioDuration: Int) {
        print(fileName)
        print(audioDuration)
        
        let docDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        let url = docDir.URLByAppendingPathComponent(fileName)
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
            audioPlayer.prepareToPlay() // for AVAudioPlayerDelegate
        }catch let error as NSError{
            print(error)
        }
        
    }
}

