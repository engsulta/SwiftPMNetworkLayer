//
//  VFGNetworkProgressDelegate.swift
//  VFGFoundation
//
//  Created by Ahmed Sultan on 11/6/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation
public struct GenericTask {
    var progressHandler: ((Double) -> Void)?
    var dataTask: URLSessionDataTaskProtocol?
    var downloadTask: URLSessionDownloadTaskProtocol?
    var expectedContentLength: Int64 = 0
    var buffer = Data()
}
open class VFGNetworkProgressDelegate: NSObject {
    var workingTask = GenericTask()
    override init() {}
    func addTask(dataTask task: URLSessionDataTaskProtocol? = nil,
                 downloadTask downTask: URLSessionDownloadTaskProtocol? = nil,
                 progressClosure: VFGNetworkProgressClosure?) {
        guard let progress = progressClosure else {
            return
        }
        workingTask.progressHandler = progress

        if let task = task {
            workingTask.dataTask = task
        } else if let task = downTask {
            workingTask.downloadTask = task
        }
    }
}

extension VFGNetworkProgressDelegate: URLSessionDataDelegate, URLSessionDownloadDelegate {
    open func urlSession(_ session: URLSession,
                         dataTask: URLSessionDataTask,
                         didReceive response: URLResponse,
                         completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let task = workingTask.dataTask as? URLSessionDataTask, task == dataTask else {
                completionHandler(.cancel)
                return
        }
        workingTask.expectedContentLength = response.expectedContentLength
        completionHandler(.allow)
    }
    open func urlSession(_ session: URLSession,
                         dataTask: URLSessionDataTask,
                         didReceive data: Data) {
        guard let task = workingTask.dataTask as? URLSessionDataTask, task == dataTask else {
            return
        }
        workingTask.buffer.append(data)
        let percentageDownloaded = Double(workingTask.buffer.count) / Double(workingTask.expectedContentLength)
        DispatchQueue.main.async {
            self.workingTask.progressHandler?(percentageDownloaded)
        }
    }
    open func urlSession(_ session: URLSession,
                         task: URLSessionTask,
                         didCompleteWithError error: Error?) {
        guard let currentTask = workingTask.dataTask as? URLSessionDataTask, currentTask == task else {
            return
        }
        DispatchQueue.main.async {
            if error != nil {
                self.workingTask.progressHandler?(-1) // this means faild to track progress for any reason
            }
        }
    }
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
          guard let currentTask = workingTask.downloadTask as? URLSessionDownloadTask,
            currentTask == downloadTask else {
              return
          }
        DispatchQueue.main.async {
                self.workingTask.progressHandler?(100) // this means faild to track progress for any reason
        }
      }
}
