//
//  ProductsApi.swift
//  Network
//
//  Created by Natalia Kramarz on 30/12/2024.
//

import Foundation

class ProductsApi {
    let productsUrl = URL(string: "http://127.0.0.1:8000/")!
    
    
    func getProducts(completion:@escaping (CategoryResponse) -> ()) {
        URLSession.shared.dataTask(with: productsUrl) { data, _, error  in
            let products = try! JSONDecoder().decode(CategoryResponse.self, from: data!)
            
            if let error = error {
                        print("Error fetching products: \(error.localizedDescription)")
                        return
            }
                    
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                let categoryResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(categoryResponse)
                }
            } catch {
                print("Error decoding products: \(error.localizedDescription)")
            }
        }
        .resume()
        
    }
    
    struct CategoryResponse: Codable {
        let categories: [Category]
    }
    
    
    struct Category: Codable, Identifiable {
        let id: String
        let name: String
        let products: [Product]
    }

    struct Product: Codable, Identifiable {
        let id: String
        let name: String
        let price: Decimal
        let description: String
        let imageUrl: String
        
        enum CodingKeys: String, CodingKey {
                case id, name, price, description
                case imageUrl = "image_url"
            }
    }
}
