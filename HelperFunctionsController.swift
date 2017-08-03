//
//  HelperFunctionsController.swift
//  ColorOmega
//
//  Created by  user on 7/18/17.
//  Copyright © 2017 Aman Meghrajani. All rights reserved.
//

import UIKit

class HelperFunctionsController: UIViewController {


    
    class func levels() -> [Int : Int] {
        var l = [Int: Int]()
        for i in 1...50 {
            l[i] = i*i
        }
        return l
    }
    
    class func randomColor() -> UIColor{
        var red = CGFloat(drand48())
        var blue = CGFloat(drand48())
        var green = CGFloat(drand48())
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    class func provideColors(_ numberOfColors : Int) -> [String :UIColor]{
        // var colorNames: DBColorNames = DBColorNames()
        var colors : [String : UIColor] = ["blue": UIColor.blue, "red" : UIColor.red, "green" : UIColor.green, "black" : UIColor.black, "magenta" : UIColor.magenta]
        var colorArray : NSArray = ["blue", "red", "black", "magenta"]
        
        var i = 1
        var colorsDictionary = [String : UIColor] ()
        while i <= numberOfColors {
            let rn1 = ((CGFloat(drand48()) * CGFloat(drand48()))) * 4
            print(rn1)
            let colorname = colorArray[Int(rn1)] as! String
            
            colorsDictionary[colorname] = colors[colorname]
               print(colorname)
            i += 1
        }
        print (colorsDictionary)
        return colorsDictionary
}
    

}
