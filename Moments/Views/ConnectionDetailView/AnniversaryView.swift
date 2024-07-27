//
//  AnniversaryView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/18/24.
//

import SwiftUI
import FirebaseFirestore

struct Anniversary{
    @DocumentID var id: String?
    var name: String
    var emoji: String
    var date: Date
    var color: Color
}

struct AnniversaryView: View {
    var anniversary: Anniversary
    var body: some View {
        ZStack{
            HStack{
                Text(anniversary.emoji)
                VStack(alignment: .leading){
                    Text(anniversary.name)
                    Text(anniversary.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                let diffs = Calendar.current.dateComponents([.day], from: anniversary.date, to: Date())
                Text("^[\(diffs.day?.description ?? "") day](inflection: true) left")
            }
        }
        
    }
}

#Preview {
    AnniversaryView(anniversary: Anniversary(name: "Anniversary", emoji: "😘", date: Date(), color: .white))
        .padding()
}
