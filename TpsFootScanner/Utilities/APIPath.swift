//
//  APIPath.swift
//  SceneDepthPointCloud
//
//  Created by Nguyen Le on 8/16/22.
//  Copyright © 2022 Apple. All rights reserved.
//

enum APIPath {
    enum Auth: String {
        case signIn = "/api/auth/signin"
        case signUp = "/api/auth/signup"
        
    }
    enum Issue: String {
        case createNewGame = "/api/planning-poker/games"
        case getIssueList = "/api/planning-poker/issues/showIssue/"
        case voteIssue = "/api/planning-poker/issues/vote-issue"
        case createIssue = "/api/planning-poker/issues"
        case getIssueDetail = "/api/issue/detail/"
        case editAndDeleteIssue = "/api/planning-poker/issues/"
        case deleteAllIssue = "/api/planning-poker/issues/games/"
    }
}
