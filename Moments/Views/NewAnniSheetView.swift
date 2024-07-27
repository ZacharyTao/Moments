//
//  NewAnniView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/19/24.
//

import SwiftUI
enum SheetType: String, Equatable, CaseIterable{
    case countDown = "Days Left"
    case countUp = "Days Passed"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

struct NewAnniSheetView: View {
    
    
    
    @Environment(\.dismiss) private var dismiss
    @State var anni = Anniversary(name: "", emoji: "🎂", date: Date(), color: .white)
    @State private var selectedColor: Color = ColorOptions.default
    @State private var symbolNames = AnniSymbols.symbolNames
    @State private var searchInput = ""
    @State private var countType = SheetType.countDown
    var columns = Array(repeating: GridItem(.flexible()), count: 5)

    var body: some View {
            VStack {
                HStack{
                    Spacer()
                    Button("Save"){
                        dismiss()
                    }.padding(.horizontal)
                        .tint(.blue)
                }.padding(.horizontal)
                    .padding(.top)
                
                Picker("Choose your Day Counting Type", selection: $countType){
                    ForEach(SheetType.allCases, id: \.self){value in
                        Text(value.localizedName)
                                .tag(value)
                    }
                    
                }.pickerStyle(.segmented)
                    .padding(.horizontal)
                
            
                Form{
                    Section("PICK A COLOR"){
                        HStack {
                            colorPicker
                        }
                    }
                    
                    Section("PICK A NAME"){
                        TextField("Name your countdown", text: $anni.name)
                    }
                    
                    Section("PICK A DATE"){
                        if countType == .countDown{
                            DatePicker("", selection: $anni.date,
                                       in: Date()...,
                                       displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }else{
                            DatePicker("", selection: $anni.date,
                                       in: ...Date(),
                                       displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }
                    }
                    Section("PICK AN EMOJI"){
                           emojiGrid
                    }
                }
                .scrollContentBackground(.hidden)

            }
            .tint(.blue)
            .buttonStyle(BorderlessButtonStyle())
            .onAppear {
                selectedColor = Color(anni.color)
            }
            .background(anni.color.opacity(0.3))


    }
    
    private var colorPicker: some View{
        ForEach(ColorOptions.all, id: \.self) { color in
            Button {
                withAnimation(.snappy){
                    selectedColor = color
                    anni.color = color
                }
            } label: {
                Circle()
                    .foregroundColor(color)
                    .shadow(radius: 1)
            }
        }
    }
    
    private var emojiGrid: some View{
        LazyVGrid(columns: columns) {
            ForEach(symbolNames, id: \.self) { symbolItem in
                Button {
                    anni.emoji = symbolItem
                    
                } label: {
                    ZStack{
                        
                        Circle()
                            .foregroundStyle(anni.emoji == symbolItem ? .blue : .clear)
                            .padding(0)

                        Text(symbolItem)
                            .font(.title)
                            .padding(3)
                    }
                }
                .buttonStyle(.plain)
            }
        }.padding(0)
        .drawingGroup()
    }
}




#Preview {
        NewAnniSheetView()
}
