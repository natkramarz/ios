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
    @NSManaged public var price: NSDecimalNumber?
    
    public var wrappedName: String {
        name ?? "Unknown Product"
    }
    
    public var wrappedPrice: Decimal {
        price as? Decimal ?? Decimal(0)
    }
}

extension Product : Identifiable {

}
