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
    @IBOutlet weak var dimmedAlbumImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var isScrubbing = false
    
    var timer: Timer? = nil
    
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
    
    @IBAction func sliderDidStart(_ sender: UISlider) {
        isScrubbing = true
    }
    
    @IBAction func sliderDidFinish(_ sender: UISlider) {
        isScrubbing = false
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 5) {
            self.albumImageView.alpha = 0
            self.dimmedAlbumImageView.alpha = 1
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [unowned self] _ in
            guard let player = self.player else {
                return
            }
            
            guard !self.isScrubbing else {
                return
            }
            
            let progress = Float(player.currentTime / player.duration)
            self.slider.setValue(progress, animated: 0.025 < progress && progress < 0.975)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        albumImageView.alpha = 1
        dimmedAlbumImageView.alpha = 0
        
        timer?.invalidate()
        timer = nil
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
    
    @IBAction func setProgress(_ sender: UISlider) {
        guard let player = self.player else {
            return
        }
        
        player.currentTime = Double(sender.value) * player.duration
    }
    
    func setTrackPath(_ destinationUrl: URL) {
        guard FileManager.default.fileExists(atPath: destinationUrl.path) else {
            self.player = nil
            return
        }

        let player = try! AVAudioPlayer(contentsOf: destinationUrl)
        player.prepareToPlay()
        player.volume = 1
        self.player = player
    }
}
