class Grammar {
    
    var initialProduction: Production
    
    var productions: [Production] = []
    
    private var terminals: Set<String> = []
    
    internal private(set) var nullableNonTerminals: Set<String> = []
    internal private(set) var firstSets: [String : Set<String>] = [:]
    internal private(set) var followSets: [String : Set<String?>] = [:]
    
    private var nullabilityCount: Int { nullableNonTerminals.count }
    private var firstSetCount: Int { firstSets.map { $0.value.count } .sum() }
    private var followSetCount: Int { followSets.map { $0.value.count } .sum() }
    
    init(_ initialProduction: Production) {
        
        self.initialProduction = initialProduction
        
        initialProduction.isAccepting = true
        
        addProduction(self.initialProduction)
        
    }
    
    func addProduction(_ production: Production) {
        
        production.grammar = self
        productions.append(production)
        
        terminals.formUnion(production.terminals)
        
    }
    
    func productionsFor(_ nonTerminal: String) -> [Production] {
        
        return productions.filter { $0.lhs == nonTerminal }
        
    }
    
    func calculateFirstAndFollowSets() {
        
        nullableNonTerminals = []
        
        productions.forEach {
            firstSets[$0.lhs] = []
            followSets[$0.lhs] = []
        }
        
        followSets[initialProduction.lhs] = [nil]
        
        calculateNullability()
        calculateFirstSets()
        calculateFollowSets()
        
        followSets.forEach {
            Swift.print($0)
        }
        
    }
    
    private func calculateNullability() {
        
        let nonTerminalStrings = productions.filter { $0.rhs.count == 0 } .map { $0.lhs }
        nullableNonTerminals = Set<String>(nonTerminalStrings)
        
        var nullCounts = [nullableNonTerminals.count]
        var didWrapAround = false
        
        var didReachFixedPoint: Bool {
            
            let lastIndex = nullCounts.count - 1
            
            Swift.print(nullCounts, nullabilityCount)
            
            Swift.print(lastIndex)
            
            return didWrapAround
                && nullCounts[lastIndex] == nullCounts[lastIndex - productions.count]
            
        }
        
        var productionIndex = 0
        
        while !didReachFixedPoint {
            
            let production = productions[productionIndex]
            
            if indirectlyNullable(production) {
                let lhs = production.lhs
                Swift.print(lhs, "is nullable!")
                nullableNonTerminals.insert(lhs)
                Swift.print(nullableNonTerminals)
            }
            
            let adjusted = (productionIndex + 1) % (productions.count)
            
            if adjusted != productionIndex + 1 {
                didWrapAround = true
            }
            
            productionIndex = adjusted
            nullCounts.append(nullabilityCount)
            
        }
        
    }
    
    private func indirectlyNullable(_ production: Production) -> Bool {
        
        for index in 0 ..< production.rhs.count {
            
            switch production.rhs[index] {
            case .nonTerminal(let nonTerminal):
                
                guard nullableNonTerminals.contains(nonTerminal) else {
                    return false
                }
                
            case .terminal(_):
                return false
            }
            
        }
        
        return true
        
    }
    
    private func calculateFirstSets() {
        
        var firstSetCounts: [Int] = []
        
        let productionCount = productions.count
        
        var didReachFixedPoint: Bool {
            
            let lastIndex = firstSetCounts.count - 1
            
            // Hvis gått en hel runde uten oppdatering (periode på productionCount) så har vi et fixed point.
            return firstSetCounts.count > productionCount
                && firstSetCounts[lastIndex] == firstSetCounts[lastIndex - productionCount]
            
        }
        
        var productionIndex = 0
        
        while !didReachFixedPoint {
            
            let production = productions[productionIndex]
            let lhs = production.lhs
            let rhs = production.rhs
            
            // Only look at productions with a non-empty RHS
            if production.rhs.count > 0 {
                updateFirstSet(of: lhs, with: rhs)
            }
            
            firstSetCounts.append(firstSetCount)
            productionIndex = (productionIndex + 1) % productionCount
            
        }
        
        firstSets.forEach {
            
            Swift.print("First set of", $0.key, "is", $0.value)
            
        }
        
    }
    
    private func updateFirstSet(of lhs: String, with rhs: [Symbol]) {
        
        if case .nonTerminal(let firstNonTerminal) = rhs[0] {
            
            let otherFirst = firstSets[firstNonTerminal]!
            firstSets[lhs]?.formUnion(otherFirst)
            
            guard nullableNonTerminals.contains(firstNonTerminal) && rhs.count >= 2 else {
                return
            }
            
            if case .nonTerminal(let nextNonTerminal) = rhs[1] {
                
                let otherFirst = firstSets[nextNonTerminal]!
                firstSets[lhs]?.formUnion(otherFirst)
                
            } else if case .terminal(let terminal) = rhs[1] {
                
                firstSets[lhs]?.insert(terminal)
                
            }
            
        } else if case .terminal(let terminal) = rhs[0] {
            
            firstSets[lhs]?.insert(terminal)
            
        }
        
        
    }
    
    private func calculateFollowSets() {
        
        var followSetCounts: [Int] = []
        
        let productionCount = productions.count
        
        var didReachFixedPoint: Bool {
            
            let lastIndex = followSetCounts.count - 1
            
            return followSetCounts.count > productionCount
                && followSetCounts[lastIndex] == followSetCounts[lastIndex - productionCount]
            
        }
        
        var productionIndex = 0
        
        while !didReachFixedPoint {
            
            let production = productions[productionIndex]
            
            supplyFollowSet(from: production)
            
            followSetCounts.append(followSetCount)
            productionIndex = (productionIndex + 1) % productionCount
            
        }
        
    }
    
    private func supplyFollowSet(from production: Production) {
        
        let lhs = production.lhs
        
        for nonTerminal in production.nonTerminals {
            
            for nextNonTerminal in production.nonTerminalsAfter(nonTerminal) {
                let otherFirst = firstSets[nextNonTerminal]!
                followSets[nonTerminal]?.formUnion(otherFirst)
            }
            
            for nextTerminal in production.terminalsAfter(nonTerminal) {
                followSets[nonTerminal]?.insert(nextTerminal)
            }
            
            if production.nonTerminalIsLast(nonTerminal) {
                let lhsFollow = followSets[lhs]!
                followSets[nonTerminal]?.formUnion(lhsFollow)
            }
            
        }
        
    }
    
    func print(with indentation: Int = 0) {
        
        let prefix = String(repeating: "\t", count: indentation)
        
        Swift.print("\n" + prefix + "Grammar {")
        
        productions.forEach {
            Swift.print(prefix + "\t\($0)")
        }
        
        Swift.print(prefix + "}\n")
        
    }
    
}
