/**
 * A simple fuzzy matching utility for Ether.
 * Returns a score (higher is better) and the matched indices (for highlighting).
 */
export function fuzzyMatch(pattern, text) {
  if (!pattern) return { score: 1, indices: [] };
  
  const p = pattern.toLowerCase();
  const t = text.toLowerCase();
  let score = 0;
  let pIdx = 0;
  const indices = [];

  for (let i = 0; i < t.length && pIdx < p.length; i++) {
    if (t[i] === p[pIdx]) {
      // Bonus for consecutive matches
      if (indices.length > 0 && indices[indices.length - 1] === i - 1) {
        score += 2;
      } else {
        score += 1;
      }
      
      // Bonus for matches at the start of words
      if (i === 0 || t[i-1] === ' ' || t[i-1] === '-' || t[i-1] === '_') {
        score += 3;
      }

      indices.push(i);
      pIdx++;
    }
  }

  if (pIdx !== p.length) return null;

  // Penalize for extra length
  score -= (text.length - pattern.length) * 0.1;

  return { score, indices };
}

/**
 * Filters and sorts items based on fuzzy matching.
 */
export function fuzzyFilter(pattern, items, key = 'name') {
  if (!pattern) return items.map(item => ({ ...item, score: 0 }));

  return items
    .map(item => {
      const match = fuzzyMatch(pattern, item[key]);
      return match ? { ...item, score: match.score, indices: match.indices } : null;
    })
    .filter(item => item !== null)
    .sort((a, b) => b.score - a.score);
}
