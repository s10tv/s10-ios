@objc(User)
class User: _User {

	// Custom logic goes here.

}

class Photo {
    let url: String
    
    init(url: String) {
        self.url = url
    }
}

class PhotosValueTransformer : NSValueTransformer {
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        let photos = value as Array<Photo>
        let urls = photos.map { $0.url }
        return NSJSONSerialization.dataWithJSONObject(urls, options: nil, error: nil)
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        let urls = NSJSONSerialization.JSONObjectWithData(value as NSData, options: nil, error: nil) as Array<String>
        return urls.map { Photo(url: $0) }
    }
}