//
//  TestView.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/30/25.
//
import Foundation
import SwiftUI

struct TestView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                Text("To use, simply add a button to this page and in the onclick handler of the button call your function. Then see if the funciton works as desired")
                    .foregroundColor(.white)
                Button ("Example Test"){
                    exampleTest()
                }

            }
            TabbarView()
        }
    }
}

func exampleTest() {
    print("This is logged in the console")
}
