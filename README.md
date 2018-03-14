# High performance image analysis with Vision Framework

Share Knowledge activity @Apple Developer Academy, Naples. This is a project example of Face Detection with Vision written Stefano Formicola and Gian Marco Orlando.

Try it out with real time face detection on your iPhone! 📱

---
## Guiding Activity

Use the Vision VNResult objects to draw on screen a face rectangle and facial landmarks. Use the swift file 'What to add.swift' to add the methods in the ViewController.swift.


## Details

Specify the `VNRequest` for face recognition, either `VNDetectFaceRectanglesRequest` or `VNDetectFaceLandmarksRequest`.

```swift
private var requests = [VNRequest]() // you can do mutiple requests at the same time

var faceDetectionRequest: VNRequest!
@IBAction func UpdateDetectionType(_ sender: UISegmentedControl) {
    // use segmentedControl to switch over VNRequest
    faceDetectionRequest = sender.selectedSegmentIndex == 0 ? VNDetectFaceRectanglesRequest(completionHandler: handleFaces) : VNDetectFaceLandmarksRequest(completionHandler: handleFaceLandmarks) 
}

```

Perform the requests every single frame. The image comes from camera via `captureOutput(_:didOutput:from:)`, see [AVCaptureVideoDataOutputSampleBufferDelegate](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate/1385775-captureoutput)


Handle the return of your request, `VNRequestCompletionHandler`.  
- `handleFaces` for `VNDetectFaceRectanglesRequest`
- `handleFaceLandmarks` for `VNDetectFaceLandmarksRequest`

then you will get the result from the request, which are `VNFaceObservation`s. That's all you got from the **Vision API**

```swift
func handleFaces(request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
        //perform all the UI updates on the main queue
        guard let results = request.results as? [VNFaceObservation] else { return }
        print("face count = \(results.count) ")
        self.previewView.removeMask()

        for face in results {
            self.previewView.drawFaceboundingBox(face: face)
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
```
