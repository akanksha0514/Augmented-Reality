//
//  ViewController.swift
//  World Tracking
//
//  Created by akanksha on 11/12/17.
//

import UIKit
import ARKit
import SceneKit
class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var arScene: ARSCNView!
    @IBOutlet weak var lblPlane: UILabel!
    var portalNode = SCNNode()
    
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arScene.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin] //starting
        self.configuration.planeDetection = .horizontal
        self.arScene.session.run(configuration)
        self.arScene.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.arScene.addGestureRecognizer(tapGesture)
        
    }
    
   @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitResult.isEmpty{ //hittestresult is not empty
            //add room
            self.addPortal(hitResult: hitResult.first!)
        }
        else{
            
        }
    }
    
    func addPortal(hitResult: ARHitTestResult){
        let portalScn = SCNScene(named: "Portal.scnassets/portal.scn")
        portalNode = portalScn!.rootNode.childNode(withName: "portal", recursively: false)!
        let transform = hitResult.worldTransform
        let positionX = transform.columns.3.x
        let positionY = transform.columns.3.y
        let positionZ = transform.columns.3.z
        portalNode.position = SCNVector3Make(positionX, positionY, positionZ)
        self.arScene.scene.rootNode.addChildNode(portalNode)
        self.addPlane(nodeName: "roof", portalNode: portalNode, image: "TOP_A")
        self.addPlane(nodeName: "floor", portalNode: portalNode, image: "DOWN_B")
        self.addWall(nodeName: "wall2", portalNode: portalNode, image: "LEFT_B")
        self.addWall(nodeName: "wall1", portalNode: portalNode, image: "RIGHT_B")
        self.addWall(nodeName: "backWall", portalNode: portalNode, image: "FRONT_B")
        self.addWall(nodeName: "entrance", portalNode: portalNode, image: "ENTRANCE_B")
        self.addWall(nodeName: "red carpet", portalNode: portalNode, image: "Red carpet")
        self.addWall(nodeName: "object", portalNode: portalNode, image: "perfume")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addObject))
        self.arScene.addGestureRecognizer(tapGesture)
    }
    
    func addMultipleObj(){

    }
    
    @objc func addObject(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: arScene)
        let hitResult = sceneView.hitTest(touchLocation, options: nil)
        if !hitResult.isEmpty{ //hittestresult is not empty
            let lastNode = hitResult.last?.node
            print("hitresult\(hitResult)")
            if lastNode?.name == "object"
            {
                let layer = CALayer()
                layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                layer.backgroundColor = UIColor.white.cgColor
                let textLayer = CATextLayer()
                textLayer.frame = layer.bounds
                textLayer.foregroundColor = UIColor.black.cgColor
                textLayer.fontSize = 5.0
                textLayer.font = UIFont.fontNames(forFamilyName: "HelveticaNeue-Light") as CFTypeRef
                textLayer.alignmentMode = kCAAlignmentLeft
                layer.contentsScale = UIScreen.main.scale
                textLayer.contentsScale = UIScreen.main.scale

                textLayer.string = """
                 Spoon: clay material
                 - This ceramic spoon
                 manually of white
                 burnt using milk.
                 - The master dips
                 item into the cream
                """
                textLayer.display()
                textLayer.allowsFontSubpixelQuantization = true 
                layer.addSublayer(textLayer)
                
                let planeGeometry = SCNPlane(width: 0.7, height: 0.7)
                let planeNode = SCNNode(geometry: planeGeometry)
                planeGeometry.firstMaterial?.locksAmbientWithDiffuse = true
                let materialText = SCNMaterial()
                materialText.diffuse.contents = UIColor.lightGray
                let materialColor = SCNMaterial()
                materialColor.diffuse.contents = layer
                planeGeometry.materials = [materialColor,materialText]
                
                let x = (lastNode?.position.x)! - 0.1

                let animationx = self.animate(fromValue: 0.5, toValue: 1, duration: 2.0, node: planeNode, key: "transform.scale.x")
                let animationy = self.animate(fromValue: 0.5, toValue: 1, duration: 2.0, node: planeNode, key: "transform.scale.y")
                let animationOpacity = self.animate(fromValue: 0.3, toValue: 1.0, duration: 2.0, node: planeNode, key: "opacity")

                let animationPos = CABasicAnimation(keyPath: "position")
                animationPos.fromValue = SCNVector3Make((lastNode?.position.x)!, (lastNode?.position.y)!, (lastNode?.position.z)!)
                animationPos.toValue = SCNVector3Make(x, (lastNode?.position.y)!, (lastNode?.position.z)!)
                animationPos.duration = 1.0

                planeNode.addAnimation(animationx, forKey: "transform.scale.x")
                planeNode.addAnimation(animationy, forKey: "transform.scale.y")
                planeNode.addAnimation(animationOpacity, forKey: "opacity")
                planeNode.addAnimation(animationPos, forKey: "position")
                
                
                planeNode.position = SCNVector3(x, (lastNode?.position.y)!, (lastNode?.position.z)!)
                planeNode.eulerAngles = SCNVector3((lastNode?.eulerAngles.x)!, (lastNode?.eulerAngles.y)!, (lastNode?.eulerAngles.z)!)
                let child = portalNode.childNode(withName: "red carpet", recursively: true)
                child?.addChildNode(planeNode)
            }
        }
        else{
            
        }
    }
    
    func animate(fromValue: Double, toValue: Double, duration: CFTimeInterval, node: SCNNode, key: String) -> CABasicAnimation {
        let animationPos = CABasicAnimation(keyPath: key)
        animationPos.fromValue = fromValue
        animationPos.toValue = toValue
        animationPos.duration = duration
        return animationPos
    }
    
    func addPlane(nodeName: String, portalNode: SCNNode, image: String){
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(image).png")
    }
    
    func addWall(nodeName: String, portalNode: SCNNode, image: String){
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(image).png")
    }

    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        print("heyy")
        DispatchQueue.main.async {
            self.lblPlane.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.lblPlane.isHidden = true
        }
    }

}

