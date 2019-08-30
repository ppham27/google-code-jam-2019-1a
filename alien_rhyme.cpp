#include <algorithm>
#include <list>
#include <iostream>
#include <string>
#include <vector>

using namespace std;

// Reverses and sorts suffixes to make finding common longest common suffix easier.
vector<string> NormalizeSuffixes(const vector<string>& words) {
  vector<string> suffixes; suffixes.reserve(words.size());
  for (const string& word : words) {
    suffixes.push_back(word);
    reverse(suffixes.back().begin(), suffixes.back().end());
  }
  sort(suffixes.begin(), suffixes.end());
  return suffixes;
}

int CountPrefix(const string &a, const string &b) {
  int size = 0;
  for (int i = 0; i < min(a.length(), b.length()); ++i)
    if (a[i] == b[i]) { ++size; } else { break; }
  return size;
}

int MaximizePairs(const vector<string>& words) {
  const vector<string> suffixes = NormalizeSuffixes(words);
  // Pad with zeros: pretend there are empty strings at the beginning and end.
  list<int> prefix_sizes{0};
  for (int i = 1; i < suffixes.size(); ++i)
    prefix_sizes.push_back(CountPrefix(suffixes[i - 1], suffixes[i]));
  prefix_sizes.push_back(0);
  // Count the pairs by continually finding the longest common prefix.
  list<int>::iterator max_prefix_size;
  while ((max_prefix_size = max_element(prefix_sizes.begin(), prefix_sizes.end())) !=
         prefix_sizes.begin()) {
    // Claim this prefix and shorten the other matches.
    while (*next(max_prefix_size) == *max_prefix_size) {
      --(*max_prefix_size);
      ++max_prefix_size;
    }
    // Use transitivity to update the common prefix size.
    *next(max_prefix_size) = min(*prev(max_prefix_size), *next(max_prefix_size));
    prefix_sizes.erase(prefix_sizes.erase(prev(max_prefix_size)));
  }
  return suffixes.size() - (prefix_sizes.size() - 1);
}

int main(int argc, char* argv[]) {
  ios::sync_with_stdio(false); cin.tie(NULL);
  int T; cin >> T;
  for (int t = 1; t <= T; ++t) {
    int N; cin >> N;
    vector<string> words; words.reserve(N);
    for (int i = 0; i < N; ++i) {
      string word; cin >> word; words.push_back(word);
    }
    cout << "Case #" << t << ": " << MaximizePairs(words) << endl;
  }
  return 0;
}
