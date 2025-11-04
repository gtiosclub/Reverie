//
//  SignUpView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/28/25.
//

import SwiftUI

struct SignUpView: View {
//    @Environment(FirebaseLoginService.self) private var fls
    
    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var name = ""
    @State private var isSigningUp = false
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Spacer()
            Text("Create Account")
                .font(Font.custom("Quicksand-Medium", size: 32))
                .foregroundColor(Color.gray)
                .padding(36)
            
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "person")
                    TextField("Name", text: $name)
                        .textContentType(.name)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .padding(.bottom, 15)
                
                HStack {
                    Image(systemName: "envelope")
                    TextField("Email Address", text: $email)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .padding(.bottom, 15)
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .padding(.bottom, 15)
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Confirm Password", text: $repeatPassword)
                        .textContentType(.newPassword)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                
                if let errorText = FirebaseLoginService.shared.errorText {
                    Text(errorText)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top)
                } else {
                    Text(" ").padding(.top)
                }
                
                Button(action: signUp) {
                    if isSigningUp {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign Up")
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 19, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 45)
                .background(Color.indigo)
                .cornerRadius(60)
                .disabled(isSigningUp)
            }
            .padding([.leading, .trailing], 20)
            
            Spacer()
            
            HStack {
                Text("Already have an account?")
                Button("Log In") {
                    dismiss()
                }
                .underline()
            }
            .foregroundColor(Color.gray)
            .padding(.bottom, 25)
        }
        .background(BackgroundView().ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
    
    private func signUp() {
        FirebaseLoginService.shared.errorText = nil
        guard password == repeatPassword else {
            FirebaseLoginService.shared.errorText = "Passwords do not match"
            return
        }
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty, !password.isEmpty, !cleanName.isEmpty else {
            FirebaseLoginService.shared.errorText = "Please fill in all fields"
            return
        }
        
        Task {
            isSigningUp = true
            
            await FirebaseLoginService.shared.createUser(
                withEmail: cleanEmail,
                password: password,
                name: cleanName
            )
            
            isSigningUp = false
        }
    }
}

#Preview {
    SignUpView()
        .environment(FirebaseLoginService.shared)
}
