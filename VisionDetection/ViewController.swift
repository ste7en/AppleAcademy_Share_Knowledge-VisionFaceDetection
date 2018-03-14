//
//  ViewController.swift
//  VisionDetection
//
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    // VNRequest: Either Retangles or Landmarks
    var faceDetectionRequest: VNRequest!
    private var requests = [VNRequest]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the video preview view.
        previewView.session = session
        
        // MARK: - Set up Vision Request
        faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: nil) // Default - pass the self.handleFaces completionHandler to draw the facial rectangle
        setupVision()

        self.configureSession()
        self.session.startRunning()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Only setup observers and start the session running if setup succeeded.
        self.isSessionRunning = self.session.isRunning
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.session.stopRunning()
        self.isSessionRunning = self.session.isRunning

        super.viewWillDisappear(animated)
    }
    
    @IBAction func UpdateDetectionType(_ sender: UISegmentedControl) {
        // use segmentedControl to switch over VNRequest

        // MARK: - Complete this to draw Vision results

        faceDetectionRequest = sender.selectedSegmentIndex == 0 ? VNDetectFaceRectanglesRequest(completionHandler: nil) : VNDetectFaceLandmarksRequest(completionHandler: nil)

        // Pass the self.handleFaces completionHandler to draw the facial rectangle to VNDetectFaceRectanglesRequest
        // Pass the self.handleFaceLandmarks completionHandler to draw the facial landmarks to VNDetectFaceLandmarksRequest
        setupVision()
    }
    
    
    @IBOutlet weak var previewView: PreviewView!
    
    // MARK: AVSession Management
    
    private var devicePosition: AVCaptureDevice.Position = .front
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil) // Communicate with the session and other session objects on this queue.

    private var videoDeviceInput: AVCaptureDeviceInput!
    
    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    

    private func configureSession() {
        
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the front camera
            if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                self.previewView.videoPreviewLayer.connection!.videoOrientation = .portrait
            }
        } catch {
            print("Could not create video device input: \(error)")
            session.commitConfiguration()
            return
        }
        
        // add output
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
        
        if session.canAddOutput(videoDataOutput) {
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            session.addOutput(videoDataOutput)
        } else {
            print("Could not add metadata output to the session")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }

}


extension ViewController {
    func setupVision() {
        self.requests = [faceDetectionRequest]
    }
    
    // MARK: - Vision CompletionHandler
    
    func handleFaces(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            //perform all the UI updates on the main queue
            guard let results = request.results as? [VNFaceObservation] else { return }
            self.previewView.removeMask()
            for face in results {
                self.previewView.drawFaceBoundingBox(face: face)
            }
        }
    }

    func handleFaceLandmarks(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            //perform all the UI updates on the main queue
            guard let results = request.results as? [VNFaceObservation] else { return }
            self.previewView.removeMask()
            for face in results {
                self.previewView.drawFaceWithLandmarks(face: face)
            }
        }
    }

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let exifOrientation = CGImagePropertyOrientation.leftMirrored
        var requestOptions: [VNImageOption : Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics : cameraIntrinsicData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(requests)
        }
            
        catch {
            print(error)
        }
        
    }
    
}
