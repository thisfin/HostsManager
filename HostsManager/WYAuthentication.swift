//
//  WYAuthentication.swift
//  Authorization
//
//  Created by wenyou on 2017/4/20.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

// http://blog.laurent.etiemble.com/index.php?post/2005/12/05/36
public class WYAuthentication {
    static let sharedInstance = WYAuthentication()

    private init() {
    }

    var authorizationRef: AuthorizationRef?
    var delegate: WYAuthenticationDelegate?

    func isAuthenticated(_ command: String) -> Bool {
        var item: AuthorizationItem
        var rights: AuthorizationRights
        var err: OSStatus = 0

        if nil == authorizationRef {
            rights = AuthorizationRights.init(count: 0, items: nil)
//            err = AuthorizationCreate(&rights, nil, [], UnsafeMutablePointer<AuthorizationRef?>(authorizationRef))
            err = AuthorizationCreate(&rights, nil, [], &authorizationRef)
        }

        item = AuthorizationItem.init(name: kAuthorizationRightExecute,
                                      valueLength: command.characters.count,
                                      value: UnsafeMutableRawPointer(Unmanaged<NSString>.passUnretained(command as NSString).toOpaque()),
                                      flags: 0)
        var items = [item]
        rights = AuthorizationRights.init(count: 1, items: &items)

        var authorizedRights: UnsafeMutablePointer<AuthorizationRights>? = UnsafeMutablePointer<AuthorizationRights>.allocate(capacity: MemoryLayout.size(ofValue: AuthorizationRights()))

        err = AuthorizationCopyRights(authorizationRef!, &rights, nil, [.extendRights], pointFromAddress(&authorizedRights))
        let authorized = (errAuthorizationSuccess == err)
        if authorized {
            AuthorizationFreeItemSet(authorizedRights!)
        }
        return authorized
    }

    func fetchPassword(_ command: String) -> Bool {
        var item: AuthorizationItem
        var rights: AuthorizationRights
        var err: OSStatus = 0

        if let _ = authorizationRef {
            rights = AuthorizationRights.init(count: 0, items: nil)
            //            err = AuthorizationCreate(&rights, nil, [], UnsafeMutablePointer<AuthorizationRef?>(authorizationRef))
            err = AuthorizationCreate(&rights, nil, [], &authorizationRef)
        }

        item = AuthorizationItem.init(name: kAuthorizationRightExecute,
                                      valueLength: command.characters.count,
                                      value: UnsafeMutableRawPointer(Unmanaged<NSString>.passUnretained(command as NSString).toOpaque()),
                                      flags: 0)
        var items = [item]
        rights = AuthorizationRights.init(count: 1, items: &items)

        var authorizedRights: UnsafeMutablePointer<AuthorizationRights>? = UnsafeMutablePointer<AuthorizationRights>.allocate(capacity: MemoryLayout.size(ofValue: AuthorizationRights()))

        err = AuthorizationCopyRights(authorizationRef!, &rights, nil, [.extendRights, .interactionAllowed], pointFromAddress(&authorizedRights))
        let authorized = (errAuthorizationSuccess == err)
        if authorized {
            AuthorizationFreeItemSet(authorizedRights!)
            if let _ = delegate {
                delegate?.authenticationDidAuthorize(authentication: self)
            }
        }
        return authorized
    }

    func authenticate(_ command: String) -> Bool {
        if !self.isAuthenticated(command) {
            _ = self.fetchPassword(command)
        }
        return self.isAuthenticated(command)
    }

    func deauthenticate() {
        if let _ = authorizationRef {
            AuthorizationFree(authorizationRef!, [.destroyRights])
            authorizationRef = nil
            if let _ = delegate {
                delegate?.authenticationDidDeauthorize(authentication: self)
            }
        }
    }

    private func pointFromAddress<T>(_ p: UnsafeMutablePointer<T>?) -> UnsafeMutablePointer<T>? {
        return p
    }
}

protocol WYAuthenticationDelegate {
    func authenticationDidAuthorize(authentication: WYAuthentication)
    func authenticationDidDeauthorize(authentication: WYAuthentication)
}
