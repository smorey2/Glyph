//
//  BarcodeDetector.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import ARKit
import Vision

protocol BarcodeDetectorDelegate: class {
    func barcodeUpdated(with: Set<ARReferenceImage>)
}

struct BarcodeResult {
    var version: Int
    let referenceImage: ARReferenceImage
}

// https://developer.apple.com/documentation/arkit/tracking_and_altering_images
class BarcodeDetector: NSObject, ARSessionDelegate {
    
    // Callback
    weak var delegate: BarcodeDetectorDelegate?
    
    // Discovered Barcodes
    var foundBarcodes: [String:BarcodeResult] = [:]
    
    // The pixel buffer being held for analysis; used to serialize Vision requests.
    var currentBuffer: CVPixelBuffer?
    
    // Queue for dispatching vision classification requests
    let visionQueue = DispatchQueue(label: "com.contoso.Glyph.visionQueue")
    
    // CIPerspectiveCorrection
    let perspectiveTransform = CIFilter(name: "CIPerspectiveCorrection")!
    
    // Barcode Request
    lazy var barcodeRequest: VNDetectBarcodesRequest = {
        let request = VNDetectBarcodesRequest(completionHandler: { [weak self] request, error in
            self?.processBarcodes(for: request, error: error)
        })
        request.symbologies = [.QR]
        request.usesCPUOnly = false
        return request
    }()
    
    // Version
    var version = 0
    
    // Run the Vision detector on the current image buffer.
    /// - Tag: DetectCurrentImage
    func detectCurrentImage() {
        version &+= 1
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: .up, options: [:])
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                try requestHandler.perform([self.barcodeRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
    
    // Handle completion of the Vision request
    /// - Tag: ProcessBarcodes
    func processBarcodes(for request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNBarcodeObservation] else {
            print("Unable to process barcode.\n\(error!.localizedDescription)")
            return
        }

        for result in results {
            let payload = result.payloadStringValue!
    
            // Continue if payload exists
            if var foundBarcode = self.foundBarcodes[payload] {
                foundBarcode.version = version
                self.foundBarcodes[payload] = foundBarcode
                continue
            }
            
            // Extract image
            guard let image = extractImage(for: result) else {
                print("Error: Could not extract image for \(payload).")
                continue
            }
            
            guard let referenceImage = createReferenceImage(image: image) else {
                print("Error: Could not create reference image for \(payload).")
                continue
            }
            
            self.foundBarcodes[payload] = BarcodeResult(version: version, referenceImage: referenceImage)
            
            let referenceImages = Set(self.foundBarcodes.values.map { $0.referenceImage })
            
            delegate?.barcodeUpdated(with: referenceImages)
        }
    }
    
    func createReferenceImage(image: CIImage) -> ARReferenceImage? {
        guard let referenceImagePixelBuffer = image.toPixelBuffer(pixelFormat: kCVPixelFormatType_32BGRA) else {
            print("Error: Could not convert image into an ARReferenceImage.")
            return nil
        }
        
        /*
         Set a default physical width of 50 centimeters for the new reference image.
         While this estimate is likely incorrect, that's fine for the purpose of the
         app. The content will still appear in the correct location and at the correct
         scale relative to the image that's being tracked.
         */
        let referenceImage = ARReferenceImage(referenceImagePixelBuffer, orientation: .up, physicalWidth: CGFloat(0.5))
        
        referenceImage.validate { (error) in
            if let error = error {
                print("Reference image validation failed: \(error.localizedDescription)")
                return
            }
        }
        
        return referenceImage
    }
    
    func extractImage(for result: VNBarcodeObservation) -> CIImage? {
        guard let currentBuffer = self.currentBuffer else { return nil }

        let width = CGFloat(CVPixelBufferGetWidth(currentBuffer))
        let height = CGFloat(CVPixelBufferGetHeight(currentBuffer))
        let topLeft = CGPoint(x: result.topLeft.x * width, y: result.topLeft.y * height)
        let topRight = CGPoint(x: result.topRight.x * width, y: result.topRight.y * height)
        let bottomLeft = CGPoint(x: result.bottomLeft.x * width, y: result.bottomLeft.y * height)
        let bottomRight = CGPoint(x: result.bottomRight.x * width, y: result.bottomRight.y * height)

        perspectiveTransform.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
        perspectiveTransform.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
        perspectiveTransform.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
        perspectiveTransform.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")

        let ciImage = CIImage(cvPixelBuffer: currentBuffer).oriented(.up)
        perspectiveTransform.setValue(ciImage, forKey: kCIInputImageKey)

        guard let perspectiveImage: CIImage = perspectiveTransform.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("Error: Rectangle detection failed - perspective correction filter has no output image.")
            return nil
        }
        return perspectiveImage
    }

    // MARK: - ARSessionDelegate
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else { return }
        self.currentBuffer = frame.capturedImage
        detectCurrentImage()
    }
}
