class Folder: Decodable {
    
//    let id: Int
//    let name: String
//    let createdAt: String
//    let updatedAt: String
//    let childFolders: [Folder]
//    let childFiles: [File]
    
    let path: String
    let childFolders: [Folder]
    let childFiles: [File]
    
}
