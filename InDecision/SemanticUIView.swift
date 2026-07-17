//
//  SemanticUIView.swift
//  InDecision
//
//  Created by Troy Ginbey on 17/7/2026.
//

import SwiftUI

var name: String = "Dan"
var verb: String = "wants"
var attendeeNum: String = "1-6"
var noun: String = "adventurers"
var toStr: String = "to"
var act: String = "do"
var thing: String = "tai-chi"
var with: String = "with"
var when: String = "tomorrow"

struct SemanticUIView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            Text("39,853 things to do in Perth")
                .font(.body)
                .foregroundStyle(.gray)
            
            HStack(alignment: .top, spacing: 2) {
                Text("\(Text(name).foregroundStyle(.blue)) \(verb) \(Text(attendeeNum).foregroundStyle(.green)) \(Text(noun).foregroundStyle(.indigo)) \(toStr) \(Text(act).foregroundStyle(.red)) \(Text(thing).foregroundStyle(.orange) .underline()) \(with) \(Text(when).foregroundStyle(.blue)).").font(.largeTitle.bold()).lineHeight(.multiple(factor: 1.08))

            }
            
            Text("What would you like to do?")
                .font(.body)
        }
        
        .padding(32)
        
    }
}

#Preview {
    SemanticUIView()
}
