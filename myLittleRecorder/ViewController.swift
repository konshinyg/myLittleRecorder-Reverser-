
import UIKit
import AVFoundation

var recordTracks = [Tracks]()

class ViewController: UIViewController {
    
    @IBOutlet weak var recButtonOutlet: UIButton!
    @IBOutlet weak var toTrackListButton: UIBarButtonItem!
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    
    var isPlaying = false
    var url = URL(fileURLWithPath: "")
    var urlReversed = URL(fileURLWithPath: "")
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recButtonOutlet.setImage(UIImage(named: "rec.png"), for: UIControlState.normal)
    }
    
    @IBAction func recButton(_ sender: UIButton) {
        
        // press to start rec
        if audioRecorder == nil {
            recButtonOutlet.setImage(UIImage(named: "stop.png"), for: UIControlState.normal)
            print("recButton pressed")
            toTrackListButton.isEnabled = false
            startRec()
            return
        }
        
        // press to start stop
        if  audioRecorder.isRecording || isPlaying {
            print("stopButton pressed")
            recButtonOutlet.setImage(UIImage(named: "rec.png"), for: UIControlState.normal)
            recStop()
            return
        }
    }
    
    // MARK: -- StartRec, StartPlay, StartStop functions
    func startRec() {
        print("\(#function)")
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! audioSession.setActive(true)
        let documents = try! FileManager.default.url(for: .documentDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
        let dataURL = documents.appendingPathComponent("recordTest_" + "\(recordTracks.count)" + ".wav")
        let dataURLReversed = documents.appendingPathComponent("recordTest_" + "\(recordTracks.count)" + "_reversed.wav")
        let dataPath = dataURL.path
        let dataPathReversed = dataURLReversed.path
        url = NSURL.fileURL(withPath: dataPath as String)
        urlReversed = NSURL.fileURL(withPath: dataPathReversed as String)
        let recordSettings:[String : Any] = [AVSampleRateKey : 16000,
                                             AVFormatIDKey : kAudioFormatLinearPCM,
                                             AVNumberOfChannelsKey : 1,
                                             AVEncoderAudioQualityKey : AVAudioQuality.low.hashValue]
        print("url : \(url)")
        try! audioRecorder = AVAudioRecorder(url:url, settings: recordSettings)
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func startPlay(urlReversed: URL) {
        print("\(#function)")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(audioPlayerDidFinishPlaying),
                                     userInfo: nil,
                                     repeats: true)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: urlReversed)
            isPlaying = true
            recButtonOutlet.isEnabled = false
            audioPlayer.volume = 2.0
            audioPlayer.play()
        } catch {
        }
    }
    
    func playStop() {
        print("\(#function)")
        audioPlayer.stop()
        isPlaying = false
        timer.invalidate()
    }
    
    func recStop() {
        print("\(#function)")
        if isPlaying {
            playStop()
        }
        if audioRecorder.isRecording {
            audioRecorder.stop()
            audioRecorder = nil
            
            // making reversed track
            urlReversed = makeItReverse()
            saveTrackURL(url: urlReversed)
            print("reversed file: \(urlReversed.absoluteString)")
            
            // remove direct track after reversed was made
            print("removing file at \(url.absoluteString)")
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
                print("error deleting recording")
            }
            startPlay(urlReversed: urlReversed)
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {}
        
        recButtonOutlet.isEnabled = true
        toTrackListButton.isEnabled = true
    }
    
    // MARK: -- audioPlayerDidFinishPlaying
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        print("\(#function)")
        if !audioPlayer.isPlaying {
            print("stop because of playing finish")
            recButtonOutlet.setImage(UIImage(named: "play.png"), for: UIControlState.normal)
            playStop()
        }
    }
    
    // MARK: -- Reverse function
    func makeItReverse() -> URL {
        print("\(#function)")
        let forwardAudioURL = url
        let reversedAudioURL = urlReversed
        
        // Load forward audio into originalAudioFile
        var originalAudioFile: AudioFileID? = nil
        let possibleError1 = AudioFileOpenURL(forwardAudioURL as CFURL,
                                              AudioFilePermissions.readPermission,
                                              0,
                                              &originalAudioFile)
        
        // Load the size in bytes of the original audio into originalAudioSize variable
        var originalAudioSize: Int64 = 0
        var propertySize: UInt32 = 8
        let possibleError2 = AudioFileGetProperty(originalAudioFile!,
                                                  kAudioFilePropertyAudioDataByteCount,
                                                  &propertySize,
                                                  &originalAudioSize)
        
        if possibleError1 != 0 || possibleError2 != 0 {
            // Handle errors if you want
        }
        
        // Set up file that the reversed audio will be loaded into
        var reversedAudioFile: AudioFileID? = nil
        var format = AudioStreamBasicDescription()
        format.mSampleRate = 16000
        format.mFormatID = kAudioFormatLinearPCM
        format.mChannelsPerFrame = 1
        format.mFramesPerPacket = 1
        format.mBitsPerChannel = 16
        format.mBytesPerPacket = 2
        format.mBytesPerFrame = 2
        AudioFileCreateWithURL(reversedAudioURL as CFURL,
                               kAudioFileCAFType,
                               &format,
                               AudioFileFlags.eraseFile,
                               &reversedAudioFile)
        
        // Read data into the reversedAudioFile
        var readPoint: Int64 = originalAudioSize
        var writePoint: Int64 = 0
        var buffer: Int16 = 0
        while readPoint > 0 {
            var bytesToRead: UInt32 = 2;
            AudioFileReadBytes(originalAudioFile!,
                               false,
                               readPoint,
                               &bytesToRead,
                               &buffer)
            AudioFileWriteBytes(reversedAudioFile!,
                                false,
                                writePoint,
                                &bytesToRead,
                                &buffer)
            writePoint += 2
            readPoint -= 2
        }
        AudioFileClose(originalAudioFile!)
        AudioFileClose(reversedAudioFile!)
        
        return reversedAudioURL
    }
    
    // MARK: -- saveTrack method
    func saveTrackURL(url: URL) {
        print("\(#function)")
        let AudioURLPath = String(describing: url)
        let context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        let track = Tracks.init(entity: Tracks.entity(), insertInto: context)
        track.setValue(AudioURLPath, forKey: "rectrack")
        
        let trackName = "record#" + "\(recordTracks.count + 1)"
        track.setValue(trackName, forKey: "name")
        
        do {
            try context.save()
            recordTracks.append(track)
        } catch {
            print("\(error). Mistake came from saveTrack method")
        }
    }
    
    // MARK: -- viewWillAppear method override
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let result = try context.fetch(Tracks.fetchRequest())
            recordTracks = result as! [Tracks]
        } catch {
            print("\(error). Mistake came from viewWillAppear")
        }
    }
}

