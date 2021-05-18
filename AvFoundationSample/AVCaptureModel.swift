//
//  AVCaputureModel.swift
//  CameraWithAVFoundation
//
//  Created by Tomoaki Yagishita on 2020/08/11.
// https://software.small-desk.com/development/2020/08/13/swiftuiavfoundation-photofromavcapturesession/

// *****違うモデルを作って、キャプチャのoutをもらえるようにして、リアルタイムでのISOとかを出してみたい
// sessionのoutputとかに何か入れればうまくいくか？
// https://stackoverflow.com/questions/44682698/how-to-take-uiimage-of-avcapturevideopreviewlayer-instead-of-avcapturephotooutpu

// こっちのほうがうまくいきそう
// https://zenn.dev/yorifuji/articles/swiftui-avfoundation

// すくなくともこれぐらいは取得できるはず
// https://github.com/NextLevel/NextLevel/issues/192


import Foundation
import AVFoundation
import UIKit
 
public class AVCaptureModel : NSObject, AVCapturePhotoCaptureDelegate, ObservableObject {
    public var captureSession: AVCaptureSession
    public var videoInput: AVCaptureDeviceInput!
    public var photoOutput: AVCapturePhotoOutput
    
    var frontCamera: AVCaptureDevice?
    @Published var image: UIImage?
    
    public override init() {
        self.captureSession = AVCaptureSession()
        self.photoOutput = AVCapturePhotoOutput()
    }
    
    public func setupSession() {
        captureSession.beginConfiguration()
        // guard let videoCaputureDevice = AVCaptureDevice.default(for: .video) else { return }
 
        
        // https://qiita.com/t_okkan/items/b2dd11426eab107c5d15
        // カメラデバイスのプロパティ設定
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
            } else if device.position == AVCaptureDevice.Position.front {
                self.frontCamera = device
            }
        }
        
        self.printCameraConfiguration()
        
        guard let videoInput = try? AVCaptureDeviceInput(device: frontCamera!) else { return }
        
        // guard let videoInput = try? AVCaptureDeviceInput(device: videoCaputureDevice) else { return }
        self.videoInput = videoInput
        guard captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)
 
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        
        captureSession.commitConfiguration()
    }
    
    public func updateInputOrientation(orientation: UIDeviceOrientation) {
        for conn in captureSession.connections {
            conn.videoOrientation = ConvertUIDeviceOrientationToAVCaptureVideoOrientation(deviceOrientation: orientation)
        }
    }
    
    
    public func takePhoto() {
        let photoSetting = AVCapturePhotoSettings()
        photoSetting.flashMode = .off
        
        
        photoSetting.isHighResolutionPhotoEnabled = false
        photoOutput.capturePhoto(with: photoSetting, delegate: self)
        return
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        self.image = UIImage(data: imageData!)
        
        self.printCameraConfiguration()
      
    }
    
    public func printInfo(){
        printCameraConfiguration()
    }
    
    func printCameraConfiguration() {
        print("AVCaptureDevice.currentISO: " + String(AVCaptureDevice.currentISO))
        print("AVCaptureDevice.currentLensPosition: " + String(AVCaptureDevice.currentLensPosition))
        print("AVCaptureDevice.currentExposureDuration: " + String(AVCaptureDevice.currentExposureDuration.positionalTime))
        print("AVCaptureDevice.currentExposureDuration: redGrain: " + String(AVCaptureDevice.currentWhiteBalanceGains.redGain))
        print("AVCaptureDevice.currentExposureDuration: greenGrain: " + String(AVCaptureDevice.currentWhiteBalanceGains.greenGain))
        print("AVCaptureDevice.currentExposureDuration: blueGrain: " + String(AVCaptureDevice.currentWhiteBalanceGains.blueGain))
        
        print("device: activeFormat:maxExposureDuration: " + String(CMTimeGetSeconds(self.frontCamera!.activeFormat.maxExposureDuration)))
        print("device: activeFormat:minExposureDuration: " + String(CMTimeGetSeconds(self.frontCamera!.activeFormat.minExposureDuration)))
        print("device: exposureDuration: " + String(CMTimeGetSeconds(self.frontCamera!.exposureDuration)))
        print("device: activeFormat:maxISO " + String(self.frontCamera!.activeFormat.maxISO))
        print("device: activeFormat:minISO " + String(self.frontCamera!.activeFormat.minISO))
        print("device: iso: " + String(self.frontCamera!.iso))
        print("device: lensAperture: " + String(self.frontCamera!.lensAperture))
        print("device: deviceWhiteBalanceGains.redGrain: " + String(self.frontCamera!.deviceWhiteBalanceGains.redGain))
        print("device: deviceWhiteBalanceGains.greenGrain: " + String(self.frontCamera!.deviceWhiteBalanceGains.greenGain))
        print("device: deviceWhiteBalanceGains.blueGrain: " + String(self.frontCamera!.deviceWhiteBalanceGains.blueGain))
        print("device: exposureTargetBias: " + String(self.frontCamera!.exposureTargetBias))
        print("device: exposureTargetOffset: " + String(self.frontCamera!.exposureTargetOffset))
        print("device: focusMode: " + String(self.frontCamera!.focusMode.rawValue))
        print("device: exposureMode: " + String(self.frontCamera!.exposureMode.rawValue))
        print("device: whiteBalanceMode: " + String(self.frontCamera!.whiteBalanceMode.rawValue))
        print("device: isGlobalToneMappingEnabled: " + String(self.frontCamera!.isGlobalToneMappingEnabled))
        print("device: isTorchActive: " + String(self.frontCamera!.isTorchActive))
        print("device: isLowLightBoostEnabled: " + String(self.frontCamera!.isLowLightBoostEnabled))
        print("device: isVideoHDREnabled: " + String(self.frontCamera!.isVideoHDREnabled))
        print("device: isSmoothAutoFocusEnabled: " + String(self.frontCamera!.isSmoothAutoFocusEnabled))
        print("device: isSmoothAutoFocusSupported: " + String(self.frontCamera!.isSmoothAutoFocusSupported))
        print("device: isGlobalToneMappingEnabled: " + String(self.frontCamera!.isGeometricDistortionCorrectionEnabled))
        print("device: isGlobalToneMappingEnabled: " + String(self.frontCamera!.isGeometricDistortionCorrectionSupported))
        print("device: isGlobalToneMappingEnabled: " + String(self.frontCamera!.isSubjectAreaChangeMonitoringEnabled))
        print("device: isGlobalToneMappingEnabled: " + String(self.frontCamera!.isAutoFocusRangeRestrictionSupported))
        print("device: deviceType: " + String(self.frontCamera!.deviceType.rawValue))
        print("device: activeFormat.videoFieldOfView: " + String(self.frontCamera!.activeFormat.videoFieldOfView))
        print("device: activeFormat.videoSupportedFrameRateRanges: " + String(self.frontCamera!.activeFormat.videoSupportedFrameRateRanges.description))
        print("device: localizedName: " + String(self.frontCamera!.localizedName))
        print("device: manufacturer: " + String(self.frontCamera!.manufacturer))
        print("device: position: " + String(self.frontCamera!.position.rawValue))
        print("device: lensPosition: " + String(self.frontCamera!.lensPosition))
        print("device: description" + String(self.frontCamera!.description))
        print("device: activeFormat.description" + String(self.frontCamera!.activeFormat.description))
    }
    
//    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) ->UIImage? {
//         guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//             return nil
//         }
//         CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
//         let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
//         let width = CVPixelBufferGetWidth(pixelBuffer)
//         let height = CVPixelBufferGetHeight(pixelBuffer)
//         let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
//         let colorSpace = CGColorSpaceCreateDeviceRGB()
//         let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
//         guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
//             return nil
//         }
//         guard let cgImage = context.makeImage() else {
//             return nil
//         }
//         let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
//         CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
//         return image
//     }
}
 
// https://stackoverflow.com/questions/54662047/converting-cmtime-to-string-is-wrong-value-return
public func ConvertUIDeviceOrientationToAVCaptureVideoOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
    switch deviceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
    }
}

extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var hours:  Int { return Int(roundedSeconds / 3600) }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String {
        if self.roundedSeconds.isNaN {
            return "--:--:--"
        }
        
        print(self.roundedSeconds)
        
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}
