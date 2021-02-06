//
//  BarCodeScanner.swift
//  SthenosScanner
//
//  Created by Valentin Quelquejay on 05.02.21.
//

import UIKit
import SwiftUI
import AVFoundation


struct BarCodeScanner : UIViewControllerRepresentable {
    
    @Binding var userID: String?
    @Binding var user: User?
    @Binding var fetching: Bool
    @Binding var isPresented: Bool
    @Binding var alertId: AlertID?
    
    @Environment(\.presentationMode) private var presentationMode
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.black
        
        context.coordinator.captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { fatalError() }
        let videoInput: AVCaptureDeviceInput
        videoInput = try! AVCaptureDeviceInput(device: videoCaptureDevice)
        

        if (context.coordinator.captureSession.canAddInput(videoInput)) {
            context.coordinator.captureSession.addInput(videoInput)
        } else {
            print("Could not add input to capture session")
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (context.coordinator.captureSession.canAddOutput(metadataOutput)) {
            context.coordinator.captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            //scan qr code
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
           
            print("Outputproblem")
        }

        context.coordinator.previewLayer = AVCaptureVideoPreviewLayer(session: context.coordinator.captureSession)
        context.coordinator.previewLayer.frame = vc.view.layer.bounds
        context.coordinator.previewLayer.videoGravity = .resizeAspectFill
        vc.view.layer.addSublayer(context.coordinator.previewLayer)

        context.coordinator.captureSession.startRunning()
        
        
        return vc
    }
    
    
  
    
    class Coordinator : NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: BarCodeScanner
        
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        init(_ parent: BarCodeScanner) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
                captureSession.stopRunning()
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        func found(code: String) {
            print(code)
            parent.userID = code
            parent.fetching = true
            parent.isPresented = false
            APIService().getUserInfo(userID: code) { (user,error) in
                if (error == nil) {
                    DispatchQueue.main.async {
                        self.parent.user = user
                        self.parent.fetching = false
                    }
                } else {
                    //api error
                    let err = error?._code
                    if (err == 403) {
                        print("user does not exist")
                        self.parent.alertId = AlertID(id: .userNotFound)
                        self.parent.fetching = false
                    } else {
                        print("API Error")
                        self.parent.alertId = AlertID(id: .otherError)
                        self.parent.fetching = false
                    }
                }
            }
        }
        
    }
}

