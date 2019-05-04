//
//  SchemaBuilder.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

class SchemaBuilder {
    private var schema: String
    
    init(schema: String = RouteConstants.Nouns.kvasir) {
        self.schema = "\(schema):/"
    }
    
    func component(_ aComponent: String) -> SchemaBuilder {
        if aComponent.isEmpty { fatalError("route component should not be empty") }
        schema.append(contentsOf: "/\(aComponent)")
        return self
    }
    
    func extract() -> String {
        return schema
    }
}
