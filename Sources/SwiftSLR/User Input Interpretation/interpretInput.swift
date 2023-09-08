func interpretInput(_ input: String) throws -> [Production] {
    
    let tokens = try Lexer().lex(input)
    
    var index = 0
    var productions: [Production] = []
    
    while index < tokens.count {
        
        guard let production = parseProduction(&index, tokens) else {
            throw SLRError.failed
        }
        
        productions.append(production)
        
    }
    
    return productions
    
}

private func parseProduction(_ index: inout Int, _ tokens: [Token]) -> Production? {
    
    guard index <= tokens.count - 3 else {
        print("Index is \(index), tokens.count is \(tokens.count)")
        return nil
    }
    
    guard
        tokens[index].type == "nonTerminal",
        tokens[index + 1].type == "arrow"
    else {
        print("tokens[index] is \(tokens[index]). Next is \(tokens[index + 1])")
        tokens.forEach {print($0)}
        return nil
    }
    
    let lhs = tokens[index].content
    var rhs: [Symbol] = []
    
    index += 2
    
    while (index < tokens.count) {
        
        print(index, tokens[index])
        
        let symbol: Symbol?
        let content = tokens[index].content
        
        switch tokens[index].type {
        case "terminal":
            let type = String(content.dropFirst())
            symbol = .terminal(type)
        case "nonTerminal":
            symbol = .nonTerminal(content)
        default:
            symbol = nil
        }
        
        if let symbol = symbol {
            
            rhs.append(symbol)
            index += 1
            
        } else {
            
            break
            
        }
        
    }
    
    while index < tokens.count, tokens[index].type == "newLine" {
        index += 1
    }
    
    return Production(lhs: lhs, rhs: rhs)
    
}
