class SwiftGenerator {
    
    
    static func generate(_ filename: String, from slrAutomaton: SLRAutomaton, _ includingToken: Bool, _ grammar: Grammar, _ visibility: String) -> String {
        
        return """
        
        // \(filename).swift
        // Auto-generated by SwiftSLR
        // See https://github.com/Fleli/SwiftSLR
        
        \(SwiftLibrary.slrClass(generateFunctions(for: slrAutomaton, grammar), grammar))
        
        \(SwiftLibrary.typesInFile(includingToken, visibility: visibility))
        
        """
        
    }
    
    
    private static func generateFunctions(for slrAutomaton: SLRAutomaton, _ grammar: Grammar) -> String {
        
        var functions: String = ""
        
        for state in slrAutomaton.states {
            
            let function = generateFuncFor(state, grammar)
            functions.append(function)
            
        }
        
        return functions
        
    }
    
    
    private static func generateFuncFor(_ state: SLRAutomatonState, _ grammar: Grammar) -> String {
        
        var function = "\tprivate func state_\(state.id)() throws {\n\n"
        
        for transition in state.transitions where transition.transitionSymbol.isNonTerminal {
            function += statement(for: transition)
        }
        
        for transition in state.transitions where !transition.transitionSymbol.isNonTerminal {
            function += statement(for: transition)
        }
        
        function += reduceStatement(state, grammar)
        
        let errorMessage = state.errorMessage
        
        function += """
                    if index < input.count {
                        throw ParseError.unexpected("\(errorMessage.nonTerminal)", input[index].description, "\(errorMessage.expected?.description ?? "reduction")")
                    } else {
                        throw ParseError.abruptEnd("\(errorMessage.nonTerminal)", "\(errorMessage.expected?.description ?? "reduction")")
                    }
                    
            
            """
        
        function += "\t}\n\t\n"
        
        return function
        
    }
    
    
    private static func statement(for transition: SLRAutomatonTransition) -> String {
        
        let newState = transition.newState.id
        let transitionSymbol = transition.transitionSymbol
        
        switch transitionSymbol {
            
        case .terminal(let type):
            
            return SwiftLibrary.shiftIfTopOfStack(is: type, to: newState)
            
        case .nonTerminal(let nonTerminal):
            
            return SwiftLibrary.goto(newState, ifTopOfStackIs: nonTerminal)
            
        }
        
    }
    
    
    private static func reduceStatement(_ state: SLRAutomatonState, _ grammar: Grammar) -> String {
        
        let reducingProductions = state.productions.filter { $0.isReduction }
        let reduceCount = reducingProductions.count
        
        if (reduceCount > 1) {
            print("The grammar contains a REDUCE/REDUCE conflict:")
            print("Erroneous state: \(state.id)")
            reducingProductions.forEach { print($0) }
            fatalError()
        }
        
        var string = ""
        
        if let first = reducingProductions.first {
            
            string += SwiftLibrary.reduce(first, grammar)
            
        }
        
        return string
        
    }
    
    
}
