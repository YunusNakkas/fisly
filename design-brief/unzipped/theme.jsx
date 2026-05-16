// theme.jsx — Fişly design tokens, theme tweaks, helpers
// Modern Finans (Monzo/Revolut-ish) — light bg, dark hero cards, indigo accent.
// Material 3 tabanlı ama custom tokens ile fark yaratıyor.

const ACCENT_PALETTES = {
  indigo: {
    name: "Indigo",
    primary: "#5B5BD6",
    primaryHover: "#4848C2",
    primaryContainer: "#E8E9FF",
    onPrimaryContainer: "#1B1B6F",
    primaryDim: "#9494E6",
    heroBg: "#16161E",
    heroAccent: "#A3A3F5",
  },
  graphite: {
    name: "Graphite",
    primary: "#0A0A0A",
    primaryHover: "#1A1A1A",
    primaryContainer: "#EFEFEF",
    onPrimaryContainer: "#0A0A0A",
    primaryDim: "#A8A8A8",
    heroBg: "#0A0A0A",
    heroAccent: "#D4D4D4",
  },
  emerald: {
    name: "Emerald",
    primary: "#0E8A5F",
    primaryHover: "#0A6E4B",
    primaryContainer: "#D6F4E5",
    onPrimaryContainer: "#03311F",
    primaryDim: "#6FC9A0",
    heroBg: "#0B1F18",
    heroAccent: "#7BE0B3",
  },
  amber: {
    name: "Amber",
    primary: "#C2410C",
    primaryHover: "#9A3412",
    primaryContainer: "#FFE7D6",
    onPrimaryContainer: "#3D1306",
    primaryDim: "#F4A66B",
    heroBg: "#1E1612",
    heroAccent: "#F4A66B",
  },
};

const TYPE_STACKS = {
  jakarta: {
    name: "Plus Jakarta Sans",
    body: "'Plus Jakarta Sans', system-ui, -apple-system, sans-serif",
    display: "'Plus Jakarta Sans', system-ui, sans-serif",
    mono: "'JetBrains Mono', 'Geist Mono', ui-monospace, monospace",
    displayWeight: 700,
    bodyWeight: 500,
  },
  geist: {
    name: "Geist",
    body: "'Geist', system-ui, sans-serif",
    display: "'Geist', system-ui, sans-serif",
    mono: "'Geist Mono', ui-monospace, monospace",
    displayWeight: 600,
    bodyWeight: 500,
  },
  manrope: {
    name: "Manrope",
    body: "'Manrope', system-ui, sans-serif",
    display: "'Manrope', system-ui, sans-serif",
    mono: "'JetBrains Mono', ui-monospace, monospace",
    displayWeight: 700,
    bodyWeight: 500,
  },
  inst: {
    name: "Mixed (sans + serif numbers)",
    body: "'Plus Jakarta Sans', system-ui, sans-serif",
    display: "'Instrument Serif', 'Plus Jakarta Sans', serif",
    mono: "'Instrument Serif', serif",
    displayWeight: 500,
    bodyWeight: 500,
  },
};

// Neutral palette — bg-on-light Monzo-esque
const NEUTRALS = {
  bg: "#F4F4F7",           // app background (cool warm gray)
  bgAlt: "#EFEFF3",        // hover/subtle
  surface: "#FFFFFF",      // cards
  surfaceContainer: "#F8F8FB",
  outline: "#E8E8EE",      // hairline borders
  outlineSoft: "#F0F0F4",
  textHi: "#0F0F14",       // primary text
  textMid: "#5C5C68",      // secondary
  textLo: "#9090A0",       // tertiary / hint
  textInv: "#FFFFFF",
  danger: "#DC2626",
  warn: "#D97706",
  ok: "#059669",
};

// 12 sabit kategori renk paleti — soft tinted square treatment için
// Her renk: { color (icon), tint (12% bg) }
const CATEGORY_COLORS = {
  market: "#10B981",
  ulasim: "#3B82F6",
  faturalar: "#F59E0B",
  yeme: "#EF4444",
  saglik: "#EC4899",
  eglence: "#8B5CF6",
  diger: "#6B7280",
  teal: "#14B8A6",
  orange: "#F97316",
  sky: "#0EA5E9",
  purple: "#A855F7",
  lime: "#84CC16",
};

const RADIUS = { sm: 8, md: 12, lg: 16, xl: 20, pill: 999 };
const SHADOW = {
  none: "none",
  sm: "0 1px 2px rgba(15,15,20,0.04)",
  card: "0 1px 3px rgba(15,15,20,0.04), 0 0 0 0.5px rgba(15,15,20,0.04)",
  raised: "0 4px 16px rgba(15,15,20,0.08), 0 1px 2px rgba(15,15,20,0.04)",
};

// Default tweak values — must be valid JSON between the markers
const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "accent": "indigo",
  "typo": "jakarta",
  "showDots": true
}/*EDITMODE-END*/;

function buildTheme(tw) {
  const acc = ACCENT_PALETTES[tw.accent] || ACCENT_PALETTES.indigo;
  const typ = TYPE_STACKS[tw.typo] || TYPE_STACKS.jakarta;
  return {
    accent: acc,
    type: typ,
    n: NEUTRALS,
    cat: CATEGORY_COLORS,
    r: RADIUS,
    s: SHADOW,
    tw,
  };
}

// Hex + alpha → rgba string
function tint(hex, a) {
  const h = hex.replace("#", "");
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  return `rgba(${r},${g},${b},${a})`;
}

// Turkish currency format — ₺1.234,56
function fmtTRY(n, opts = {}) {
  const { symbol = "₺", decimals = 2 } = opts;
  const sign = n < 0 ? "-" : "";
  const abs = Math.abs(n);
  const [whole, frac] = abs.toFixed(decimals).split(".");
  const wholeFmt = whole.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
  return `${sign}${symbol}${wholeFmt},${frac}`;
}

Object.assign(window, {
  ACCENT_PALETTES, TYPE_STACKS, NEUTRALS, CATEGORY_COLORS, RADIUS, SHADOW,
  TWEAK_DEFAULTS, buildTheme, tint, fmtTRY,
});
