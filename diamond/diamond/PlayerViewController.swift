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

    let decompressor = Decompressor(modelFileInfo: FileInfo("model24", "onnx"))!
    
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

        API.shared.downloadChunk(id: "0", index: 0) { [weak self] data in
            guard let self = self else {
                return
            }

            let url = try! self.decompressor.runModel(onData: data)

            self.setTrackPath(url)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 5) {
            self.albumImageView.alpha = 0
            self.dimmedAlbumImageView.alpha = 1
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let player = self?.player else {
                return
            }
            
            guard self?.isScrubbing == false else {
                return
            }
            
            let progress = Float(player.currentTime / player.duration)
            self?.slider.setValue(progress, animated: 0.025 < progress && progress < 0.975)
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

func getFile(forResource resource: String, withExtension fileExt: String?) -> [UInt8]? {
    // See if the file exists.
    guard let fileUrl: URL = Bundle.main.url(forResource: resource, withExtension: fileExt) else {
        return nil
    }

    do {
        // Get the raw data from the file.
        let rawData: Data = try Data(contentsOf: fileUrl)

        // Return the raw data as an array of bytes.
        return [UInt8](rawData)
    } catch {
        // Couldn't read the file.
        return nil
    }
}
