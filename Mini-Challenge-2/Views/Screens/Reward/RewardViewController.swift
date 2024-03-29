//
//  RewardViewController.swift
//  Mini-Challenge-2
//
//  Created by Johnny Camacho on 18/10/21.
//

import UIKit

protocol RewardDelegate: AnyObject {
    func exitToCategoriesScreen() -> Void
    func gotoNextSession() -> Void
}

class RewardViewController: UIViewController {
    
    @IBOutlet weak var animation: UIImageView!
    
    @IBOutlet weak var punctuation: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var leaveButton: UIButton!
    
    weak var delegate: RewardDelegate!
    
    private var notiPermission: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adjustsFontSizeButton(continueButton)
        adjustsFontSizeButton(leaveButton)
    }
    
    private func adjustsFontSizeButton(_ button: UIButton) {
        let font = button.titleLabel!.font!
        
        button.titleLabel!.font = font.withSize(button.frame.height / 1.87)
    }
    
    @IBAction func didTappedContinue(_ sender: UIButton) {
        self.dismiss(animated: true)
        Haptics.share.vibrateSuccess()
        self.delegate.gotoNextSession()
    }
    
    @IBAction func didTappedLeave(_ sender: Any) {
        Haptics.share.vibrateSuccess()
        self.delegate.exitToCategoriesScreen()
        
        if self.notiPermission == false{
            permissionNotification()
            permissionNotification()
        }else{
            self.notiPermission = true
        }
    }
    
    private func permissionNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { sucess, error in
            if sucess {
                print("notificação permitida")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
}
