//
//  ProfileViewModel.swift
//  Texty
//
//  Created by Jeslin Yeoh on 03/03/2022.
//

import Foundation


enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
