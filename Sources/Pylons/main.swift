func findSequence(N: Int, M: Int) -> [(row: Int, column: Int)]? {
    // Other cells to which we are not allowed to jump.
    var badNeighbors: [Set<Int>] = Array(repeating: Set(), count: N * M)
    for i in 0..<(N * M) {
        let (ri, ci) = (i / M, i % M)
        for j in 0..<(N * M) {
            let (rj, cj) = (j / M, j % M)
            if ri == rj || ci == cj || ri - ci == rj - cj || ri + ci == rj + cj {
                badNeighbors[i].insert(j)
                badNeighbors[j].insert(i)
            }
        }
    }
    // Greedily select the cell which has the most unallowable cells.
    var sequence: [(row: Int, column: Int)] = []
    var visited: Set<Int> = Set()
    while sequence.count < N * M {
        guard let i = (badNeighbors.enumerated().filter {
            if visited.contains($0.offset) { return false }
            guard let (rj, cj) = sequence.last else { return true }
            let (ri, ci) = ($0.offset / M, $0.offset % M)
            return rj != ri && cj != ci && rj + cj != ri + ci && rj - cj != ri - ci
        }.reduce(nil) {
            (state: (i: Int, count: Int)?, value) -> (i: Int, count: Int)? in
            if let count = state?.count, count > value.element.count { return state }
            return (i: value.offset, count: value.element.count)
        }?.i) else { return nil }
        sequence.append((row: i / M, column: i % M))
        visited.insert(i)
        for j in badNeighbors[i] { badNeighbors[j].remove(i) }
    }
    return sequence
}

let T = Int(readLine() ?? "") ?? 0
for t in 0..<T {
    guard let line = readLine() else { fatalError("Line \(t) should exist!") }
    let args = line.split(separator: " ").compactMap { Int($0) }
    let (N, M) = (args[0], args[1])
    if let sequence = findSequence(N: N, M: M) {
        print("Case #\(t + 1): POSSIBLE")
        for coordinates in sequence {
            print("\(coordinates.row + 1) \(coordinates.column + 1)")
        }
    } else {
        print("Case #\(t + 1): IMPOSSIBLE")
    }    
}
