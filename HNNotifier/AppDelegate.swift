//
//  AppDelegate.swift
//  HNNotifier
//
//  Created by Kun Li on 8/11/14.
//
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
                            
    @IBOutlet var window: NSWindow!
    @IBOutlet weak var updateIntervalInputField: NSTextField!
    @IBOutlet weak var postCntInputField: NSTextField!
    
    // User defaults keys
    let keyUpdateInterval = "update_interval"
    let keyPostCnt = "post_count"
    let keyObjectId = "object_id"
    
    let apiLink = "http://hn.algolia.com/api/v1/search_by_date?tags=story"
    let hackerNewsPostLinkPrefix = "https://news.ycombinator.com/item?id="
    let hackerNewsLink = "https://news.ycombinator.com/newest"
    let noNewItemMsg = "Nothing new, Go back to WORK!"
    let postCntLimit = 50   // It doesn't make sense to have more than 50 items in the menu
    var preObjectId = 0

    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem : NSMenuItem = NSMenuItem()
    var unreadMenuItems = [NSMenuItem]()
    var menuItemLinks = [String]()
    var timer: NSTimer!
    var menuOpenDate: NSDate!
    
    var postCnt: Int = 0
    var updateIntervalInMinute: Int = 0

    override func awakeFromNib() {
        // Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        menu.delegate = self
        
        postCnt = NSUserDefaults.standardUserDefaults().integerForKey(keyPostCnt)
        updateIntervalInMinute = NSUserDefaults.standardUserDefaults().integerForKey(keyUpdateInterval)
        preObjectId = NSUserDefaults.standardUserDefaults().integerForKey(keyObjectId)
        // Default value for first time use
        if postCnt == 0 { postCnt = 20 }
        if updateIntervalInMinute == 0 { updateIntervalInMinute = 1 }
        
        updatePost()
        updateStatusBar()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(
            NSTimeInterval(updateIntervalInMinute) * 60, target: self, selector: "updatePost", userInfo: nil, repeats: true)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        self.window.orderOut(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    @IBAction func onPreferenceConfirm(sender: AnyObject) {
        if updateIntervalInputField.integerValue > 0 {
            updateIntervalInMinute = updateIntervalInputField.integerValue
            NSUserDefaults.standardUserDefaults().setInteger(updateIntervalInMinute, forKey: keyUpdateInterval)
            timer.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(
                NSTimeInterval(60 * updateIntervalInMinute), target: self, selector: "updatePost", userInfo: nil, repeats: true)
        }
        if postCntInputField.integerValue > 0 {
            postCnt = postCntInputField.integerValue
            if postCnt > postCntLimit {
                postCnt = postCntLimit
            }
            NSUserDefaults.standardUserDefaults().setInteger(postCnt, forKey: keyPostCnt)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        self.window.orderOut(sender)
    }
    
    @IBAction func onPreferenceCancel(sender: AnyObject) {
        self.window.orderOut(sender)
    }
    
    func updateStatusBar() {
        if unreadMenuItems.count > 0 {
            statusBarItem.image = NSImage(named: "BarItemIconActive")
        } else {
            statusBarItem.image = NSImage(named: "BarItemIconInactive")
        }
    }
    
    func updateMenu() {
        menu.removeAllItems()
        
        // Add menuItem to menu
        menuItem.title = "Latest Hacker News Post"
        //menuItem.action = Selector("setWindowVisible:")
        menuItem.keyEquivalent = ""
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem.separatorItem())
        
        if unreadMenuItems.count == 0 {
            menu.addItemWithTitle(noNewItemMsg, action: nil, keyEquivalent: "")
        } else {
            var endIndex = unreadMenuItems.count > postCnt ? postCnt : unreadMenuItems.count
            for i in 0..<endIndex {
                menu.addItem(unreadMenuItems[i])
            }
        }
        
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Option", action: "openPreference:", keyEquivalent: "")
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Quit", action: "exit:", keyEquivalent: "")
    }
    
    // MARK: - Selectors
    
    func updatePost() {
        let request:NSURLRequest = NSURLRequest(URL: NSURL(string: apiLink)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var reply = NSString(data: data, encoding: NSUTF8StringEncoding)
            let json = JSONValue(data)
            if let posts = json["hits"].array {
                if posts.count <= 0 {
                    return
                }
                var endIndex = posts.count > self.postCnt ? self.postCnt : posts.count
                var incomingStoryList = [NSMenuItem]()
                var incomingLinkList = [String]()
                for i in 0..<endIndex {
                    if let id = posts[i]["objectID"].string {
                        if let intId = id.toInt() {
                            if intId > self.preObjectId {   // New post
                                let menuItem = NSMenuItem()
                                menuItem.title = posts[i]["title"].string!
                                menuItem.toolTip = "\(self.hackerNewsPostLinkPrefix)\(intId)"
                                menuItem.action = Selector("openLink:")
                                incomingStoryList.append(menuItem)
                            } else {
                                break
                            }
                        }
                    }
                }
                self.unreadMenuItems = incomingStoryList + self.unreadMenuItems
                self.menuItemLinks = incomingLinkList + self.menuItemLinks
                self.preObjectId = posts[0]["objectID"].string!.toInt()!
                NSUserDefaults.standardUserDefaults().setInteger(self.preObjectId, forKey: self.keyObjectId)
                NSUserDefaults.standardUserDefaults().synchronize()
                if self.unreadMenuItems.count > 0 {
                    self.updateStatusBar()
                    self.updateMenu()
                }
            }
        })
        
    }
    
    func openLink(sender: AnyObject) {
        var item: NSMenuItem = sender as NSMenuItem
        if let toolTip = item.toolTip {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: toolTip)!)
        }
    }
    
    func openPreference(sender: AnyObject) {
        println("open preference")
        self.window.orderFrontRegardless()
    }
    
    func exit(sender: AnyObject) {
        timer?.invalidate()
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // MARK: - Menu delegates
    
    func menuWillOpen(menu: NSMenu!) {
        menuOpenDate = NSDate()
        updateMenu()
    }
    
    func menuDidClose(menu: NSMenu!) {
        let duration = NSDate().timeIntervalSinceDate(menuOpenDate)
        if duration > 1 {
            // Assume user glanced over all items, clear
            unreadMenuItems.removeAll(keepCapacity: false)
            updateStatusBar()
        }
    }
}

