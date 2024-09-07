//
//  MomentV2Widget.swift
//  MomentV2Widget
//
//  Created by Zachary Tao on 4/24/24.
//

import WidgetKit
import SwiftUI
import Firebase
import FirebaseFirestore
import Kingfisher

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: date)!
        fetchFromDB{ pre in
            let entry = SimpleEntry(date: Date(), model: pre)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    func fetchFromDB(completion: @escaping (PreviewPhotoModel) -> ()) {
        guard let user = Auth.auth().currentUser else {
            completion(PreviewPhotoModel(error: "Error: Please login"))
            return
        }
        let db = Firestore.firestore().collection("Connections").whereField("participantsId", arrayContains: user.uid)
        
        Task {
            do {
                var latestMessages: [Message] = []
                let documents = try await db.getDocuments()
                for document in documents.documents {
                    let connection = try document.data(as: Connection.self)
                    guard let connectionID = connection.id else {
                        print("Error: Connection ID is missing")
                        continue
                    }
                    
                    let messageDocuments = try await Firestore.firestore().collection("Connections").document(connectionID).collection("messages")
                        .order(by: "timestamp", descending: true)
                        .limit(to: 1)
                        .getDocuments()
                    if let latestMessage = try messageDocuments.documents.first?.data(as: Message.self) {
                        latestMessages.append(latestMessage)
                    }
                }
                let latestMessagesSorted = latestMessages.sorted(by: { $0.timestamp ?? Date() > $1.timestamp ?? Date() })
                for message in latestMessagesSorted{
                    if message.senderId != user.uid{
                        completion(PreviewPhotoModel(picture: message.photoURL, caption: message.caption ?? ""))
                        return
                    }
                }
                completion(PreviewPhotoModel(error: "No messages found"))
//                if let latestMessage = latestMessages.sorted(by: { $0.timestamp ?? Date() > $1.timestamp ?? Date() }).first {
//                    completion(PreviewPhotoModel(picture: latestMessage.photoURL, caption: latestMessage.caption ?? ""))
//                } else {
//                    completion(PreviewPhotoModel(error: "No messages found"))
//                }
            } catch {
                print("Error: \(error.localizedDescription)")
                completion(PreviewPhotoModel(error: "Failed to fetch messages"))
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var model: PreviewPhotoModel?
}


struct MomentsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        
        VStack{
            Spacer()
            HStack{
                if let preview = entry.model{
                    if preview.error == ""{
                        Text(preview.caption)
                            .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.white)
                    }else{
                        Text(preview.error)
                    }
                }
                else{
                    Text("")
                }
                Spacer()
            }
        }
            
    }
}

extension View {
    @ViewBuilder func widgetBackground<T: View>(@ViewBuilder content: () -> T) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget, content: content)
        }else {
            background(content())
        }
    }
}

extension UIImage {
  func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
    let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
    let format = imageRendererFormat
    format.opaque = isOpaque
    return UIGraphicsImageRenderer(size: canvas, format: format).image {
      _ in draw(in: CGRect(origin: .zero, size: canvas))
    }
  }
}

struct NetworkImage: View {

  public let url: URL?

  var body: some View {

    Group {
     if let url = url, let imageData = try? Data(contentsOf: url),
        let uiImage = UIImage(data: imageData)?.resized(toWidth: 800){

         Image(uiImage: uiImage)
         .resizable()
         .aspectRatio(contentMode: .fill)
      }
      else {
       Image("placeholder-image")
      }
    }
  }

}

struct PreviewPhotoModel: Identifiable{
    var id = UUID()
    var picture: URL?
    var profilePicture: URL?
    var caption = ""
    var error = ""
}

struct MomentsWidget: Widget {
    let kind: String = "MomentsWidget"
    
    init(){
        FirebaseApp.configure()
        do{
//            if let teamId = ProcessInfo.processInfo.environment["teamId"]{
//                try Auth.auth().useUserAccessGroup("\(teamId).edu.vanderbilt.zachtao.Moments")
//            }
            try Auth.auth().useUserAccessGroup("\(teamId).edu.vanderbilt.zachtao.Moments")
        }catch{
            print("firebase configure error: \(error.localizedDescription)")
        }
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MomentsWidgetEntryView(entry: entry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .widgetBackground{
                        if let preview = entry.model{
                            NetworkImage(url: preview.picture)
                        }
                    }
                    .fontDesign(.rounded)
            } else {
                MomentsWidgetEntryView(entry: entry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .widgetBackground{
                        if let preview = entry.model{
                            NetworkImage(url: preview.picture)
                        }
                    }
                    .fontDesign(.rounded)
            }
        }
        .supportedFamilies([.systemLarge, .systemMedium, .systemSmall])
        .configurationDisplayName("Moments")
        .description("Moments photo")
    }
}



struct Message: Identifiable, Codable{
    @DocumentID var id : String?
    let senderId: String
    //message data
    var photoURL: URL?
    var caption: String?
    var timestamp: Date?
    var location: String?
}


struct Connection: Identifiable, Codable, Hashable{
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        if let id1 = lhs.id, let id2 = rhs.id{
            return id1 == id2
        }
        return false
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    @DocumentID var id: String?
    
    
    var participantsId: [String] = []
}
