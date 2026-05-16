// ui.jsx — Shared UI: PhoneFrame, StatusBar, AppBar, BottomNav, CategoryAvatar,
// ProgressBar, Card, Button, ListRow, etc. All theme-aware via useTheme().

const ThemeCtx = React.createContext(null);
function useTheme() { return React.useContext(ThemeCtx); }

function ThemeProvider({ tw, children }) {
  const theme = React.useMemo(() => buildTheme(tw), [tw]);
  // Inject CSS vars on a wrapper so children can use var(--n-bg) etc
  const vars = {
    "--accent": theme.accent.primary,
    "--accent-hover": theme.accent.primaryHover,
    "--accent-c": theme.accent.primaryContainer,
    "--accent-onc": theme.accent.onPrimaryContainer,
    "--accent-dim": theme.accent.primaryDim,
    "--hero-bg": theme.accent.heroBg,
    "--hero-accent": theme.accent.heroAccent,
    "--n-bg": theme.n.bg,
    "--n-surface": theme.n.surface,
    "--n-surface-c": theme.n.surfaceContainer,
    "--n-outline": theme.n.outline,
    "--n-outline-soft": theme.n.outlineSoft,
    "--n-text-hi": theme.n.textHi,
    "--n-text-mid": theme.n.textMid,
    "--n-text-lo": theme.n.textLo,
    "--n-danger": theme.n.danger,
    "--n-warn": theme.n.warn,
    "--n-ok": theme.n.ok,
    "--font-body": theme.type.body,
    "--font-display": theme.type.display,
    "--font-mono": theme.type.mono,
    "--fw-body": theme.type.bodyWeight,
    "--fw-display": theme.type.displayWeight,
  };
  return (
    <ThemeCtx.Provider value={theme}>
      <div style={vars}>{children}</div>
    </ThemeCtx.Provider>
  );
}

// ─── PhoneFrame ───────────────────────────────────────────────────
// 360×760 viewport with iOS-ish bezel + status bar + bottom safe area.
const PHONE_W = 360;
const PHONE_H = 760;

function PhoneFrame({ children, bg, label, time = "22:40", statusbar = true, dark = false }) {
  const t = useTheme();
  const bezel = 10;
  const radiusOuter = 48;
  const radiusInner = 38;
  return (
    <div style={{
      width: PHONE_W + bezel * 2,
      height: PHONE_H + bezel * 2,
      background: "#0A0A0A",
      borderRadius: radiusOuter,
      padding: bezel,
      boxSizing: "border-box",
      boxShadow: "0 0 0 1px rgba(0,0,0,0.6), 0 30px 60px -20px rgba(15,15,25,0.25), 0 8px 24px -10px rgba(15,15,25,0.15)",
      position: "relative",
    }}>
      <div style={{
        width: PHONE_W,
        height: PHONE_H,
        borderRadius: radiusInner,
        background: bg ?? t.n.bg,
        overflow: "hidden",
        position: "relative",
        fontFamily: "var(--font-body)",
        color: "var(--n-text-hi)",
      }}>
        {statusbar && <StatusBar time={time} dark={dark} />}
        {children}
      </div>
    </div>
  );
}

function StatusBar({ time = "22:40", dark = false }) {
  const fg = dark ? "#FFFFFF" : "#0F0F14";
  return (
    <div style={{
      position: "absolute", top: 0, left: 0, right: 0, height: 44,
      display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "0 24px", zIndex: 10, pointerEvents: "none",
      fontFamily: "var(--font-body)", color: fg,
    }}>
      <div style={{ fontWeight: 600, fontSize: 15, fontVariantNumeric: "tabular-nums" }}>{time}</div>
      <div style={{
        position: "absolute", left: "50%", top: 8, transform: "translateX(-50%)",
        width: 110, height: 28, background: "#0A0A0A", borderRadius: 999,
      }} />
      <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
        {/* signal */}
        <svg width="18" height="12" viewBox="0 0 18 12" fill={fg}>
          <rect x="0" y="9" width="3" height="3" rx="0.5" />
          <rect x="5" y="6" width="3" height="6" rx="0.5" />
          <rect x="10" y="3" width="3" height="9" rx="0.5" />
          <rect x="15" y="0" width="3" height="12" rx="0.5" />
        </svg>
        {/* wifi */}
        <svg width="16" height="12" viewBox="0 0 16 12" fill={fg}>
          <path d="M8 11.5a1.2 1.2 0 100-2.4 1.2 1.2 0 000 2.4zM3.5 7a6 6 0 019 0l-1.2 1.2A4 4 0 005 8.2zM0.5 4a10 10 0 0115 0l-1.2 1.2a8 8 0 00-12.6 0z"/>
        </svg>
        {/* battery */}
        <div style={{ width: 26, height: 12, border: `1px solid ${fg}`, borderRadius: 3, padding: 1, opacity: 0.9 }}>
          <div style={{ width: "85%", height: "100%", background: fg, borderRadius: 1 }} />
        </div>
      </div>
    </div>
  );
}

// ─── AppBar ───────────────────────────────────────────────────────
function AppBar({ title, leading, trailing, center = true, large = false, sticky = false }) {
  return (
    <div style={{
      paddingTop: 52, paddingBottom: 12,
      paddingLeft: 16, paddingRight: 16,
      display: "flex", alignItems: "center", justifyContent: "space-between",
      gap: 12,
      position: sticky ? "sticky" : "relative", top: 0, zIndex: 5,
      background: "transparent",
    }}>
      <div style={{ width: 40, display: "flex", alignItems: "center" }}>{leading}</div>
      <div style={{
        flex: 1, textAlign: center ? "center" : "left",
        fontSize: large ? 22 : 16, fontWeight: 600, color: "var(--n-text-hi)",
        fontFamily: "var(--font-display)",
        display: "flex", alignItems: "center", justifyContent: center ? "center" : "flex-start", gap: 6,
      }}>{title}</div>
      <div style={{ width: 40, display: "flex", alignItems: "center", justifyContent: "flex-end" }}>{trailing}</div>
    </div>
  );
}

function MonthPicker({ value = "Mayıs 2026" }) {
  return (
    <div style={{
      display: "inline-flex", alignItems: "center", gap: 6,
      padding: "6px 12px",
      borderRadius: 999,
      background: "var(--n-surface-c)",
      border: "1px solid var(--n-outline)",
      fontSize: 14, fontWeight: 600,
    }}>
      {value} <Icon name="chevron_down" size={14} weight={2.4} />
    </div>
  );
}

// ─── Category visuals — soft tinted square ─────────────────────────
function CategoryAvatar({ cat = "diger", size = 44, radius = 14 }) {
  const c = CATEGORIES[cat] || CATEGORIES.diger;
  return (
    <div style={{
      width: size, height: size, borderRadius: radius,
      background: tint(c.color, 0.14),
      display: "flex", alignItems: "center", justifyContent: "center",
      flexShrink: 0,
    }}>
      <Icon name={c.icon} size={Math.round(size * 0.5)} color={c.color} weight={2} />
    </div>
  );
}

function CategoryDot({ cat = "diger", size = 8 }) {
  const c = CATEGORIES[cat] || CATEGORIES.diger;
  return <div style={{ width: size, height: size, borderRadius: 999, background: c.color, flexShrink: 0 }} />;
}

// ─── Progress bar ─────────────────────────────────────────────────
function ProgressBar({ value = 0.5, color, trackColor, height = 6, radius = 999 }) {
  const t = useTheme();
  const c = color || t.accent.primary;
  const trk = trackColor || tint(c, 0.14);
  return (
    <div style={{ width: "100%", height, background: trk, borderRadius: radius, overflow: "hidden" }}>
      <div style={{ width: `${Math.min(100, value * 100)}%`, height: "100%", background: c, borderRadius: radius }} />
    </div>
  );
}

// ─── Card ──────────────────────────────────────────────────────────
function Card({ children, dark = false, style, padding = 16, radius = 20, hairline = true }) {
  return (
    <div style={{
      background: dark ? "var(--hero-bg)" : "var(--n-surface)",
      color: dark ? "#FFFFFF" : "var(--n-text-hi)",
      borderRadius: radius,
      padding,
      border: hairline && !dark ? "1px solid var(--n-outline)" : "none",
      boxShadow: dark ? "0 8px 24px -8px rgba(15,15,30,0.25)" : "0 1px 2px rgba(15,15,20,0.03)",
      ...style,
    }}>
      {children}
    </div>
  );
}

// ─── Buttons ──────────────────────────────────────────────────────
function Button({ children, variant = "filled", size = "md", icon, iconRight, full = false, onClick, style, disabled = false }) {
  const t = useTheme();
  const sizes = {
    sm: { pad: "8px 14px", font: 13, h: 36, gap: 6, iconSize: 16 },
    md: { pad: "12px 18px", font: 15, h: 48, gap: 8, iconSize: 18 },
    lg: { pad: "16px 22px", font: 16, h: 56, gap: 10, iconSize: 20 },
  };
  const sz = sizes[size];
  const variants = {
    filled: { bg: t.accent.primary, fg: "#FFFFFF", border: "transparent" },
    tonal:  { bg: t.accent.primaryContainer, fg: t.accent.onPrimaryContainer, border: "transparent" },
    outlined: { bg: "transparent", fg: t.accent.primary, border: t.accent.primary },
    ghost:  { bg: "transparent", fg: t.accent.primary, border: "transparent" },
    danger: { bg: "#FEE2E2", fg: "#B91C1C", border: "transparent" },
    dark:   { bg: t.accent.heroBg, fg: "#FFFFFF", border: "transparent" },
  };
  const v = variants[variant];
  return (
    <button onClick={onClick} disabled={disabled} style={{
      display: "inline-flex", alignItems: "center", justifyContent: "center",
      gap: sz.gap, padding: sz.pad, height: sz.h,
      width: full ? "100%" : "auto",
      background: v.bg, color: v.fg,
      border: variant === "outlined" ? `1.5px solid ${v.border}` : "none",
      borderRadius: 999,
      fontFamily: "var(--font-body)", fontWeight: 600, fontSize: sz.font,
      cursor: disabled ? "not-allowed" : "pointer",
      opacity: disabled ? 0.5 : 1,
      transition: "background .15s, transform .1s",
      ...style,
    }}>
      {icon && <Icon name={icon} size={sz.iconSize} color={v.fg} />}
      {children}
      {iconRight && <Icon name={iconRight} size={sz.iconSize} color={v.fg} />}
    </button>
  );
}

// ─── Bottom navigation (4 tabs + center FAB) ──────────────────────
function BottomNav({ active = "expenses", onTab }) {
  const tabs = [
    { id: "expenses",      label: "Harcamalar", icon: "receipt_long" },
    { id: "reports",       label: "Özet",       icon: "bar_chart" },
    { id: "subscriptions", label: "Abonelikler", icon: "repeat" },
    { id: "settings",      label: "Ayarlar",    icon: "settings" },
  ];
  return (
    <>
      {/* Tab bar */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 0,
        background: "var(--n-surface)",
        borderTop: "1px solid var(--n-outline)",
        paddingTop: 10, paddingBottom: 22,
        display: "grid", gridTemplateColumns: "1fr 1fr 1fr 1fr",
        zIndex: 10,
      }}>
        {tabs.map((t, i) => {
          const isActive = t.id === active;
          // leave middle gap for FAB — column gap between tabs 1-2 and 2-3
          const isMidLeft = i === 1;
          const isMidRight = i === 2;
          return (
            <div key={t.id}
              onClick={() => onTab && onTab(t.id)}
              style={{
                display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
                paddingLeft: isMidRight ? 14 : 0, paddingRight: isMidLeft ? 14 : 0,
                cursor: "pointer",
              }}
            >
              <div style={{
                padding: "4px 14px", borderRadius: 999,
                background: isActive ? "var(--accent-c)" : "transparent",
                color: isActive ? "var(--accent-onc)" : "var(--n-text-mid)",
              }}>
                <Icon name={t.icon} size={20} color={isActive ? "var(--accent-onc)" : "var(--n-text-mid)"} weight={2} />
              </div>
              <div style={{
                fontSize: 11, fontWeight: 600,
                color: isActive ? "var(--n-text-hi)" : "var(--n-text-mid)",
              }}>{t.label}</div>
            </div>
          );
        })}
      </div>
      {/* Floating scan FAB — center docked */}
      <div style={{
        position: "absolute", bottom: 56, left: "50%", transform: "translateX(-50%)",
        zIndex: 11,
      }}>
        <div style={{
          width: 56, height: 56, borderRadius: 18,
          background: "var(--accent)",
          display: "flex", alignItems: "center", justifyContent: "center",
          boxShadow: "0 8px 20px -4px rgba(91,91,214,0.45), 0 2px 6px rgba(15,15,20,0.12)",
          border: "3px solid var(--n-bg)",
        }}>
          <Icon name="document_scanner" size={24} color="#FFFFFF" weight={2.2} />
        </div>
      </div>
    </>
  );
}

// ─── Common section helpers ──────────────────────────────────────
function SectionLabel({ children, action }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "8px 4px 12px",
    }}>
      <div style={{
        fontSize: 11, fontWeight: 700, letterSpacing: "0.12em", textTransform: "uppercase",
        color: "var(--n-text-lo)",
      }}>{children}</div>
      {action}
    </div>
  );
}

function ListRow({ leading, title, subtitle, trailing, onClick, divider = true, dense = false }) {
  return (
    <div onClick={onClick} style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: dense ? "10px 16px" : "14px 16px",
      cursor: onClick ? "pointer" : "default",
      borderBottom: divider ? "1px solid var(--n-outline-soft)" : "none",
    }}>
      {leading}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: "var(--n-text-hi)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{title}</div>
        {subtitle && <div style={{ fontSize: 13, color: "var(--n-text-mid)", marginTop: 2 }}>{subtitle}</div>}
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>{trailing}</div>
    </div>
  );
}

// Days-until pill (Abonelikler)
function DaysPill({ days }) {
  let bg, fg, label;
  if (days < 0) { bg = "#FEE2E2"; fg = "#B91C1C"; label = "Gecikti"; }
  else if (days === 0) { bg = "#FEE2E2"; fg = "#B91C1C"; label = "Bugün"; }
  else if (days === 1) { bg = "#FFEDD5"; fg = "#C2410C"; label = "Yarın"; }
  else if (days <= 3) { bg = "#FFEDD5"; fg = "#C2410C"; label = `${days} gün`; }
  else if (days <= 7) { bg = "#DBEAFE"; fg = "#1D4ED8"; label = `${days} gün`; }
  else return null;
  return (
    <span style={{
      display: "inline-block",
      padding: "2px 8px", borderRadius: 10,
      background: bg, color: fg,
      fontSize: 11, fontWeight: 700,
    }}>{label}</span>
  );
}

// Floating + button (above bottom nav, right side)
function FAB({ icon = "plus", onClick }) {
  return (
    <div onClick={onClick} style={{
      position: "absolute", bottom: 110, right: 20,
      width: 56, height: 56, borderRadius: 18,
      background: "var(--accent-c)",
      display: "flex", alignItems: "center", justifyContent: "center",
      boxShadow: "0 6px 16px -4px rgba(91,91,214,0.25)",
      cursor: "pointer", zIndex: 8,
    }}>
      <Icon name={icon} size={26} color="var(--accent)" weight={2.4} />
    </div>
  );
}

Object.assign(window, {
  ThemeProvider, useTheme, ThemeCtx,
  PhoneFrame, StatusBar, AppBar, MonthPicker,
  CategoryAvatar, CategoryDot,
  ProgressBar, Card, Button, BottomNav,
  SectionLabel, ListRow, DaysPill, FAB,
  PHONE_W, PHONE_H,
});
