//
//  ViewModel.swift
//  SingOnGo
//
//  Created by Vitaly on 24/12/21.
//

import SwiftUI
import AVFoundation

class ViewModel: ObservableObject {
    
    @Published var currentInput: AVAudioSessionPortDescription?
    
    @Published var isFirstTime = true
    @Published var isInputSelected = false
    @Published var isActive = false
    
    @Published var inputAlert = false
    @Published var requestAlert = false
    
    @Published var session: AVAudioSession!
    @Published var engine = AVAudioEngine()
    @Published var player = AVAudioPlayerNode()
    @Published var inputs: [AVAudioSessionPortDescription] = []
    
    @Published var volume: Float = 7.0
    
    func appear() {
        session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .measurement, options: [.allowBluetooth, .allowBluetoothA2DP, .mixWithOthers])
        } catch {
            print(error.localizedDescription)
        }
        session.requestRecordPermission { (status) in
            if !status {
                self.requestAlert.toggle()
            }
        }
        if session.availableInputs != nil {
            inputs = session.availableInputs!
        }
    }
    
    func prepare() {
        do {
            try session.setActive(true)
            try session.setPreferredInput(currentInput)
            try session.setPreferredIOBufferDuration(0.0007)
        } catch {
            print(error.localizedDescription)
        }
        
        engine = AVAudioEngine()
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: engine.inputNode.outputFormat(forBus: 0))
        engine.inputNode.installTap(onBus: 0, bufferSize: 256, format: engine.inputNode.outputFormat(forBus: 0)) { (buffer, time) -> Void in
            buffer.frameLength = 256
            self.player.scheduleBuffer(buffer)
        }
        engine.prepare()
    }
    
    func changedVolume(volume: Float) {
        engine.mainMixerNode.outputVolume = volume
    }
    
    func start() {
        do {
            try engine.start()
        } catch {
            print(error.localizedDescription)
        }
        engine.mainMixerNode.outputVolume = volume
        player.prepare(withFrameCount: 256)
        player.play()
    }
    
    func stop() {
        engine.stop()
        player.stop()
    }
    
    func play() {
        if isInputSelected && !isActive && isFirstTime {
            prepare()
            start()
            withAnimation(.spring(dampingFraction: 0.8, blendDuration: 0.2)) {
                isActive.toggle()
            }
            isFirstTime.toggle()
        } else if isInputSelected && !isActive && !isFirstTime {
            start()
            withAnimation(.spring(dampingFraction: 0.8, blendDuration: 0.2)) {
                isActive.toggle()
            }
        } else if isInputSelected && isActive {
            stop()
            withAnimation(.spring(dampingFraction: 0.8, blendDuration: 0.2)) {
                isActive.toggle()
            }
        } else {
            inputAlert.toggle()
        }
    }
}
