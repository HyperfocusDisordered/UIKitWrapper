//
//  File.swift
//  
//
//  Created by  Denis Ovchar new on 15.04.2022.
//

import Foundation


public final class AssociatedValues {
	private var values: [AnyKeyPath: Any] = [:]
	
	public init() {}
	
	public subscript<T>(_ keyPath: KeyPath<AssociatedValues, T>) -> T? {
		get {
			if let any = values[keyPath], type(of: any) == T.self {
				return any as? T
			}
			return nil
		}
		set {
			guard let newValue = newValue else { return }
			values[keyPath] = newValue
		}
	}
}

extension NSObjectProtocol {
	public var associated: AssociatedValues {
		get {
			if let result = objc_getAssociatedObject(self, &key) as? AssociatedValues {
				return result
			}
			let result = AssociatedValues()
			objc_setAssociatedObject(self, &key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return result
		}
		set { objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}

private var key = "key"




import UIKit

open class UIEnvironmentValues {
	
	private var values: [AnyKeyPath: Any] = [:]
	public var link: (() -> UIEnvironmentValues?)?
	
	public init() {}
	
	public subscript<T>(_ keyPath: WritableKeyPath<UIEnvironmentValues, T>) -> T? {
		get {
			self[key: keyPath]
		}
		set {
			self[key: keyPath] = newValue
		}
	}
	
//	public subscript<T>(_ keyPath: KeyPath<UI, UIEnvironmentValue<T>>) -> T {
//		get {
//			self[key: keyPath] ?? EmptyUI()[keyPath: keyPath].defaultValue
//		}
//		set {
//			self[key: keyPath] = newValue
//		}
//	}
	
	private subscript<T>(key keyPath: AnyKeyPath) -> T? {
		get {
			if let any = values[keyPath] ?? link?()?[key: keyPath] {
				return any as? T
			}
			return nil
		}
		set {
			guard let newValue = newValue else { return }
			values[keyPath] = newValue
		}
	}
	
	public func merge(with parent: UIEnvironmentValues) {
		values.merge(parent.values) { it, _ in
			it
		}
	}
}

extension UIResponder {
	
	public var environments: UIEnvironmentValues {
		get {
			var result = associated.environments
			if let parent = next {
				result.link = {[weak parent] in parent?.environments }
			}
			return result
		}
		set {
			var result = newValue
			result.link = nil
			associated.environments = result
		}
	}
}

private extension AssociatedValues {
	var environments: UIEnvironmentValues {
		get { self[\.environments] ?? .init() }
		set { self[\.environments] = newValue }
	}
}
