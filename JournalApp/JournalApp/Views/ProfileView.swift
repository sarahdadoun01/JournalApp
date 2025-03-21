//
//  ProfileView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-27.
//

import SwiftUI

struct ProfileView: View {
    @State private var username: String = ""
    
    var body: some View {
        VStack {
                    TextField("Username", text: $username) // <1>, <2>
                }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
