//
//  Product+CoreDataProperties.swift
//  shopping_list
//
//  Created by Natalia Kramarz on 28/12/2024.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: Category?
    
    public var wrappedName: String {
        name ?? "Unknown Product"
    }

}

extension Product : Identifiable {

}
