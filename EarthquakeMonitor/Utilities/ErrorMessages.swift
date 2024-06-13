//
//  ErrorMessages.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/13/24.
//

import Foundation

enum ErrorType: String {
    
   case notConnectedToInternet = "No internet connection. Please check your network settings."
   case timedOut = "The request timed out. Please try again.."
   case cannotFindHost = "Cannot find host. Please check the server address."
   case badServerResponse = "Server error. Please try again later."

}
