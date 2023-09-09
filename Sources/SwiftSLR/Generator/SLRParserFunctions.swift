extension SwiftLibrary {
    
    
    static var slrParserFunctions: String {
        
        return """
            
            func parse(_ tokens: [Token]) throws -> SLRNode? {
                
                self.index = 0
                self.input = tokens
                
                self.accepted = false
                
                self.stack = []
                self.states = [state_0]
                
                repeat {
                    
                    try states[states.count - 1]()
                    
                } while !accepted
                
                if stack.count != 1 {
                    print(stack)
                    return nil
                }
                
                return stack[0]
                
            }
            
            private func shift() {
                
                let token = input[index]
                let slrNode = SLRNode(token)
                stack.append(slrNode)
                index += 1
                
            }
            
            private func reduce(_ numberOfStates: Int, to nonTerminal: String) {
                
                let children = [SLRNode](stack[stack.count - numberOfStates ..< stack.count])
                
                let newNode = SLRNode(nonTerminal, children)
                
                stack.removeLast(numberOfStates)
                states.removeLast(numberOfStates)
                
                stack.append(newNode)
                
            }
            
            private func topOfStackIsToken(_ type: String) -> Bool {
                return topOfStackIsAmong([type])
            }
            
            private func topOfStackIsAmong(_ terminals: Set<String?>) -> Bool {
                
                guard notExhausted else {
                    return terminals.contains(nil)
                }
                
                return terminals.contains(input[index].type)
                
            }
            
            private func topOfStackIsNonTerminal(_ type: String) -> Bool {
                
                guard stack.count > 0 else {
                    return false
                }
                
                let top = stack[stack.count - 1]
                
                if top.token != nil {
                    return false
                }
                
                return type == top.type
                
            }
            
            private func pushState(_ newState: @escaping () throws -> ()) {
                states.append(newState)
            }
        
        """
        
    }
    
    
}
