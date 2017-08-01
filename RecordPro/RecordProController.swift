//
//  RecordProController.swift
//  RecordPro
//
//  Created by Simon Ng on 11/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class RecordProController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet fileprivate var stopButton: UIButton!
    @IBOutlet fileprivate var playButton: UIButton!
    @IBOutlet fileprivate var recordButton: UIButton!
    @IBOutlet fileprivate var timeLabel: UILabel!
    
    fileprivate var timer: Timer?
    fileprivate var elapsedTimeInSecond: Int = 0
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Disable Stop.Play button when application launches
        stopButton.isEnabled = false
        playButton.isEnabled = false
        
        //Get the document directory. If fails, just skip the rest os code
        guard let directoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the documents directory for recording the audio. PLease try againe later.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
            return
        }
        //Set the default audio file
        let audioFileURL = directoryURL.appendingPathComponent("MyAudioMemo.m4a")
        //Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            
            //Define the recorder setting
            let recorderSetting: [String: Any] = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100.0, AVNumberOfChannelsKey: 2, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Initiate and prepare the recorder
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: recorderSetting)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Action methods
    
    @IBAction func stop(sender: UIButton) {
        recordButton.setImage(UIImage(named: "Record"), for: .normal)
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        playButton.isEnabled = true
        
        //Stop the audio recorder
        audioRecorder?.stop()
        resetTimer()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }

    @IBAction func play(sender: UIButton) {
        if let recorder = audioRecorder {
            if !recorder.isRecording {
                audioPlayer = try? AVAudioPlayer(contentsOf: recorder.url)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                startTimer()
            }
        }
    }

    @IBAction func record(sender: UIButton) {
        //Stop the audio player before recording
        if let player = audioPlayer {
            if player.isPlaying {
                player.stop()
            }
        }
        
        if let recorder = audioRecorder {
            if !recorder.isRecording {
                let audioSession = AVAudioSession.sharedInstance()
                
                do {
                    try audioSession.setActive(true)
                    //Start recording
                    recorder.record()
                    startTimer()
                    //Change to the Pause image
                    recordButton.setImage(UIImage(named: "Pause"), for: .normal)
                } catch {
                    print(error)
                }
            } else {
                //Pause recording
                recorder.pause()
                pauseTimer()
                //Change to the Record image
                recordButton.setImage(UIImage(named: "Record"), for: .normal)
            }
        }
        
        stopButton.isEnabled = true
        playButton.isEnabled = false
    }
    
    //MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "Finish Recording", message: "Successfully recorded the audio!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
        }
    }

}

//MARK: - AVAudioPlayerDelegate
extension RecordProController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isSelected = false
        
        let alertMessage = UIAlertController(title: "Finish PLaying!", message: "Finish playing the rocording!", preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertMessage, animated: true, completion: nil)
    }
}

//MARK: - Timer Label
extension RecordProController {
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.elapsedTimeInSecond += 1
            self.updateTimeLabel()
        })
    }
    
    func pauseTimer() {
        timer?.invalidate()
    }
    
    func resetTimer() {
        timer?.invalidate()
        elapsedTimeInSecond = 0
        updateTimeLabel()
    }
    
    func updateTimeLabel() {
        let seconds = elapsedTimeInSecond % 60
        let minutes = (elapsedTimeInSecond / 60) % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}














