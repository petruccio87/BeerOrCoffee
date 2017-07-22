//
//  FileTasks.swift
//  BeerOrCoffee
//
//  Created by OSX on 22.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

//
//  FilesTasks.swift
//  2less3
//
//  Created by kirill lukyanov on 10.01.17.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

import NVHTarGzip

let ft = FilesTasks()

class FilesTasks {
    let fileManager = FileManager()
    let tempDir = NSTemporaryDirectory()
    let homeDir = NSHomeDirectory()
    //    let fileName = "file"
    
    func checkFilesInDirectory(dirname: String) -> [String] {
        var filesInDirectory: [String] = []
        do {
            filesInDirectory = try fileManager.contentsOfDirectory(atPath: homeDir.appending(dirname))
            //            let filesInDirectory = (homeDir as NSString).appendingPathComponent(dirname)
            //            for file in filesInDirectory {
            //                file_list.append(file)
            ////                if file == fileName {
            ////                    print("file found")
            ////                    return file
            ////                } else {
            ////                    print("File not found")
            ////                    return nil
            ////                }
            //            }
        } catch let error as NSError {
            print(error)
        }
        return filesInDirectory
    }
    
    func createFile(dirname: String, filename: String) {
        
        let path = (homeDir.appending(dirname) as NSString).appendingPathComponent(filename)
        let content: String = ""
        // Записываем в файл
        do {
            try content.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            print("File created")
        } catch let error as NSError {
            print("could't create file because of error: \(error)")
        }
        
    }
    func makeContentOfFile(filename: String, content: String) {
        let path = (homeDir as NSString).appendingPathComponent(filename)
        //        let content = "Some contents"
        // Записываем в файл
        do {
            try content.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            print("File succsesful write")
        } catch let error as NSError {
            print("file write error: \(error)")
        }
    }
    func viewDirectory(dirname: String) {
        // Смотрим содержимое папки
        let directoryWithFiles = checkFilesInDirectory(dirname: dirname)
        print("Contents of Directory =  \(directoryWithFiles)")
    }
    
    func readFile(filename: String) -> String {
        
        //        let filename = checkFilesInDirectory() ?? "Empty"
        let path = (homeDir as NSString).appendingPathComponent(filename)
        var content: String = ""
        do {
            content = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
            print("content of the file is: \(content)")
            
        } catch let error as NSError {
            print("there is an file reading error: \(error)")
        }
        return content
    }
    
    func createDir(dirName: String) {
        let path = (homeDir as NSString).appendingPathComponent(dirName)
        //        let dataPath = URL(string: path)
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    func deleteFile(filename: String) {
        
        //        let filename = checkFilesInDirectory(dirname: dirname)
        do {
            let path = (homeDir as NSString).appendingPathComponent(filename)
            try fileManager.removeItem(atPath: path)
            print("file deleted")
        } catch let error as NSError {
            print("error deleting file: \(error.localizedDescription)")
        }
    }
    func gzip(filename: String, deleteSource: Bool) {
        let path = (homeDir as NSString).appendingPathComponent(filename)
        let pathDest = path + ".gz"
        //        let url = URL(string: path)
        let new_file = "file://" + path + ".gz"
        print(new_file)
        //        let newFile
        let newFileUrl = URL(string: new_file)
        let data = path.data(using: String.Encoding.utf8)
        print(path)
        
        NVHTarGzip.sharedInstance().gzipFile(atPath: path, toPath: pathDest, completion: {(_ gzipError: Error?) -> Void in
            if gzipError != nil {
                print("Error ungzipping \(gzipError)")
            }
            if deleteSource {
                ft.deleteFile(filename: filename)
            }
            
        })
    }
    func gunzip(filename: String) {
        let path = (homeDir as NSString).appendingPathComponent(filename)
        //        let url = URL(string: path)
        let pathDest = path + "_gunziped"
        let new_file = "file://" + path + "_gunziped"
        let newFileUrl = URL(string: new_file)
        //        let data = path.data(using: String.Encoding.utf8)
        //        print(path)
        
        NVHTarGzip.sharedInstance().unGzipFile(atPath: path, toPath: pathDest, completion: {(_ gzipError: Error?) -> Void in
            if gzipError != nil {
                print("Error ungzipping \(gzipError)")
            }
        })
        
        
    }
//    
//    func parseJsonOfFile(_ filepath: String){
//        print("start parse file \(filepath)")
//        if let aStreamReader = StreamReader(path: filepath) {
//            
//            defer {
//                aStreamReader.close()
//            }
//            while let line = aStreamReader.nextLine() {
//                print(line)
//            }
////        }
//    
//    }
}
