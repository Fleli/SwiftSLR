import Foundation

public func generate(from input: String, includingToken: Bool, location: String, parseFile: String, visibility: String = "public") throws {
    try Generator.generate(from: input, includingToken: includingToken, location: location, parseFile: parseFile, visibility: visibility)
}

private class Generator {
    
    static func generate(from input: String, includingToken: Bool, location: String, parseFile: String, visibility: String) throws {
        
        let productions = try interpretInput(input)
        
        let grammar = createGrammarFrom(productions)
        
        grammar.calculateFirstAndFollowSets()
        
        let automaton = SLRAutomaton(grammar)
        
        automaton.print()
        
        let code = SwiftGenerator.generate(parseFile, from: automaton, includingToken, grammar, visibility)
        
        let data = code.data(using: .ascii)
        let fileManager = FileManager()
        let didCreate = fileManager.createFile(atPath: location + parseFile + ".swift", contents: data)
        
        print("Created file: \(didCreate)")
        
    }
    
    private static func createGrammarFrom(_ productions: [Production]) -> Grammar {
        
        guard (productions.count > 0) else {
            fatalError("No productions.")
        }
        
        let grammar = Grammar(productions[0])
        
        for index in 1 ..< productions.count {
            grammar.addProduction(productions[index])
        }
        
        return grammar
        
    }
    
}
