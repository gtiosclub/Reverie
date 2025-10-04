//
//  LoginView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/28/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(FirebaseLoginService.self) private var fls
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningIn = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Sign In")
                    .font(Font.custom("Quicksand-Medium", size: 32))
                    .foregroundColor(Color.gray)
                    .padding(36)
                
                VStack(spacing: 15) {
                    HStack {
                        Text("Email Address")
                        Spacer()
                    }
                    .foregroundColor(Color.gray)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .frame(width: 21, height: 17)
                        TextField("Email Address", text: $email)
                            .foregroundColor(.primary)
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .padding(.bottom, 15)
                    
                    HStack {
                        Text("Password")
                        Spacer()
                    }
                    .foregroundColor(Color.gray)
                    
                    HStack {
                        Image(systemName: "lock")
                            .frame(width: 15, height: 17)
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    
                    if let errorText = fls.errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                            .padding(.top)
                    } else {
                        Text(" ").padding(.top)
                    }
                    
                    // Login Button
                    Button(action: signIn) {
                        if isSigningIn {
                            ProgressView()
                        } else {
                            Text("Login")
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 19, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 45)
                    .background(Color.indigo)
                    .cornerRadius(60)
                    .disabled(isSigningIn)
                }
                .padding([.leading, .trailing], 20)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    NavigationLink("Sign Up") {
                        SignUpView()
                    }
                }
                .foregroundColor(Color.gray)
                .padding(.bottom, 25)
            }
            .background(BackgroundView().ignoresSafeArea())
        }
    }
    
    private func signIn() {
        isSigningIn = true
        Task {
            await fls.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            isSigningIn = false
        }
    }
}

#Preview {
    LoginView()
        .environment(FirebaseLoginService.shared)
}
