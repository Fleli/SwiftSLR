class Production: Hashable, CustomStringConvertible {
    
    var description: String {
        
        var rhsString = "[ "
        
        for index in 0 ... rhs.count {
            
            if index == marker {
                rhsString.append(". ")
            }
            
            if index < rhs.count {
                rhsString.append("\(rhs[index])")
            }
            
            rhsString.append(" ")
            
        }
        
        rhsString.removeLast()
        rhsString.append("]")
        
        return lhs + " -> \(rhsString)"
        
    }
    
    weak var grammar: Grammar!
    
    let lhs: String
    let rhs: [Symbol]
    var marker = 0
    
    var isAccepting = false
    
    var terminals: Set<String> = []
    var nonTerminals: Set<String> = []
    
    var currentSymbol: Symbol? { marker < rhs.count ? rhs[marker] : nil }
    
    var isReduction: Bool { currentSymbol == nil }
    var isShift: Bool { !isReduction }
    
    // TODO: Cache denne når den først er funnet, for den vil brukes svært mange ganger.
    var closure: Set<Production> {
        
        var productionClosure: Set<Production> = []
        
        fillClosure(&productionClosure)
        
        return productionClosure
        
    }
    
    convenience init(lhs: String, rhs: [Symbol]) {
        self.init(lhs, rhs, 0)
    }
    
    private init(_ lhs: String, _ rhs: [Symbol], _ marker: Int) {
        
        self.lhs = lhs
        self.rhs = rhs
        self.marker = marker
        
        for symbol in rhs {
            if case .terminal(let terminal) = symbol {
                terminals.insert(terminal)
            } else if case .nonTerminal(let nonTerminal) = symbol {
                nonTerminals.insert(nonTerminal)
            }
        }
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(lhs)
    }
    
    private func fillClosure(_ closure: inout Set<Production>) {
        
        if closure.contains(where: {$0 == self} ) {
            return
        }
        
        closure.insert(self)
        
        guard let currentSymbol = currentSymbol, case .nonTerminal(let nonTerminal) = currentSymbol else {
            return
        }
        
        let productions = grammar!.productionsFor(nonTerminal)
        
        productions.forEach {
            $0.fillClosure(&closure)
        }
        
    }
    
    func withAdvancedMarker() -> Production {
        let newProduction = Production(lhs, rhs, marker + 1)
        newProduction.grammar = grammar
        newProduction.isAccepting = self.isAccepting
        return newProduction
    }
    
    // TODO: De neste funksjonene bør cache resultatene sine etter første call. Har en mistanke om at
    // disse vil calles svært mange ganger for store grammatikker, men resultatene vil alltid være de samme.
    
    func nonTerminalIsLast(_ expected: String) -> Bool {
        
        guard case .nonTerminal(let actual) = rhs.last else {
            return false
        }
        
        return actual == expected
        
    }
    
    func nonTerminalsAfter(_ nonTerminal: String) -> Set<String> {
        
        var nonTerminals: Set<String> = []
        
        for index in 0 ..< rhs.count - 1 {
            
            let this = rhs[index]
            let next = rhs[index + 1]
            
            guard case .nonTerminal(let this) = this, case .nonTerminal(let next) = next else {
                continue
            }
            
            if this == nonTerminal {
                nonTerminals.insert(next)
            }
            
        }
        
        return nonTerminals
        
    }
    
    func terminalsAfter(_ nonTerminal: String) -> Set<String> {
        
        var terminals: Set<String> = []
        
        for index in 0 ..< rhs.count - 1 {
            
            let this = rhs[index]
            let next = rhs[index + 1]
            
            guard case .nonTerminal(let this) = this, case .terminal(let next) = next else {
                continue
            }
            
            if this == nonTerminal {
                terminals.insert(next)
            }
            
        }
        
        return terminals
        
    }
    
    static func == (lhs: Production, rhs: Production) -> Bool {
        return (lhs.lhs == rhs.lhs) && (lhs.rhs == rhs.rhs) && (lhs.marker == rhs.marker)
    }
    
}
