extension Token: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(content)
    }
    
    public static func == (lhs: Token, rhs: Token) -> Bool {
        return (lhs.type == rhs.type) && (lhs.content == rhs.content)
    }
    
}
