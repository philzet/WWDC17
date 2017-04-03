//: # Playground project for WWDC 2017 Scholarship
//: Created by *Philipp Zakharchenko* (also known as *Phil Zet*).

import Foundation
import UIKit
import SceneKit
import SpriteKit
import PlaygroundSupport
import CoreMotion
import AVFoundation
import AudioToolbox

//: `StoryScene` is the main view of the Playground. It controls the execution, its timing, and manipulates objects.
class StoryScene: SCNView {
	
	var varBoxNode = VarBox()
	var letBoxNode = LetBox()
	var objArray = [SCNNode?]()
	
	var cameraNode = SCNNode()
	
	var canExplode = true
	var canBuild = true
	
	// The initializer takes a camera node object as an argument
	init(cameraNode: SCNNode) {
		
		// Setting up the scene, camera and `liveView`
		super.init(frame: CGRect(x: 0, y: 0, width: 750, height: 750), options: [SCNView.Option.preferredRenderingAPI.rawValue: SCNRenderingAPI.metal.rawValue])
		
		self.cameraNode = cameraNode
		
		PlaygroundPage.current.needsIndefiniteExecution = true
		PlaygroundPage.current.liveView = self
		
	}
	
	func executeScenario() {
		
		super.scene = SCNScene()
		
		autoenablesDefaultLighting = true
		
		self.cameraNode.camera = SCNCamera()
		self.cameraNode.light = SCNLight()
		self.cameraNode.light?.type = SCNLight.LightType.ambient
		self.cameraNode.light?.color =  UIColor(white: 0.0005, alpha: 1.0)
		self.cameraNode.position = SCNVector3(x: 0, y: 0, z: 100)
		
		scene?.rootNode.addChildNode(self.cameraNode)
		
		// Setting up the first scene: Rotating planet Earth
		let sphere = SCNSphere(radius: 5.0)
		let earthNode = SCNNode(geometry: sphere)
		scene?.rootNode.addChildNode(earthNode)
		
		sphere.firstMaterial?.lightingModel = SCNMaterial.LightingModel.physicallyBased
		sphere.firstMaterial?.diffuse.contents = UIImage(named: "earth.jpg")
		sphere.firstMaterial?.normal.contents = UIImage(named: "earth-normal.jpg")
		sphere.firstMaterial?.specular.contents = UIImage(named: "earth-spec.jpg")
		sphere.firstMaterial?.specular.intensity = 0.25
		
		earthNode.rotation = SCNVector4(x: 1, y: 1.0, z: 0, w: 0)
		
		let sphereClouds = SCNSphere(radius: 5.1)
		sphereClouds.firstMaterial?.diffuse.contents = UIImage(named: "clouds.png")
		let cloudsNode = SCNNode(geometry: sphereClouds)
		scene?.rootNode.addChildNode(cloudsNode)
		
		cloudsNode.rotation = SCNVector4(x: 1, y: 1.0, z: 0, w: 0)
		
		let spin = CABasicAnimation(keyPath: "rotation.w")
		spin.toValue = 2*M_PI
		spin.duration = 35
		spin.repeatCount = HUGE
		earthNode.addAnimation(spin, forKey: "spin")
		
		let spinFast = CABasicAnimation(keyPath: "rotation.w")
		spinFast.toValue = 2*M_PI
		spinFast.duration = 30
		spinFast.repeatCount = HUGE
		cloudsNode.addAnimation(spinFast, forKey: "spinFast")
		
		let backgroundImage = UIImage(named: "space.jpg")
		scene?.background.contents = backgroundImage
		
		let environment = UIImage(named: "space.jpg")
		scene?.lightingEnvironment.contents = environment
		scene?.lightingEnvironment.intensity = 2.0
		
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light?.type = .ambient
		lightNode.light?.color = #colorLiteral(red: 1, green: 0.984990326, blue: 0.8418862264, alpha: 1)
		lightNode.position = SCNVector3(x: -1, y: 1, z: 20)
		scene?.rootNode.addChildNode(lightNode)
		
		let skScene = SKScene(size: CGSize(width: self.bounds.width, height: self.bounds.height))
		
		let label = TutorialLabel()
		label.displayCentered(width: skScene.size.width, height: skScene.size.height - 150.0)
		skScene.addChild(label)
		
		self.overlaySKScene = skScene
		self.overlaySKScene?.scaleMode = .aspectFill
		
		var whiteSquareSpace = UIView()
		
		let audioSession = AVAudioSession.sharedInstance()
		
		let audioSource = SCNAudioSource(named: "music.mp3")
		let audioPlayer = SCNAudioPlayer(source: audioSource!)
		self.scene?.rootNode.addAudioPlayer(audioPlayer)
		
		label.threeMessagesSequence(messages: ["Hello.", "You are about to land on Earth", "Tilt the iPad to control the spaceship"])
		
		let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 6), duration: 16.5)
		moveTo.timingMode = .easeIn
		self.cameraNode.runAction(moveTo)
		
		// Setting up the transition (fade to white)
		
		Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { (timer) in
			whiteSquareSpace = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
			
			whiteSquareSpace.backgroundColor = UIColor.white
			whiteSquareSpace.alpha = 0.0
			self.addSubview(whiteSquareSpace)
			
			UIView.animate(withDuration: 3.0, delay: 0.0, options: [.curveEaseInOut], animations: {
				whiteSquareSpace.alpha = 1.0
			}, completion: nil)
		}
		
		Timer.scheduledTimer(withTimeInterval: 18.0, repeats: false) { (timer) in
			self.scene?.background.contents = nil
			lightNode.removeFromParentNode()
			earthNode.removeFromParentNode()
			cloudsNode.removeFromParentNode()
			label.fontColor = SKColor.black
			
			self.cameraNode.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
			
			label.displayCentered(width: skScene.size.width, height: skScene.size.height)
			
			Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
				whiteSquareSpace.alpha = 0.0
				label.threeMessagesSequence(messages: ["It is year 2117", "Swift is a global language", "Let's explore its basics"])
			}
			
			Timer.scheduledTimer(withTimeInterval: 9.0, repeats: false) { (timer) in
				
				whiteSquareSpace.alpha = 1.0
				UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
					whiteSquareSpace.alpha = 0.0
				}, completion: nil)
				
				// The second scene: rotating tappable var and let boxes
				Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { (timer) in
					let cur = self.cameraNode.rotation
					self.cameraNode.runAction(SCNAction.rotate(toAxisAngle: SCNVector4Make(0, 0, 1, cur.w - Float(M_PI_4 * 0.5)), duration: 3.0))
				}
				
				let backgroundImage = UIImage(named: "blurred-view.jpg")
				self.scene?.background.contents = backgroundImage
				
				let environment = UIImage(named: "blurred-view.jpg")
				self.scene?.lightingEnvironment.contents = environment
				self.scene?.lightingEnvironment.intensity = 2.0
				
				// Creating an ambient light
				let ambientLight = SCNLight()
				ambientLight.type = SCNLight.LightType.ambient
				ambientLight.intensity = 700.0
				ambientLight.color = UIColor.white
				ambientLight.castsShadow = true
				let ambientLightNode = SCNNode()
				ambientLightNode.light = ambientLight
				
				self.scene?.rootNode.addChildNode(ambientLightNode)
				
				// Creating an omni-directional light
				let omniLight = SCNLight()
				omniLight.type = SCNLight.LightType.omni
				omniLight.intensity = 700.0
				omniLight.color = UIColor.white
				omniLight.castsShadow = true
				let omniLightNode = SCNNode()
				omniLightNode.light = omniLight
				omniLightNode.position = SCNVector3(x: -10.0, y: 20, z: 10.0)
				
				self.scene?.rootNode.addChildNode(omniLightNode)
				
				self.cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
				self.cameraNode.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
				
				self.scene?.rootNode.addChildNode(self.varBoxNode)
				self.scene?.rootNode.addChildNode(self.letBoxNode)
				
				label.displayAtTheTop(width: skScene.size.width, height: skScene.size.height)
				
				label.fontColor = UIColor.white
				
			}
			
		}
		
		Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { (timer) in
			Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
				label.threeMessagesSequence(messages: ["Var is a variable", "Let is a constant", "Tap the boxes to feel the difference"])
			}
			
			// Transition to the third scene
			Timer.scheduledTimer(withTimeInterval: 11.0, repeats: false) { (timer) in
				let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 18), duration: 2.0)
				moveTo.timingMode = .easeInEaseOut
				self.cameraNode.runAction(moveTo)
				Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { (timer) in
					let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: -4), duration: 0.7)
					moveTo.timingMode = .easeInEaseOut
					self.cameraNode.runAction(moveTo)
				}
			}
		}
		
		// The third scene: a field of metal and wooden spheres. Wooden spheres explode on tap
		Timer.scheduledTimer(withTimeInterval: 45.5, repeats: false) { (timer) in
			self.varBoxNode.removeFromParentNode()
			self.letBoxNode.removeFromParentNode()
			
			label.displayCentered(width: skScene.size.width, height: skScene.size.height)
			
			let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 15), duration: 0.7)
			moveTo.timingMode = .easeInEaseOut
			self.cameraNode.runAction(moveTo)
			
			let defaultSphere = SCNSphere(radius: 1.0)
			defaultSphere.firstMaterial?.diffuse.contents = UIImage(named: "metal.jpg")
			
			let explodingSphere = SCNSphere(radius: 1.0)
			explodingSphere.firstMaterial?.lightingModel = SCNMaterial.LightingModel.physicallyBased
			explodingSphere.firstMaterial?.diffuse.contents = UIImage(named: "wood.jpg")
			
			let env = UIImage(named: "blurred-view.jpg")
			self.scene?.lightingEnvironment.contents = env
			self.scene?.lightingEnvironment.intensity = 2.0
			
			let fieldArea = 31
			var coordinates = [-fieldArea, -fieldArea]
			var counter = 0
			
			while coordinates[1] <= fieldArea {
				
				let chance = Int(arc4random_uniform(2) + 1)
				
				self.objArray.append(SCNNode(geometry: defaultSphere))
				
				self.objArray[counter]?.name = "defaultSphere"
				if chance == 1 {
					self.objArray[counter]? = SCNNode(geometry: explodingSphere)
					self.objArray[counter]?.name = "explodingSphere"
				}
				
				self.objArray[counter]?.position = SCNVector3(x: Float(coordinates[0]), y: Float(coordinates[1]), z: 0)
				self.scene?.rootNode.addChildNode(self.objArray[counter]!)
				
				coordinates[0] += 3
				
				if coordinates[0] > fieldArea {
					coordinates[0] = -fieldArea
					coordinates[1] += 3
				}
				counter += 1
				
			}
			
			Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { (timer) in
				
				label.threeMessagesSequence(messages: ["The object explodes IF it is wooden", "This is called condition", "Try tapping the spheres"])
				
			}
			
			// Setting up random auto-explosion of the spheres
			Timer.scheduledTimer(withTimeInterval: 12.0, repeats: false) { (timer) in
				
				let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 35), duration: 5.0)
				moveTo.timingMode = .easeInEaseOut
				self.cameraNode.runAction(moveTo)
				
				Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (timer) in
					
					var delay = 0.0
					
					self.objArray = self.objArray.shuffled()
					for item in self.objArray {
						if item != nil {
							let currentItem = item as! SCNNode
							if currentItem.name == "explodingSphere" {
								Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { (timer) in
									self.explodeSphere(hitNode: currentItem)
								}
								delay += 0.08
							}
						}
						
					}
					
				}
				
			}
			
			Timer.scheduledTimer(withTimeInterval: 21.0, repeats: false) { (timer) in
				label.threeMessagesSequence(messages: ["Now all wooden objects are exploding", "This occurs WHILE there's something left", "This is a loop"])
				
				//: Transition from the third scene
				Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { (timer) in
					let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: -30), duration: 2.0)
					moveTo.timingMode = .easeInEaseOut
					self.cameraNode.runAction(moveTo)
					
					Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false) { (timer) in
						self.canExplode = false
					}
					
				}
			}
			
		}
		
		// Setting up the bricks scene
		Timer.scheduledTimer(withTimeInterval: 77.0, repeats: false) { (timer) in
			
			for item in self.objArray {
				item?.removeFromParentNode()
			}
			self.objArray = [SCNNode?]()
			
			let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 15), duration: 0.7)
			moveTo.timingMode = .easeInEaseOut
			self.cameraNode.runAction(moveTo)
			
			// Adding first brick
			let brick = Brick()
			brick.position = SCNVector3(x: 0, y: 0, z: 0)
			self.objArray.append(brick)
			self.scene?.rootNode.addChildNode(brick)
			
			let fieldArea = 30
			var coordinates = [-fieldArea, -fieldArea]
			var counter = 0
			
			while coordinates[1] <= fieldArea {
				
				self.objArray.append(Brick())
				self.objArray[counter + 1]?.position = SCNVector3(x: Float(coordinates[0]), y: Float(coordinates[1]), z: 0)
				self.objArray[counter + 1]?.name = "brick"
				
				coordinates[0] += 2
				
				if coordinates[0] > fieldArea {
					coordinates[0] = -fieldArea
					coordinates[1] += 2
				}
				counter += 1
				
			}
			
			Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
				label.singleMessageSequence(message: "This is a brick")
			}
			
			Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
				
				self.canExplode = false
				
				Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
					label.threeMessagesSequence(messages: ["Imagine you need to build a wall", "A wall consists of many similar bricks", "A wall is an ARRAY of bricks"])
				}
				
				var delay = 0.0
				
				// Bricks random appearance and dust effect
				self.objArray = self.objArray.shuffled()
				for item in self.objArray {
					if item != nil {
						Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { (timer) in
							
							if self.canBuild {
								self.scene?.rootNode.addChildNode(item!)
								
								let particleSystem = SCNParticleSystem(named: "Dust", inDirectory: nil)
								let systemNode = SCNNode()
								systemNode.addParticleSystem(particleSystem!)
								systemNode.position = item!.position
								self.scene?.rootNode.addChildNode(systemNode)
							
							}
							
						}
						delay += 0.015
					}
				}
				
			}
			
			// Sorting scene
			Timer.scheduledTimer(withTimeInterval: 12.0, repeats: false) { (timer) in
				let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 20), duration: 2.0)
				moveTo.timingMode = .easeInEaseOut
				self.cameraNode.runAction(moveTo)
				
				Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { (timer) in
					
					label.threeMessagesSequence(messages: ["Arrays can be manipulated easily", "You can iterate through items to modify them", "You can also sort objects"])
					
					var counter = 0
					var normalBricks = [Brick]()
					var lighterBricks = [Brick]()
					
					while counter < self.objArray.count {
						
						if counter % 2 == 0 {
							let current = (self.objArray[counter] as! Brick)
							current.changeColor()
							lighterBricks.append(current)
						} else {
							normalBricks.append(self.objArray[counter] as! Brick)
						}
						
						counter += 1
						
					}
					
					// moving lighter bricks backwards
					Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { (timer) in
						for item in lighterBricks {
							item.moveBackwards()
						}
					}
					
					// Sorting lighter bricks
					
					let fieldArea = 30
					
					Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (timer) in
						
						var coordinates = [-fieldArea, -fieldArea]
						var counter = 0
						
						for item in lighterBricks {
							
							let move = SCNAction.move(to: SCNVector3(x: Float(coordinates[0]), y: Float(coordinates[1]), z: -2.0), duration: 2.0)
							move.timingMode = .easeInEaseOut
							item.runAction(move)
							
							coordinates[0] += 2
							
							if coordinates[0] >= 0 {
								coordinates[0] = -fieldArea
								coordinates[1] += 2
							}
							counter += 1
							
						}
						
					}
					
					// Sorting normal bricks
					
					Timer.scheduledTimer(withTimeInterval: 6.5, repeats: false) { (timer) in
					
						coordinates = [0, -fieldArea]
						counter = 0
						
						for item in normalBricks {
							
							let move = SCNAction.move(to: SCNVector3(x: Float(coordinates[0]), y: Float(coordinates[1]), z: -2.0), duration: 2.0)
							move.timingMode = .easeInEaseOut
							item.runAction(move)
							
							coordinates[0] += 2
							
							if coordinates[0] > fieldArea {
								coordinates[0] = 0
								coordinates[1] += 2
							}
							counter += 1
							
						}
					}
					
					// moving green bricks forwards
					Timer.scheduledTimer(withTimeInterval: 9.0, repeats: false) { (timer) in
						for item in lighterBricks {
							item.moveForwards()
						}
					}
				}
				
				// Crash effect and transition from the scene
				Timer.scheduledTimer(withTimeInterval: 18.0, repeats: false) { (timer) in
					
					let particleSystem = SCNParticleSystem(named: "Dust-large", inDirectory: nil)
					let systemNode = SCNNode()
					systemNode.addParticleSystem(particleSystem!)
					systemNode.position = SCNVector3(x: 0, y: 0, z: 0)
					self.scene?.rootNode.addChildNode(systemNode)
					
					SystemSoundID.playFileNamed(fileName: "brick-crash", withExtenstion: "mp3")
					
					Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
						
						let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: -30), duration: 1.0)
						self.cameraNode.runAction(moveTo)

					}
					
				}
			}
			
		}
		
		// Adding fireworks particle systems after the transition from the bricks scene
		Timer.scheduledTimer(withTimeInterval: 109.0, repeats: false) { (timer) in
			
			self.canBuild = false
			
			for item in self.objArray {
				item?.removeFromParentNode()
			}
			self.objArray = [SCNNode?]()
			
			let coord = [SCNVector3(x: 5, y: 4, z: -50),
			             SCNVector3(x: -3, y: 8, z: -46),
			             SCNVector3(x: 8, y: -2, z: -53),
			             SCNVector3(x: -12, y: 4, z: -57),
			             SCNVector3(x: 16, y: 14, z: -48),
			             SCNVector3(x: 8, y: 15, z: -54),
			             SCNVector3(x: 0, y: -2, z: -48)]
			var option = "red"
			var delay = 0.0
			
			for c in coord {
				
				Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { (timer) in
					
					let particleSystem = SCNParticleSystem(named: "Firework-\(option)", inDirectory: nil)
					let systemNode = SCNNode()
					systemNode.addParticleSystem(particleSystem!)
					systemNode.position = c as! SCNVector3
					self.scene?.rootNode.addChildNode(systemNode)
					
					SystemSoundID.playFileNamed(fileName: "fireworks", withExtenstion: "mp3")
					
					if option == "red" {
						option = "yellow"
					} else {
						option = "red"
					}
					
				}
				
				delay += 0.3
				
			}
			
		}
		
		// Fading out, displaying the author name and photo
		Timer.scheduledTimer(withTimeInterval: 112.0, repeats: false) { (timer) in
			
			whiteSquareSpace = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
			whiteSquareSpace.backgroundColor = UIColor.black
			whiteSquareSpace.alpha = 0.0
			self.addSubview(whiteSquareSpace)
			
			UIView.animate(withDuration: 2.0, delay: 0.0, options: [.curveEaseInOut], animations: {
				whiteSquareSpace.alpha = 1.0
			}, completion: nil)
			
			Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
				
				self.scene?.background.contents = UIColor.black
				
				Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
					
					whiteSquareSpace.alpha = 0.0
					
					label.threeMessagesSequence(messages: ["Created by Phil Zet", "a.k.a. Philipp Zakharchenko", ""])
					
				}
				
				// Displaying a photo of me
				Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { (timer) in
					
					var myPicture = SKSpriteNode(imageNamed: "me.jpg")
					myPicture.size = CGSize(width: self.bounds.width, height: self.bounds.width * 0.6)
					myPicture.position = CGPoint(x: skScene.frame.width / 2, y: skScene.frame.height / 2)
					
					let sequence = SKAction.sequence([
						SKAction.fadeIn(withDuration: 0.5),
						SKAction.wait(forDuration: 2.0),
						SKAction.scale(to: 0.0, duration: 0.5)
						])
					
					myPicture.run(sequence)
					
					skScene.addChild(myPicture)
					
					self.overlaySKScene = skScene
					self.overlaySKScene?.scaleMode = .aspectFill
					
				}
				
			}
			
		}
		
		// Post-scriptum (fourth) scene. Displaying my apps as rotating tappable boxes
		Timer.scheduledTimer(withTimeInterval: 124.0, repeats: false) { (timer) in
			
			let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 15), duration: 0.7)
			moveTo.timingMode = .easeInEaseOut
			self.cameraNode.runAction(moveTo)
			
			self.scene?.background.contents = UIColor.black
			
			label.threeMessagesSequence(messages: ["P.S. I'm a student of the 10th grade", "Here are some of my apps", "They are available on the App Store"])
			
			var counter = 0
			
			let positions = [
				SCNVector3(x: -4, y: -2, z: 0),
				SCNVector3(x: 0, y: -2, z: 0),
				SCNVector3(x: 4, y: -2, z: 0),
				SCNVector3(x: -2, y: 2, z: 0),
				SCNVector3(x: 2, y: 2, z: 0)
			]
			
			while counter < positions.count {
				
				let appBox = RotatingBox(imgName: "app\(counter).png")
				appBox.position = positions[counter]
				self.objArray.append(appBox)
				self.objArray[counter]?.name = "app-\(counter)"
				self.scene?.rootNode.addChildNode(appBox)
				
				counter += 1
			}
			
			Timer.scheduledTimer(withTimeInterval: 12.0, repeats: false) { (timer) in
				let moveTo = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: -30), duration: 2.0)
				moveTo.timingMode = .easeInEaseOut
				self.cameraNode.runAction(moveTo)
				
				label.singleMessageSequence(message: "Thanks for interacting 😀")
				
				Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
					
					
					
				}
				
			}
		}

	}
	
	// Detecting touches on current `StoryScene` object. Detecting touched nodes and performing actions
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let p = touch.location(in: self)
			let options = [SCNHitTestOption.rootNode: self.scene!.rootNode, SCNHitTestOption.clipToZRange: 15, SCNHitTestOption.sortResults: true] as [SCNHitTestOption : Any]
			let hitResults = self.hitTest(p, options: options)
			let hit = hitResults.first
			if hit != nil {
				let hitNode = (hit?.node)! as SCNNode
				let hitNodeNameArr = hitNode.name?.components(separatedBy: "-")
				
				if hitNode == self.varBoxNode {
					
					self.varBoxNode.changeImage()
					SystemSoundID.playFileNamed(fileName: "positive", withExtenstion: "mp3")
					
					let particleSystem = SCNParticleSystem(named: "Bokeh", inDirectory: nil)
					let systemNode = SCNNode()
					systemNode.addParticleSystem(particleSystem!)
					systemNode.position = hitNode.position
					self.scene?.rootNode.addChildNode(systemNode)
					
				} else if hitNode.name == "defaultSphere" || hitNode == self.letBoxNode {
					
					SystemSoundID.playFileNamed(fileName: "negative", withExtenstion: "mp3")
					
				} else if hitNode.name == "explodingSphere" {
					
					self.explodeSphere(hitNode: hitNode)
					SystemSoundID.playFileNamed(fileName: "explosion", withExtenstion: "mp3")
					
				} else if hitNode.name == "brick" {
					
					let particleSystem = SCNParticleSystem(named: "Dust", inDirectory: nil)
					let systemNode = SCNNode()
					systemNode.addParticleSystem(particleSystem!)
					systemNode.position = hitNode.position
					self.scene?.rootNode.addChildNode(systemNode)
					
				} else if hitNodeNameArr != nil {
				
					if hitNodeNameArr!.count > 1 {
						
						if hitNodeNameArr![0] == "app" {
							
							let particleSystem = SCNParticleSystem(named: "Apps", inDirectory: nil)
							let systemNode = SCNNode()
							systemNode.addParticleSystem(particleSystem!)
							let particleSystem2 = SCNParticleSystem(named: "Bokeh", inDirectory: nil)
							systemNode.addParticleSystem(particleSystem2!)
							systemNode.position = hitNode.position
							self.scene?.rootNode.addChildNode(systemNode)
							
							SystemSoundID.playFileNamed(fileName: "positive", withExtenstion: "mp3")
							
						}
						
					}
				
				}
			}
		}
		super.touchesBegan(touches, with: event)
	}
	
	// Function for exploding a specified wooden sphere
	func explodeSphere(hitNode: SCNNode) {
		if self.canExplode {
			let particleSystem = SCNParticleSystem(named: "Explosion", inDirectory: nil)
			let systemNode = SCNNode()
			systemNode.addParticleSystem(particleSystem!)
			systemNode.position = hitNode.position
			self.scene?.rootNode.addChildNode(systemNode)
			
			hitNode.name = ""
			
			hitNode.removeFromParentNode()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

//: `VarBox` and `LetBox` are subclasses of `RotatingBox` and represent var and let tappable boxes and possible actions for them
class VarBox: RotatingBox {
	let colorsArray = ["red", "green", "orange", "purple"]
	var currentColor = 0
	
	init() {
		super.init(imgName: "\(colorsArray[currentColor])Var.png")
		Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (timer) in
			self.changeImage()
		}
		self.position = SCNVector3(x: -2, y: 0, z: 0)
	}
	
	func changeImage() {
		
		currentColor += 1
		if currentColor == colorsArray.count {
			currentColor = 0
		}
		self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(colorsArray[currentColor])Var.png")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class LetBox: RotatingBox {
	init() {
		super.init(imgName: "let.png")
		self.position = SCNVector3(x: 2, y: 0, z: 0)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

//: `RotatingBox` initializer creates a rotating `SCNBox` with a specified texture and fixed `chamferRadius`
class RotatingBox: SCNNode {
	init(imgName: String) {
		let varBox = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.1)
		varBox.firstMaterial?.diffuse.contents = UIImage(named: imgName)
		super.init()
		self.geometry = varBox
		let spin = CABasicAnimation(keyPath: "rotation.w")
		spin.toValue = 2*M_PI
		spin.duration = 10
		spin.repeatCount = HUGE
		self.addAnimation(spin, forKey: "spin around")
		self.rotation = SCNVector4(x: 1, y: 1, z: 0, w: 0)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

//: `Brick` class is used for creation of a node with brick texture
class Brick: SCNNode {
	override init() {
		let box = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.0)
		box.firstMaterial?.diffuse.contents = UIImage(named: "brick.jpg")
		super.init()
		self.geometry = box
	}
	
	// chnges the color of the brick
	func changeColor() {
		self.name == "greenBrick"
		self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "brick-sort.jpg")
	}
	
	// moves current Brick object backwards (z-axis)
	func moveBackwards() {
		let moveBackwards = SCNAction.move(to: SCNVector3(x: self.position.x, y: self.position.y, z: -2.0), duration: 1.0)
		moveBackwards.timingMode = .easeInEaseOut
		self.runAction(moveBackwards)
	}
	
	// moves current Brick object forwards (z-axis)
	func moveForwards() {
		let moveForwards = SCNAction.move(to: SCNVector3(x: self.position.x, y: self.position.y, z: 0.0), duration: 1.0)
		moveForwards.timingMode = .easeInEaseOut
		self.runAction(moveForwards)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

//: `TutorialLabel` is a `SpriteKit` label, which is used for captions throughout the Playground. Has custom functions for displaying a message sequence, centering and displaying at the top of the view
class TutorialLabel: SKLabelNode {
	override init() {
		super.init()
		self.fontColor = SKColor.white
		self.fontSize = 24.0
		self.fontName = "AvenirNext-Medium"
		self.horizontalAlignmentMode = .center
		self.verticalAlignmentMode = .center
		self.alpha = 0.0
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// displays current TutorialLabel object at the center of a given rectangle
	func displayCentered(width: CGFloat, height: CGFloat) {
		self.position = CGPoint(x: width / 2, y: height / 2)
	}
	
	// displays current TutorialLabel object at the top of a given rectangle
	func displayAtTheTop(width: CGFloat, height: CGFloat) {
		self.position = CGPoint(x: width / 2, y: height - 50)
	}
	
	// diplays an animated sequence of three messages
	func threeMessagesSequence(messages: [String]) {
		let labelActionSequence = SKAction.sequence([
			SKAction.run({
				self.text = messages[0]
			}),
			SKAction.fadeIn(withDuration: 0.5),
			SKAction.wait(forDuration: 2.0),
			SKAction.fadeOut(withDuration: 0.5),
			SKAction.run({
				self.text = messages[1]
			}),
			SKAction.fadeIn(withDuration: 0.5),
			SKAction.wait(forDuration: 2.0),
			SKAction.fadeOut(withDuration: 0.5),
			SKAction.run({
				self.text = messages[2]
			}),
			SKAction.fadeIn(withDuration: 0.5),
			SKAction.wait(forDuration: 2.0),
			SKAction.fadeOut(withDuration: 0.5)
		])
		
		self.run(labelActionSequence)
	}
	
	// diplays a single animated message
	func singleMessageSequence(message: String) {
		let labelActionSequence = SKAction.sequence([
			SKAction.run({
				self.text = message
			}),
			SKAction.fadeIn(withDuration: 0.5),
			SKAction.wait(forDuration: 2.0),
			SKAction.fadeOut(withDuration: 0.5)
			])
		
		self.run(labelActionSequence)
	}

}

//: `SystemSoundID` extension for playing a sound effect from a specified file
extension SystemSoundID {
	
	static func playFileNamed(fileName: String, withExtenstion fileExtension: String) {
		var sound: SystemSoundID = 0
		if let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
			AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
			AudioServicesPlaySystemSound(sound)
		}
	}
	
}

//: `Array` extension for randomly shuffling a specified Array object
extension Array {
	
	func shuffled() -> [Element] {
		var results = [Element]()
		var indexes = (0 ..< count).map { $0 }
		while indexes.count > 0 {
			let indexOfIndexes = Int(arc4random_uniform(UInt32(indexes.count)))
			let index = indexes[indexOfIndexes]
			results.append(self[index])
			indexes.remove(at: indexOfIndexes)
		}
		return results
	}
	
}

//: Playground initialization code. Creating camera node and `StoryScene` object
var cameraNode = SCNNode()
var scene = StoryScene(cameraNode: cameraNode)

//: Starting motion detection (used in the first scene)

func startMotion() {
	
	scene.executeScenario()
	
	// Initializing motion manager
	let motionManager = CMMotionManager()
	if motionManager.isAccelerometerAvailable {
		
		var startVal: SCNVector3?
		
		motionManager.deviceMotionUpdateInterval = 0.5
		motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (motion: CMAccelerometerData?, error: Error?) in
			if startVal == nil {
				// Calibrating the accelerometer
				startVal = SCNVector3(x: Float((motion?.acceleration.x)!), y: Float((motion?.acceleration.y)!), z: Float((motion?.acceleration.z)!))
			} else {
				// Rotating the camera based on motion
				cameraNode.runAction(SCNAction.rotateBy(x: (CGFloat((motion?.acceleration.x)! - Double(startVal!.x)) / 1200), y: (CGFloat((motion?.acceleration.y)! - Double(startVal!.y)) / 1200), z: (CGFloat((motion?.acceleration.z)! - Double(startVal!.z)) / 1200), duration: 0.3))
			}
		})
	}
	
	//: Cancelling motion detection
	Timer.scheduledTimer(withTimeInterval: 26.0, repeats: false) { (timer) in
		
		motionManager.stopAccelerometerUpdates()
		
	}
}

startMotion()
