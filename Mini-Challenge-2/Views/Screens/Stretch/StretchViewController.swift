//
//  StretchViewController.swift
//  Mini-Challenge-2
//
//  Created by Johnny Camacho on 14/10/21.
//

import UIKit
import Core
import AVKit

class StretchViewController: UIViewController {
   
    
    // MARK: Properties
    @IBOutlet weak var descriptionStretch: UILabel!
    @IBOutlet weak var timerElipse: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var videoView: UIView!
    
    let stretchVideoController = AVPlayerViewController()

    var viewModel: StretchesViewModel!
    
    lazy var circleAttributed = UIColor.getColorBy(category: viewModel.category) //Retorna o attributed                                                                         de acordo com a categoria
    var exitToCategories: (() -> Void)?
    
    var timer: Timer?
    
    //Ring properties
    var pulsatingLayer = CAShapeLayer()
    let shape          = CAShapeLayer()
    let trackShape     = CAShapeLayer()
    var circlePath     = UIBezierPath()


    func showTransitionBetweenStretches() {
        

        let transitionStoryboard = UIStoryboard(name: "Transition", bundle: nil)
        let transitionViewController = transitionStoryboard.instantiateViewController(withIdentifier: "TransitionViewController") as! TransitionViewController
        
        self.present(transitionViewController, animated: true)
        self.shape.isHidden = true
        
        transitionViewController.onDismiss = {
            self.beginStretch()
            self.stretchVideoController.player?.play()
            self.viewModel.startCountdownTimer()
        }
    }
    
    func beginStretch() {
        self.shape.isHidden = false
        self.ringTimerAnimation()
    }
    
    func stretchDidChange() {
        
        self.view.layer.removeAnimation(forKey: "transform.scale")
        self.pulsatingLayer.removeFromSuperlayer()
        self.trackShape.removeFromSuperlayer()
        
        self.setupRingAnimation()

        self.descriptionStretch.text = "\(self.viewModel.currentStretch.title)"
        
        if self.viewModel.mustShowTransition {
            self.showTransitionBetweenStretches()
        }else{
            self.beginStretch()
        }
        
        print("current stretch: \(self.viewModel.currentStretch)")
    }
    
    func counterDidChange(counter: Int) {
        print("[StretchViewController] \(counter)")
        self.timerLabel.text = "\(counter)"
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.publishStretch = self.stretchDidChange
        self.viewModel.publishCountdown = self.counterDidChange
        self.setupRingAnimation()
        self.setupVideoView()
        self.setupStretchVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.circlePath = UIBezierPath.init(arcCenter: timerLabel.center, radius: timerLabel.frame.width, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        
        pulsatingLayer.path = UIBezierPath(arcCenter: .zero, radius: timerLabel.frame.width, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        trackShape.path         = circlePath.cgPath
        shape.path         = circlePath.cgPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewModel.startSession()
    }
    
    func setupVideoView() {
        
        videoView.layer.cornerRadius = 20
        videoView.clipsToBounds = true
    }
    func setupStretchVideo(){
        
        videoView.addSubview(stretchVideoController.view)
        stretchVideoController.showsPlaybackControls = false
        stretchVideoController.view.frame = videoView.bounds
        stretchVideoController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let videoName = self.viewModel.currentStretch.videoName

        let videoPath = Bundle.main.path(forResource: videoName, ofType: "mp4")
        let videoUrl = URL(fileURLWithPath: videoPath!)
        stretchVideoController.player = AVPlayer(url: videoUrl)
        
//        stretchVideoController.player?.play()


    }
    
    @IBAction func presentPauseViewController() {
        showPauseViewController()
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor, radius: CGFloat) -> CAShapeLayer {
        
        let label = self.timerLabel
                
        let layer = CAShapeLayer()
        let circularPath  = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        layer.path        = circularPath.cgPath
        layer.strokeColor = self.circleAttributed.pulse.cgColor
        layer.lineWidth   = 16
        layer.fillColor   = fillColor.cgColor
        layer.lineCap     = .round
        layer.position    = label!.center
        return layer
    }
    
    func setupRingAnimation() {
        
        let label = self.view.subviews.first { view in
            return type(of: view) == UILabel.self
        }
        
        guard label != nil else { return }
         
        self.circlePath = UIBezierPath.init(arcCenter: label!.center, radius: label!.intrinsicContentSize.width, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        
        pulsatingLayer = createCircleShapeLayer(strokeColor: .green, fillColor: UIColor.clear, radius: label!.intrinsicContentSize.width)
        view.layer.addSublayer(pulsatingLayer)
        
        animatePulsatingLayer()
                    
        view.addShadow(layer: trackShape, path: self.circlePath, color: circleAttributed.shadowColor)
        
        trackShape.path         = circlePath.cgPath
        trackShape.fillColor    = UIColor.clear.cgColor
        trackShape.lineWidth    = 15
        trackShape.strokeColor  = circleAttributed.trackColor.cgColor
        view.layer.addSublayer(trackShape)

        shape.path         = circlePath.cgPath
        shape.lineWidth    = 15
        shape.strokeColor  = circleAttributed.shapeColor.cgColor
        shape.lineCap      = .round
        shape.fillColor    = UIColor.clear.cgColor
        shape.strokeEnd    = 0
        view.layer.addSublayer(shape)
    }
    
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue        = 1.2
        animation.duration       = 2.2
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses   = true
        animation.repeatCount    = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    func ringTimerAnimation() {
        
        let startAnimate      = CABasicAnimation(keyPath: "strokeEnd")
        
        startAnimate.toValue  = 1
        startAnimate.duration = CFTimeInterval(self.viewModel.currentStretch.durationInSeconds)
        startAnimate.fillMode = .forwards
        startAnimate.isRemovedOnCompletion = false
     
        shape.add(startAnimate, forKey: "animation")
    }
    
    func pauseRingAnimation() {
        let pausedTime   = shape.convertTime(CACurrentMediaTime(), from: nil)
        shape.speed      = 0
        shape.timeOffset = pausedTime
    }
    
    func resumeRingAnimation() {
        let pausedTime = shape.timeOffset
        
        shape.speed      = 1
        shape.timeOffset = 0
        shape.beginTime  = 0
        
        let timeSincePause = shape.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shape.beginTime    = timeSincePause
    }
    
//    @objc func tick(){
//        contador -= 1
//
//        if !self.viewModel.session.isDone {
//            self.view.layer.removeAnimation(forKey: "transform.scale")
//            self.pulsatingLayer.removeFromSuperlayer()
//            self.trackShape.removeFromSuperlayer()
//            self.viewModel.nextStretch()
//        }
//    }
//
    func showPauseViewController() {
        let story = UIStoryboard(name: "Pause", bundle: nil)
        let pauseViewController = story.instantiateViewController(withIdentifier: "PauseViewController") as! PauseViewController
        
        self.viewModel.pauseCountdownTime()
        pauseRingAnimation()
        pauseViewController.delegate = self

        self.present(pauseViewController, animated: true, completion: nil)
    }
}

extension StretchViewController: PauseDelegate {
    
    func onPauseScreenDismiss() {
        self.viewModel.resumeCountdownTimer()
        self.resumeRingAnimation()
    }
    
    func exitToCategoriesScreen() {
        self.exitToCategories?()
    }
}

extension UIView {
    func addShadow(layer: CALayer, path: UIBezierPath, color: UIColor) {
      
     layer.backgroundColor = UIColor.clear.cgColor
     let roundedShapeLayer = CAShapeLayer()

     roundedShapeLayer.frame = self.bounds
     roundedShapeLayer.fillColor = UIColor.clear.cgColor
     roundedShapeLayer.path = path.cgPath
        
     layer.insertSublayer(roundedShapeLayer, at: 0)
     layer.shadowOpacity = 1
     layer.shadowOffset  = CGSize(width: 0, height: 0)
     layer.shadowRadius  = 5
     layer.shadowColor   = color.cgColor

   }
}
