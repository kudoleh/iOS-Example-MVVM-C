//
//  MVVMView.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 09.04.19.
//

import Foundation
import UIKit

protocol MVVMView {
    
    associatedtype ViewModel: MVVMViewModel
    
    var viewModel: ViewModel! { get set }
    
    func bind(to viewModel: ViewModel)
}

extension MVVMView where Self: UIViewController, Self: StoryboardInstantiable {
    
    static func instantiate(with viewModel: ViewModel) -> Self {
        
        var viewController = Self.instantiateViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
}
