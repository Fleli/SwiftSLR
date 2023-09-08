extension SwiftLibrary {
    
    
    static var slrParserFields: String {
        
        return """
            private var index: Int = 0
            private var input: [Token] = []
            private var stack: [SLRNode] = []
            private var states: [() throws -> ()] = []
            
            private var accepted = false
            
            private var notExhausted: Bool { index < input.count }
        """
        
    }
    
    
}
