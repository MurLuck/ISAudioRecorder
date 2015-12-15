//
//  ISAudioRecorderViewController.swift
//  TextVoice
//
//  Created by VSquare on 07/12/2015.
//  Copyright © 2015 VSquare. All rights reserved.
//

import Foundation
import AVFoundation

public enum SCSiriWaveformViewInputType{
    case Recorder
    case Player
}

class ISAudioRecorderViewController: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------//
    //----------------------------------------------------------     Class Variabls     ---------------------------------------------------------------//
    //-------------------------------------------------------------------------------------------------------------------------------------------------//
    
    ///delegate that pass the data to parent controller
    var recorderDelegate:ISAudioRecorderViewDelegate?
    
    ///blure effect style (ExtraLight,light,Dark) - default is Dark
    var blurEffectType:UIBlurEffectStyle?
    
    ///left UIBarButtonItem Label - default is Cancel
    var leftToolBarLabelText:String?
    
    ///right UIBarButtonItem Label - default is Send
    var rightToolBarLabelText:String?
    
    ///recorder limit time - default is 30 secend (00:30)
    var recorderLimitTime:Double?
    
    ///the tool bar color you desire - default is darkGrayColor
    var toolBarTintColor:UIColor?
    
    ///the tool bar color you desire - default is whiteColor
    var timeLimitLabelColor:UIColor?
    
//------------------------------------------------------------------------//
//                              Private Vars                              //
//------------------------------------------------------------------------//
    
    //the toolBar that appears at the bottom
    private var toolBar:UIToolbar!
    
    //the visual time for record and play sound
    private var progerssCicle:CircleProgressView!
    
    //bool indentifing if its recording
    private var isRecording = false
    
    //bool indentifing if its playing
    private var isPlaying = false
    
    //wave visualizer
    private var waveView:SCSiriWaveformView!
    
    //wave type if its record or player
    private var waveViewInputType:SCSiriWaveformViewInputType!
    
    //recorder instansce
    private var recorder:AVAudioRecorder!
    
    //player instansce
    private var player:AVAudioPlayer!
    
    //the record audio file path
    private var soundFileURL:NSURL!
    
    //looper for wave visualizer
    private var displayLink:CADisplayLink!
    
    //the parent view controller that called theis class
    private var testParentViewController:UIViewController!
    
    //play btn for playing the audio recorded
    private var playBtn:UIButton!
    
    //stop btn for stopping the audio that are playing
    private var stopBtn:UIButton!
    
    //UIButton for record that go to uibarbuttonitem
    private var recorderImgBtn:UIButton!
    
    //the file name wich will be passed to parent viewcontroller
    private var fileName:String!
    
    //the looper for progressCicle
    private var meterTimer:NSTimer!
    
    //the send button in the toolBar that isnt clickAble until you record something
    private var rightToolBarItem:UIBarButtonItem!
    
    //the cancel button in the toolBar wich dismiss the recorderviewcontroller
    private var leftToolBarItem:UIBarButtonItem!
    
    //the background blur
    private var blurView: UIVisualEffectView!
    
//-------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------    Super Class Functions    ------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------//
    
//------------------------------------------------------------------------//
    override func viewDidLoad() {
//------------------------------------------------------------------------//
        super.viewDidLoad()
    }
    
//------------------------------------------------------------------------//
    override func viewWillAppear(animated: Bool) {
//------------------------------------------------------------------------//
        super.viewWillAppear(true)
    }
    
//------------------------------------------------------------------------//
    override func viewWillDisappear(animated: Bool) {
//------------------------------------------------------------------------//
        super.viewWillDisappear(true)
    }
    
//------------------------------------------------------------------------//
    override func didReceiveMemoryWarning() {
//------------------------------------------------------------------------//
        super.didReceiveMemoryWarning()
    }
    
//-------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------     Class Functions    ---------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------//
    
//------------------------------------------------------------------------//
    func prepareViewForLoading(parentViewController:UIViewController){
//------------------------------------------------------------------------//
        self.testParentViewController = parentViewController
        if let navBarHeight = parentViewController.navigationController?.navigationBar.frame.height{
            self.view.frame = CGRectMake(parentViewController.view.bounds.origin.x, parentViewController.view.bounds.origin.y, parentViewController.view.bounds.width, parentViewController.view.bounds.height + navBarHeight + 20)
        }else{
            self.view.frame = parentViewController.view.bounds
        }
        
        self.view.alpha = 0
        if let nav = parentViewController.navigationController{
            nav.addChildViewController(self)
            nav.view.addSubview(self.view)
        }else{
            parentViewController.addChildViewController(self)
            parentViewController.view.addSubview(self.view)
        }
        prepareRecorderView()
    }
    
//------------------------------------------------------------------------//
    private func prepareRecorderView(){
//------------------------------------------------------------------------//
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: .Dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.alpha = 1
        self.view.addSubview(blurView)
        
        toolBarSetUp()
        setUpProgressCicle()
        
        let waveHeight = (self.view.frame.height - progerssCicle.frame.height - toolBar.frame.height) - 50
        let ypos = progerssCicle.frame.maxY + 10
        waveView = SCSiriWaveformView(frame: CGRectMake(0, ypos , self.view.frame.width, waveHeight))
        waveView.backgroundColor = UIColor.clearColor()
        waveView.primaryWaveLineWidth = 3.0
        waveView.waveColor = UIColor(red: 42/255, green: 169/255, blue: 255/255, alpha: 1.0)
        waveView.secondaryWaveLineWidth = 1.0
        waveView.updateWithLevel(0.0)
        
        self.view.addSubview(progerssCicle)
        self.view.addSubview(waveView)
        
        displayLink = CADisplayLink(target: self, selector: "updateMeters")
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        loadUserSettings()
        loadRecordView()
    }
    
//------------------------------------------------------------------------//
    private func toolBarSetUp(){
//------------------------------------------------------------------------//
        toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.height - 48, self.view.frame.width, 48))
        toolBar.barTintColor = UIColor.darkGrayColor()
        self.view.addSubview(toolBar)
        
        rightToolBarItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: "sendBarButtonOnClick")
        rightToolBarItem.tintColor = UIColor.whiteColor()
        rightToolBarItem.enabled = false
        
        let flexibleBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        leftToolBarItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelBarButtonOnClick")
        leftToolBarItem.tintColor = UIColor.whiteColor()
        
        let imgViewRecorder = UIImage(named: "audio_record.png")
        recorderImgBtn = UIButton(type: .Custom)
        recorderImgBtn.frame = CGRectMake(0, 0, 100, 100)
        recorderImgBtn.setImage(imgViewRecorder, forState: UIControlState.Normal)
        recorderImgBtn.addTarget(self, action: "recordAudioOnClick", forControlEvents: UIControlEvents.TouchDown)
        recorderImgBtn.addTarget(self, action: "recordAudioOnClickRealease", forControlEvents: UIControlEvents.TouchUpInside)
        recorderImgBtn.addTarget(self, action: "recordAudioOnClickRealease", forControlEvents: UIControlEvents.TouchDragOutside)
        recorderImgBtn.addTarget(self, action: "recordAudioOnClickRealease", forControlEvents: UIControlEvents.TouchDragExit)
   
        let midlleBarButtonItem = UIBarButtonItem()
        midlleBarButtonItem.customView = recorderImgBtn
        
        let barItems = [leftToolBarItem!,flexibleBarButtonItem,midlleBarButtonItem,flexibleBarButtonItem,rightToolBarItem!]
        
        toolBar.setItems(barItems, animated: false)
    }
    
//------------------------------------------------------------------------//
    private func setUpProgressCicle(){
//------------------------------------------------------------------------//
        let sHeight = UIScreen.mainScreen().bounds.size.height
        
        playBtn = UIButton(type: UIButtonType.Custom)
        stopBtn = UIButton(type: UIButtonType.Custom)
        
        if sHeight <= 667{
            progerssCicle = CircleProgressView(frame: CGRectMake(self.view.frame.width/2 - 58, 40, 120, 120))
            
            var xpos = progerssCicle.frame.maxX + (self.view.frame.width - progerssCicle.frame.maxX)/2 - 28
            let btnYpos = progerssCicle.frame.midY - 23
            playBtn.frame = CGRectMake(xpos, btnYpos, 46, 46)
            
            xpos = (progerssCicle.frame.minX)/2 - 23
            stopBtn.frame = CGRectMake(xpos, btnYpos, 46, 46)
            
        }else if sHeight >= 736{
            progerssCicle = CircleProgressView(frame: CGRectMake(self.view.frame.width/2 - 88, 40, 180, 180))
            
            var xpos = progerssCicle.frame.maxX + (self.view.frame.width - progerssCicle.frame.maxX)/2 - 28
            let btnYpos = progerssCicle.frame.midY - 28
            playBtn.frame = CGRectMake(xpos, btnYpos, 56, 56)
            
            xpos = (progerssCicle.frame.minX)/2 - 28
            stopBtn.frame = CGRectMake(xpos, btnYpos, 56, 56)
        }
        
        progerssCicle.status = "                       "
        progerssCicle.timeLimit = 30
        progerssCicle.elapsedTime = 0

        playBtn.setImage(UIImage(named: "play.png"), forState: .Normal)
        playBtn.enabled = false
        playBtn.addTarget(self, action: "playRecord", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(playBtn)

        stopBtn.setImage(UIImage(named: "stop.png"), forState: .Normal)
        stopBtn.enabled = false
        stopBtn.addTarget(self, action: "stopRecord", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(stopBtn)

    }
    
    
//------------------------------------------------------------------------//
    private func loadRecordView(){
//------------------------------------------------------------------------//
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.alpha = 1
        })
    }
   
//------------------------------------------------------------------------//
    private func loadUserSettings(){
//------------------------------------------------------------------------//

      
        if let blur = blurEffectType{
            
            blurView.effect = UIBlurEffect(style: blur)
        
            switch blur{
            case UIBlurEffectStyle.Dark:
                break
            case UIBlurEffectStyle.Light:
                toolBar.barTintColor = UIColor.whiteColor()
                progerssCicle.progressLabel.textColor = UIColor.grayColor()
                leftToolBarItem.tintColor = UIColor.grayColor()
                rightToolBarItem.tintColor = UIColor.grayColor()
                break
            case UIBlurEffectStyle.ExtraLight:
                toolBar.barTintColor = UIColor.whiteColor()
                progerssCicle.progressLabel.textColor = UIColor.grayColor()
                leftToolBarItem.tintColor = UIColor.grayColor()
                rightToolBarItem.tintColor = UIColor.grayColor()
                break
            }
        }
        
        if let leftbarButtonTitle = leftToolBarLabelText{
            leftToolBarItem.title = leftbarButtonTitle
        }
        
        if let rightbarButtonTitle = rightToolBarLabelText{
            rightToolBarItem.title = rightbarButtonTitle
        }
        
        if let recorderTimelimit = recorderLimitTime{
            progerssCicle.timeLimit = recorderTimelimit
            progerssCicle.elapsedTime = 0
        }
        
        if let tintColor = toolBarTintColor {
            toolBar.barTintColor = tintColor
        }
        
        if let ciclelabelColor = timeLimitLabelColor {
            progerssCicle.progressLabel.textColor = ciclelabelColor
        }
    }
    
//------------------------------------------------------------------------//
    func updateMeters(){
//------------------------------------------------------------------------//
        var normalizedValue:Float = 0.0
        switch waveViewInputType{
        case SCSiriWaveformViewInputType.Recorder?:
            recorder.updateMeters()
            normalizedValue = normalizedPowerLevelFromDecibels(recorder.averagePowerForChannel(0))
            break
        case SCSiriWaveformViewInputType.Player?:
            player.updateMeters()
            normalizedValue = normalizedPowerLevelFromDecibels(player.averagePowerForChannel(0))
            break
        default:
            break
        }
        
        waveView.updateWithLevel(CGFloat(normalizedValue))
    }
    
//------------------------------------------------------------------------//
    private func normalizedPowerLevelFromDecibels(decibels:Float) -> Float{
//------------------------------------------------------------------------//
        if (decibels < -60.0 || decibels == 0.0) {
            return 0.0
        }
        return powf((powf(10.0, 0.05 * decibels) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0)
    }
    
//------------------------------------------------------------------------//
    func updateProgress(){
//------------------------------------------------------------------------//
        if isRecording{
            progerssCicle.elapsedTime = recorder.currentTime
        }else if isPlaying{
            progerssCicle.elapsedTime = player.currentTime
        }
    }
    
//------------------------------------------------------------------------//
    private func runMeterTimer(){
//------------------------------------------------------------------------//
        meterTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
    }
    
//-------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------     Button Functions     -------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------//
    
//------------------------------------------------------------------------//
    func recordAudioOnClick(){
//------------------------------------------------------------------------//
        print("Pressed")
        if !isRecording{
            isRecording = true
            playBtn.enabled = false
            if soundFileURL != nil{
                do{
                    try NSFileManager.defaultManager().removeItemAtPath(soundFileURL.path!)
                }catch let error as NSError{
                    print(error)
                }
            }
            
            progerssCicle.status = "Recording"
            recorderLimitTime != nil ? (progerssCicle.timeLimit = recorderLimitTime!) : (progerssCicle.timeLimit = 30)
            progerssCicle.elapsedTime = 0
            
            waveViewInputType = SCSiriWaveformViewInputType.Recorder
            setUpRecorder()
            
            do{
                try AVAudioSession.sharedInstance().setActive(true)
                recorder.record()
                runMeterTimer()
            }catch let error as NSError{
                print(error)
            }
        }
    }
    
//------------------------------------------------------------------------//
    func recordAudioOnClickRealease(){
//------------------------------------------------------------------------//
        if isRecording{
            isRecording = false
            rightToolBarItem.enabled = true
            progerssCicle.status = "Finished"
            progerssCicle.elapsedTime = recorder.currentTime
            recorder.stop()
            meterTimer.invalidate()

            playBtn.enabled = true
            waveViewInputType = nil
            setUpPlayer()
        }
    }
    
//------------------------------------------------------------------------//
    func cancelBarButtonOnClick(){
//------------------------------------------------------------------------//
        
        progerssCicle.removeFromSuperview()
        toolBar.removeFromSuperview()
        waveView.removeFromSuperview()
        stopBtn.removeFromSuperview()
        playBtn.removeFromSuperview()
        
        if displayLink != nil{
            displayLink.invalidate()
        }
        
        if meterTimer != nil{
            meterTimer.invalidate()
        }
        
        waveView = nil
        toolBar = nil
        progerssCicle = nil
        recorder = nil
        playBtn = nil
        stopBtn = nil
        player = nil
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.alpha = 0
            }) { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                self.dismissViewControllerAnimated(false,completion: nil)
        }
    }
    
//------------------------------------------------------------------------//
    func sendBarButtonOnClick(){
//------------------------------------------------------------------------//
        if player != nil{
            print(player.duration)
            recorderDelegate?.ISAudioRecorderViewWillDismiss(fileName, audioDuration:Int(player.duration))
        }else{
            recorderDelegate?.ISAudioRecorderViewWillDismiss(fileName, audioDuration:Int(0))
        }
        cancelBarButtonOnClick()
    }
    
//------------------------------------------------------------------------//
    func playRecord(){
//------------------------------------------------------------------------//
        if !isPlaying && player != nil{
            isPlaying = true
            
            progerssCicle.timeLimit = player.duration
            progerssCicle.elapsedTime = 0
            progerssCicle.status = "Playing"
            
            stopBtn.enabled = true
            playBtn.enabled = false
            recorderImgBtn.enabled = false
            waveViewInputType = SCSiriWaveformViewInputType.Player

            player.play()
            runMeterTimer()
        }
    }
    
//------------------------------------------------------------------------//
    func stopRecord(){
//------------------------------------------------------------------------//
        if isPlaying{
            isPlaying = false
            player.stop()
            
            progerssCicle.status = "Stoped"
            progerssCicle.timeLimit = player.duration
            progerssCicle.elapsedTime = player.duration

            player.currentTime = 0
            
            playBtn.enabled = true
            stopBtn.enabled = false
            recorderImgBtn.enabled = true
            
            waveViewInputType = nil
            meterTimer.invalidate()
        }
    }
    
    
//-------------------------------------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------     AV Player & Recorder     ------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------//
    
//------------------------------------------------------------------------//
    private func setUpRecorder(){
//------------------------------------------------------------------------//
        getRecorderFileURLPath()
        
        print(soundFileURL)
        let recorderSettings:[String:AnyObject] = [AVFormatIDKey : NSNumber(unsignedInt: kAudioFormatMPEG4AAC), AVSampleRateKey : 44100.0 as NSNumber, AVNumberOfChannelsKey : 2 as NSNumber, AVEncoderAudioQualityKey : AVAudioQuality.High.rawValue as NSNumber,AVEncoderBitRateKey : 320000 as NSNumber]
        
        do {
            recorder = try AVAudioRecorder(URL: soundFileURL, settings: recorderSettings)
            recorderLimitTime != nil ? recorder.recordForDuration(recorderLimitTime!) : recorder.recordForDuration(30.0)
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord()
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        }catch let error as NSError{
            print(error)
        }
    }
    
//------------------------------------------------------------------------//
    private func getRecorderFileURLPath(){
//------------------------------------------------------------------------//
        let format = NSDateFormatter()
        format.dateFormat = "YYYY.MM.dd-hh.mm.ss"
        
        //only if u have navigationController
//        if let parentView = self.parentViewController?.childViewControllers[1]{
//            if let title = parentView.title{
//                let currentFileName = "record_\(title)_\(format.stringFromDate(NSDate())).m4a"
//                fileName = currentFileName
//                let documentDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
//                self.soundFileURL = documentDirectory.URLByAppendingPathComponent(currentFileName)
//            }
//        }else{
        
        let currentFileName = "record_\(format.stringFromDate(NSDate())).m4a"
        let documentDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        soundFileURL = documentDirectory.URLByAppendingPathComponent(currentFileName)
        fileName = currentFileName

//        }
    }
    
//------------------------------------------------------------------------//
    private func setUpPlayer(){
//------------------------------------------------------------------------//
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            player = try AVAudioPlayer(contentsOfURL: recorder.url)
            player.delegate = self
            player.meteringEnabled = true
            player.prepareToPlay()
        }catch let error as NSError{
            print(error)
        }
    }
    
//------------------------------------------------------------------------------------//
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
//------------------------------------------------------------------------------------//
        self.stopRecord()
    }
    
//--------------------------------------------------------------------------------------------//
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
//--------------------------------------------------------------------------------------------//
        self.recordAudioOnClickRealease()
    }
}