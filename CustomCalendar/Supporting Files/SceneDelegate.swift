//
//  SceneDelegate.swift
//  CustomCalendar
//
//  Created by Oleg Soloviev on 25.10.2020.
//  Copyright © 2020 Oleg Soloviev. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: CalendarViewController())
        window?.makeKeyAndVisible()
    }
}
