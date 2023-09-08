extension SLRAutomatonState {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SLRAutomatonState, rhs: SLRAutomatonState) -> Bool {
        return lhs.productions == rhs.productions && lhs.id == rhs.id
    }
    
}

extension SLRAutomatonTransition {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(oldState)
        hasher.combine(newState)
    }
    
    static func == (lhs: SLRAutomatonTransition, rhs: SLRAutomatonTransition) -> Bool {
        return (lhs.oldState == rhs.oldState) && (lhs.newState == rhs.newState) && (lhs.transitionSymbol == rhs.transitionSymbol)
    }
    
}
