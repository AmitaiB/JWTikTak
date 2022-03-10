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

class CameraViewController: UIViewController {
    // Capture session
    var captureSession = AVCaptureSession()
    
    // Capture device
    var videoCaptureDevice: AVCaptureDevice?
    
    // Capture output
    var captureOutput = AVCaptureMovieFileOutput()
    
    // Capture preview
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let cameraView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .close) { [weak self] in
            self?.captureSession.stopRunning()
            self?.tabBarController?.tabBar.isHidden = false
            self?.tabBarController?.selectedIndex   = 0
        }
    }()
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(cameraView)
        cameraView.snp.makeConstraints( {$0.edges.equalToSuperview()} )
        setupCamera()
        
        navigationItem.leftBarButtonItem = closeButton
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    func setupCamera() {
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
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(#function, error.localizedDescription)
            return
        }
        
        print("Finished recording to url: \(outputFileURL.absoluteString)")
    }
}
