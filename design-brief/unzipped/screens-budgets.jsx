// screens-budgets.jsx — Bütçeler ayar ekranı

const MOCK_BUDGETS = [
  { id: 1, type: "general", label: "Genel bütçe", period: "Aylık", limit: 5000, spent: 1411.95 },
  { id: 2, cat: "market",    period: "Aylık", limit: 1500, spent: 530.25 },
  { id: 3, cat: "yeme",      period: "Aylık", limit: 250,  spent: 210 },
  { id: 4, cat: "eglence",   period: "Aylık", limit: 400,  spent: 500 },
  { id: 5, cat: "ulasim",    period: "Haftalık", limit: 200, spent: 24.5 },
];

function ScrBudgets() {
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<IconButton icon="chevron_left" />}
        title="Bütçeler"
        trailing={<IconButton icon="more_h" />}
      />
      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 110px" }}>
        {/* Summary header */}
        <Card padding={18} radius={20} style={{ marginBottom: 18 }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: "var(--n-text-mid)", textTransform: "uppercase", letterSpacing: "0.08em" }}>
            Bu ay toplam bütçen
          </div>
          <div style={{
            marginTop: 4, fontSize: 30, fontWeight: 700,
            fontFamily: "var(--font-display)", letterSpacing: "-0.02em",
          }}>₺7.350,00</div>
          <div style={{ marginTop: 8, fontSize: 13, color: "var(--n-text-mid)" }}>
            5 bütçe · <span style={{ color: "var(--n-warn)", fontWeight: 600 }}>1 aşıldı</span>
          </div>
        </Card>

        <SectionLabel>Aktif bütçeler</SectionLabel>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {MOCK_BUDGETS.map((b) => <BudgetSettingsRow key={b.id} {...b} />)}
        </div>

        {/* Tip card */}
        <Card padding={14} radius={14} style={{ marginTop: 20, background: "var(--n-surface-c)", border: "none" }}>
          <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
            <Icon name="sparkle" size={16} color="var(--accent)" />
            <div style={{ fontSize: 12, color: "var(--n-text-mid)", lineHeight: 1.5 }}>
              <strong style={{ color: "var(--n-text-hi)" }}>İpucu:</strong> Her kategoriye ayrı bütçe koyarsan harcama dağılımın daha net olur.
            </div>
          </div>
        </Card>
      </div>
      <FAB icon="plus" />
    </div>
  );
}

function BudgetSettingsRow({ type, cat, label, period, limit, spent }) {
  const pct = spent / limit;
  const status = pct >= 1 ? "danger" : pct >= 0.8 ? "warn" : "ok";
  const color = status === "danger" ? "var(--n-danger)" : status === "warn" ? "var(--n-warn)" : "var(--n-ok)";
  const catLabel = cat ? CATEGORIES[cat].label : label;
  return (
    <Card padding={14} radius={16}>
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 10 }}>
        {cat ? <CategoryAvatar cat={cat} size={38} radius={12} /> : (
          <div style={{
            width: 38, height: 38, borderRadius: 12,
            background: "var(--accent-c)", color: "var(--accent-onc)",
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <Icon name="wallet" size={18} color="var(--accent-onc)" />
          </div>
        )}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 15, fontWeight: 600 }}>{catLabel}</div>
          <div style={{ fontSize: 11, color: "var(--n-text-mid)", marginTop: 2 }}>
            {period} · {fmtTRY(limit)} limit
          </div>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <div style={{ textAlign: "right" }}>
            <div style={{ fontSize: 14, fontWeight: 700, color, fontVariantNumeric: "tabular-nums" }}>
              {Math.round(pct * 100)}%
            </div>
            <div style={{ fontSize: 10, color: "var(--n-text-lo)", marginTop: 1, fontWeight: 500 }}>
              {limit - spent >= 0 ? `${fmtTRY(limit - spent)} kaldı` : `${fmtTRY(spent - limit)} aşıldı`}
            </div>
          </div>
          <Icon name="more_v" size={16} color="var(--n-text-lo)" />
        </div>
      </div>
      <ProgressBar value={Math.min(1, pct)} color={color} height={6} />
      <div style={{ marginTop: 6, display: "flex", justifyContent: "space-between", fontSize: 11, color: "var(--n-text-lo)" }}>
        <span>{fmtTRY(spent)}</span>
        <span>{fmtTRY(limit)}</span>
      </div>
    </Card>
  );
}

Object.assign(window, { ScrBudgets, BudgetSettingsRow });
