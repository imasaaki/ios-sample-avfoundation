//
//  ContentView.swift
//  AvFoundationSample
//
//  Created by iyoda masaaki on 2021/04/18.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var captureModel: AVCaptureModel
    @GestureState var scale: CGFloat = 1.0
    
    var body: some View {
        captureModel.setupSession()
        return VStack {
            Image(systemName: "camera")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
 
            GeometryReader { geom in
                SwiftUIAVCaptureVideoPreviewView(previewFrame: CGRect(x: 0, y: 0, width: geom.size.width, height: geom.size.height),
                                                 captureModel: captureModel)
            }
            .border(Color.red)
            
            HStack {
                if captureModel.image != nil {
                    Image(uiImage: captureModel.image!)
                        .resizable()
                        .scaledToFit()
                        .frame(height:100)
                }
                Button("Button", action: {
                    captureModel.takePhoto()
                            })
                Button("OnlyInfo", action: {
                    captureModel.printInfo()
                            })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(captureModel: AVCaptureModel())
    }
}
