//
//  AppDelegate.swift
//  HNNotifier
//
//  Created by Kun Li on 8/11/14.
//
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    
    let apiLink = "http://hn.algolia.com/api/v1/search_by_date?tags=story"
    let hackerNewsLink = "https://news.ycombinator.com/newest"
    let updateCntLimit = 10
    var preObjectId = 0

    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem : NSMenuItem = NSMenuItem()
    var menuItemForPost = [NSMenuItem]()
    var timer: NSTimer!
    var menuOpenDate: NSDate!

    override func awakeFromNib() {
        // Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        menu.delegate = self
        
        updateStatusBar()
        updateMenu()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("updatePost:"), userInfo: nil, repeats: true)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        self.window.orderOut(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    func updateStatusBar() {
        if menuItemForPost.count > 0 {
            statusBarItem.image = NSImage(named: "BarItemIconActive")
        } else {
            statusBarItem.image = NSImage(named: "BarItemIconInactive")
        }
    }
    
    func updateMenu() {
        println("update menu")
        menu.removeAllItems()
        
        // Add menuItem to menu
        menuItem.title = "Latest Hacker News Post"
        //menuItem.action = Selector("setWindowVisible:")
        menuItem.keyEquivalent = ""
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem.separatorItem())
        
        if menuItemForPost.count == 0 {
            menu.addItemWithTitle("N/A", action: nil, keyEquivalent: "")
        } else {
            for item in menuItemForPost {
                menu.addItem(item)
            }
        }
        
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Option", action: Selector("exit:"), keyEquivalent: "")
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Quit", action: Selector("exit:"), keyEquivalent: "")
    }
    
    // MARK: - Selectors
    func updatePost(sender: AnyObject) {
        menuItemForPost.removeAll(keepCapacity: false)
        
        let request:NSURLRequest = NSURLRequest(URL: NSURL(string: apiLink))
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var reply = NSString(data: data, encoding: NSUTF8StringEncoding)
            let json = JSONValue(data)
            if let posts = json["hits"].array {
                if posts.count > 0 {
                    var endIndex = posts.count > self.updateCntLimit ? self.updateCntLimit : posts.count
                    for i in 0...endIndex {
                        if let id = posts[i]["objectID"].string {
                            if let intId = id.toInt() {
                                println(self.preObjectId)
                                println(intId)
                                if intId > self.preObjectId {
                                    let menuItem = NSMenuItem()
                                    menuItem.title = posts[i]["title"].string!
                                    menuItem.action = Selector("openLink:")
                                    self.menuItemForPost.append(menuItem)
                                } else {
                                    break
                                }
                            }
                        }
                    }
                    self.preObjectId = posts[0]["objectID"].string!.toInt()!
                    if self.menuItemForPost.count > 0 {
                        self.updateStatusBar()
                        self.updateMenu()
                    }
                }
            }
        })
        
    }
    
    func openLink(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL.URLWithString("https://news.ycombinator.com/newest"))
    }
    
    func exit(sender: AnyObject) {
        timer?.invalidate()
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // MARK: - Menu delegates
    
    func menuWillOpen(menu: NSMenu!) {
        menuOpenDate = NSDate()
    }
    
    func menuDidClose(menu: NSMenu!) {
        let duration = NSDate().timeIntervalSinceDate(menuOpenDate)
        if duration > 3 {
            // Assume user glanced over all items, clear
            menuItemForPost.removeAll(keepCapacity: false)
            updateStatusBar()
            updateMenu()
        }
    }
}

