// Open your XCode project

/*
// MARK: - AVSession Management
Line 55
Here you can see I configured the AVCaptureSession of the app
and actually it is very simple.

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
Line 147
Next I want to show you the method of the AVCapture delegate 
that notifies the viewcontroller that a new sampleBuffer is
ready to be analysed.

Please note that it doesn't come with its exif orientation
so i have to pass it manually to vision.

The work is done in just one line: 
//line 139
imageRequestHandler.perform
*/


/*
I want to show you a live demo. Now, Vision in performing its tasks
but we didn't set a completionHandler so we are doing nothing with these
results.
*/
// RUN DEMO

/*
Now let's do something with our results.
*/
// LINE 128

// draw face rectangles




/*            Cut-paste these functions in ViewController.swift              */




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

// END

// draw face landmarks

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

/*
Now I set these completion handler in the requests initializers
line 24: self.handleFaces
line 50: self.handleFaces 
line 50.5: self.handleFaceLandmarks

*/
