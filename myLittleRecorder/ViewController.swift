
import UIKit
import AVFoundation

var recordTracks = [Tracks]()

class ViewController: UIViewController {
    
    @IBOutlet weak var recButtonOutlet: UIButton!
    @IBOutlet weak var toTrackListButton: UIButton!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var recordTimer: UILabel!
    @IBOutlet weak var oneMoreTrackLabel: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var reverseStatusLabel: UILabel!

    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    
    var isPlaying = false
    var url = URL(fileURLWithPath: "")
    var urlReversed = URL(fileURLWithPath: "")
    var timer = Timer()
    var date = ""
    var isReversed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        try! audioSession.setActive(true)
        oneMoreTrackLabel.isEnabled = false
        recButtonOutlet.addTarget(self, action: #selector(makeItReverse), for: .touchUpInside)
        reverseStatusLabel.text = ""
    }
    
    @IBAction func recButton(_ sender: UIButton) {
        
        // press to start rec
        if audioRecorder == nil {
            recButtonOutlet.setImage(UIImage(named: "stop.png"), for: UIControlState.normal)
            toTrackListButton.isEnabled = false
            startRec()
        }
            
        else if audioRecorder != nil && !audioRecorder.isRecording && !isPlaying {
            recButtonOutlet.setImage(UIImage(named: "stop.png"), for: UIControlState.normal)
            reverseStatusLabel.text = ""
            startPlay(urlReversed: urlReversed)
        }
            
            // press to start stop
        else if  audioRecorder.isRecording || isPlaying {
            recStop()
        }
    }
    
    
    // MARK: -- StartRec, StartPlay, StartStop functions
    func startRec() {
        audioSession.requestRecordPermission() {
            [unowned self] granted in
            if granted {
                
                DispatchQueue.main.async {
                    self.setupRecorder()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                                      selector: #selector(self.timerTrackUpdate),
                                                      userInfo: nil,
                                                      repeats: true)
                    self.timerTrackUpdate()
                    self.audioRecorder.record()
                }
            } else {
                print("Permission to record not granted")
            }
        }
        
        if audioSession.recordPermission() == .denied {
            print("permission denied")
        }
    }
    
    func startPlay(urlReversed: URL) {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                     selector: #selector(timerTrackUpdate),
                                     userInfo: nil,
                                     repeats: true)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: urlReversed)
            isPlaying = true
            audioPlayer.volume = 1.0
            audioPlayer.play()
            oneMoreTrackLabel.isEnabled = false
            toTrackListButton.isEnabled = false
        } catch {}
    }
    
    func playStop() {
        audioPlayer.stop()
        isPlaying = false
        timer.invalidate()
        recordTimer.text = "00:00"
        toTrackListButton.isEnabled = true
        oneMoreTrackLabel.isEnabled = true
    }
    
    func recStop() {
        if isPlaying {
            playStop()
        }
        if audioRecorder.isRecording {
            self.audioRecorder.stop()
            isReversed = true
        }
        timer.invalidate()
        recordTimer.text = "00:00"
    }
    
    // MARK: -- setup recorder
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat = "HH-mm-ss"
        date = format.string(from: Date())
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                     appropriateFor: nil, create: true)
        let dataURL = documents.appendingPathComponent("recordTest_" + "\(date)" + ".wav")
        let dataURLReversed = documents.appendingPathComponent("recordTest_" + "\(date)" + "_reversed.wav")
        let dataPath = dataURL.path
        let dataPathReversed = dataURLReversed.path
        url = NSURL.fileURL(withPath: dataPath as String)
        urlReversed = NSURL.fileURL(withPath: dataPathReversed as String)
        let recordSettings:[String : Any] = [AVSampleRateKey : 16000,
                                             AVFormatIDKey : kAudioFormatLinearPCM,
                                             AVNumberOfChannelsKey : 1,
                                             AVEncoderAudioQualityKey : AVAudioQuality.low.hashValue]
        do {
            try audioRecorder = AVAudioRecorder(url:url, settings: recordSettings)
            audioRecorder.prepareToRecord()
        } catch {
            audioRecorder = nil
        }
    }
    
    // MARK: -- oneMoreTrackButtonPressed
    @IBAction func oneMoreTrackButtonPressed(_ sender: UIButton) {
        recButtonOutlet.setImage(UIImage(named: "rec.png"), for: UIControlState.normal)
        oneMoreTrackLabel.isEnabled = false
        audioRecorder = nil
    }
    
    // MARK: -- Reverse function
    func makeItReverse() {
        if isReversed {
            isReversed = false
            let forwardAudioURL = url
            let reversedAudioURL = urlReversed
            
            // Load forward audio into originalAudioFile
            var originalAudioFile: AudioFileID? = nil
            _ = AudioFileOpenURL(forwardAudioURL as CFURL,
                                 AudioFilePermissions.readPermission,
                                 0,
                                 &originalAudioFile)
            
            // Load the size in bytes of the original audio into originalAudioSize variable
            var originalAudioSize: Int64 = 0
            var propertySize: UInt32 = 8
            _ = AudioFileGetProperty(originalAudioFile!,
                                     kAudioFilePropertyAudioDataByteCount,
                                     &propertySize,
                                     &originalAudioSize)

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
            spinner.startAnimating()
            reverseStatusLabel.text = "Подождите, обрабатываю..."
            recButtonOutlet.isEnabled = false
            DispatchQueue.global(qos: .background).async {
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
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.reverseStatusLabel.text = "Готово!"
                    self.recButtonOutlet.isEnabled = true
                    self.recButtonOutlet.setImage(UIImage(named: "play.png"), for: UIControlState.normal)
                    self.oneMoreTrackLabel.isEnabled = true
                    self.toTrackListButton.isEnabled = true
                }
            }

            // saving track to Core Data
            saveTrackURL(url: reversedAudioURL)
            
            // remove direct track after reversed was made
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: url)
            } catch {}
            do {
                try audioSession.setActive(false)
            } catch {}
            
            urlReversed = reversedAudioURL
        }
    }
    
    // MARK: -- saveTrack method
    func saveTrackURL(url: URL) {
        let AudioURLPath = String(describing: url)
        let context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        let track = Tracks.init(entity: Tracks.entity(), insertInto: context)
        track.setValue(AudioURLPath, forKey: "rectrack")
        
        let trackName = "track " + "\(date)"
        track.setValue(trackName, forKey: "name")
        trackNameLabel.text = trackName
        
        do {
            try context.save()
            recordTracks.append(track)
        } catch {}
    }
    
    // MARK: -- timerTrackUpdate
    func timerTrackUpdate() {
        if audioRecorder.isRecording {
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let min = Int(audioRecorder.currentTime / 60)
            let time = String(format: "%02d:%02d", min, sec)
            recordTimer.text = time
        }
        else if isPlaying {
            let sec = Int(audioPlayer.currentTime.truncatingRemainder(dividingBy: 60))
            let min = Int(audioPlayer.currentTime / 60)
            let time = String(format: "%02d:%02d", min, sec)
            recordTimer.text = time
            if !audioPlayer.isPlaying {
                recButtonOutlet.setImage(UIImage(named: "play.png"), for: UIControlState.normal)
                oneMoreTrackLabel.isEnabled = true
                playStop()
            }
        }
    }
    
    // MARK: -- viewWillAppear method override
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let result = try context.fetch(Tracks.fetchRequest())
            recordTracks = result as! [Tracks]
        } catch {}
    }
}

