//
//  UIAVCaptureVideoPreviewView.swift
//  AvFoundationSample
//
//  Created by iyoda masaaki on 2021/04/18.
//

import AVFoundation
import UIKit
import SwiftUI


// copy from https://software.small-desk.com/development/2020/08/10/swiftui-avfoundation-avcapturevideopreviewlayer/
public class UIAVCaptureVideoPreviewView: UIView {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
 
    public init(frame: CGRect, session: AVCaptureSession) {
        self.captureSession = session
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        // no implementation
    }
    
    func setupPreview(previewSize: CGRect) {
            self.frame = previewSize
     
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer.frame = self.bounds
            
            self.updatePreviewOrientation()
     
            self.layer.addSublayer(previewLayer)
     
            self.captureSession.startRunning()
    }
    
    func updateFrame(frame: CGRect) {
            self.frame = frame
            self.previewLayer.frame = frame
    }
     
    func updatePreviewOrientation() {
        switch UIDevice.current.orientation {
        case .portrait:
            self.previewLayer.connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            self.previewLayer.connection?.videoOrientation = .landscapeRight
        case .landscapeRight:
            self.previewLayer.connection?.videoOrientation = .landscapeLeft
        default:
            self.previewLayer.connection?.videoOrientation = .portrait
        }
        return
    }
 
//    func setupSession() {
//        captureSession = AVCaptureSession()
//        captureSession.beginConfiguration()
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
//
//        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
//        guard captureSession.canAddInput(videoInput) else { return }
//        captureSession.addInput(videoInput)
//
//        let photoOutput = AVCapturePhotoOutput()
//        guard captureSession.canAddOutput(photoOutput) else { return }
//        captureSession.sessionPreset = .photo
//        captureSession.addOutput(photoOutput)
//
//        captureSession.commitConfiguration()
//    }
//    
//    func setupPreview() {
//        self.frame = CGRect(x: 0, y: 0, width: 500, height: 500)   // 空のUIViewを使っているため、適当なサイズ設定が必要です
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
//        previewLayer.frame = self.frame
//        previewLayer.connection?.videoOrientation = .portrait
//        self.layer.addSublayer(previewLayer)
//
//        self.captureSession.startRunning()
//    }
}
 
public struct SwiftUIAVCaptureVideoPreviewView: UIViewRepresentable {
    let previewFrame: CGRect
    let captureModel: AVCaptureModel
 
    public func makeUIView(context: Context) -> UIAVCaptureVideoPreviewView {
        let view = UIAVCaptureVideoPreviewView(frame: previewFrame, session: self.captureModel.captureSession)
        view.setupPreview(previewSize: previewFrame)
        return view
    }
    
    public func updateUIView(_ uiView: UIAVCaptureVideoPreviewView, context: Context) {
        print("in updateUIView")
        self.captureModel.updateInputOrientation(orientation: UIDevice.current.orientation)
        uiView.updateFrame(frame: previewFrame)
    }
}
