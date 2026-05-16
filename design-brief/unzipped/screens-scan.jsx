// screens-scan.jsx — Fiş Tara modal (3 states) + settings sub-screens

// ─── Scan Modal: Picker view ───────────────────────────────────────
function ScrScanPicker() {
  const quota = { used: 12, total: 30 };
  const pct = quota.used / quota.total;
  const quotaColor = pct >= 1 ? "var(--n-danger)" : pct >= 0.8 ? "var(--n-warn)" : "var(--n-ok)";

  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<IconButton icon="close" />}
        title="Fiş Tara"
      />

      <div style={{ padding: "0 24px" }}>
        {/* Quota banner */}
        <Card padding={14} radius={16} style={{ marginBottom: 24 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
            <div style={{ fontSize: 12, fontWeight: 600, color: "var(--n-text-mid)" }}>Bu ay tarama kotan</div>
            <div style={{ fontSize: 13, fontWeight: 700, color: quotaColor, fontVariantNumeric: "tabular-nums" }}>{quota.used}/{quota.total}</div>
          </div>
          <ProgressBar value={pct} color={quotaColor} height={6} />
        </Card>
      </div>

      {/* Big illustrative receipt card */}
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 32px" }}>
        <BigReceiptIcon />
        <div style={{
          marginTop: 22,
          fontFamily: "var(--font-display)", fontWeight: "var(--fw-display)",
          fontSize: 24, letterSpacing: "-0.02em", textAlign: "center", lineHeight: 1.15,
        }}>
          Fişini tara veya<br/>galeriden seç
        </div>
        <div style={{
          marginTop: 10, fontSize: 14, color: "var(--n-text-mid)",
          textAlign: "center", lineHeight: 1.45, textWrap: "balance",
        }}>
          Gemini yapay zekâ fişini saniyeler içinde okuyup ürünleri kategorilere ayıracak.
        </div>

        {/* Trust strip */}
        <div style={{
          marginTop: 22, padding: "10px 14px",
          background: "var(--n-surface-c)", borderRadius: 14,
          display: "flex", alignItems: "center", gap: 10,
          fontSize: 12, color: "var(--n-text-mid)",
        }}>
          <Icon name="lock" size={14} color="var(--n-text-mid)" />
          Fotoğrafların sadece okuma için kullanılır, sunucuda saklanmaz.
        </div>
      </div>

      <div style={{ padding: "0 24px 36px", display: "flex", flexDirection: "column", gap: 10 }}>
        <Button variant="filled" full size="lg" icon="camera">Kameradan Çek</Button>
        <Button variant="outlined" full size="lg" icon="image">Galeriden Seç</Button>
      </div>
    </div>
  );
}

function BigReceiptIcon() {
  return (
    <div style={{ position: "relative", width: 160, height: 160 }}>
      {/* Decorative dotted ring */}
      <svg width="160" height="160" style={{ position: "absolute", inset: 0 }}>
        <circle cx="80" cy="80" r="76" fill="none" stroke="var(--accent-c)" strokeWidth="1.5" strokeDasharray="2 6" />
      </svg>
      <div style={{
        position: "absolute", left: 40, top: 24, width: 80, height: 110,
        background: "var(--n-surface)", borderRadius: 12,
        border: "1.5px solid var(--n-outline)",
        padding: 10,
        display: "flex", flexDirection: "column", gap: 4,
      }}>
        <div style={{ height: 4, background: "var(--n-outline)", borderRadius: 2, width: "60%" }} />
        <div style={{ height: 3, background: "var(--n-outline-soft)", borderRadius: 2, width: "80%" }} />
        <div style={{ height: 3, background: "var(--n-outline-soft)", borderRadius: 2, width: "70%" }} />
        <div style={{ height: 1, background: "var(--n-outline)", margin: "3px 0" }} />
        <div style={{ height: 3, background: "var(--n-outline-soft)", borderRadius: 2, width: "85%" }} />
        <div style={{ height: 3, background: "var(--n-outline-soft)", borderRadius: 2, width: "60%" }} />
        <div style={{ height: 3, background: "var(--n-outline-soft)", borderRadius: 2, width: "75%" }} />
        <div style={{ height: 1, background: "var(--n-outline)", margin: "3px 0" }} />
        <div style={{ height: 5, background: "var(--accent)", borderRadius: 2, width: "55%", marginLeft: "auto" }} />
      </div>
      {/* Sparkle accent */}
      <div style={{
        position: "absolute", top: 18, right: 18,
        width: 36, height: 36, borderRadius: 12,
        background: "var(--accent)", color: "#FFF",
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: "0 6px 14px -3px rgba(91,91,214,0.45)",
      }}>
        <Icon name="sparkle" size={18} color="#FFF" weight={2.2} />
      </div>
    </div>
  );
}

// ─── Scan Modal: Scanning state ───────────────────────────────────
function ScrScanProcessing() {
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<IconButton icon="close" />}
        title="Fiş okunuyor…"
      />
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 24px" }}>
        {/* Mock receipt photo with scanning overlay */}
        <div style={{ position: "relative", width: 220, height: 280, marginBottom: 28 }}>
          <div style={{
            position: "absolute", inset: 0,
            background: "#FFFCF7", border: "1px solid var(--n-outline)",
            borderRadius: 18, padding: 18,
            boxShadow: "0 16px 38px -12px rgba(15,15,30,0.2)",
          }}>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.12em", color: "var(--n-text-mid)" }}>BİM A.Ş.</div>
            <div style={{ fontSize: 9, color: "var(--n-text-lo)", marginBottom: 8 }}>15.05.2026 18:32</div>
            {[0.9, 0.7, 0.85, 0.6, 0.75, 0.55, 0.8].map((w, i) => (
              <div key={i} style={{ height: 5, background: "var(--n-outline)", borderRadius: 2, marginBottom: 6, width: `${w * 100}%` }} />
            ))}
          </div>
          {/* Scanning beam */}
          <div style={{
            position: "absolute", left: 8, right: 8, top: "50%",
            height: 4, background: "linear-gradient(90deg, transparent, var(--accent), transparent)",
            boxShadow: "0 0 20px var(--accent)",
            borderRadius: 999,
          }} />
          {/* Corners */}
          {[[0,0],[1,0],[0,1],[1,1]].map(([x, y], i) => (
            <div key={i} style={{
              position: "absolute",
              left: x ? "auto" : -4, right: x ? -4 : "auto",
              top: y ? "auto" : -4, bottom: y ? -4 : "auto",
              width: 20, height: 20,
              borderTop: !y ? "3px solid var(--accent)" : "none",
              borderBottom: y ? "3px solid var(--accent)" : "none",
              borderLeft: !x ? "3px solid var(--accent)" : "none",
              borderRight: x ? "3px solid var(--accent)" : "none",
              borderTopLeftRadius: !x && !y ? 8 : 0,
              borderTopRightRadius: x && !y ? 8 : 0,
              borderBottomLeftRadius: !x && y ? 8 : 0,
              borderBottomRightRadius: x && y ? 8 : 0,
            }} />
          ))}
        </div>

        {/* Progress steps */}
        <div style={{ width: "100%", maxWidth: 280, display: "flex", flexDirection: "column", gap: 12 }}>
          <ProgressStep label="Görüntü yükleniyor" status="done" />
          <ProgressStep label="Metin çıkarılıyor" status="done" />
          <ProgressStep label="Ürünler ayrıştırılıyor" status="active" />
          <ProgressStep label="Kategoriler atanıyor" status="pending" />
        </div>

        <div style={{ marginTop: 24, fontSize: 12, color: "var(--n-text-lo)", display: "inline-flex", alignItems: "center", gap: 6 }}>
          <Icon name="sparkle" size={12} color="var(--accent)" />
          Gemini Vision · ~3 sn
        </div>
      </div>
    </div>
  );
}

function ProgressStep({ label, status }) {
  const color = status === "done" ? "var(--n-ok)" : status === "active" ? "var(--accent)" : "var(--n-text-lo)";
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
      <div style={{
        width: 18, height: 18, borderRadius: 999,
        background: status === "pending" ? "var(--n-surface-c)" : color,
        display: "flex", alignItems: "center", justifyContent: "center",
        flexShrink: 0,
        border: status === "pending" ? "1.5px solid var(--n-outline)" : "none",
      }}>
        {status === "done" && <Icon name="check" size={11} color="#FFF" weight={3} />}
        {status === "active" && <div style={{ width: 8, height: 8, borderRadius: 999, background: "#FFF" }} />}
      </div>
      <div style={{
        fontSize: 13, fontWeight: 500,
        color: status === "pending" ? "var(--n-text-lo)" : "var(--n-text-hi)",
      }}>{label}</div>
    </div>
  );
}

// ─── Scan Modal: Result state ─────────────────────────────────────
const SCAN_ITEMS = [
  { id: 1, name: "Süt 1L", amount: 28.50, cat: "market" },
  { id: 2, name: "Tam Buğday Ekmek", amount: 12.00, cat: "market" },
  { id: 3, name: "Çikolata 80gr", amount: 45.00, cat: "market" },
  { id: 4, name: "Domates 500gr", amount: 18.75, cat: "market" },
  { id: 5, name: "Coca-Cola 2L", amount: 32.00, cat: "yeme" },
];

function ScrScanResult() {
  const total = SCAN_ITEMS.reduce((a, i) => a + i.amount, 0);
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<IconButton icon="close" />}
        title="Tarama Sonucu"
        trailing={<IconButton icon="edit" />}
      />

      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px" }}>
        {/* Merchant header */}
        <Card padding={16} radius={18} style={{ marginBottom: 16 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <CategoryAvatar cat="market" size={44} radius={14} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 17, fontWeight: 700, color: "var(--n-text-hi)", letterSpacing: "-0.01em" }}>BİM A.Ş.</div>
              <div style={{ fontSize: 12, color: "var(--n-text-mid)", marginTop: 2 }}>15 Mayıs 2026 · 18:32 · {SCAN_ITEMS.length} ürün</div>
            </div>
            <span style={{
              padding: "4px 8px", borderRadius: 999,
              background: "var(--accent-c)", color: "var(--accent-onc)",
              fontSize: 11, fontWeight: 700,
              display: "inline-flex", alignItems: "center", gap: 4,
            }}>
              <Icon name="sparkle" size={11} color="var(--accent-onc)" />
              %98 güven
            </span>
          </div>
        </Card>

        <SectionLabel action={<span style={{ fontSize: 12, color: "var(--accent)", fontWeight: 600 }}>+ Ürün ekle</span>}>
          Tespit edilen ürünler
        </SectionLabel>

        <Card padding={0} radius={18} style={{ marginBottom: 16 }}>
          {SCAN_ITEMS.map((it, i) => (
            <ScanItemRow key={it.id} {...it} divider={i < SCAN_ITEMS.length - 1} />
          ))}
        </Card>

        {/* Total row */}
        <Card padding={16} radius={18} style={{ marginBottom: 88 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
            <span style={{ fontSize: 13, color: "var(--n-text-mid)" }}>Ara toplam</span>
            <span style={{ fontSize: 13, color: "var(--n-text-hi)", fontFamily: "var(--font-mono)" }}>{fmtTRY(total)}</span>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
            <span style={{ fontSize: 13, color: "var(--n-text-mid)" }}>KDV (%8)</span>
            <span style={{ fontSize: 13, color: "var(--n-text-hi)", fontFamily: "var(--font-mono)" }}>{fmtTRY(total * 0.08)}</span>
          </div>
          <div style={{
            paddingTop: 12, borderTop: "1px solid var(--n-outline-soft)",
            display: "flex", justifyContent: "space-between", alignItems: "baseline",
          }}>
            <span style={{ fontSize: 14, fontWeight: 700, color: "var(--n-text-hi)" }}>Toplam</span>
            <span style={{ fontSize: 24, fontWeight: 700, fontFamily: "var(--font-display)", letterSpacing: "-0.02em" }}>
              {fmtTRY(total * 1.08)}
            </span>
          </div>
        </Card>
      </div>

      {/* Sticky action bar */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 0,
        padding: "12px 16px 24px",
        background: "linear-gradient(0deg, var(--n-bg) 0%, var(--n-bg) 60%, rgba(244,244,247,0) 100%)",
        display: "flex", gap: 10,
      }}>
        <Button variant="outlined" size="lg" icon="document_scanner" style={{ flex: 0 }}>Yeniden</Button>
        <Button variant="filled" size="lg" iconRight="check" style={{ flex: 1 }} full>Tümünü Kaydet</Button>
      </div>
    </div>
  );
}

function ScanItemRow({ name, amount, cat, divider }) {
  const c = CATEGORIES[cat];
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 10,
      padding: "12px 14px",
      borderBottom: divider ? "1px solid var(--n-outline-soft)" : "none",
    }}>
      <CategoryDot cat={cat} size={8} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: "var(--n-text-hi)" }}>{name}</div>
        <div style={{ marginTop: 4, display: "inline-flex", alignItems: "center", gap: 4,
          padding: "2px 8px", borderRadius: 999,
          background: tint(c.color, 0.12), color: c.color,
          fontSize: 11, fontWeight: 600,
        }}>
          {c.label} <Icon name="chevron_down" size={11} color={c.color} weight={2.4} />
        </div>
      </div>
      <div style={{ fontSize: 15, fontWeight: 700, fontFamily: "var(--font-display)", letterSpacing: "-0.01em" }}>
        {fmtTRY(amount)}
      </div>
      <Icon name="edit" size={16} color="var(--n-text-lo)" />
    </div>
  );
}

Object.assign(window, {
  ScrScanPicker, ScrScanProcessing, ScrScanResult,
  ProgressStep, ScanItemRow,
});
