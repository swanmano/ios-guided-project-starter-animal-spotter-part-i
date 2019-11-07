//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case noAuthorization
    case incorrectAuthorization
    case otherError
    case badData
    case noDecode
}

class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    var bearer: Bearer?
    
    // create function for sign up
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        let signUpUrl = baseUrl.appendingPathComponent("users/signup")
        
        var request = URLRequest(url: signUpUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    // create function for sign in
    func signIn(with user: User, completion: @escaping (Error?) -> ()) {
        let loginUrl = baseUrl.appendingPathComponent("users/login")
        
        var request = URLRequest(url: loginUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                print("Effor decoding bearer object: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }

    
    // create function for fetching all animal names
    
    func fetchAllAnimalNames(completion: @escaping (Result<[String], NetworkError>) -> ()) {
        guard let bearer = bearer else {
            completion(.failure(.noAuthorization))
            return }
        
        let allAnimalsUrl = baseUrl.appendingPathComponent("animals/all")
        var request = URLRequest(url: allAnimalsUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.incorrectAuthorization))
                return
            }
            
            if let error = error {
                print("Error receiving animal name data: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                completion(.success(animalNames))
            } catch {
                print("Error decoding animal objects: \(error)")
                completion(.failure(.noDecode))
                return
            }
            
        }.resume()
    }
    
    // create function for fetching a specific animal
    func fetchDetails(for animalName: String, completion: @escaping (Result<Animal, NetworkError>) -> ()) {
        guard let bearer = bearer else {
        completion(.failure(.noAuthorization))
        return
        }
        let allAnimalUrl = baseUrl.appendingPathComponent("animals/\(animalName)")
        var request = URLRequest(url: allAnimalUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                   if let response = response as? HTTPURLResponse,
                       response.statusCode == 401 {
                       completion(.failure(.incorrectAuthorization))
                       return
                   }
                   
                   if let error = error {
                       print("Error receiving animal (\(animalName)) details: \(error)")
                       completion(.failure(.otherError))
                       return
                   }
                   
                   guard let data = data else {
                       completion(.failure(.badData))
                       return
                   }
                   
                   let decoder = JSONDecoder()
                   do {
                    let animal = try decoder.decode(Animal.self, from: data)
                       completion(.success(animal))
                   } catch {
                       print("Error decoding animal object (\(animalName)): \(error)")
                       completion(.failure(.noDecode))
                       return
                   }
                   
               }.resume()
    }
    
    // create function to fetch image
}
