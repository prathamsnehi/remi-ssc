//
//  PhotoHeader.swift
//  remi
//
//  Created by Pratham S on 12/23/25.
//

import SwiftUI

struct PhotoHeader: View {
    let image: UIImage?
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 4)
                .padding(.top)
        }
    }
}
