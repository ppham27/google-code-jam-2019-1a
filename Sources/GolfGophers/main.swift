import Foundation

func query(_ q: [Int]) -> Int {
    print(q.map({String($0)}).joined(separator: " ")); fflush(stdout)
    return readLine()!.split(separator: " ").compactMap({ Int($0) }).reduce(0, +)
}

func invert(_ a: Int, mod b: Int) -> Int {
    /// Extended euclidean algorithm.
    /// [i j : m]
    /// [k l : n]
    /// Assume m < n.
    func reduce(_ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int, _ n: Int) -> Int {
        if m == 0 {
            let inverse = k % b            
            return inverse < 0 ? inverse + b : inverse
        }
        let q = n / m
        return reduce(k - i * q, l - j * q, i, j, n - m * q, m)
    }
    return reduce(1, 0, 0, 1, a % b, b)
}

let queryCount = 18
let queries = [3, 4, 5, 7, 11, 13, 17]
let queryProduct = queries.reduce(1, *)

func count() -> Int {
    // Apply Chinese remainder theorem.
    func update(state: Int, _ q: Int) -> Int {
        let response = query(Array(repeating: q, count: queryCount))
        let n = queryProduct / q
        let nextTerm = n * invert(n, mod: q) * response
        return (state + nextTerm) % queryProduct
    }
    let answer = queries.reduce(0, { update(state: $0, $1) })
    return query([answer])
}

func readArgs() -> (T: Int, N: Int, M: Int) {
    let args = readLine()!.split(separator: " ").compactMap { Int($0) }    
    return (args[0], args[1], args[2])
}

let (T, N, M) = readArgs()
for _ in 0..<T { assert(count() == 1, "Answer should be correct!") }
