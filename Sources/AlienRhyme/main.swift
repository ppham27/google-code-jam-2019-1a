/// Counts the size of the least common prefix.
func countPrefix<T: StringProtocol>(_ a: T, _ b: T) -> Int {
    var count = 0
    for (x, y) in zip(a, b) {
        if x == y { count += 1 } else { break }
    }
    return count
}

/// Removes any unnecessary suffix information.
func normalizeSuffixes(_ words: [String]) -> [Substring] {
    let reversedWords = words.map({ String($0.reversed()) }).sorted()
    var suffixes: [Substring] = []
    suffixes.append(
      reversedWords[0].prefix(
        countPrefix(reversedWords[0], reversedWords[1])))
    for i in 1..<(words.count - 1) {
        let prefixCount = max(
          countPrefix(reversedWords[i], reversedWords[i - 1]),
          countPrefix(reversedWords[i], reversedWords[i + 1]))
        suffixes.append(reversedWords[i].prefix(prefixCount))
    }
    suffixes.append(
      reversedWords[words.count - 1].prefix(
        countPrefix(reversedWords[words.count - 1], reversedWords[words.count - 2])))
    suffixes = suffixes.filter({ $0 != "" })
    suffixes.sort()
    return suffixes
}

struct MinimumRange<T: Collection> where T.Element: Comparable {
    private let memo: [[T.Element]]
    private let reduce: (T.Element, T.Element) -> T.Element

    init(_ collection: T,
         reducer reduce: @escaping (T.Element, T.Element) -> T.Element = min) {
        let k = collection.count
        var memo: [[T.Element]] = Array(repeating: [], count: k)
        for (i, element) in collection.enumerated() { memo[i].append(element) }
        for j in 1..<(k.bitWidth - k.leadingZeroBitCount) {
            let offset = 1 << (j - 1)
            for i in 0..<memo.count {
                memo[i].append(
                  i + offset < k ?
                    reduce(memo[i][j - 1], memo[i + offset][j - 1]) : memo[i][j - 1])
            }
        }
        self.memo = memo
        self.reduce = reduce
    }

    func query(from: Int, to: Int) -> T.Element {
        let (from, to) = (max(from, 0), min(to, memo.count))
        let rangeCount = to - from        
        let bitShift = rangeCount.bitWidth - rangeCount.leadingZeroBitCount - 1
        let offset = 1 << bitShift
        return self.reduce(self.memo[from][bitShift], self.memo[to - offset][bitShift])
    }

    func query(from: Int, through: Int) -> T.Element {
        return query(from: from, to: through + 1)
    }
}

struct Node<T: Hashable> {
    var children: [T: Node<T>]
    var count: Int
}

func makePrefixTree<T: StringProtocol>(_ words: [T]) -> Node<T.Element> {
    let prefixCounts = words.reduce(
      into: (counts: [0], word: "" as T),
      {
          $0.counts.append(countPrefix($0.word, $1))
          $0.word = $1
      }).counts
    let minimumPrefixCount = MinimumRange(prefixCounts)
    let words = [""] + words    
    /// Inserts `words[i]` into a rooted tree.
    ///
    /// - Parameters:
    ///  - root: The root node of the tree.
    ///  - state: The index of the word for the current path and depth of `root`.
    ///  - i: The index of the word to be inserted.
    /// - Returns: The index of the next word to be inserted.
    func insert(_ root: inout Node<T.Element>,
                _ state: (node: Int, depth: Int),
                _ i: Int) -> Int {
        // Start inserting only for valid indices and at the right depth.
        if i >= words.count { return i }
        // Max number of nodes that can be reused for `words[i]`.
        let prefixCount = state.node == i ?
          prefixCounts[i] : minimumPrefixCount.query(from: state.node + 1, through: i)
        // Either (a) inserting can be done more efficiently at a deeper node;
        // or (b) we're too deep in the wrong state.
        if prefixCount > state.depth || (prefixCount < state.depth && state.node != i) { return i }
        // Start insertion process! If we're at the right depth, insert and move on.
        if state.depth == words[i].count {
            root.count += 1
            return insert(&root, (i, state.depth), i + 1)
        }
        // Otherwise, possibly create a node and traverse deeper.
        let key = words[i][words[i].index(words[i].startIndex, offsetBy: state.depth)]
        if root.children[key] == nil {
            root.children[key] = Node<T.Element>(children: [:], count: 0)
        }
        // After finishing traversal insert the next word.
        return insert(
          &root, state, insert(&root.children[key]!, (i, state.depth + 1), i))
    }
    var root = Node<T.Element>(children: [:], count: 0)
    let _ = insert(&root, (0, 0), 1)
    return root
}

/// Use path compression. Not necessary, but it's fun!
func compress(_ uncompressedRoot: Node<Character>) -> Node<String> {
    var root = Node<String>(
      children: [:], count: uncompressedRoot.count)
    for (key, node) in uncompressedRoot.children {        
        let newChild = compress(node)
        if newChild.children.count == 1, newChild.count == 0,
           let (childKey, grandChild) = newChild.children.first {
            root.children[String(key) + childKey] = grandChild
        } else {
            root.children[String(key)] = newChild
        }
    }
    return root
}

func maximizeTreePairs<T: Collection>(
  root: Node<T>, depth: Int, minPairWordCount: Int) -> (used: Int, unused: Int)
  where T.Element: Hashable {
    let (used, unused) = root.children.reduce(
      (used: 0, unused: root.count),
      {
          (state: (used: Int, unused: Int), child) -> (used: Int, unused: Int) in
          let childState = maximizeTreePairs(
            root: child.value, depth: child.key.count + depth, minPairWordCount: depth)
          return (state.used + childState.used, state.unused + childState.unused)
      })
    let shortPairUsed = min(2 * (depth - minPairWordCount), (unused / 2) * 2)
    return (used + shortPairUsed, unused - shortPairUsed)    
}

func maximizePairs(_ words: [String]) -> Int {
    let suffixes = normalizeSuffixes(words)
    let prefixTree = compress(makePrefixTree(suffixes))
    return prefixTree.children.reduce(
      0, { $0 + maximizeTreePairs(
             root: $1.value, depth: $1.key.count, minPairWordCount: 0).used })
}

func readLines(_ n: Int) throws -> [String] {
    var lines: [String] = []
    for _ in 0..<n {
        guard let line = readLine() else { fatalError("Missing line!") }
        lines.append(line)
    }
    return lines
}

let T = Int(readLine()!)!
for t in 0..<T {
    let N = Int(readLine()!)!
    let words = try! readLines(N)
    print("Case #\(t + 1): \(maximizePairs(words))")
}
