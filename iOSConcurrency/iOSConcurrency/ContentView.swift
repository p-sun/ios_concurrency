//
//  ContentView.swift
//  iOSConcurrency
//
//  Created by Paige Sun on 2023-09-05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(.orange).opacity(0.2).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    Text("iOS Concurrency")
                        .navigationBarTitleDisplayMode(.inline).font(.title)
                    
                    ScrollView {
                        Spacer()
                        DispatchQueueExamples()
                    }
                    .padding()

                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
