
import UIKit
import AVFoundation

class RecordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    let cellName = ["record#1", "record#2", "record#3", "record#4", "record#5"]
    var player: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordTracks.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recCell = tableView.dequeueReusableCell(withIdentifier: "recCell", for: indexPath)
        recCell.textLabel?.text = (recordTracks[indexPath.row]).value(forKey: "name") as? String
        return recCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentTrack = (recordTracks[indexPath.row]).value(forKey: "rectrack") as! String
        let currentTrackURL = URL(string: currentTrack)
        playIt(url: currentTrackURL!)
        
    }
    
    func playIt(url: URL) {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if editingStyle == .delete {
            
            // get path of reversed track for removing
            let currentTrack = (recordTracks[indexPath.row]).value(forKey: "rectrack") as! String
            let currentTrackURL = URL(string: currentTrack)
            
            // delete track URL from Core Data context
            context.delete(recordTracks[indexPath.row])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                try context.fetch(Tracks.fetchRequest())
            } catch {
                print("\(error). Mistake came from tableView commit editingStyle")
            }
            
            // remove reversed track after track's URL was deleted from Core Data
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: currentTrackURL!)
            } catch {
                print(error.localizedDescription)
                print("error deleting recording")
            }
        }
        tableView.reloadData()
    }
}
