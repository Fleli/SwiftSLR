class SLRAutomatonState: Hashable, CustomStringConvertible {
    
    var description: String {
        return "\(id)"
    }
    
    private weak var slrAutomaton: SLRAutomaton!
    
    var id = -1
    var productions: Set<Production> {
        didSet { fillGroups() }
    }
    
    var terminalGroups: [String : Set<Production>] = [:]
    var nonTerminalGroups: [String : Set<Production>] = [:]
    
    var transitions: Set<SLRAutomatonTransition> = []
    
    var errorMessage: (nonTerminal: String, expected: Symbol?) {
        let first = productions.first!
        return (first.lhs, first.currentSymbol)
    }
    
    var isReducing: Bool { productions.filter {$0.isReduction} .count > 0 }
    var isShifting: Bool { productions.filter {$0.isShift} .count > 0 }
    
    var isShiftReduceConflict: Bool { isReducing && isShifting }
    var isReduceReduceConflict: Bool { productions.filter {$0.isReduction} .count > 1 }
    
    private var didGenerate = false
    
    private var stateCache: [Symbol : SLRAutomatonState] = [:]
    
    convenience init(_ slrAutomaton: SLRAutomaton, from initialProduction: Production) {
        
        let closure = initialProduction.closure
        
        self.init(slrAutomaton, from: closure)
        
    }
    
    init(_ slrAutomaton: SLRAutomaton, from closure: Set<Production>) {
        
        self.slrAutomaton = slrAutomaton
        self.productions = closure
        
        slrAutomaton.addState(self)
        
        fillGroups()
        
    }
    
    private func fillGroups() {
        
        nonTerminalGroups = [:]
        productions.forEach { enterIntoGroup($0) }
        
    }
    
    private func enterIntoGroup(_ production: Production) {
        
        guard let symbol = production.currentSymbol else {
            return
        }
        
        if case .nonTerminal(let name) = symbol {
            
            if (nonTerminalGroups[name] != nil) {
                
                nonTerminalGroups[name]?.insert(production)
                
            } else {
                
                nonTerminalGroups[name] = [production]
                
            }
            
            return
            
        }
        
        if case .terminal(let type) = symbol {
            
            if (terminalGroups[type] != nil) {
                
                terminalGroups[type]?.insert(production)
                
            } else {
                
                terminalGroups[type] = [production]
                
            }
            
            return
            
        }
        
    }
    
    func generateFullSLRAutomaton() {
        
        if (didGenerate) {
            return
        }
        
        didGenerate = true
        
        nonTerminalGroups.forEach {
            propagateGeneration(for: $0, isNonTerminal: true)
        }
        
        terminalGroups.forEach {
            propagateGeneration(for: $0, isNonTerminal: false)
        }
        
    }
    
    private func propagateGeneration(for group: (key: String, value: Set<Production>), isNonTerminal: Bool) {
        
        let terminal = Symbol.terminal(group.key)
        let nonTerminal = Symbol.nonTerminal(group.key)
        
        var closure: Set<Production> = []
        
        group.value.forEach {
            
            let advanced = $0.withAdvancedMarker()
            closure.formUnion(advanced.closure)
            
        }
        
        let transitionSymbol = isNonTerminal ? nonTerminal : terminal
        
        propagateAutomatonGeneration(with: closure, transitionSymbol)
        
    }
    
    private func propagateAutomatonGeneration(with closure: Set<Production>, _ transitionSymbol: Symbol) {
        
        let otherState = slrAutomaton.fetchState(with: closure)
        otherState.generateFullSLRAutomaton()
        
        let transition = SLRAutomatonTransition(self, otherState, transitionSymbol)
        transitions.insert(transition)
        
    }
    
}
