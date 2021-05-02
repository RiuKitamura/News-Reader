//
//  Webservice.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 28/04/21.
//

import UIKit

enum NetworkError: Error {
    case decodingError
    case domainError
    case urlError
}

struct Resource<T: Decodable> {
    let url: URL
}

final class Webservice {
    
    func fetchNews<T>(resource: Resource<T>, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        URLSession.shared.dataTask(with: resource.url) { (data, response, error) in
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.domainError))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    print("DEBUG: json decode error: \(error)")
                    completion(.failure(.decodingError))
                }
            }
            
        }.resume()
    }
    
    
    func downloadImage(with link: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        
        guard let url = URL(string: link) else {
            completion(.failure(.urlError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.domainError))
                }
                return
            }
            
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
            
        }.resume()
        
    }
}
