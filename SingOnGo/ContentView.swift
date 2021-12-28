//
//  ContentView.swift
//  SingOnGo
//
//  Created by Vitaly on 24/12/21.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Namespace var animation
    
    @State private var currentInputName: String = "Find your mic input"
    @State private var isExpanded = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 40) {
                if !viewModel.isActive {
                    Text("""
                    Find your headphone's mic in the form
                    above and press at gray circle in bottom
                    of the screen
                    """)
                        .kerning(0.5)
                        .modifier(MainText())
                } else {
                    Text("""
                    Now you hear yourself in parallel with
                    the music. Just set your mic volume
                    to your comfortable level and sing!
                    """)
                        .kerning(0.5)
                        .modifier(MainText())
                }
                VStack(alignment: .leading) {
                    
                    if !viewModel.isActive {
                        Text("Input settings")
                            .kerning(0.8)
                            .font(.system(size: 24).weight(.bold))
                        DisclosureGroup(isExpanded: $isExpanded, content: {
                            DisclosureGroupContent(currentInput: $viewModel.currentInput, currentInputName: $currentInputName, isExpanded: $isExpanded, isInputSelected: $viewModel.isInputSelected, mics: viewModel.inputs)
                        }, label: {
                            DisclosureGroupTitle(currentInputName: $currentInputName)
                        })
                            .accentColor(Color("BlackWhite"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.2))
                            .cornerRadius(7)
                    } else {
                        Text("Current mic volume")
                            .kerning(0.8)
                            .font(.system(size: 24).weight(.bold))
                            .padding(.bottom, 32)
                        Slider(value: $viewModel.volume, in: 0...10)
                            .tint(.red)
                    }
                }
                
                Spacer()
                
                Button {
                    viewModel.play()
                } label: {
                    HStack {
                        Spacer()
                        ZStack {
                            if !viewModel.isActive {
                                Circle()
                                    .fill(.gray)
                                    .matchedGeometryEffect(id: "color", in: animation)
                                    .frame(width: 64, height: 64)
                            } else {
                                Circle()
                                    .fill(.red)
                                    .matchedGeometryEffect(id: "color", in: animation)
                                    .frame(width: 80, height: 80)
                            }
                        }
                        Spacer()
                    }
                    .frame(maxHeight: 96, alignment: .center)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .navigationTitle(Text("Sing along the music"))
        }
        //        .alert(isPresented: $inputAlert, content: {
        //            Alert(title: Text("Input not selected"), message: Text("First you need to select your mic input"), dismissButton: .default(Text("Select one")))
        //        })
        .alert(isPresented: $viewModel.requestAlert, content: {
            Alert(title: Text("Error"), message: Text("Enable Access"))
        })
        .onAppear {
            viewModel.appear()
        }
        .onChange(of: viewModel.volume) { newValue in
            viewModel.changedVolume(volume: newValue)
        }
    }
}

struct DisclosureGroupTitle: View {
    
    @Binding var currentInputName: String
    
    var body: some View {
        HStack {
            Image(systemName: "mic.fill")
                .padding(.trailing, 2)
            Text(currentInputName)
                .kerning(0.5)
                .foregroundColor(Color("BlackWhite"))
        }
        .modifier(MainText())
    }
}

struct DisclosureGroupItem: View {
    
    var selectedInputName: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "mic.fill")
                    .padding(.trailing, 2)
                Text(selectedInputName)
                    .kerning(0.5)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            .modifier(MainText())
        }
        .padding(.bottom, 4)
    }
}

extension ContentView {
    
    struct DisclosureGroupContent: View {
        
        @EnvironmentObject var viewModel: ViewModel
        @Binding var currentInput: AVAudioSessionPortDescription?
        @Binding var currentInputName: String
        @Binding var isExpanded: Bool
        @Binding var isInputSelected: Bool
        
        var mics: [AVAudioSessionPortDescription]
        
        var body: some View {
            VStack(alignment: .leading) {
                Divider()
                ForEach(mics, id: \.self) { mic in
                    DisclosureGroupItem(selectedInputName: mic.portName.localizedCapitalized)
                        .onTapGesture {
                            viewModel.currentInput = mic
                            currentInputName = mic.portName.localizedCapitalized
                            viewModel.isInputSelected = true
                            withAnimation(.spring(dampingFraction: 0.8, blendDuration: 0.2)) {
                                isExpanded.toggle()
                            }
                        }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
    }
}

struct MainText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18).weight(.medium))
            .lineSpacing(2)
            .foregroundColor(Color("BlackWhite"))
    }
}
