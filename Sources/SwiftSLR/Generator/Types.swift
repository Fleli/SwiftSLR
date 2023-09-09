extension SwiftLibrary {
    
    
    static func typesInFile(_ includingToken: Bool, visibility: String) -> String {
        
        let tail = includingToken ? """
        
        \(visibility) struct Token: CustomStringConvertible {
            
            \(visibility)  var type: String
            \(visibility)  var content: String
            
            \(visibility)  var description: String { type }
            
            \(visibility)  init(_ type: String, _ content: String) {
                
                self.type = type
                self.content = content
                
            }
            
        }
        """ : ""
        
        return """
        \(visibility) enum ParseError: Error {
            case unexpected(_ nonTerminal: String, _ content: String, _ expected: String)
            case abruptEnd(_ nonTerminal: String, _ expected: String)
        }
        
        \(visibility) class SLRNode: CustomStringConvertible {
            
            \(visibility) let type: String
            \(visibility) let children: [SLRNode]
            
            \(visibility) let token: Token?
            
            \(visibility) var description: String { "\\(type)" }
            
            \(visibility) func printFullDescription(_ indent: Int) {
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
