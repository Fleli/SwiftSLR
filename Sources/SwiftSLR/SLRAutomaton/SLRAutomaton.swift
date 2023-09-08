class SLRAutomaton {
    
    static var currentStateID = 0
    
    let grammar: Grammar
    
    var states: [SLRAutomatonState] = []
    
    init(_ grammar: Grammar) {
        
        self.grammar = grammar
        
        let initialProduction = grammar.initialProduction
        let entryState = SLRAutomatonState(self, from: initialProduction)
        
        entryState.generateFullSLRAutomaton()
        
    }
    
    func addState(_ newState: SLRAutomatonState) {
        
        states.append(newState)
        
        newState.id = Self.currentStateID
        Self.currentStateID += 1
        
    }
    
    func fetchState(with closure: Set<Production>) -> SLRAutomatonState {
        
        if let existingState = findState(with: closure) {
            return existingState
        }
        
        return SLRAutomatonState(self, from: closure)
        
    }
    
    // TODO: La denne huske tidligere resultater (i en dictionary) slik at den etter hvert blir O(1) i stedet for O(n) for n productions.
    private func findState(with closure: Set<Production>) -> SLRAutomatonState? {
        
        let filtered = states.filter { $0.productions == closure }
        
        // Vil en feil her bety at grammatikken som er gitt ikke er LR-parseable?
        // TODO: Undersøk nærmere ...
        assert(filtered.count < 2, "Expected < 2 matching productions, but found \(filtered.count): \(filtered)")
        
        return filtered.first
        
    }
    
}
