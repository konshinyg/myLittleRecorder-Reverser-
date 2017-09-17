
import UIKit
import AVFoundation

var recordTracks = [Tracks]()

class ViewController: UIViewController {
    
    @IBOutlet weak var recButtonOutlet: UIButton!
    @IBOutlet weak var removeAllButton: UIButton!
    @IBOutlet weak var toTrackListButton: UIBarButtonItem!
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    var swiftBlogs = [Int]()
    var names = [String]()
    var recArray = [String : URL]()
    var isPlaying = false
    var url = URL(fileURLWithPath: "")
    var urlReversed = URL(fileURLWithPath: "")
    var timer = Timer()
    var cell = recCell()
    
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
            startPlay(urlReversed: urlReversed)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                         selector: #selector(audioPlayerDidFinishPlaying),
                                         userInfo: nil,
                                         repeats: true)
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
    
    // MARK: -- StartRec, StartPlay, StartStop functions
    func startRec() {
        toTrackListButton.isEnabled = false
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! audioSession.setActive(true)
        let documents = try! FileManager.default.url(for: .documentDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
        let dataURL = documents.appendingPathComponent("recordTest_" + "\(swiftBlogs.count)" + ".wav")
        let dataURLReversed = documents.appendingPathComponent("recordTest_" + "\(recordTracks.count)" + "_reversed.wav")
        swiftBlogs.append(swiftBlogs.count)
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
        print("record success!")
    }
    
    func startPlay(urlReversed: URL) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: urlReversed)
            audioPlayer.play()
        } catch {
        }
    }
    
    func startStop() {
        audioRecorder.stop()
        if isPlaying {
            audioPlayer.stop()
            isPlaying = false
        } else {
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
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
        }
        timer.invalidate()
        toTrackListButton.isEnabled = true
    }
    
    // MARK: -- remove all tracks method
    @IBAction func removeAllRecsPressed(_ sender: UIButton) {
/*        if urlData.recordings.count != 0 {
            urlData.removeAllRecords()
            recButtonOutlet.setImage(UIImage(named: "rec.png"), for: UIControlState.normal)
            audioRecorder = nil
            urlData.listRecordings()
            swiftBlogs.removeAll()
        } */
    }
    
    // MARK: -- audioPlayerDidFinishPlaying
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if !audioPlayer.isPlaying {
            print("stop because of playing finish")
            recButtonOutlet.setImage(UIImage(named: "play.png"), for: UIControlState.normal)
            startStop()
        }
    }
    
    // MARK: -- Reverse function
    func makeItReverse() -> URL {
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

