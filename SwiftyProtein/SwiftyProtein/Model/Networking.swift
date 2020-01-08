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

func requestLigandDataAndInfo(forLigand ligand: String, atIndex index: Int, completion: @escaping (Result<Ligand>) -> Void) {
    let queue = OperationQueue()
    var returnLigand : Ligand? = nil
    
    queue.maxConcurrentOperationCount = 1
    
    let authString = "https://files.rcsb.org/ligands/view/\(ligand.lowercased())_ideal.pdb"
    let url = URL(string: authString)
    var request = URLRequest(url: url!)
    request.httpMethod = "get"
    
    let authStringInfo = "https://rest.rcsb.org/rest/ligands/\(ligand.lowercased())"
    let infoUrl = URL(string: authStringInfo)
    var infoRequest = URLRequest(url: infoUrl!)
    infoRequest.httpMethod = "get"
    
    let infoOperation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: infoRequest) { (data, response, error) in
        DispatchQueue.main.async {
            guard error == nil else { return completion(.error(error!.localizedDescription)) }
            guard let data = data, let res = response as? HTTPURLResponse, res.statusCode == 200 else { return completion(.error("No data returned")) }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let result = json["results"] else { return completion(.error("There was an issue with the returned data")) }
            let info = LigandInfo(json: result as! [[String : Any]])
            returnLigand?.addInfo(with: info)
            completion(.success(returnLigand!))
        }
    }
    
    let operation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: request) { (data, response, error) in
        DispatchQueue.main.async {
            guard error == nil else { return completion(.error(error!.localizedDescription)) }
            guard let data = data, let res = response as? HTTPURLResponse, res.statusCode == 200 else { return completion(.error("No data returned")) }
            guard let resultString = String(data: data, encoding: .utf8) else { return completion(.error("Invalid data obtained"))}
            returnLigand = Ligand(forLigand: ligand, withDataSet: resultString)
            queue.addOperation(infoOperation)
        }
    }
    
    queue.addOperation(operation)
}
