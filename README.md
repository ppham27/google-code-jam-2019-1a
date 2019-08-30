# Google Code Jam 2019 Round 1A

Solutions for Google Code Jam 2019 Round 1A at
https://codingcompetitions.withgoogle.com/codejam/round/0000000000051635.

## Pylons

```
swift run Pylons < data/Pylons.in
```

## Golf Gophers

### Small Test Set

$N = 365$ and $M = 100$ in this test set.

```
python interactive_runner.py python testing_tool.py 0 -- swift run GolfGophers
```

### Hard Test Set

$N = 7$ and $M = 10^6$ in this test set.

```
python interactive_runner.py python testing_tool.py 1 -- swift run GolfGophers
```


## Alien Rhyme

I've created two solutions and wrote additional test cases.

### C++

This solution greedily finds the longest matching suffix and removes pairs from
a linked list.

```
g++ -std=c++14 alien_rhyme.cpp && ./a.out < data/AlienRhyme.in
```

### Swift

This solution uses a prefix tree (also called it a trie) and recursively finds
pairs in different subtrees.

```
swift run AlienRhyme < data/AlienRhyme.in
```
