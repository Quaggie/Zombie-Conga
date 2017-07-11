//
//  AppDelegate.swift
//  ZombieCongaMac
//
//  Created by Jonathan Bijos on 11/07/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed( _ sender: NSApplication) -> Bool {
        return true;
    }
    
}
