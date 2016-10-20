//
//  Extensions.swift
//  Weather247
//
//  Created by jogja247 on 9/30/16.
//  Copyright © 2016 Solusi247. All rights reserved.
//

import Foundation

extension Int {
    func format(_ f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

/*
 let someInt = 4, someIntFormat = "03"
 println("The integer number \(someInt) formatted with \"\(someIntFormat)\" looks like \(someInt.format(someIntFormat))")
 // The integer number 4 formatted with "03" looks like 004
 
 let someDouble = 3.14159265359, someDoubleFormat = ".3"
 println("The floating point number \(someDouble) formatted with \"\(someDoubleFormat)\" looks like \(someDouble.format(someDoubleFormat))")
 // The floating point number 3.14159265359 formatted with ".3" looks like 3.142
*/

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}

extension Date {
    struct Formatter {
        static let custom = DateFormatter(dateFormat: "dd/M/yyyy, H:mm")
    }
    var customFormatted: String {
        return Formatter.custom.string(from: self as Date)
    }
}

/*
extension String {
    var asDate: Date? {
        return Date.Formatter.custom.date(from: self) as Date?
    }
    func asDateFormatted(with dateFormat: String) -> Date? {
        return DateFormatter(dateFormat: dateFormat).date(from: self) as NSDate?
    }
}
 */

/*
 let stringFromDate = NSDate().customFormatted   // "14/7/2016, 2:00"
 
 if let date = stringFromDate.asDate {  // "Jul 14, 2016, 2:00 AM"
 print(date)                        // "2016-07-14 05:00:00 +0000\n"
 date.customFormatted               // "14/7/2016, 2:00"
 }
 
 "14/7/2016".asDateFormatted(with: "dd/MM/yyyy")  // "Jul 14, 2016, 12:00 AM"
*/

extension NSString {
    
    class func convertFormatOfDate(_ date: String, originalFormat: String, destinationFormat: String) -> String! {
        
        // Orginal format :
        let dateOriginalFormat = DateFormatter()
        dateOriginalFormat.dateFormat = originalFormat      // in the example it'll take "yy MM dd" (from our call)
        
        // Destination format :
        let dateDestinationFormat = DateFormatter()
        dateDestinationFormat.dateFormat = destinationFormat // in the example it'll take "EEEE dd MMMM yyyy" (from our call)
        
        // Convert current String Date to NSDate
        let dateFromString = dateOriginalFormat.date(from: date)
        
        // Convert new NSDate created above to String with the good format
        let dateFormated = dateDestinationFormat.string(from: dateFromString!)
        
        return dateFormated
        
    }
}

/*
 Let's say you want to convert "16 05 05" to "Thursday 05 May 2016" and your date is declared as follow let date = "16 06 05"
 Then simply call call it with :
 
 let newDate = NSString.convertFormatOfDate(date, originalFormat: "yy MM dd", destinationFormat: "EEEE dd MMMM yyyy")
*/

extension NSDecimalNumber {
    func negative() -> NSDecimalNumber {
        return self.multiplying(by: NSDecimalNumber(mantissa: 1, exponent: 0, isNegative: true));
    }
}

/*
 yourNumber = yourNumber.negative() 
 */
