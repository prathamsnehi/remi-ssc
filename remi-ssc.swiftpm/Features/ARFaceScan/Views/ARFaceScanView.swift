//
//  ARFaceScanView.swift
//  remi-ssc
//
//  Created by Pratham S on 1/31/26.
//

import SwiftUI

struct ARFaceScanView: View {
    var body: some View {
        ZStack(alignment: .top) {
            ARViewContainer()
                .ignoresSafeArea()
            
            HeaderCapsule()
                .padding(.top, 16)
        }
    }
}
