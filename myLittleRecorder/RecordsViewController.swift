
import UIKit
import AVFoundation

class RecordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cellName = ["record#1", "record#2", "record#3", "record#4", "record#5"]
    var player: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        urlData.listRecordings()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlData.recordings.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recCell = tableView.dequeueReusableCell(withIdentifier: "recCell", for: indexPath)
        recCell.textLabel?.text = String(cellName[indexPath.row])
        return recCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(urlData.recordings[indexPath.row]) selected")
        playIt(urlData.recordings[indexPath.row])
    }
    
    func playIt(_ url: URL) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch {
            player = nil
            print("AVAudioPlayer init failed")
        }
    }    
}
