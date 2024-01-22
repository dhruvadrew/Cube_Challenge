//
//  ViewController.swift
//  CubeChallenge
//
//  Created by Dhruva barua on 1/22/24.
//

import UIKit
import SceneKit
import ARKit

let defaults = UserDefaults.standard
var token = defaults.integer(forKey: "count")

public var danceNode: SCNNode?

public var jumpNode: SCNNode?

public var idleNode: SCNNode?

public var fightNode: SCNNode?

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var bar: UIImageView!
    
    var planeGeometry:SCNPlane!
    let planeIdentifiers = [UUID]()
    var anchors = [ARAnchor]()
    
    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    var heartNode: SCNNode?
    
    var diamondNode: SCNNode?
    
    var puppyNode: SCNNode?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ){
        let defaults = UserDefaults.standard
        let defaultValue = ["count" : 0]
        defaults.register(defaults: defaultValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        let heartScene = SCNScene(named: "art.scnassets/heart.scn")
        let diamondScene = SCNScene(named: "art.scnassets/diamond.scn")
        let puppyScene = SCNScene(named: "art.scnassets/puppy.scn")
        let danceScene = SCNScene(named: "art.scnassets/danceFixed.scn")
        let jumpScene = SCNScene(named: "art.scnassets/jump.scn")
        let idleScene = SCNScene(named: "art.scnassets/idleFixed.scn")
        let fightScene = SCNScene(named: "art.scnassets/boxing.scn")
        
        heartNode = heartScene?.rootNode
        diamondNode = diamondScene?.rootNode
        puppyNode = puppyScene?.rootNode
        danceNode = danceScene?.rootNode
        jumpNode = jumpScene?.rootNode
        idleNode = idleScene?.rootNode
        fightNode = fightScene?.rootNode
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Images", bundle: Bundle.main){
            configuration.detectionImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "count")
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: sceneView)
        
        addNodeAtLocation(location: location!)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let smth = SCNNode()
        token += 1
        
        if let imageAnchor = anchor as? ARImageAnchor {
            danceNode?.isHidden = true
            let node  = SCNNode()
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            node.addChildNode(planeNode)
            
            var shapeNode: SCNNode?
            var dudeNode: SCNNode?
            var moneyz: SCNText?
            var hmNode: SCNNode?
            
            if imageAnchor.referenceImage.name == "Code" {
                print("count added!")
                
                moneyz = SCNText(string: "\(token)", extrusionDepth: 9)

                let textNode = SCNNode(geometry: moneyz)
                
                dudeNode = danceNode
                
                hmNode = jumpNode
                                
                dudeNode?.scale = SCNVector3(0.02,0.02,0.02)
                hmNode?.scale = SCNVector3(0.02,0.02,0.02)
                
                guard let dude = dudeNode else { return nil }
                
                guard let hmDude = hmNode else { return nil }
                
                node.addChildNode(dude)
                node.addChildNode(hmDude)
                
                shapeNode = diamondNode
                shapeNode?.scale = SCNVector3(0.2,0.2,0.2)
                guard let shape = shapeNode else { return nil }
                textNode.scale = SCNVector3(0.15,0.15,0.15)
                textNode.pivot = SCNMatrix4MakeTranslation(3, -45, 0)
                
                dude.addChildNode(textNode)
                
                let daction = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(360)), z: 0, duration: 2)
                let dforever = SCNAction.repeatForever(daction)
                textNode.runAction(dforever)
                
                node.addChildNode(shape)
                                
                let action = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(360)), z: 0, duration: 2)
                let forever = SCNAction.repeatForever(action)
                shape.runAction(forever)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    danceNode?.isHidden = false
                    jumpNode?.isHidden = true
                }
                
                return node
                
                //loadAnimation(withKey: "dancing", sceneName: "art.scnassets/ppl/danceFixed", animationIdentifier: "dance-1")
            }
            if let planeAnchor = anchor as? ARPlaneAnchor {
                var node = SCNNode()
                planeGeometry = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
                planeGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
                
                let planeNode = SCNNode(geometry: planeGeometry)
                planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
                planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
                
                updateMaterial()
                
                node.addChildNode(planeNode)
                anchors.append(planeAnchor)
            }
            return node
        }
        return smth
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a custom object to visualize the plane geometry and extent.
        let plane = Plane(anchor: planeAnchor, in: sceneView)
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)
        anchors.append(planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = node.childNodes.first as? Plane
            else { return }
        
        // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }

        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(planeAnchor.extent.x)
            extentGeometry.height = CGFloat(planeAnchor.extent.z)
            plane.extentNode.simdPosition = planeAnchor.center
        }
    }
    
    func updateMaterial() {
        let material = self.planeGeometry.materials.first!
        
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(self.planeGeometry.width), Float(self.planeGeometry.height), 1)
    }
    
    func addNodeAtLocation (location:CGPoint){
        guard anchors.count > 0 else {print(anchors); return}
        
        let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        
        if hitResults.count > 0 {
            let result = hitResults.first!
            let newLocation = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y + 0.15, z: result.worldTransform.columns.3.z)
            idleNode?.scale = SCNVector3(0.05, 0.05, 0.05)
            guard let miiNode = idleNode else { return }
            idleNode?.position = newLocation
            
            sceneView.scene.rootNode.addChildNode(miiNode)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            idleNode = fightNode
    }
        
        
    }
    @IBAction func screenShot(_ sender: Any) {
        let snapShot = self.sceneView.snapshot()
        
        UIImageWriteToSavedPhotosAlbum(snapShot, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {
            print("Error Saving ARKit Scene \(error)")
        } else {
            print("ARKit Scene Successfully Saved")
        }
    }
}
