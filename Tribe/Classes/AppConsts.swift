//
//  AppConsts.swift
//  Vweeter
//
//  Created by Ghost on 7/10/2017.
//  Copyright © 2017 Ghost. All rights reserved.
//

import UIKit
import CoreLocation

class AppConsts: NSObject {

    static let isDevMode = true
    
    static let SCR_W : CGFloat = UIScreen.main.bounds.size.width
    static let SCR_H : CGFloat = UIScreen.main.bounds.size.height
    
    static let google_api_credential = "AIzaSyBGaj-Z4u5Gdn8-oTlDPeUILWpX9KOV-Jk"
    
    static let COLOR_DEFAULT : UIColor = UIColor(colorLiteralRed: 26.0/255.0, green: 96.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    static let COLOR_BACKGROUND: UIColor = UIColor(colorLiteralRed: 211.0/255.0, green: 226.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    static let COLOR_TAB_TINT : UIColor = UIColor(colorLiteralRed: 211.0/255.0, green: 226.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    static let COLOR_TAB_FOCUS : UIColor = UIColor(colorLiteralRed: 100.0/255.0, green: 192.0/255.0, blue: 99.0/255.0, alpha: 1.0)
    static let COLOR_LIGHT_GRAY : UIColor = UIColor(colorLiteralRed: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    static let COLOR_DARK_GRAY : UIColor = UIColor(colorLiteralRed: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    static let COLOR_TEXT_DARK_BLUE : UIColor = UIColor(colorLiteralRed: 156.0/255.0, green: 167.0/255.0, blue: 177.0/255.0, alpha: 1.0)
    
    static let COLOR_LIGHT_BLUE : UIColor = UIColor(colorLiteralRed: 211.0/255.0, green: 226.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    static let COLOR_LIGHT_GREEN : UIColor = UIColor(colorLiteralRed: 100.0/255.0, green: 192.0/255.0, blue: 99.0/255.0, alpha: 1.0)
    static let COLOR_DARK_GREEN : UIColor = UIColor(colorLiteralRed: 70.0/255.0, green: 136.0/255.0, blue: 70.0/255.0, alpha: 1.0)
    
    static let RADIUS_BUTTON_CORNER : CGFloat = 8.0
    static let RADIUS_VIEW_CORNER : CGFloat = 8.0
    
    static let FONT_BUTTON : UIFont = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
    
    static func showAlert(title:String?, msg: String?, vc: UIViewController){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("alert_ok", comment: "OK"), style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func isValidLink (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    static func strHistoryDate(date:Date?) -> String {
        if date != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd '@' h:mm a"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            let strDate = formatter.string(from: date!)
            return strDate
        } else {
            return ""
        }
    }
}

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }
}

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
