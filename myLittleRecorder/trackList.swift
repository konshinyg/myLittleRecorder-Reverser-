
import Foundation

class trackList {
    var recordings = [URL]()
    
    func listRecordings() {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            recordings = urls.filter( { (name: URL) -> Bool in
                return name.lastPathComponent.hasSuffix("wav")
            })
        } catch {
            print(error.localizedDescription)
            print("something went wrong listing recordings")
        }
    }
    
    // MARK: -- delete the oldest track
    func deleteRecord() {
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: docsDir)
            let recToRemove = files.filter{ $0.hasSuffix("wav") }
        } catch {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }
        
/*        do {
            try FileManager.default.removeItem(at: URL)
        } catch {
            print(error.localizedDescription)
            print("error deleting reversed recording")
        } */
    }
    
    func removeAllRecords() {
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: docsDir)
            var recsToRemove = files.filter( { (name: String) -> Bool in
                return name.hasSuffix("wav")
            })
            for i in 0 ..< recordings.count {
                let path = docsDir + "/" + recsToRemove[i]
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
        } catch {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }        
    }
}
