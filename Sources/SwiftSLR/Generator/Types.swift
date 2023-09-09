extension SwiftLibrary {
    
    
    static func typesInFile(_ includingToken: Bool, visibility: String) -> String {
        
        let tail = includingToken ? """
        
        struct Token: CustomStringConvertible {
            
            public var type: String
            public var content: String
            
            public var description: String { type }
            
            public init(_ type: String, _ content: String) {
                
                self.type = type
                self.content = content
                
            }
            
        }
        """ : ""
        
        return """
        enum ParseError: Error {
            case unexpected(_ nonTerminal: String, _ content: String, _ expected: String)
            case abruptEnd(_ nonTerminal: String, _ expected: String)
        }
        
        \(visibility) class SLRNode: CustomStringConvertible {
            
            let type: String
            let children: [SLRNode]
            
            let token: Token?
            
            var description: String { "\\(type)" }
            
            func printFullDescription(_ indent: Int) {
                print(String(repeating: "|   ", count: indent) + type)
                for child in children {
                    child.printFullDescription(indent + 1)
                }
            }
            
            init(_ type: String, _ children: [SLRNode]) {
                self.type = type
                self.children = children
                self.token = nil
            }
            
            init(_ token: Token) {
                self.type = token.type
                self.children = []
                self.token = token
            }
            
        }
        
        \(tail)
        """
        
    }
    
    
}
