//
//  RangeSlider.swift
//  InDecision
//
//  Created by Jacob Gellard on 20/7/2026.
//

import SwiftUI

struct RangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double

    let bounds: ClosedRange<Double>

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            let lowerX = CGFloat((lowerValue - bounds.lowerBound) /
                                 (bounds.upperBound - bounds.lowerBound)) * width

            let upperX = CGFloat((upperValue - bounds.lowerBound) /
                                 (bounds.upperBound - bounds.lowerBound)) * width

            ZStack(alignment: .leading) {

                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)

                Capsule()
                    .fill(.indigo)
                    .frame(width: upperX - lowerX, height: 4)
                    .offset(x: lowerX)

                // Lower handle
                Capsule()
                    .fill(Color.white)
                    .overlay(
                        Capsule()
                            .stroke(Color.indigo, lineWidth: 2)
                    )
                    .frame(width: 42, height: 24)
                    .position(x: lowerX, y: 13)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let percentage = min(max(value.location.x / width, 0), 1)
                                let newValue = bounds.lowerBound +
                                    Double(percentage) * (bounds.upperBound - bounds.lowerBound)

                                lowerValue = min(newValue, upperValue)
                            }
                    )

                // Upper handle
                Capsule()
                    .fill(Color.white)
                    .overlay(
                        Capsule()
                            .stroke(Color.indigo, lineWidth: 2)
                    )
                    .frame(width: 42, height: 24)
                    .position(x: upperX, y: 13)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let percentage = min(max(value.location.x / width, 0), 1)
                                let newValue = bounds.lowerBound +
                                    Double(percentage) * (bounds.upperBound - bounds.lowerBound)

                                upperValue = max(newValue, lowerValue)
                            }
                    )
            }
        }
        .frame(height: 30)
    }
}

struct Viewa: View {
    @State private var lowerValue = 10.0
    @State private var upperValue = 20.0

    var body: some View {
        VStack(spacing: 20) {
            Text("Range: \(Int(lowerValue)) - \(Int(upperValue))")

            RangeSlider(
                lowerValue: $lowerValue,
                upperValue: $upperValue,
                bounds: 0.0...20.0
            )
            .padding()
        }
    }
}

#Preview {
    Viewa()
}

#Preview{
    Viewa()
}
