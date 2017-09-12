//
//  ViewController.swift
//  myLittleRecorder
//
//  Created by Core on 23.07.17.
//  Copyright © 2017 Cornelius. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var recButtonOutlet: UIButton!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    
    @IBAction func recButton(_ sender: UIButton) {
        if audioRecorder.isRecording {
            print("start stopButton")
            audioRecorder.stop()
            recButtonOutlet.setImage(#imageLiteral(resourceName: "rec.png"), for: UIControlState.normal) // set to recordButton image
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch {
            }
            let alert = UIAlertController(title: "New name", message: "Add a new name", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "Save", style: .default) {
                (action: UIAlertAction!) -> Void in
                let textField = alert.textFields![0]
                self.names.append(textField.text!)
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
                (action: UIAlertAction!) -> Void in
            }
            alert.addTextField {
                (textField: UITextField!) -> Void in
            }
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
        else {
            recButtonOutlet.setImage(#imageLiteral(resourceName: "stop.png"), for: UIControlState.normal) // set to stopButton image
            try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try! audioSession.setActive(true)
            let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let dataURL = documents.appendingPathComponent("recordTest_" + "\(swiftBlogs.count)" + ".m4a")
            swiftBlogs.append(swiftBlogs.count)
            let dataPath = dataURL.path
            let url = NSURL.fileURL(withPath: dataPath as String)
            let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                                  AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                                  AVNumberOfChannelsKey : NSNumber(value: 1),
                                  AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]
            print("url : \(url)")
            try! audioRecorder = AVAudioRecorder(url:url, settings: recordSettings)
            audioRecorder.record()

            print("record success!")
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var swiftBlogs = [Int]()
    var names = [String]()
    var recArray = [String : URL]()
    
    func reverseAudio() {
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recCell")
        cell?.textLabel!.text = "Record: \(names[indexPath.row])"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if (!audioRecorder.isRecording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer.play()
            } catch {
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        func directoryURL() -> NSURL? {
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = urls[0] as NSURL
            let soundURL = documentDirectory.appendingPathComponent("recordTest_" + "\(swiftBlogs)" + ".m4a")
            return soundURL! as NSURL
        }
        
        let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                              AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                              AVNumberOfChannelsKey : NSNumber(value: 1),
                              AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: directoryURL()! as URL,
                                                settings: recordSettings)
            audioRecorder.prepareToRecord()
        } catch {
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

