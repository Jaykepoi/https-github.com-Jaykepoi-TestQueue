//
//  MusicViewController.swift
//  TestQue
//
//  Created by Mikhail Kim on 06.04.2022.
//

import Foundation
import UIKit
import AVFoundation

class MusicViewController: UIViewController{
        
    @IBOutlet weak var Play1: UIButton!
    @IBOutlet weak var Play2: UIButton!
    @IBOutlet weak var CrossFade: UISlider!
    @IBOutlet weak var CrossFadeLabel: UILabel!
        var onePlayer = AVAudioPlayer()
        var twoPlayer = AVAudioPlayer()
        var turnPlayer: AVQueuePlayer?
        var ItemsPlayer: [AVPlayerItem] = []
    
        override func viewDidLoad() {
            super.viewDidLoad()
            CrossFade.maximumValue = 10
            CrossFade.minimumValue = 2
            do{
                onePlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "m2", ofType: "mp3")!))
                onePlayer.prepareToPlay()
                twoPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "m1", ofType: "mp3")!))
                twoPlayer.prepareToPlay()
            }catch{
                
            }
            
            let mySongs: [String] = [
                "m1", "m2",
            ]
            
            for my in mySongs {
                if let url = Bundle.main.url(forResource: my, withExtension: ".mp3"){
                    ItemsPlayer.append(AVPlayerItem(url: url))
                } else {
                    print("Could not get URL for \(my).mp3")
                }
            }
                if ItemsPlayer.count == 0 {
                          fatalError("Failed to get URL for ANY songs!")
                      }
        
            NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
    }

    func playQueue() -> Void {
        if turnPlayer == nil {
            turnPlayer = AVQueuePlayer()
        }
        guard let player = turnPlayer else {
            print("Error")
            return
        }
            player.removeAllItems()
                for item in ItemsPlayer{
                    item.seek(to: .zero, completionHandler: nil)
            }
        ItemsPlayer.forEach {
                    player.insert($0, after: nil)
                }
                    player.play()
        }
    @IBAction func Player1(_ sender: UIButton) {
        if twoPlayer.isPlaying {
            twoPlayer.pause()
            sender.setBackgroundImage(UIImage(systemName: "play.rectangle.fill"), for: .normal)
            sender.tintColor = .systemGreen
            
        } else {
            twoPlayer.play()
            sender.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            sender.tintColor = .systemGreen
        }
        twoPlayer.numberOfLoops = -1
    }
    @IBAction func Player2(_ sender: UIButton) {
        if onePlayer.isPlaying {
            onePlayer.pause()
            sender.setBackgroundImage(UIImage(systemName: "play.rectangle.fill"), for: .normal)
            sender.tintColor = .systemGreen
        } else {
            onePlayer.play()
            sender.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            sender.tintColor = .systemGreen
        }
        onePlayer.numberOfLoops = -1
    }
    @IBAction func playRestartTapped(_ sender: UIButton) {
        playQueue()
        CrossFade.maximumValue = 10
        CrossFade.minimumValue = 2
    }
    @IBAction func CrossFadeSlider(_ sender: Any) {
        CrossFadeLabel.text = "Кросс-фейд: \(Int(CrossFade.value)) с"
    }
    
    @objc func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            if let avItems = notification.object as? AVPlayerItem {
                self?.turnPlayer?.remove(avItems)
                avItems.seek(to: .zero, completionHandler: nil)
                self?.turnPlayer?.insert(avItems, after: nil)
            }
        }
    }
}
