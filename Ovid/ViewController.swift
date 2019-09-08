//
//  ViewController.swift
//  WhereEver
//
//  Created by Jan Cho on 9/4/19.
//  Copyright © 2019 Jan Cho. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit
import MessageUI

class ViewController: UIViewController, ARSCNViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBAction func logoButton(_ sender: UIButton) {
        if let url = NSURL(string: "http://www.hubspot.com") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    var audioSource = SCNAudioSource(fileNamed: "HubSpot-AboutUs.mp3")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Not an environmental sound layer, so audio should stop when done
        audioSource.loops = false
        
        // Decode the audio from the disk ahead of time to prevent a delay in playback
        audioSource.load()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Find images to track
        if let imagesToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Cards", bundle: Bundle.main) {
            
            // Set our configuration and tell it that the image(s) it should be tracking is the one specified above
            configuration.trackingImages = imagesToTrack
            
            // Our configuration currently tracks only one image
            configuration.maximumNumberOfTrackedImages = 1
            
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // the anchor is the image that it found or recognized
        
        // Contains the virtual object to be placed in the real world
        let node = SCNNode()
        
        // imageAnchor is the harry potter image on the physical newspaper
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let videoNode = SKVideoNode(fileNamed: "HubSpot-AboutUs.mp4")
            
            videoNode.play()
            
            // the videoNode is a SpriteKit video node and we need to add that to a SceneKit element (SCNPlane below) so we can place the SceneKit element into our Scene View session. To do that, we need to create a new scene:
            // the CGSize is an estimation (480p x 360p in resolution)
            let videoScene = SKScene(size: CGSize(width: 480, height: 360))
            
            // Change videoNode's position relative to its parent. Set parameters to display dead center.
            videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
            
            // Flip video on the y axis so that it displays right side up
            videoNode.yScale = -1.0
            
            videoScene.addChild(videoNode)
            
            // Create plane on which to display the video, of same dimensions as reference image
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane.firstMaterial?.diffuse.contents = videoScene
            
            // Let this plane node have the geometry of the plane created above
            let planeNode = SCNNode(geometry: plane)
            
            // Plane always gets rendered at 90 degrees to the image recognized so we need to rotate it
            // Rotate it on its x dimension, counterclockwise by half pi (which is 90 degrees) so that it's flat and flush with the image recognized
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
            
            node.addAudioPlayer(SCNAudioPlayer(source: audioSource))
            
        }
        
        return node
        
    }
    
    
    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        if let url = NSURL(string: "http://www.hubspot.com") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        let items: [Any] = ["You should watch this video:", URL(string: "https://hubspot.hubs.vidyard.com/watch/Jgw4cuRZkXyuxZ3hQnoMAv?")!]
            
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(ac, animated: true)
        
    }
    
    
    @IBAction func contactButtonTapped(_ sender: UIBarButtonItem) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["manon@madkings.com"])
            mail.setSubject("Would love to learn more")
            mail.setMessageBody("<p>You're so awesome! Let's set up a meeting.</p>", isHTML: true)
            
            present(mail, animated: true)
            
        } else {
            print("couldn't send email")
            
            // show failure alert
            let alert = UIAlertController(title: "email error alert", message: "Email was not sent. Please try again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style:. default, handler: { _ in NSLog("The \"OK\" alert occurred.") }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
