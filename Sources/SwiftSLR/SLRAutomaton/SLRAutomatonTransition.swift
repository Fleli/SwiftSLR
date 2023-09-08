class SLRAutomatonTransition: Hashable, CustomStringConvertible {
    
    var description: String { "\(oldState.id) -> \(newState.id) @ \(transitionSymbol)" }
    
    var oldState: SLRAutomatonState
    var newState: SLRAutomatonState
    
    var transitionSymbol: Symbol
    
    init(_ oldState: SLRAutomatonState, _ newState: SLRAutomatonState, _ transitionSymbol: Symbol) {
        self.oldState = oldState
        self.newState = newState
        self.transitionSymbol = transitionSymbol
    }
    
}
