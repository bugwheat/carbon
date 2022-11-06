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
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var podcast: Podcast?
    
    var isScrubbing = false
    
    var timer: Timer? = nil

    let decompressor = Decompressor(modelFileInfo: FileInfo("model24_12", "onnx"))!
    
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
    
    func setPodcast(_ podcast: Podcast) {
        OperationQueue.main.addOperation {
            self.podcast = podcast
            self.nameLabel.text = podcast.name
            self.authorLabel.text = podcast.author

            self.chunks = (0..<podcast.n_chuncks).map { _ in Data() }
            self.pendingChunks = podcast.n_chuncks
            
            for i in 0..<podcast.n_chuncks {
                API.shared.downloadChunk(id: self.podcast?.id ?? "0", index: i) { [weak self] data in
                    guard let self = self else {
                        return
                    }
                    
                    OperationQueue.main.addOperation {
                        self.chunks[i] = data
                        self.pendingChunks -= 1
                    }
                }
            }
        }
    }
    
    @IBAction func skip5(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        
        player.currentTime += 5
    }
    
    @IBAction func rewind5(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        
        player.currentTime -= 5
    }
    
    @IBAction func sliderDidStart(_ sender: UISlider) {
//        isScrubbing = true
    }
    
    @IBAction func sliderDidFinish(_ sender: UISlider) {
//        isScrubbing = false
    }
    
    var chunks: [Data] = []
    var pendingChunks = 0 {
        didSet {
            if pendingChunks == 0 && chunks.count > 0 {
                let url = try! self.decompressor.runModel(onDatas: chunks)
                self.setTrackPath(url)
            }
        }
    }
    
    override func viewDidLoad() {
        slider.setThumbImage(UIImage(), for: .normal)
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
        
        OperationQueue.main.addOperation {
            self.togglePlay(self)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.currentTime = 0
        player.play()
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
