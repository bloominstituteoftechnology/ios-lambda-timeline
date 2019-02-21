
import UIKit
import AVFoundation

class AuthorizationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Do this once user is looking at the screen, not before (as in viewDidLoad)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request permission to use the camera
        
        // Get authorization status
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        // switch over enum with 4 scenarios we need to handle
        switch authorizationStatus {
            
        case .notDetermined:
            // We have not asked the user yet for authorization
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted == false {
                    fatalError("Need to ask the user for authorization")
                }
                DispatchQueue.main.async {
                    // Now that we have access we want to perform the segue
                    self.showCamera()
                }
            }
        case .restricted:
            // Parental controls on the device prevent access to the cameras
            fatalError("Parental controls on the device are preventing access to the camera")
        case .denied:
            // We asked for permission, but they said "no"
            fatalError("User has denied access to the camera")
        case .authorized:
            // We asked for permission, and they said "yes"
            showCamera()
        }
    }
    
    private func showCamera() {
        // ask View Controller to perform segue
        performSegue(withIdentifier: "showCamera", sender: self)
    }
    
    
}
