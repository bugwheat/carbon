//
//  Decompressor.swift
//  diamond
//
//  Created by Daniel Ostashev on 06/11/2022.
//

import Accelerate
import AVFoundation
import CoreImage
import Darwin
import Foundation
import UIKit

import onnxruntime_objc

// Information about a model file or labels file.
typealias FileInfo = (name: String, extension: String)

enum OrtModelError: Error {
    case error(_ message: String)
}

class Decompressor: NSObject {
    // MARK: - Inference Properties

    let threadCount: Int32
    let threshold: Float = 0.5
    let threadCountLimit = 10

    // MARK: - Model Parameters

    let batchSize = 1
    let inputChannels = 3
    let inputWidth = 300
    let inputHeight = 300

    private let colors = [
        UIColor.red,
        UIColor(displayP3Red: 90.0 / 255.0, green: 200.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0),
        UIColor.green,
        UIColor.orange,
        UIColor.blue,
        UIColor.purple,
        UIColor.magenta,
        UIColor.yellow,
        UIColor.cyan,
        UIColor.brown
    ]

    private var labels: [String] = []

    /// ORT inference session and environment object for performing inference on the given ssd model
    private var session: ORTSession
    private var env: ORTEnv

    // MARK: - Initialization of ModelHandler
    init?(modelFileInfo: FileInfo, threadCount: Int32 = 1) {
        let modelFilename = modelFileInfo.name

        guard let modelPath = Bundle.main.path(
            forResource: modelFilename,
            ofType: modelFileInfo.extension
        ) else {
            print("Failed to get model file path with name: \(modelFilename).")
            return nil
        }

        self.threadCount = threadCount
        do {
            // Start the ORT inference environment and specify the options for session
            env = try ORTEnv(loggingLevel: ORTLoggingLevel.verbose)
            let options = try ORTSessionOptions()
            try options.setLogSeverityLevel(ORTLoggingLevel.verbose)
            try options.setIntraOpNumThreads(threadCount)
            // Create the ORTSession
            session = try ORTSession(env: env, modelPath: modelPath, sessionOptions: options)
        } catch {
            print("Failed to create ORTSession.")
            return nil
        }

        super.init()
    }

    func writePCMBuffer(url: URL, buffer: AVAudioPCMBuffer) throws {
        let settings: [String: Any] = [
            AVFormatIDKey: buffer.format.settings[AVFormatIDKey] ?? kAudioFormatLinearPCM,
            AVNumberOfChannelsKey: buffer.format.settings[AVNumberOfChannelsKey] ?? 2,
            AVSampleRateKey: buffer.format.settings[AVSampleRateKey] ?? 44100,
            AVLinearPCMBitDepthKey: buffer.format.settings[AVLinearPCMBitDepthKey] ?? 16
        ]

        do {
            let output = try AVAudioFile(forWriting: url, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: false)
            try output.write(from: buffer)
        } catch {
            throw error
        }
    }
    // This method preprocesses the image, runs the ort inferencesession and returns the inference result
    func runModel(onData data: Data) throws -> URL {
        let inputName = "frame"
        let outputName = "1427"

        let inputShape: [NSNumber] = [1 as NSNumber, 8 as NSNumber, 1500 as NSNumber]


        let inputTensor = try ORTValue(tensorData: NSMutableData(data: data),
                                       elementType: ORTTensorElementDataType.int32,
                                       shape: inputShape)
        // Run ORT InferenceSession
        let outputs = try session.run(withInputs: [inputName: inputTensor],
                                      outputNames: [outputName],
                                      runOptions: nil)

        let data = try outputs[outputName]!.tensorData()

        let audioBuffer = AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(data.length), mData: data.mutableBytes)
        var audioBufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: (audioBuffer))

        let audioBufferListPointer = UnsafePointer<AudioBufferList>(&audioBufferList)

        let pcmBuffer = AVAudioPCMBuffer(
            pcmFormat: AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: 24000.0,
                channels: 1,
                interleaved: false
            )!,
            bufferListNoCopy: audioBufferListPointer
        )!

        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(UUID().uuidString)

        try writePCMBuffer(url: destinationUrl, buffer: pcmBuffer)

        return destinationUrl
    }

    // This method preprocesses the image, runs the ort inferencesession and returns the inference result
    func runModel(onDatas datas: [Data]) throws -> URL {
        let inputName = "frame"
        let outputName = "1427"

        let inputShape: [NSNumber] = [1 as NSNumber, 8 as NSNumber, 1500 as NSNumber]

        let outs = datas.map { data in
            let inputTensor = try! ORTValue(tensorData: NSMutableData(data: data),
                                           elementType: ORTTensorElementDataType.int32,
                                           shape: inputShape)
            // Run ORT InferenceSession
            let outputs = try! session.run(withInputs: [inputName: inputTensor],
                                          outputNames: [outputName],
                                          runOptions: nil)
            
            return try! outputs[outputName]!.tensorData()
        }

        let totalData = outs.reduce(NSMutableData()) { d, s in
            d.append(s as Data)
            return d
        }

        let audioBuffer = AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(totalData.length), mData: totalData.mutableBytes)

        var audioBufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: (audioBuffer))

        let audioBufferListPointer = UnsafePointer<AudioBufferList>(&audioBufferList)

        let pcmBuffer = AVAudioPCMBuffer(
            pcmFormat: AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: 24000.0,
                channels: 1,
                interleaved: false
            )!,
            bufferListNoCopy: audioBufferListPointer
        )!

        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(UUID().uuidString)

        try writePCMBuffer(url: destinationUrl, buffer: pcmBuffer)

        return destinationUrl
    }

}
