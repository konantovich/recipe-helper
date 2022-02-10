




struct Example: Decodable {
    
    var undefinedType: Double
    
    enum CodingKeys: String, CodingKey {
        case undefinedType = "undefinedType"
    }
    
    init(from decoder: Decoder) throws {
        
        // decodeIfPresent типа опционально проверяет и оно не крашнет если параметра этого вообще не будет в моделе
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let undefinedType = try? values.decodeIfPresent(Double.self, forKey: .undefinedType) {
            self.undefinedType = undefinedType
        } else if let undefinedType = try? values.decodeIfPresent(Int.self, forKey: .undefinedType) {
            self.undefinedType = Double(undefinedType)
        } else {
            self.undefinedType = 0
        }
    }
}





//Vanek Example

    struct ArticleDetailResponse: Decodable {
        
        var id: Int
        var headline: String
        var subhead: String?
        var category: [String]
        var url: String?
        var publication_date: String
        var author: String?
        var author_url: String?
        var main_image_caption: String?
        var body: String?
        var body_blocks: [ArticlePartResponse]
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case headline = "headline"
            case subhead = "subhead"
            case category = "category"
            case url = "url"
            case publication_date = "publication_date"
            case author = "author"
            case author_url = "author_url"
            case main_image_caption = "main_image_caption"
            case body = "body"
            case body_blocks = "body_blocks"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            headline = try values.decodeIfPresent(String.self, forKey: .headline) ?? ""
            subhead = try values.decodeIfPresent(String.self, forKey: .subhead)
            category = try values.decodeIfPresent([String].self, forKey: .category) ?? []
            url = try values.decodeIfPresent(String.self, forKey: .url)
            publication_date = try values.decodeIfPresent(String.self, forKey: .publication_date) ?? ""
            author = try values.decodeIfPresent(String.self, forKey: .author)
            author_url = try values.decodeIfPresent(String.self, forKey: .author_url)
            main_image_caption = try values.decodeIfPresent(String.self, forKey: .main_image_caption)
            body = try values.decodeIfPresent(String.self, forKey: .body)
            body_blocks = try values.decodeIfPresent([ArticlePartResponse].self, forKey: .body_blocks) ?? []
        }
    }

    struct ArticlePartResponse: Decodable {
        
        var type: String
        var text: String?
        var start: Int?
        var ordered: Bool?
        var url: String?
        var caption: String?
        var title: String?
        var depth: Int?
        var source: String?
        var style: String?
        var items: [ItemsResponse]?
        var children: [ArticlePartResponse]?
        
        enum CodingKeys: String, CodingKey {
            case type = "type"
            case text = "text"
            case url = "url"
            case caption = "caption"
            case title = "title"
            case image = "image"
            case items = "items"
            case start = "start"
            case depth = "depth"
            case source = "source"
            case style = "style"
            case ordered = "ordered"
            case children = "children"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            type = try values.decode(String.self, forKey: .type)
            text = try values.decodeIfPresent(String.self, forKey: .text)
            url = try values.decodeIfPresent(String.self, forKey: .url)
            caption = try values.decodeIfPresent(String.self, forKey: .caption)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            depth = try values.decodeIfPresent(Int.self, forKey: .depth)
            source = try values.decodeIfPresent(String.self, forKey: .source)
            style = try values.decodeIfPresent(String.self, forKey: .style)
            items = try values.decodeIfPresent([ItemsResponse].self, forKey: .items)
            ordered = try values.decodeIfPresent(Bool.self, forKey: .ordered)
            children = try values.decodeIfPresent([ArticlePartResponse].self, forKey: .children)
            if let _ = try? values.decodeIfPresent(String.self, forKey: .start) {
                start = nil
            } else {
                start = try values.decodeIfPresent(Int.self, forKey: .start)
            }
            
            if let image = try values.decodeIfPresent(ImageResponse.self, forKey: .image) {
                caption = image.caption
                url = image.url
                title = image.title
            }
        }
    }

    struct ItemsResponse: Decodable {
        
        var text: String?
    }


    struct ImageResponse: Decodable {
        
        var url: String?
        var caption: String?
        var title: String?
    }
    

