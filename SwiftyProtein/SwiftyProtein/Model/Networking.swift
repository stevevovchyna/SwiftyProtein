//
//  Networking.swift
//  SwiftyProtein
//
//  Created by Steve Vovchyna on 04.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

enum Result<T> {
    case success(T)
    case error(String)
}

enum OperationState : Int {
    case ready
    case executing
    case finished
}

class DownloadOperation : Operation {
    
    private var task : URLSessionDataTask!
    private var state : OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
    init(session: URLSession, dataTaskURLRequest: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        super.init()
        task = session.dataTask(with: dataTaskURLRequest, completionHandler: { [weak self] (data, response, error) in
            if let completionHandler = completionHandler {
                completionHandler(data, response, error)
            }
            self?.state = .finished
        })
    }

    override func start() {
        if self.isCancelled {
            state = .finished
            return
        }
        state = .executing
        self.task.resume()
    }

    override func cancel() {
        super.cancel()
        self.task.cancel()
    }
}

class DownloadManager {
    private let queue = OperationQueue()
    
    private let ligandRequestStringBase = "https://files.rcsb.org/ligands/view/"
    private let ligandInfoRequestStringBase = "https://rest.rcsb.org/rest/ligands/"
    private let httpMethod = "get"
    
    init() {
        queue.maxConcurrentOperationCount = 1
    }
    
    public func requestLigandDataNInfo(forLigand ligand: String, atIndex index: Int, completion: @escaping (Result<Ligand>) -> Void) {
        var returnLigand : Ligand? = nil
        
        let ligandRequestString = ligandRequestStringBase + ligand.lowercased() + "_ideal.pdb"
        let infoRequestString = ligandInfoRequestStringBase + ligand.lowercased()
        
        let ligandURL = URL(string: ligandRequestString)
        var ligandRequest = URLRequest(url: ligandURL!)
        ligandRequest.httpMethod = httpMethod
        
        let infoURL = URL(string: infoRequestString)
        var infoRequest = URLRequest(url: infoURL!)
        infoRequest.httpMethod = httpMethod
        
        let infoOperation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: infoRequest) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    return completion(.error(error.localizedDescription))
                }
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    return completion(.error("Server error"))
                }
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary, let results = json["results"] as? NSArray, let result = results[0] as? NSDictionary else { return completion(.error("There was an issue with the returned data")) }
                let info = LigandInfo(json: result)
                returnLigand?.addInfo(with: info)
                completion(.success(returnLigand!))
            }
        }
        
        let operation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: ligandRequest) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    return completion(.error(error.localizedDescription))
                }
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    return completion(.error("Server error"))
                }
                guard let data = data, let resultString = String(data: data, encoding: .utf8) else { return completion(.error("Invalid data obtained"))}
                returnLigand = Ligand(forLigand: ligand, withDataSet: resultString)
                self.queue.addOperation(infoOperation)
            }
        }
        
        queue.addOperation(operation)

    }
}
