//
//  PlayerviewController.swift
//  diamond
//
//  Created by Daniel Ostashev on 05/11/2022.
//

import AVFAudio
import UIKit

class PlayerViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var player: AVAudioPlayer? {
        didSet {
            OperationQueue.main.addOperation {
                self.playButton.isEnabled = self.player != nil
                if let player = self.player {
                    player.delegate = self
                }
            }
        }
    }
    
    override func viewDidLoad() {
        slider.setThumbImage(UIImage(), for: .normal)
        
        let audioURL = URL(string: "https://18ba-35-228-169-29.eu.ngrok.io/podcast/0/data")!
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(UUID().uuidString)
        print(destinationUrl)
        
        try! AVAudioSession.sharedInstance().setCategory(.playback)

        let task = URLSession.shared.downloadTask(with: audioURL) { (location, response, error) in
            guard let location = location else {
                return
            }
            
            do {
                try FileManager.default.moveItem(at: location ,to : destinationUrl)
                self.setTrackPath(destinationUrl)
                print("File moved to documents folder")
            }
            catch {
                print("error")
            }
        }
        task.resume()
        
        UIView.animate(withDuration: 5) {
            self.albumImageView.image = UIImage(named: "out")
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {_ in
            guard let player = self.player else {
                return
            }
            
            let progress = (0.025 + Float(player.currentTime / player.duration)) / 1.05
            self.slider.setValue(progress, animated: true)
        }
    }
    
    @IBAction func togglePlay(_ sender: NSObject) {
        guard let player = self.player else {
            return
        }

        if player.isPlaying {
            player.pause()
            self.playButton.setBackgroundImage(UIImage(systemName: "play.circle")!, for: .normal)
        } else {
            player.play()
            self.playButton.setBackgroundImage(UIImage(systemName: "pause.circle")!, for: .normal)
        }
    }
    
    func setTrackPath(_ destinationUrl: URL) {
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            do {
                let player = try AVAudioPlayer(contentsOf: destinationUrl)
                player.prepareToPlay()
                player.volume = 1
                self.player = player
            } catch {
                print(error)
            }
        }
    }
}
