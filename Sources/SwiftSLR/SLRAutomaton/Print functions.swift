extension SLRAutomaton {
    
    func print() {
        
        Swift.print("SLR Automaton {")
        
        grammar.print(with: 1)
        
        Swift.print("\tStates {")
        
        states.forEach { $0.print(with: 2) }
        
        Swift.print("\t}\n}")
        
    }
    
}

extension SLRAutomatonState {
    
    func print(with indentation: Int) {
        
        let prefix = String(repeating: "\t", count: indentation)
        
        let isReducingNotification = isReducing ? "(REDUCING) " : ""
        let isShiftingNotification = isShifting ? "(SHIFTING) " : ""
        
        Swift.print(prefix + "State \(id) \(isReducingNotification)\(isShiftingNotification){")
        
        Swift.print(prefix + "\tClosure {")
        
        productions.forEach {
            Swift.print(prefix + "\t\t\($0)")
        }
        
        Swift.print(prefix + "\t} Transitions {")
        
        transitions.forEach {
            Swift.print(prefix + "\t\t\($0)")
        }
        
        Swift.print(prefix + "\t}")
        
        
        Swift.print(prefix + "}")
        
    }
    
}
