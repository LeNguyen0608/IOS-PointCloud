import UIKit
import Metal
import MetalKit
import ARKit

final class MainController: UIViewController, ARSessionDelegate {
    private let isUIEnabled = true
    private var clearButton = UIButton(type: .system)
    private let confidenceControl = UISegmentedControl(items: ["Low", "Medium", "High"])
    private var rgbButton = UIButton(type: .system)
    private var showSceneButton = UIButton(type: .system)
    private var saveButton = UIButton(type: .system)
    private var toggleParticlesButton = UIButton(type: .system)
    private let session = ARSession()
    private let appNameLabel = UILabel()
    private let instructionLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    var renderer: Renderer!
    private  var isPasued = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        session.delegate = self
        // Set the view to use the default device
        if let view = view as? MTKView {
            view.device = device
            view.backgroundColor = UIColor.clear
            // we need this to enable depth test
            view.depthStencilPixelFormat = .depth32Float
            view.contentScaleFactor = 1
            view.delegate = self
            // Configure the renderer to draw to the view
            renderer = Renderer(session: session, metalDevice: device, renderDestination: view)
            renderer.drawRectResized(size: view.bounds.size)
        }
        
        appNameLabel.text = "Foot Scanner"
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.textColor = .white
        appNameLabel.font = .boldSystemFont(ofSize: 25)
        view.addSubview(appNameLabel)
        
        instructionLabel.text = "Tap on record button to start"
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.textColor = .white
        instructionLabel.font = .systemFont(ofSize: 20)
        view.addSubview(instructionLabel)
        
        cancelButton.tintColor = UIColor(red: 4/255.0, green: 294/255.0, blue: 204/255.0, alpha: 1)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(self.viewValueChanged), for: .touchUpInside)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17)
        view.addSubview(cancelButton)
        cancelButton.isHidden = true
        
        nextButton.tintColor = UIColor(red: 4/255.0, green: 294/255.0, blue: 204/255.0, alpha: 1)
        nextButton.setTitle("Next", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(self.viewValueChanged), for: .touchUpInside)
        nextButton.titleLabel?.font = .systemFont(ofSize: 17)
        view.addSubview(nextButton)
        
        clearButton = createButton(mainView: self, iconName: "trash.circle.fill",
            tintColor: .red, hidden: !isUIEnabled)
        view.addSubview(clearButton)
        
        saveButton = createButton(mainView: self, iconName: "filemenu.and.selection",
            tintColor: .white, hidden: !isUIEnabled)
        view.addSubview(saveButton)
        
        showSceneButton = createButton(mainView: self, iconName: "record.circle",
            tintColor: .red, hidden: !isUIEnabled)
        view.addSubview(showSceneButton)
        
//        toggleParticlesButton = createButton(mainView: self, iconName: "circle.grid.hex.fill",
//            tintColor: .white, hidden: !isUIEnabled)
//        view.addSubview(toggleParticlesButton)
        
//        rgbButton = createButton(mainView: self, iconName: "eye",
//            tintColor: .white, hidden: !isUIEnabled)
//        view.addSubview(rgbButton)
        
        NSLayoutConstraint.activate([
            appNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            instructionLabel.bottomAnchor.constraint(equalTo: showSceneButton.topAnchor, constant: -50),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            
            nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            nextButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            
            clearButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
            clearButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55),
            clearButton.widthAnchor.constraint(equalToConstant: 50),
            clearButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55),
            
            showSceneButton.widthAnchor.constraint(equalToConstant: 60),
            showSceneButton.heightAnchor.constraint(equalToConstant: 60),
            showSceneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            showSceneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
//            toggleParticlesButton.widthAnchor.constraint(equalToConstant: 50),
//            toggleParticlesButton.heightAnchor.constraint(equalToConstant: 50),
//            toggleParticlesButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
//            toggleParticlesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
//            rgbButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
//            rgbButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
//            rgbButton.widthAnchor.constraint(equalToConstant: 60),
//            rgbButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a world-tracking configuration, and
        // enable the scene depth frame-semantic.
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
        // Run the view's session
        session.run(configuration)
        
        // The screen shouldn't dim during AR experiences.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    @objc
    func viewValueChanged(view: UIView) {
        switch view {
        case confidenceControl:
            renderer.confidenceThreshold = confidenceControl.selectedSegmentIndex
            
//        case rgbButton:
//            renderer.rgbOn = !renderer.rgbOn
//            let iconName = renderer.rgbOn ? "eye.slash": "eye"
//            rgbButton.setBackgroundImage(.init(systemName: iconName), for: .normal)
            
        case clearButton:
            renderer.isInViewSceneMode = true
            setShowSceneButtonStyle(isScanning: false)
            renderer.clearParticles()
            
        case cancelButton:
            cancelButton.isHidden = true
            renderer.isInViewSceneMode = true
            setShowSceneButtonStyle(isScanning: false)
            renderer.clearParticles()
            
        case saveButton:
            renderer.isInViewSceneMode = true
            setShowSceneButtonStyle(isScanning: false)
            goToSaveCurrentScanView()
        
        case showSceneButton:
            renderer.isInViewSceneMode = !renderer.isInViewSceneMode
            if !renderer.isInViewSceneMode {
                renderer.showParticles = true
//                self.toggleParticlesButton.setBackgroundImage(.init(systemName: "circle.grid.hex.fill"), for: .normal)
                self.setShowSceneButtonStyle(isScanning: true)
            } else {
                self.setShowSceneButtonStyle(isScanning: false)
            }
            
            if self.renderer.cpuParticlesBuffer.isEmpty {
                cancelButton.isHidden = true
            } else {
                cancelButton.isHidden = false
            }
            
//        case toggleParticlesButton:
//            renderer.showParticles = !renderer.showParticles
//            if (!renderer.showParticles) {
//                renderer.isInViewSceneMode = true
//                self.setShowSceneButtonStyle(isScanning: false)
//            }
//            let iconName = "circle.grid.hex" + (renderer.showParticles ? ".fill" : "")
//            self.toggleParticlesButton.setBackgroundImage(.init(systemName: iconName), for: .normal)
            
        default:
            break
        }
    }
    
    // Auto-hide the home indicator to maximize immersion in AR experiences.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                if let configuration = self.session.configuration {
                    self.session.run(configuration, options: .resetSceneReconstruction)
                }
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


// MARK: - MTKViewDelegate
extension MainController: MTKViewDelegate {
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.draw()
    }
}

// MARK: - Added controller functionality
extension MainController {
    private func setShowSceneButtonStyle(isScanning: Bool) -> Void {
        if isScanning {
            self.showSceneButton.setBackgroundImage(
                .init(systemName: "pause.circle"), for: .normal)
            self.showSceneButton.tintColor = .white
            self.instructionLabel.text = "Move phone around foot to scan"
        } else {
            self.showSceneButton.setBackgroundImage(
                .init(systemName: "record.circle"), for: .normal)
            self.showSceneButton.tintColor = .red
            self.instructionLabel.text = "Tap on record button to start"
        }
    }
    
    func onSaveError(error: XError) {
        displayErrorMessage(error: error)
        renderer.savingError = nil
    }
    
    func export(url: URL) -> Void {
        present(
            UIActivityViewController(
                activityItems: [url as Any],
                applicationActivities: .none),
            animated: true)
    }
    
    func measurement() -> Void {
        let err = renderer.savingError
        if err == nil {
            return  testCallAPI(renderer.savedCloudURLs.last!)
        }
        try? FileManager.default.removeItem(at: renderer.savedCloudURLs.last!)
        renderer.savedCloudURLs.removeLast()
        onSaveError(error: err!)
    }
    
    func afterSave() -> Void {
        let err = renderer.savingError
        if err == nil {
            return export(url: renderer.savedCloudURLs.last!)
        }
        try? FileManager.default.removeItem(at: renderer.savedCloudURLs.last!)
        renderer.savedCloudURLs.removeLast()
        onSaveError(error: err!)
    }
    
    func goToSaveCurrentScanView() {
        let saveContoller = SaveController()
        saveContoller.mainController = self
        present(saveContoller, animated: true, completion: nil)
    }
    
    func testCallAPI(_ url: URL) {
//        let plyFileData = (try? Data(contentsOf: url)) ?? Data()
//        let multipartDatas : [MultipartData] = [
//            MultipartDataFile(key: "file", fileName: url.path, payload: plyFileData, mineType: "application/ply"),
//        ]
//
//        let router = APIRouter(path: "http://192.168.20.190/api/upload-file",
//                               method: .post,
//                               parameters: [:],
//                               contentType: .multipartFormData)
//        APIRequest.shared.requestUploadMultipart(router: router, multipartDatas: multipartDatas) { error, response in
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let displayResultController = storyBoard.instantiateViewController(withIdentifier: "displayResult") as! DisplayResultController
//            self.present(displayResultController, animated: true, completion: nil)
//        }
//
        
        guard let path = Bundle.main.path(forResource: "nguyen_foot", ofType: "ply") else {
            return
        }

        if  let txt = FileManager.default.contents(atPath: url.path) {
            print(String(data: txt, encoding: .utf8) ?? "")
        }
                
        let parameters = [
          [
            "key": "file",
            "src": url.path,
            "type": "file"
          ]] as [[String : Any]]
        
        APIRequest.shared.sendAPI(parameters: parameters) { data, width, height in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let displayResultController = storyBoard.instantiateViewController(withIdentifier: "displayResult") as! DisplayResultController
            displayResultController.imageBase64String = data
            displayResultController.width = width
            displayResultController.height = height
            self.present(displayResultController, animated: true, completion: nil)
        }
    }
    
    func goToExportView() -> Void {
        let exportController = ExportController()
        exportController.mainController = self
        present(exportController, animated: true, completion: nil)
    }
    
    func displayErrorMessage(error: XError) -> Void {
        var title: String
        switch error {
            case .alreadySavingFile: title = "Save in Progress Please Wait."
            case .noScanDone: title = "No scan to Process."
            case .noScanMeasure: title = "No scan to Measure."
            case.savingFailed: title = "Failed To Write File."
        }
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1.75
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - RenderDestinationProvider
protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

extension SCNNode {
    func cleanup() {
        for child in childNodes {
            child.cleanup()
        }
        self.geometry = nil
    }
}

func createButton(mainView: MainController, iconName: String, tintColor: UIColor, hidden: Bool) -> UIButton {
    let button = UIButton(type: .system)
    button.isHidden = hidden
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(.init(systemName: iconName), for: .normal)
    button.tintColor = tintColor
    button.addTarget(mainView, action: #selector(mainView.viewValueChanged), for: .touchUpInside)
    button.contentMode = .scaleAspectFit
    return button
}

extension MTKView: RenderDestinationProvider {
    
}