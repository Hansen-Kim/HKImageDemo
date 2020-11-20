//
//  Image.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol ImageConvertable {
    var asImage: UIImage? { get }
}

extension UIImage: ImageConvertable {
    var asImage: UIImage? { return self }
}

extension String: ImageConvertable {
    var asImage: UIImage? { return UIImage(named: self) }
}

enum Image: ImageConvertable {
    case url(_ url: URL, placeholder: ImageConvertable)
    case local(image: ImageConvertable)
    
    var asImage: UIImage? {
        switch self {
            case .url(let url, let placeholder):
                return ImageCache.shared.image(for: url) ?? placeholder.asImage
            case .local(let image):
                return image.asImage
        }
    }
    
    fileprivate var url: URL? {
        switch self {
            case .url(let url, _):
                return ImageCache.shared.isExistInMemory(of: url) ? nil : url
            default:
                return nil
        }
    }
}

private class ImageCache {
    static let memoryCacheSize: UInt64 = 64 * 1024 * 1024
    static let storageCacheSize: UInt64 = 256 * 1024 * 1024
    static let cacheFileExtension = "imagecache"
    
    static let shared = ImageCache()
    
    class Cache {
        let id: String
        let data: Data
        var accessDate: Date
        
        init(with id: String, data: Data) {
            self.id = id
            self.data = data
            self.accessDate = Date()
        }

        private func touch() {
            self.accessDate = Date()
        }
        
        var size: UInt64 {
            return UInt64(self.data.count)
        }
        
        var image: UIImage? {
            self.touch()
            return UIImage(data: self.data)
        }
    }

    let memoryCacheSize: UInt64
    let storageCacheSize: UInt64
    let synchronizedQueue: DispatchQueue
    let storageQueue: DispatchQueue
    
    init(with memoryCacheSize: UInt64 = ImageCache.memoryCacheSize, storageCacheSize: UInt64 = ImageCache.storageCacheSize) {
        self.memoryCacheSize = memoryCacheSize
        self.storageCacheSize = storageCacheSize
    
        self.synchronizedQueue = DispatchQueue(label: "seunghan.kim.image.demo.cache.syncronized.queue", attributes: .concurrent)
        self.storageQueue = DispatchQueue(label: "seunghan.kim.image.demo.cache.storage.queue", attributes: .concurrent)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeAllMemoryCache),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
        self.storageQueue.async(flags: [.barrier]) {
            _ = self.storageCacheURLs
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    let fileManager = FileManager()
    
    lazy var cachePathURL: URL? = {
        guard let url = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("image") else { return nil }
        var isDirectory = ObjCBool(true)
        if !fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                return nil
            }
        }
        return url
    }()
    lazy var storageCacheURLs: [URL] = {
        guard let cachePathURL = self.cachePathURL else { return [] }
        do {
            return try self.fileManager.contentsOfDirectory(at: cachePathURL, includingPropertiesForKeys: [.isDirectoryKey, .contentAccessDateKey, .fileSizeKey], options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]).filter {
                guard let isDirectory = try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory else { return false }
                return $0.pathExtension == ImageCache.cacheFileExtension && !isDirectory
            }
        } catch _ {
            return []
        }
    }()
    var storageCacheUsage: UInt64 {
        return self.storageCacheURLs.reduce(UInt64(0)) { (result, url) in
            guard let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else { return result }
            return result + UInt64(fileSize)
        }
    }
    var memory: [String : Cache] = [ : ]
    var memoryCacheUsage: UInt64 = 0

    func add(url: URL, data: Data) {
        let id = url.md5String
        
        self.addMemory(id: id, data: data)
        self.checkMemory()
        
        self.addStorage(id: id, data: data)
        self.checkStorage()
    }
    
    func addMemory(id: String, data: Data) {
        self.synchronizedQueue.async(flags: [.barrier]) {
            let cache = Cache(with: id, data: data)
            
            if let previous = self.memory[id] {
                self.memoryCacheUsage -= previous.size
            }
            self.memory[id] = cache
            self.memoryCacheUsage += cache.size
        }
    }
    
    func checkMemory() {
        self.synchronizedQueue.async(flags: [.barrier]) {
            if self.memoryCacheUsage > self.memoryCacheSize {
                var removedUsage = UInt64(0)
                
                for cache in self.memory.values.sorted(by: { $0.accessDate > $1.accessDate }) {
                    removedUsage += cache.size
                    
                    self.memory.removeValue(forKey: cache.id)
                    if (self.memoryCacheUsage - removedUsage) < (self.memoryCacheSize * 8 / 10) {
                        self.memoryCacheUsage -= removedUsage
                        break
                    }
                }
            }
        }
    }
    
    func addStorage(id: String, data: Data) {
        self.storageQueue.async(flags: [.barrier]) {
            guard let url = self.pathURL(for: id) else { return }
            do {
                try data.write(to: url)
                self.storageCacheURLs.append(url)
            } catch _ {
            }
        }
    }

    func checkStorage() {
        self.storageQueue.async(flags: [.barrier]) {
            let storageCacheUsage = self.storageCacheUsage
            if storageCacheUsage > self.storageCacheSize {
                var removedUsage = UInt64(0)
                
                let storages: [(URL, Date?, UInt64?)] = self.storageCacheURLs.map {
                    guard let resource = try? $0.resourceValues(forKeys: [.fileSizeKey, .contentAccessDateKey]) else {
                        return ($0, nil, nil)
                    }
                    return ($0, resource.contentAccessDate, resource.fileSize != nil ? UInt64(resource.fileSize!) : nil)
                }
                
                for cache in storages.compactMap({ (url, date, fileSize) -> (URL, Date, UInt64)? in
                    guard let date = date, let fileSize = fileSize else {
                        try? self.fileManager.removeItem(at: url)
                        return nil
                    }
                    return (url, date, fileSize)
                }).sorted(by: { $0.1 > $1.1 }) {
                    do {
                        try self.fileManager.removeItem(at: cache.0)
                        removedUsage += cache.2
                        
                        if (storageCacheUsage - removedUsage) < (self.storageCacheSize * 8 / 10) {
                            break
                        }
                    } catch {
                    }
                }
            }
        }
    }
    
    func isExistInMemory(of url: URL) -> Bool {
        return self.memory[url.md5String] != nil
    }
    
    func image(for url: URL) -> UIImage? {
        let id = url.md5String
        var result: UIImage? = nil
        
        self.synchronizedQueue.sync {
            guard let cache = self.memory[id] else { return }
            result = cache.image
        }
        
        return result
    }
    
    func storageImage(for url: URL, handler: @escaping (UIImage?) -> Void) {
        self.storageQueue.async(flags: [.barrier]) {
            let id = url.md5String
            guard let pathURL = self.pathURL(for: id),
                  let data = try? Data(contentsOf: pathURL), let image = UIImage(data: data) else {
                handler(nil)
                return
            }
            
            self.addMemory(id: id, data: data)
            handler(image)
        }
    }
    
    func pathURL(for id: String) -> URL? {
        return self.cachePathURL?.appendingPathComponent(id).appendingPathExtension(ImageCache.cacheFileExtension)
    }
    
    @objc func removeAllMemoryCache() {
        self.memory.removeAll()
    }
}

private var kUIImageViewSessionKey = UInt8()

extension UIImageView {
    private var imageSession: APISession? {
        get { return objc_getAssociatedObject(self, &kUIImageViewSessionKey) as? APISession }
        set { objc_setAssociatedObject(self, &kUIImageViewSessionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    func fetch(_ image: Image) {
        self.imageSession = nil
        self.image = image.asImage

        guard let url = image.url else { return }
        self.fetch(url: url)
    }
    
    private func fetch(url: URL) {
        ImageCache.shared.storageImage(for: url) { [weak self] in
            guard let self = self else { return }
            if let image = $0 {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                do {
                    self.imageSession = try API
                        .get
                        .session(url: url)
                        .fetch { [weak self] (result: APIResult<Data>) in
                            guard let self = self, let data = result.value, let image = UIImage(data: data) else { return }
                            ImageCache.shared.add(url: url, data: data)
                            DispatchQueue.main.async {
                                self.image = image
                            }
                        }
                } catch _ { }
            }
        }
    }
}
