//
//  MoodChoosingView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/21/24.
//

import SwiftUI

let moodStates: [(emoji: String, description: String)] = [
    ("😴", "sleep"),
    ("😃", "happy"),
    ("😞", "sad"),
    ("🏃‍♂️", "running"),
    ("💪", "exercising"),
    ("📖", "reading"),
    ("🎧", "listening"),
    ("🍔", "eating"),
    ("🤔", "thinking"),
    ("😡", "angry"),
    ("😌", "relaxed"),
    ("🤢", "sick"),
    ("😭", "crying"),
    ("🤯", "mind blown"),
    ("😩", "tired"),
    ("🥳", "celebrating"),
    ("🧘", "meditating"),
    ("💻", "working"),
    ("🎨", "painting"),
    ("🥰", "in love"),
    ("😤", "frustrated"),
    ("😱", "shocked"),
    ("🥶", "cold"),
    //("🥵", "hot"),
    ("😈", "naughty"),
    //("🤑", "rich"),
    //("🤒", "fever"),
    ("🎭", "dramatic"),
    ("😎", "cool"),
    ("👻", "spooky"),
    ("🎅", "festive"),
    ("🧗", "climbing"),
    ("👨‍🍳", "cooking"),
]
struct Mood{
    var emoji: String
    var description: String
    var color = Color.blue
}

struct MoodChoosingView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedColor: Color = .white
    @State var mood = Mood(emoji: "🤩", description: "Amazing")
    var columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        VStack{
            
            HStack{
                Spacer()
                Button("Save"){
                    dismiss()
                }.padding(.horizontal)
                    .tint(.blue)
            }.overlay{
                Text("Set mood")
                    .fontWeight(.semibold)
                    .font(.title3)
            }.padding(5)
            
            HStack{
                Text(mood.emoji)
                    .font(.title)
                
                Text(mood.description)
                    .font(.title)
            } .font(.caption)
                .padding(10)
                .background(mood.color.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay{
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.secondary, lineWidth: 2)
                }
                .padding(3)
            
            HStack {
                colorPicker
            }.padding(.horizontal)
            ScrollView{
                emotionGrid
            }
                .padding(.horizontal, 2)
        }.padding(3)
    }
    
    private var emotionGrid: some View{
        LazyVGrid(columns: columns) {
            ForEach(moodStates, id: \.emoji) { moodEmoji, moodDescription in
                Button {
                    mood.emoji = moodEmoji
                    mood.description = moodDescription
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(moodEmoji == mood.emoji ? .blue : .gray.opacity(0.2))
                        VStack{
                            Text(moodEmoji)
                                .font(.title)
                            Text(moodDescription)
                                .font(.caption)
                        }.padding(2)
                        
                    }
                }
                .buttonStyle(.plain)
            }
        }.padding(0)
            .drawingGroup()
    }
    
    private var colorPicker: some View{
        ForEach(ColorOptions.all, id: \.self) { color in
            Button {
                withAnimation(.snappy){
                    selectedColor = color
                    mood.color = color
                }
            } label: {
                Circle()
                    .foregroundColor(color)
                    .shadow(radius: 1)
            }
        }
    }
}

#Preview {
    MoodChoosingView()
}
