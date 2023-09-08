extension SwiftLibrary {
    
    
    static func slrClass(_ slrStateFunctions: String, _ grammar: Grammar) -> String {
        
        return """
        
        class SLRParser {
        
        \(slrParserFields)
        \(slrParserFunctions)
        \(slrStateFunctions)
        }
        """
        
    }
    
    
}
