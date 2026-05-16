// icons.jsx — Material-style SVG icons used in Fişly.
// Outlined / round style to match Material 3.

function Icon({ name, size = 24, color = "currentColor", weight = 2, style }) {
  const sw = weight;
  const common = {
    width: size, height: size, viewBox: "0 0 24 24",
    fill: "none", stroke: color, strokeWidth: sw,
    strokeLinecap: "round", strokeLinejoin: "round",
    style,
  };
  const paths = {
    // Bottom nav
    receipt_long: (
      <>
        <path d="M5 3v18l2-1.5L9 21l2-1.5L13 21l2-1.5L15 21l2-1.5L19 21V7l-2-2H7" />
        <path d="M5 3l2 2" />
        <path d="M9 9h6M9 13h6M9 17h4" />
      </>
    ),
    bar_chart: (
      <>
        <line x1="6" y1="20" x2="6" y2="11" />
        <line x1="12" y1="20" x2="12" y2="5" />
        <line x1="18" y1="20" x2="18" y2="14" />
      </>
    ),
    repeat: (
      <>
        <path d="M17 1l4 4-4 4" />
        <path d="M3 11V9a4 4 0 014-4h14" />
        <path d="M7 23l-4-4 4-4" />
        <path d="M21 13v2a4 4 0 01-4 4H3" />
      </>
    ),
    settings: (
      <>
        <circle cx="12" cy="12" r="3" />
        <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 11-4 0v-.09a1.65 1.65 0 00-1-1.51 1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 110-4h.09a1.65 1.65 0 001.51-1 1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 110 4h-.09a1.65 1.65 0 00-1.51 1z" />
      </>
    ),
    document_scanner: (
      <>
        <path d="M4 7V5a2 2 0 012-2h2" />
        <path d="M20 7V5a2 2 0 00-2-2h-2" />
        <path d="M4 17v2a2 2 0 002 2h2" />
        <path d="M20 17v2a2 2 0 01-2 2h-2" />
        <line x1="2" y1="12" x2="22" y2="12" />
      </>
    ),
    // Common
    chevron_down: <polyline points="6 9 12 15 18 9" />,
    chevron_right: <polyline points="9 18 15 12 9 6" />,
    chevron_left: <polyline points="15 18 9 12 15 6" />,
    plus: <><line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" /></>,
    close: <><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></>,
    check: <polyline points="20 6 9 17 4 12" />,
    search: <><circle cx="11" cy="11" r="8" /><line x1="21" y1="21" x2="16.65" y2="16.65" /></>,
    more_h: <><circle cx="5" cy="12" r="1.2" fill={color} /><circle cx="12" cy="12" r="1.2" fill={color} /><circle cx="19" cy="12" r="1.2" fill={color} /></>,
    more_v: <><circle cx="12" cy="5" r="1.2" fill={color} /><circle cx="12" cy="12" r="1.2" fill={color} /><circle cx="12" cy="19" r="1.2" fill={color} /></>,
    filter: <><line x1="4" y1="6" x2="20" y2="6" /><line x1="7" y1="12" x2="17" y2="12" /><line x1="10" y1="18" x2="14" y2="18" /></>,
    edit: <><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" /><path d="M18.5 2.5a2.121 2.121 0 113 3L12 15l-4 1 1-4 9.5-9.5z" /></>,
    trash: <><polyline points="3 6 5 6 21 6" /><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6" /><path d="M10 11v6M14 11v6" /></>,
    camera: <><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" /><circle cx="12" cy="13" r="4" /></>,
    image: <><rect x="3" y="3" width="18" height="18" rx="2" /><circle cx="8.5" cy="8.5" r="1.5" /><polyline points="21 15 16 10 5 21" /></>,
    bell: <><path d="M18 8a6 6 0 00-12 0c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.73 21a2 2 0 01-3.46 0" /></>,
    // Category icons (Material parity)
    shopping_cart: <><circle cx="9" cy="21" r="1" /><circle cx="20" cy="21" r="1" /><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6" /></>,
    directions_car: <><path d="M5 17h14v-5l-2-5H7l-2 5z" /><circle cx="7.5" cy="17.5" r="1.5" /><circle cx="16.5" cy="17.5" r="1.5" /></>,
    restaurant: <><path d="M3 2v8a2 2 0 002 2h0v10" /><path d="M7 2v8M5 2v8M19 15V2a4 4 0 00-4 4v6h4v10" /></>,
    local_hospital: <><rect x="3" y="3" width="18" height="18" rx="2" /><line x1="12" y1="8" x2="12" y2="16" /><line x1="8" y1="12" x2="16" y2="12" /></>,
    movie: <><rect x="2" y="4" width="20" height="16" rx="2" /><line x1="6" y1="4" x2="7" y2="20" /><line x1="11" y1="4" x2="12" y2="20" /><line x1="16" y1="4" x2="17" y2="20" /></>,
    home: <><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2h-4v-7h-6v7H5a2 2 0 01-2-2z" /></>,
    flash: <><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" /></>,
    wallet: <><path d="M21 12V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2h14a2 2 0 002-2v-2" /><path d="M16 12h6v4h-6a2 2 0 010-4z" /></>,
    shapes: <><polygon points="12 2 19 21 5 21 12 2" opacity="0.0" /><circle cx="7" cy="17" r="3.5" /><path d="M14 14h6v6h-6z" /><path d="M14 3l3 6h-6z" /></>,
    chat: <><path d="M21 11.5a8.38 8.38 0 01-.9 3.8 8.5 8.5 0 01-7.6 4.7 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8 8.5 8.5 0 014.7-7.6 8.38 8.38 0 013.8-.9h.5a8.48 8.48 0 018 8z" /></>,
    user: <><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" /><circle cx="12" cy="7" r="4" /></>,
    lock: <><rect x="3" y="11" width="18" height="11" rx="2" /><path d="M7 11V7a5 5 0 0110 0v4" /></>,
    logout: <><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4" /><polyline points="16 17 21 12 16 7" /><line x1="21" y1="12" x2="9" y2="12" /></>,
    feedback: <><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z" /></>,
    arrow_up: <><line x1="12" y1="19" x2="12" y2="5" /><polyline points="5 12 12 5 19 12" /></>,
    arrow_down: <><line x1="12" y1="5" x2="12" y2="19" /><polyline points="19 12 12 19 5 12" /></>,
    arrow_right: <><line x1="5" y1="12" x2="19" y2="12" /><polyline points="12 5 19 12 12 19" /></>,
    sparkle: <><path d="M12 3l1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5L12 3z" /><path d="M19 14l.7 2.3L22 17l-2.3.7L19 20l-.7-2.3L16 17l2.3-.7z" /></>,
    eye: <><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8S1 12 1 12z" /><circle cx="12" cy="12" r="3" /></>,
    eye_off: <><path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19m-6.72-1.07a3 3 0 11-4.24-4.24" /><line x1="1" y1="1" x2="23" y2="23" /></>,
    calendar: <><rect x="3" y="4" width="18" height="18" rx="2" /><line x1="16" y1="2" x2="16" y2="6" /><line x1="8" y1="2" x2="8" y2="6" /><line x1="3" y1="10" x2="21" y2="10" /></>,
    bolt: <><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" /></>,
    pie: <><path d="M21.21 15.89A10 10 0 118 2.83" /><path d="M22 12A10 10 0 0012 2v10z" /></>,
    google: <>
      <path d="M21.35 11.1H12v3.8h5.35c-.23 1.45-1.66 4.25-5.35 4.25-3.22 0-5.85-2.66-5.85-5.95s2.63-5.95 5.85-5.95c1.83 0 3.06.78 3.76 1.45l2.56-2.47C16.7 4.7 14.55 3.7 12 3.7c-4.6 0-8.35 3.75-8.35 8.5s3.75 8.5 8.35 8.5c4.82 0 8.02-3.4 8.02-8.18 0-.55-.06-.97-.13-1.42z" fill={color} stroke="none" />
    </>,
    apple: <>
      <path d="M17.05 12.04c-.03-3.16 2.58-4.67 2.7-4.75-1.47-2.15-3.76-2.44-4.57-2.48-1.94-.2-3.79 1.14-4.78 1.14-.99 0-2.52-1.11-4.14-1.08-2.13.03-4.1 1.24-5.2 3.15-2.22 3.85-.57 9.54 1.59 12.67 1.06 1.53 2.32 3.25 3.97 3.19 1.6-.06 2.2-1.03 4.13-1.03 1.93 0 2.48 1.03 4.17 1 1.72-.03 2.81-1.56 3.86-3.1 1.22-1.78 1.72-3.51 1.75-3.6-.04-.02-3.35-1.29-3.39-5.11zM14.04 3.65c.88-1.07 1.47-2.56 1.31-4.04-1.27.05-2.81.85-3.71 1.92-.81.95-1.52 2.46-1.33 3.91 1.42.11 2.85-.72 3.73-1.79z" fill={color} stroke="none" />
    </>,
    fingerprint: <><path d="M12 1a11 11 0 00-11 11" /><path d="M7 12a5 5 0 0110 0v3a3 3 0 01-3 3" /><path d="M12 12v3" /><path d="M17 12a5 5 0 00-10 0v3" /></>,
  };
  return (
    <svg {...common}>
      {paths[name] || paths["more_h"]}
    </svg>
  );
}

// Category catalog — name → {icon, color, label}
const CATEGORIES = {
  market:    { label: "Market",     icon: "shopping_cart",  color: "#10B981" },
  ulasim:    { label: "Ulaşım",     icon: "directions_car", color: "#3B82F6" },
  faturalar: { label: "Faturalar",  icon: "receipt_long",   color: "#F59E0B" },
  yeme:      { label: "Yeme-İçme",  icon: "restaurant",     color: "#EF4444" },
  saglik:    { label: "Sağlık",     icon: "local_hospital", color: "#EC4899" },
  eglence:   { label: "Eğlence",    icon: "movie",          color: "#8B5CF6" },
  diger:     { label: "Diğer",      icon: "shapes",         color: "#6B7280" },
};

Object.assign(window, { Icon, CATEGORIES });
