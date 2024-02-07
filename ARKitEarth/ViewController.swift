//
//  ViewController.swift
//  ARKitEarth
//
//  Created by Attharva Kulkarni on 04/11/18.
//  Copyright © 2018 Attharva Kulkarni. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate,SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var planeGeometry:SCNPlane!
    var anchors = [ARAnchor]()
    var sceneLight:SCNLight!
    
    
    
    var mercuryNode = SCNNode()
    var venusNode = SCNNode()
    var earthNode = SCNNode()
    var marsNode = SCNNode()
    var jupiterNode = SCNNode()
    var saturnNode = SCNNode()
    var uranusNode = SCNNode()
    var neptuneNode = SCNNode()
    var sunNode = SCNNode()
    var voyagerNode = SCNNode()
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = false
        
        
        //  addTapGestureToSceneView()
        
        //sceneView.allowsCameraControl = true
        
        
        
        let scene = SCNScene(named: "art.scnassets/Scene.scn")!
        
        
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneLight = SCNLight()
        sceneLight.type = .omni
        
        let lightNode = SCNNode()
        lightNode.light = sceneLight
        lightNode.position = SCNVector3(x:0, y:10, z:2 )
        
        sceneView.scene.rootNode.addChildNode(lightNode)
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: sceneView)
        
        
        var doesNodeExist = false
        
        sceneView.scene.rootNode.enumerateChildNodes { (node,_) in
            if node.name == "voyager"{
                
                doesNodeExist = true
            }
        }
        if !doesNodeExist{
            addNodeAtLocation(location: location!)
            
            
            
            sceneView.scene.rootNode.enumerateChildNodes { (node,_) in
                if node.name == "ring"{
                    
                    configuration.planeDetection = []
                    sceneView.session.run(configuration)
                    planeNode.opacity = 0.0
                    
                }
            }
            
        }
    }
    
    
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let estimate = self.sceneView.session.currentFrame?.lightEstimate{
            sceneLight.intensity = estimate.ambientIntensity
        }
    }
    var planeNode = SCNNode()
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        var node:SCNNode?
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            node = SCNNode()
            node?.name = "floor"
            planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            planeGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.13)
            
            
            planeNode = SCNNode(geometry: planeGeometry)
            planeNode.position = SCNVector3(x:planeAnchor.center.x, y:0, z:planeAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi /
                2, 1, 0, 0)
            
            
            UpdateMaterial()
            
            node?.addChildNode(planeNode)
            anchors.append(planeAnchor)
        }
        
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            if anchors.contains(planeAnchor) {
                if node.childNodes.count > 0 {
                    let planeNode = node.childNodes.first!
                    planeNode.position = SCNVector3(x:planeAnchor.center.x, y:0,z:planeAnchor.center.z)
                    
                    if let plane = planeNode.geometry as? SCNPlane{
                        plane.width = CGFloat(planeAnchor.extent.x)
                        plane.height = CGFloat(planeAnchor.extent.z)
                        UpdateMaterial()
                    }
                }
            }
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        removeNode(named: "floor")
    }
    
    func removeNode(named:String){
        sceneView.scene.rootNode.enumerateChildNodes { (node,_) in
            if node.name == named{
                node.removeFromParentNode()
            }
            
        }
    }
    
    
    func UpdateMaterial() {
        let material = self.planeGeometry.materials.first!
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(self.planeGeometry.width), Float(self.planeGeometry.height), 1)
        
    }
    
    func addNodeAtLocation(location:CGPoint){
        guard anchors.count > 0 else {
            print("anchors are not created yet"); return
        }
        
        
        let hitResults = sceneView.hitTest(location, types:.existingPlaneUsingExtent)
        if hitResults.count > 0  {
            let result = hitResults.first!
            
            
            
            //sceneView.backgroundColor = .black
            
            
            
            var planets = ["mercury","venus","earth","mars","asteroid","jupiter","saturn","uranus","neptune","asteroid","blackhole"]
            var rings =  [0.085,0.168,0.27,0.3736,0.435,0.5,0.635,0.75,0.86,0.96,1]
            
            
            
            var sizes = [0.02,0.031,0.035,0.025,0.00002,0.05,0.045,0.04,0.0383,0.00002,0.07]
            
            var vortex = [0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.15,0.1,0.1,0.1]
            //var orbits = [1.2,0.8,0.5,0.4,0.9,0.7,0.5,0.4,0.3] jup 0.3
            var orbits = [1,0.7,0.5,0.4,0.3,0.09,0.07,0.05,0.04,0.3,0.03]
            
            for index in 0 ..< rings.count{
                let ring = CGFloat(rings[index])
                let size = sizes[index]
                let planet = planets[index]
                let vor = CGFloat(vortex[index])
                let orbit = CGFloat(orbits[index])
                
                let ringGeo = SCNTorus(ringRadius: ring, pipeRadius: 0.003 )//0.0033
                let ringNode = SCNNode(geometry: ringGeo)
                ringNode.name = "ring"
                
                sceneView.scene.rootNode.addChildNode(ringNode)
                
                let ringLocation = SCNVector3(result.worldTransform.columns.3.x,
                                              result.worldTransform.columns.3.y ,
                                              result.worldTransform.columns.3.z)
                ringNode.position = ringLocation
                sceneView.scene.rootNode.addChildNode(ringNode)
                
                
                let planetGeo = SCNSphere(radius: CGFloat(size))
                let planetNode = SCNNode(geometry: planetGeo)
                
                
                ringNode.addChildNode(planetNode)
                
                planetNode.position = SCNVector3(x: Float(ring), y: Float(vor), z: 0)
                planetGeo.firstMaterial?.diffuse.contents = UIImage(named: "texture_" + planet + ".jpg")
                planetGeo.firstMaterial?.normal.contents = UIColor.blue
                planetGeo.firstMaterial?.emission.contents = UIImage(named: "texture_" + "emission_" + planet + ".jpg")
                
                planetGeo.firstMaterial?.normal.contents = UIImage(named:"texture_" + "normal_" + planet + ".jpg" )
                
                planetGeo.firstMaterial?.specular.contents = UIImage(named: "texture_" + "specular_" + planet + ".jpg")
                planetGeo.firstMaterial?.transparency = 1
                planetGeo.firstMaterial?.isDoubleSided = true
                planetGeo.firstMaterial?.shininess = 50
                
                
                
                
                ringGeo.firstMaterial?.diffuse.contents = UIImage(named: "texture_" + planet + ".jpg")
                
                
                ringGeo.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.000001)  //0.000001
                
                //                ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                
                var moonNode:SCNNode!
                
                if index == 2{//0.123
                    
                    let moonRingGeo = SCNTorus(ringRadius: 0.053 , pipeRadius: 0.003)
                    let moonOrbitNode = SCNNode(geometry: moonRingGeo)
                    
                    planetNode.addChildNode(moonOrbitNode)
                    moonOrbitNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1.2, z: 0, duration: 1)))
                    
                    let moonGeo = SCNSphere(radius: CGFloat(0.013))
                    moonGeo.firstMaterial?.diffuse.contents = UIImage(named: "texture_moon.jpg")
                    moonGeo.firstMaterial?.emission.contents = UIImage(named: "texture_emission_moon.jpg")
                    moonGeo.firstMaterial?.normal.contents = UIColor.blue
                    moonGeo.firstMaterial?.isDoubleSided = true
                    moonGeo.firstMaterial?.transparency = 1
                    moonGeo.firstMaterial?.shininess = 50
                    
                    
                    moonNode = SCNNode(geometry: moonGeo)
                    moonOrbitNode.addChildNode(moonNode)
                    moonNode.position = SCNVector3(0.053, 0, 0)
                    print(moonOrbitNode.position)
                    
                    
                    moonRingGeo.firstMaterial?.diffuse.contents = UIImage(named: "texture_" + planet + ".jpg")
                    
                    moonRingGeo.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.000001) //0.0001
                    
                    let action = SCNAction.rotate(by: 360 * CGFloat(Double.pi / 180), around: SCNVector3(x:0, y:1, z:0), duration: 8)
                    let repeatAction = SCNAction.repeatForever(action)
                    planetNode.runAction(repeatAction)
                    
                    ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                    
                }
                
                if index == 4{
                    let stars = SCNParticleSystem(named: "Stars.scnp", inDirectory: nil)!
                    stars.isAffectedByGravity = false
                    // planetNode.addParticleSystem(stars)
//                          ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                }
                if index == 9{
                    let stars = SCNParticleSystem(named: "Stars.scnp", inDirectory: nil)!
                    stars.isAffectedByGravity = false
                    // planetNode.addParticleSystem(stars)
//                          ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                }
                
                
                
                
                
                
                
                if index == 10{
                    
                    
                    
                    let blackHoleEventDown = SCNNode()
                    // blackHoleEventDown.geometry = SCNTube(innerRadius: 0.7, outerRadius: 1.6, height:0.0002)
                    blackHoleEventDown.geometry = SCNTorus(ringRadius: 0.07, pipeRadius: 0.001)
                    
                    blackHoleEventDown.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                    let action = SCNAction.rotate(by: -360 * CGFloat(Double.pi / 180), around: SCNVector3(x:0, y:1, z:0), duration: 8)
                    let repeatAction = SCNAction.repeatForever(action)
                    blackHoleEventDown.runAction(repeatAction)
                    blackHoleEventDown.geometry?.firstMaterial?.shininess = 100
                    blackHoleEventDown.geometry?.firstMaterial?.transparency = 1
                    blackHoleEventDown.geometry?.firstMaterial?.isDoubleSided = true
                    
                    
                    blackHoleEventDown.position.y = 0.0025
                    
                    
                    
                    
                    let Geo1 = SCNSphere(radius: 0.001)
                    let sphereNode1 = SCNNode(geometry: Geo1)
                    sphereNode1.position.x =  0.08 //1.38
                    sphereNode1.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow.withAlphaComponent(0.0000001)
                    
                    let eventHorizonDownside1 = SCNParticleSystem(named: "fire2.scnp", inDirectory: nil)!
                    
                    sphereNode1.addParticleSystem(eventHorizonDownside1)
                    
                    
                    blackHoleEventDown.addChildNode(sphereNode1)
                    
                    /*
                     let Geo4 = SCNSphere(radius: 0.001)
                     let sphereNode4 = SCNNode(geometry: Geo4)
                     sphereNode4.position.x = 1.2
                     sphereNode4.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.0000001)
                     
                     let eventHorizonDownside4 = SCNParticleSystem(named: "fire2.scnp", inDirectory: nil)!
                     
                     sphereNode4.addParticleSystem(eventHorizonDownside4)
                     blackHoleEventDown.addChildNode(sphereNode4)
                     
                     
                     
                     
                     
                     
                     let Geo2 = SCNSphere(radius: 0.001)
                     let sphereNode2 = SCNNode(geometry: Geo2)
                     sphereNode2.position.x = 1
                     sphereNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.0000001)
                     
                     let eventHorizonDownside2 = SCNParticleSystem(named: "fire2.scnp", inDirectory: nil)!
                     
                     sphereNode2.addParticleSystem(eventHorizonDownside2)
                     blackHoleEventDown.addChildNode(sphereNode2)
                     
                     let Geo3 = SCNSphere(radius: 0.001)
                     let sphereNode3 = SCNNode(geometry: Geo3)
                     sphereNode3.position.x = 0.75
                     sphereNode3.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.0000001)
                     
                     
                     let eventHorizonDownside3 = SCNParticleSystem(named: "fire2.scnp", inDirectory: nil)!
                     
                     sphereNode3.addParticleSystem(eventHorizonDownside3)
                     blackHoleEventDown.addChildNode(sphereNode3)
                     
                     
                     */
                    
                    let blackHoleEventUp = SCNNode()
                    blackHoleEventUp.geometry = SCNTube(innerRadius: 0.07, outerRadius:  0.08, height:0.0002)
                    
                    
                    blackHoleEventUp.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                    blackHoleEventUp.eulerAngles.z = -4.6
                    blackHoleEventUp.geometry?.firstMaterial?.shininess = 50
                    blackHoleEventUp.geometry?.firstMaterial?.transparency = 1
                    blackHoleEventUp.geometry?.firstMaterial?.isDoubleSided = true
                    
                    let action1 = SCNAction.rotate(by: -360 * CGFloat(Double.pi / 180), around: SCNVector3(x:1, y:0, z:0), duration: 8)
                    let repeatAction1 = SCNAction.repeatForever(action1)
                    blackHoleEventUp.runAction(repeatAction1)
                    
                    
                    blackHoleEventUp.position.y = -0.0078   //0.008
                    
                    
                    
                    let dummy2 = SCNSphere(radius: 0.001)
                    let dummy2Node = SCNNode(geometry: dummy2)
                    dummy2Node.position.x = 0.079
                    
                    dummy2Node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow.withAlphaComponent(0.0000001)
                    
                    blackHoleEventUp.addChildNode(dummy2Node)
                    let eventHorizonUpside = SCNParticleSystem(named: "fir.scnp", inDirectory: nil)!
                    dummy2Node.addParticleSystem(eventHorizonUpside)
                    
                    planetNode.addChildNode(blackHoleEventDown)
                    planetNode.addChildNode(blackHoleEventUp)
                    planetNode.eulerAngles.z = -3
                    
                    
                    
                    
                    
                    
                    
                    
                    let blackHoleEventUp2 = SCNNode()
                    blackHoleEventUp2.geometry = SCNTube(innerRadius: 0.05, outerRadius:  0.062, height:0.0002)
                    
                    blackHoleEventUp2.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                    blackHoleEventUp2.eulerAngles.z = -4.6
                    blackHoleEventUp2.geometry?.firstMaterial?.shininess = 50
                    blackHoleEventUp2.geometry?.firstMaterial?.transparency = 1
                    blackHoleEventUp2.geometry?.firstMaterial?.isDoubleSided = true
                    
                    
                    blackHoleEventUp2.position.y = -0.015
                    
                    
                    
                    
                    planetNode.addChildNode(blackHoleEventUp2)
                    
                    
                    
                }
                
                
                
                
                
                
                if index == 3{
                    ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                }
                if index == 0{
                    ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                }
                if index == 1{
                    ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                }
                
                
                
                if index == 6{
                    let saturnRing1 = SCNNode()
                    saturnRing1.geometry = SCNTube(innerRadius:0.052, outerRadius: 0.06, height:0.002)
                    
                    saturnRing1.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture_saturn.jpg")
                    
                    saturnRing1.geometry?.firstMaterial?.shininess = 50
                    saturnRing1.geometry?.firstMaterial?.transparency = 1
                    saturnRing1.geometry?.firstMaterial?.isDoubleSided = true
                    saturnRing1.geometry?.firstMaterial?.emission.contents = UIImage(named: "texture_saturn.jpg")
                    
                    
                    
                    let action1 = SCNAction.rotateBy(x: 0, y: orbit + 1 , z: 0, duration: 0.001)
                    ringNode.runAction(action1)
                    ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                    
                    
                    
                    
                    
                    planetNode.addChildNode(saturnRing1)
                    planetNode.eulerAngles.z = -2.5
                    let action = SCNAction.rotate(by: 360 * CGFloat(Double.pi / 180), around: SCNVector3(x:0, y:1, z:0), duration: 8)
                    let repeatAction = SCNAction.repeatForever(action)
                    planetNode.runAction(repeatAction)
                    
                }
                
                if index == 5{
                    let action = SCNAction.rotate(by: 360 * CGFloat(Double.pi / 180), around: SCNVector3(x:0, y:1, z:0), duration: 8)
                    let repeatAction = SCNAction.repeatForever(action)
                    planetNode.runAction(repeatAction)
                    ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                    
                    
                }
                
                if index == 7{
                    //  ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                    //1.3
                    let action1 = SCNAction.rotateBy(x: 0, y: orbit + 2.5 , z: 0, duration: 0.001)
                    ringNode.runAction(action1)
                    ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                    
                }
                if index == 8{
                    
                    let action1 = SCNAction.rotateBy(x: 0, y: orbit + 3.5 , z: 0, duration: 0.001)
                    ringNode.runAction(action1)
                    ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))
                    
                    //                    let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                    //                    planetNode.physicsBody = physicsBody
                    //                    planetNode.name = "nep"
                    //                    physicsBody.isAffectedByGravity = false;
                    
                }
                
                
                if index == 0 {mercuryNode = planetNode }
                if index == 1 {venusNode = planetNode }
                if index == 2 {earthNode = planetNode }
                if index == 3 {marsNode = planetNode }
                if index == 5 {jupiterNode = planetNode }
                if index == 6 {saturnNode = planetNode }
                if index == 7 {uranusNode = planetNode }
                if index == 8 {neptuneNode = planetNode }
            }
            
            
            
            
            let sunGeo = SCNSphere(radius: 0.0675)
            sunNode.geometry = sunGeo
            sunNode.position = SCNVector3(result.worldTransform.columns.3.x , result.worldTransform.columns.3.y + 0.05, result.worldTransform.columns.3.z)
                        sunGeo.firstMaterial?.diffuse.contents = UIImage(named: "sunE.jpg")
          
            sunGeo.firstMaterial?.isDoubleSided = true
            sunGeo.firstMaterial?.transparency = 1
            sunGeo.firstMaterial?.shininess = 50
            sunNode.name = "sun"
            
            
            sceneView.scene.rootNode.addChildNode(sunNode)
            
            
            
            
            
            
            
            voyagerNode = sceneView.scene.rootNode.childNode(withName: "mainContainer", recursively: false)!
            
            
            voyagerNode.isHidden = false
            
            
            
            
            
            
            voyagerNode.position = SCNVector3(result.worldTransform.columns.3.x + 0.5 , result.worldTransform.columns.3.y + 0.1, result.worldTransform.columns.3.z)
            
            
            
            
            
            
            //y 0.03 dur 5
            
            
            let action1 = SCNAction.moveBy(x: 0, y:  0.02, z: 0 , duration: 3)
            
            
            
            let action2 = SCNAction.moveBy(x: 0 , y: 0 , z: CGFloat(jupiterNode.position.z - 0.35) , duration: 5)
            
            
            
            
            
            
            //   let action3 = SCNAction.moveBy(x: -0.1, y: -0.1, z: 0, duration: 3)
            
            let action4 = SCNAction.moveBy(x: -0.3, y: 0, z: -0.1, duration: 4)
            //saturn
            let action5 = SCNAction.moveBy(x: -0.22, y:0, z: 0, duration: 3)
            
            let action6 = SCNAction.moveBy(x: -0.1, y: 0, z: 0.05, duration: 3)
            //uranus
            
            let action7 = SCNAction.moveBy(x:-0.2 , y: 0, z: 0.65, duration: 4)
            
            let action8 = SCNAction.rotateTo(x: 0, y: 1, z: 0, duration: 4)
            // let action7 = SCNAction.moveBy(x: -0.5, y: 0.5, z: 0.5, duration: 3)
            
            let action9 = SCNAction.moveBy(x: 0.35, y: 0, z: 0.273, duration: 5)
            
            let action10 = SCNAction.rotateTo(x: 0, y: 2, z: 0, duration: 2)
            
            let action11 = SCNAction.moveBy(x: 2.5, y: -3, z: 0, duration: 6)
            
            let voyagerAction = SCNAction.sequence([action1,action2,action4,action5,action6,action7,action8,action9,action10,action11])
            
            
            
            sceneView.scene.rootNode.addChildNode(voyagerNode)
            
     
            
            voyagerAction.timingMode = .easeInEaseOut
            voyagerNode.runAction(voyagerAction)
            
            voyagerNode.name = "voyager"
            
            
            
            
            
            
            /*
             
             voyagerNode.name = "voyager"
             voyagerNode.position = SCNVector3(sunNode.position.x , sunNode.position.y, sunNode.position.z)
             
             
             
             //voyagerNode.pivot = SCNMatrix4MakeTranslation(0,0,0)
             
             
             
             voyagerNode.pivot = SCNMatrix4Translate(SCNMatrix4MakeTranslation(0.1,0,0), 0.15, 0, 0)
             
             
             
             let ar = SCNAction.rotate(by: 360 * CGFloat(Double.pi / 180), around: SCNVector3(x:0, y:10, z:0), duration: 30)
             let repion = SCNAction.repeatForever(ar)
             voyagerNode.runAction(repion)
             
             
             */
            
            // Timer.scheduledTimer(timeInterval: 25, target: self, selector: #selector(tiltAngle), userInfo: nil, repeats: false)
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            

            var commetBelts = ["star"]
            var commetRings = [0.94]
            var commetSize = [0.00002]
            var commetOrbits = [0.4]
            
            for index in 0 ..< commetRings.count {
                let ring = CGFloat(commetRings[index]);
                let size = commetSize[index]
                let commet = commetBelts[index]

                let orbit = CGFloat(commetOrbits[index])

                let ringGeo = SCNTorus(ringRadius: ring, pipeRadius: 0.000003)
                let ringNode = SCNNode(geometry: ringGeo)
                ringNode.name = "comet"
                ringNode.eulerAngles.z = -29.85
                ringNode.position.x = 7

                let ringLocation = SCNVector3(result.worldTransform.columns.3.x,
                                              result.worldTransform.columns.3.y ,
                                              result.worldTransform.columns.3.z)
                ringNode.position = ringLocation
                ringGeo.firstMaterial?.diffuse.contents = UIImage(named:"texture_earth.jpg")
                ringGeo.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.00000001)




                ringNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: orbit, z: 0, duration: 1)))

                sceneView.scene.rootNode.addChildNode(ringNode)



                let stars = SCNParticleSystem(named: "fire.scnp", inDirectory: nil)!
                stars.isAffectedByGravity = false





                let planetGeo = SCNSphere(radius: CGFloat(size))
                let planetNode = SCNNode(geometry: planetGeo)
                ringNode.addChildNode(planetNode)
                planetNode.position = SCNVector3(x: Float(ring), y: 0, z: 0)
                planetGeo.firstMaterial?.diffuse.contents = UIImage(named: commet + ".png")

                planetNode.addParticleSystem(stars)

            }
            
        }
        
        
        
    }
    
    @objc func tiltAngle(){
        
        
        
        
        
    }
    
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

