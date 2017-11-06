//
//  TBMainVC.swift
//  Tribe
//
//  Created by Mask on 7/9/17.
//  Copyright © 2017 Patrick. All rights reserved.
//

import UIKit

class TBMainVC: UIViewController {
    
    @IBOutlet weak var viewToolbar: UIView!
    @IBOutlet weak var viewUnderline: UIView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var btnShared: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var scrollContainer: UIScrollView!
    
    @IBOutlet weak var constraintUnderlineX: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnHome.setImage(#imageLiteral(resourceName: "ic_home").withRenderingMode(.alwaysTemplate), for: .normal)
        btnHome.tintColor = AppConsts.COLOR_TAB_FOCUS

        btnHistory.setImage(#imageLiteral(resourceName: "ic_history").withRenderingMode(.alwaysTemplate), for: .normal)
        btnHistory.tintColor = AppConsts.COLOR_TAB_TINT

        btnShared.setImage(#imageLiteral(resourceName: "ic_shared").withRenderingMode(.alwaysTemplate), for: .normal)
        btnShared.tintColor = AppConsts.COLOR_TAB_TINT

        btnSetting.setImage(#imageLiteral(resourceName: "ic_settings").withRenderingMode(.alwaysTemplate), for: .normal)
        btnSetting.tintColor = AppConsts.COLOR_TAB_TINT
        
        AppManager.sharedManager.pageListener = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectPage(index: 0)

    }
    
    @IBAction func onPressSelectTab(_ sender: UIButton) {
        if sender == btnHome {
            selectPage(index: 0)
        } else if sender == btnHistory {
            selectPage(index: 1)
        } else if sender == btnShared {
            selectPage(index: 2)
        } else if sender == btnSetting {
            selectPage(index: 3)
        }
    }
    
    fileprivate func selectPage(index: Int, shouldScroll: Bool = true) {
        let x = btnHome.frame.origin.x + 10 + (btnHome.frame.size.width + 20) * CGFloat(index)
        constraintUnderlineX.constant = x
        updateConstraintWithAnimate()
        
        var i = 0
        for button in [btnHome, btnHistory, btnShared, btnSetting] {
            if i == index {
                button?.tintColor = AppConsts.COLOR_TAB_FOCUS
            } else {
                button?.tintColor = AppConsts.COLOR_TAB_TINT
            }
            i += 1
        }

        if (shouldScroll) {
            let offset = CGPoint(x: scrollContainer.frame.size.width * CGFloat(index), y: 0)
            self.scrollContainer.setContentOffset(offset, animated: true)
        }
    }
    
}

extension TBMainVC: AppManagerPageListener {
    func selectPageAt(index: Int) {
        selectPage(index: index)
    }
}

extension TBMainVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndexForCurrentOffset = Int(scrollView.contentOffset.x / scrollView.frame.width)
        selectPage(index: pageIndexForCurrentOffset, shouldScroll: false)
        
    }
    
}

extension UIViewController {
    
    func updateConstraintWithAnimate(_ animate: Bool = true) -> Void {
        if animate == true {
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (complete) in
                
            })
        } else {
            updateViewConstraints()
        }
    }
}
