// ignore: dangling_library_doc_comments
/// マークダウン用の記号・ギリシャ文字・古字などの変換ユーティリティ
/// 追加・保守が容易なようにマップで管理

String convertMarkdownSymbols(String text) {
  // 上付き・下付き数字
  final superscriptMap = {
    '^0': '⁰',
    '^1': '¹',
    '^2': '²',
    '^3': '³',
    '^4': '⁴',
    '^5': '⁵',
    '^6': '⁶',
    '^7': '⁷',
    '^8': '⁸',
    '^9': '⁹',
    '^n': 'ⁿ',
    '^-1': '⁻¹',
  };
  final subscriptMap = {
    '_0': '₀',
    '_1': '₁',
    '_2': '₂',
    '_3': '₃',
    '_4': '₄',
    '_5': '₅',
    '_6': '₆',
    '_7': '₇',
    '_8': '₈',
    '_9': '₉',
    '_n': 'ₙ',
  };
  // ギリシャ文字・記号・古字・その他
  final symbolMap = {
    // 小文字ギリシャ
    'alpha': 'α', 'beta': 'β', 'gamma': 'γ', 'delta': 'δ', 'epsilon': 'ε',
    'zeta': 'ζ', 'eta': 'η', 'theta': 'θ', 'iota': 'ι', 'kappa': 'κ',
    'lambda': 'λ', 'mu': 'μ', 'nu': 'ν', 'xi': 'ξ', 'omicron': 'ο',
    'pi': 'π', 'rho': 'ρ', 'sigma': 'σ', 'tau': 'τ', 'upsilon': 'υ',
    'phi': 'φ', 'chi': 'χ', 'psi': 'ψ', 'omega': 'ω',
    // 大文字ギリシャ
    'Delta': 'Δ', 'Sigma': 'Σ', 'Pi': 'Π', 'Omega': 'Ω', 'Gamma': 'Γ',
    'Theta': 'Θ', 'Lambda': 'Λ', 'Phi': 'Φ', 'Psi': 'Ψ', 'Xi': 'Ξ',
    // 数学記号
    'sqrt': '√', 'infinity': '∞', '<=': '≤', '>=': '≥', '->': '→', '<-': '←',
    '<->': '↔', '+-': '±', 'degree': '°', '≒': '≒', '≠': '≠', '≡': '≡',
    // 古字
    'ゑ': 'ゑ', 'ゐ': 'ゐ', 'ヱ': 'ヱ', 'ヰ': 'ヰ',
    // その他
    'hbar': 'ℏ', 'angstrom': 'Å', 'ohm': 'Ω',
  };

  // 上付き
  superscriptMap.forEach((k, v) {
    text = text.replaceAll(k, v);
  });
  // 下付き
  subscriptMap.forEach((k, v) {
    text = text.replaceAll(k, v);
  });
  // 記号・ギリシャ・古字
  symbolMap.forEach((k, v) {
    text = text.replaceAll(k, v);
  });
  return text;
}
