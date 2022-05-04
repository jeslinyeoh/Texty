//
//  Extensions.swift
//  Texty
//
//  Created by Jeslin Yeoh on 27/12/2021
//  following iOS Academy's YouTube tutorial.
//

import Foundation
import UIKit

extension UIView{
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
    
}

extension Notification.Name {
    
    /// Notfication when user logs in
    static let didLogInNotification = Notification.Name("didLogInNotification")
    static let didSuggestionsUpdateNotification = Notification.Name("didSuggestionsUpdateNotification")
}



