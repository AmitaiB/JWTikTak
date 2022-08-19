//
//  CameraViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import AVFoundation
import SnapKit
import Actions
import SCLAlertView
import JWPlayerKit

class CameraViewController: UIViewController {
    // Capture session
    var captureSession = AVCaptureSession()
    
    // Capture device
    var videoCaptureDevice: AVCaptureDevice?
    
    // Capture output
    var captureOutput = AVCaptureMovieFileOutput()
    
    // Capture preview
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    
    /// Used to save recorded videos to the camera roll / photos.
    var recordedVideoURL: URL?
    
    private let cameraView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .black
        return view
    }()
    
    private let recordButton = RecordButton(frame: .zero)
    
    // After the video is saved locally, let the user preview before uploading/deleting.
    private var previewLayer: AVPlayerLayer?
    /// Set in the delegate, this allows for uploading.
    private var recordedVideoUrl: URL?
    
    /// If a video was recorded, this 'cancels' it (resets the camera).
    /// Else, it exits the tab, and returns to the main tab.
    private lazy var closeButton: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .close) { [weak self] in
            self?.navigationItem.rightBarButtonItem = nil // resets the "Next" button
            
            if let layer = self?.previewLayer {
                self?.resetCamera()
            } else {
                self?.captureSession.stopRunning()
                self?.tabBarController?.tabBar.isHidden = false
                self?.tabBarController?.selectedIndex   = 0
            }
        }
    }()
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(cameraView)
        cameraView.snp.makeConstraints( {$0.edges.equalToSuperview()} )
        setupCamera()
        setupRecordButton()
        navigationItem.leftBarButtonItem = closeButton
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // The camera view controller should occupy the entire screen.
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupCamera() {
        // TODO: add true error handling/reporting
        // Add devices
        if
            let audioDevice = AVCaptureDevice.default(for: .audio),
            let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
            captureSession.canAddInput(audioInput)
        {
            captureSession.addInput(audioInput)
        }
        
        if
            let videoDevice = AVCaptureDevice.default(for: .video),
            let videoInput  = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoInput)
        {
            captureSession.addInput(videoInput)
        }
        
        // update the session
        captureSession.sessionPreset = .hd1280x720
        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
        }
        
        // configure the preview
        capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreviewLayer?.videoGravity = .resizeAspectFill
        capturePreviewLayer?.frame = view.bounds
        if let previewLayer = capturePreviewLayer {
            cameraView.layer.addSublayer(previewLayer)
        }
        
        // enable camera start
        captureSession.startRunning()
    }
    
    private func resetCamera() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        recordButton.isHidden = false
        recordButton.toggleUI(for: .isNotRecording)
    }
        
    private func setupRecordButton() {
        // layout
        cameraView.addSubview(recordButton)
        
        recordButton.snp.makeConstraints { make in
            make.height.width.equalTo(70)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-70)
        }
        
        // function
        recordButton.add(event: .touchUpInside) { [unowned self] button in
            guard let recordButton = button as? RecordButton else { return }
            
            // Toggle recording off/on
            if self.captureOutput.isRecording {
                recordButton.toggleUI(for: .isNotRecording)
                captureOutput.stopRecording()
            } else {
                recordButton.toggleUI(for: .isRecording)
                self.safelyStartRecording()
            }
        }
    }
        
    private func safelyStartRecording() {
        guard var localUrl = FileManager.defaultLocalUrl else { return }
        localUrl.appendPathComponent(L10n.defaultVideoFilename)
        
        do     { try FileManager.default.removeItem(at: localUrl) }
        catch  { print(error.localizedDescription) }
        
        captureOutput.startRecording(to: localUrl, recordingDelegate: self)
    }
}


// MARK: - AVCaptureFileOutputRecordingDelegate

// TODO: - Have a minimum video length, say, about 6s.
/*
 Specifically, make an AVMutableComposition loop a too-short recording.
 See https://stackoverflow.com/a/60727408/4898050
 */
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            SCLAlertView().showError(L10n.error, subTitle: error!.localizedDescription)
            resetCamera()
            print(#function, error!.localizedDescription)
            return
        }

        
        recordedVideoURL = outputFileURL
        
        if UserDefaults.standard.bool(forKey: L10n.UserSettings.shouldSaveVideosKey) {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        }
        
        // happy path
        print("Finished recording to url: \(outputFileURL.absoluteString)")
        recordedVideoUrl = outputFileURL
        startPreviewLayer(with: outputFileURL)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.next, style: .done) { [weak self] in
            guard let localVideoURL = self?.recordedVideoUrl else { return }
            let captionVC = CaptionViewController(videoURL: localVideoURL)
            self?.navigationController?.pushViewController(captionVC, animated: true)
        }
    }
    
    func startPreviewLayer(with outputFileURL: URL) {
        // setting up preview functionality
        recordButton.isHidden = true

        // JWPlayerView would be overkill here.
        let player   = AVPlayer(url: outputFileURL)
        previewLayer = AVPlayerLayer(player: player)
        
        guard let previewLayer    = previewLayer else { return }
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame        = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.player?.play()
    }
}

extension FileManager {
    fileprivate static var defaultLocalUrl: URL? {
        FileManager.default.urls(for: .documentDirectory, in:  .userDomainMask).first
    }
}
