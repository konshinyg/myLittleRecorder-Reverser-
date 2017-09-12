//
//  ViewController.swift
//  myLittleRecorder
//
//  Created by Core on 23.07.17.
//  Copyright © 2017 Cornelius. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var recButtonOutlet: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    var swiftBlogs = [Int]()
    var names = [String]()
    var recArray = [String : URL]()
    var isPlaying = false
    var url = URL(fileURLWithPath: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recButtonOutlet.setImage(UIImage(named: "rec.png"), for: UIControlState.normal)
    }
    
    @IBAction func recButton(_ sender: UIButton) {

        // press to start rec
        if audioRecorder == nil {
            recButtonOutlet.setImage(UIImage(named: "stop.png"), for: UIControlState.normal)
            print("start recButton")
            startRec()
            return
        }
            
        // press to start play
        if audioRecorder != nil  && !audioRecorder.isRecording && !isPlaying {
            print("start playButton")
            recButtonOutlet.setImage(UIImage(named: "stop.png"), for: UIControlState.normal)
            isPlaying = true
            makeItReverse()
            startPlay()
            return
        }
            
        // press to start stop
        if  audioRecorder.isRecording || isPlaying {
            print("start stopButton")
            recButtonOutlet.setImage(UIImage(named: "play.png"), for: UIControlState.normal)
            startStop()
            return
        }
    }
    
    func startRec() {
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! audioSession.setActive(true)
        print("setActive on")
        let documents = try! FileManager.default.url(for: .documentDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
        let dataURL = documents.appendingPathComponent("recordTest_" + "\(swiftBlogs.count)" + ".m4a")
        swiftBlogs.append(swiftBlogs.count)
        let dataPath = dataURL.path
        url = NSURL.fileURL(withPath: dataPath as String)
        let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                              AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                              AVNumberOfChannelsKey : NSNumber(value: 1),
                              AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]
        print("url : \(url)")
        try! audioRecorder = AVAudioRecorder(url:url, settings: recordSettings)
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        print("record success!")
    }
    
    func startPlay() {
        if (!audioRecorder.isRecording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer.play()
            } catch {
            }
        }
    }
    
    func startStop() {
        audioRecorder.stop()
        if isPlaying {
            audioPlayer.stop()
            isPlaying = false
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            print("setActive off")
        } catch {
        }
    }
    
    func makeItReverse() {
        
    }
}

