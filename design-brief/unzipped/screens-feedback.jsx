// screens-feedback.jsx — Geri bildirim + extra states (empty, add expense sheet)

function ScrFeedback() {
  const types = [
    { id: "bug", label: "Hata", icon: "bolt", color: "#EF4444" },
    { id: "feature", label: "Öneri", icon: "sparkle", color: "#8B5CF6" },
    { id: "question", label: "Soru", icon: "chat", color: "#3B82F6" },
    { id: "other", label: "Diğer", icon: "more_h", color: "#6B7280" },
  ];
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<IconButton icon="chevron_left" />}
        title="Geri bildirim"
      />
      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 32px" }}>
        <div style={{ marginBottom: 20 }}>
          <div style={{
            fontFamily: "var(--font-display)", fontWeight: 700,
            fontSize: 22, lineHeight: 1.15, letterSpacing: "-0.015em",
          }}>Düşüncen bizim için değerli.</div>
          <div style={{ marginTop: 6, fontSize: 14, color: "var(--n-text-mid)" }}>
            Hata bildirimleri 48 saat içinde yanıtlanır.
          </div>
        </div>

        <SectionLabel>Tür</SectionLabel>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 20 }}>
          {types.map((t, i) => (
            <div key={t.id} style={{
              padding: 14, borderRadius: 16,
              background: i === 0 ? tint(t.color, 0.1) : "var(--n-surface)",
              border: `1.5px solid ${i === 0 ? t.color : "var(--n-outline)"}`,
              display: "flex", alignItems: "center", gap: 10,
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: 10,
                background: tint(t.color, 0.14),
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <Icon name={t.icon} size={16} color={t.color} />
              </div>
              <div style={{ fontSize: 14, fontWeight: 600, color: "var(--n-text-hi)" }}>{t.label}</div>
            </div>
          ))}
        </div>

        <SectionLabel>Mesajın</SectionLabel>
        <div style={{
          padding: "14px 16px",
          background: "var(--n-surface)",
          border: "1.5px solid var(--n-outline)",
          borderRadius: 16,
          minHeight: 120,
          fontSize: 14, color: "var(--n-text-mid)", lineHeight: 1.5,
        }}>
          Yaşadığın sorunu veya öneriyi mümkün olduğunca detaylı yaz…
        </div>

        <SectionLabel>Ekran görüntüsü (opsiyonel)</SectionLabel>
        <div style={{
          padding: 18, borderRadius: 16,
          border: "1.5px dashed var(--n-outline)",
          display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 6,
          marginBottom: 24,
        }}>
          <Icon name="image" size={22} color="var(--n-text-mid)" />
          <div style={{ fontSize: 13, fontWeight: 600, color: "var(--n-text-hi)" }}>Ekran görüntüsü ekle</div>
          <div style={{ fontSize: 11, color: "var(--n-text-lo)" }}>PNG, JPG · Maks. 5 MB</div>
        </div>

        <Button variant="filled" full size="lg">Gönder</Button>

        <div style={{ marginTop: 16, padding: 14, background: "var(--n-surface-c)", borderRadius: 14, fontSize: 12, color: "var(--n-text-mid)", lineHeight: 1.5, textAlign: "center" }}>
          Acil mi? <span style={{ color: "var(--accent)", fontWeight: 700 }}>destek@fişly.app</span>
        </div>
      </div>
    </div>
  );
}

// ─── Empty state: Harcamalar ───────────────────────────────────────
function ScrEmptyExpenses() {
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<MonthPicker value="Mayıs 2026" />}
        title=""
        trailing={<IconButton icon="search" />}
      />
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 32px", paddingBottom: 132 }}>
        <div style={{ position: "relative", width: 140, height: 140, marginBottom: 24 }}>
          <div style={{
            position: "absolute", inset: 0,
            background: "var(--accent-c)",
            borderRadius: 48,
            opacity: 0.5,
          }} />
          <div style={{
            position: "absolute", left: 35, top: 22, width: 70, height: 96,
            background: "var(--n-surface)", borderRadius: 12,
            border: "1.5px solid var(--n-outline)",
            display: "flex", flexDirection: "column", padding: 10, gap: 5,
          }}>
            <div style={{ height: 4, background: "var(--n-outline)", borderRadius: 2, width: "60%" }} />
            <div style={{ height: 3, background: "var(--n-outline-soft)", borderRadius: 2 }} />
            <div style={{ height: 3, background: "var(--n-outline-soft)", borderRadius: 2, width: "80%" }} />
            <div style={{ height: 1, background: "var(--n-outline)", margin: "3px 0" }} />
            <div style={{ height: 6, background: "var(--accent-dim)", borderRadius: 2, width: "55%", marginLeft: "auto", marginTop: "auto" }} />
          </div>
        </div>
        <div style={{
          fontFamily: "var(--font-display)", fontWeight: 700,
          fontSize: 22, letterSpacing: "-0.015em", textAlign: "center",
        }}>Bu ay henüz harcama yok</div>
        <div style={{ marginTop: 8, fontSize: 14, color: "var(--n-text-mid)", textAlign: "center", lineHeight: 1.45, maxWidth: 260 }}>
          İlk fişini tarayarak başla veya manuel olarak harcama ekle.
        </div>
        <div style={{ marginTop: 20, display: "flex", flexDirection: "column", gap: 10, width: "100%", maxWidth: 280 }}>
          <Button variant="filled" full size="md" icon="document_scanner">Fiş tara</Button>
          <Button variant="ghost" full size="md" icon="plus">Manuel ekle</Button>
        </div>
      </div>
      <BottomNav active="expenses" />
    </div>
  );
}

// ─── Add Expense bottom sheet ─────────────────────────────────────
function ScrAddExpense() {
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column",
      background: "rgba(15, 15, 20, 0.4)",
    }}>
      {/* Backdrop fake — show a faded expense list behind */}
      <div style={{
        position: "absolute", inset: 0,
        filter: "blur(8px)", opacity: 0.5,
        background: "var(--n-bg)",
      }} />

      <div style={{ flex: 1 }} />

      {/* Sheet */}
      <div style={{
        background: "var(--n-bg)",
        borderTopLeftRadius: 28, borderTopRightRadius: 28,
        padding: "10px 0 28px",
        boxShadow: "0 -10px 30px -10px rgba(15,15,30,0.2)",
        position: "relative",
        maxHeight: "85%",
      }}>
        <div style={{ width: 36, height: 4, background: "var(--n-outline)", borderRadius: 999, margin: "0 auto 14px" }} />

        <div style={{ padding: "0 20px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
            <div style={{ fontSize: 18, fontWeight: 700, fontFamily: "var(--font-display)", letterSpacing: "-0.01em" }}>Yeni Harcama</div>
            <IconButton icon="close" />
          </div>

          {/* Amount input */}
          <div style={{ display: "flex", alignItems: "baseline", justifyContent: "center", gap: 4, padding: "16px 0 22px" }}>
            <span style={{ fontSize: 28, fontWeight: 700, color: "var(--n-text-mid)" }}>₺</span>
            <input
              type="text" defaultValue="234,80"
              style={{
                background: "transparent", border: "none", outline: "none",
                fontFamily: "var(--font-display)", fontWeight: 700,
                fontSize: 56, letterSpacing: "-0.03em", textAlign: "center",
                color: "var(--n-text-hi)", width: 200,
              }}
            />
          </div>

          {/* Field grid */}
          <div style={{ display: "flex", flexDirection: "column", gap: 12, marginBottom: 18 }}>
            <SheetField label="Açıklama" value="Migros - Haftalık alışveriş" />
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
              <SheetField label="Tarih" value="15 May 2026" leading={<Icon name="calendar" size={16} color="var(--n-text-mid)" />} />
              <SheetField label="Hesap" value="Garanti" />
            </div>
          </div>

          {/* Category chips */}
          <div style={{ marginBottom: 8 }}>
            <div style={{ fontSize: 12, fontWeight: 600, color: "var(--n-text-mid)", marginBottom: 8 }}>Kategori</div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
              {Object.keys(CATEGORIES).map((cat, i) => {
                const c = CATEGORIES[cat];
                const active = i === 0;
                return (
                  <div key={cat} style={{
                    display: "inline-flex", alignItems: "center", gap: 6,
                    padding: "8px 12px", borderRadius: 999,
                    background: active ? c.color : "var(--n-surface)",
                    color: active ? "#FFF" : "var(--n-text-hi)",
                    border: active ? "none" : "1px solid var(--n-outline)",
                    fontSize: 13, fontWeight: 600,
                  }}>
                    <Icon name={c.icon} size={14} color={active ? "#FFF" : c.color} />
                    {c.label}
                  </div>
                );
              })}
            </div>
          </div>

          <div style={{ marginTop: 22, display: "flex", gap: 10 }}>
            <Button variant="outlined" size="lg" style={{ flex: 1 }} full>İptal</Button>
            <Button variant="filled" size="lg" style={{ flex: 1 }} full>Kaydet</Button>
          </div>
        </div>
      </div>
    </div>
  );
}

function SheetField({ label, value, leading }) {
  return (
    <div style={{
      padding: "10px 14px",
      background: "var(--n-surface)",
      border: "1px solid var(--n-outline)",
      borderRadius: 12,
    }}>
      <div style={{ fontSize: 11, fontWeight: 600, color: "var(--n-text-mid)", marginBottom: 2 }}>{label}</div>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        {leading}
        <div style={{ fontSize: 14, fontWeight: 500, color: "var(--n-text-hi)" }}>{value}</div>
      </div>
    </div>
  );
}

Object.assign(window, { ScrFeedback, ScrEmptyExpenses, ScrAddExpense, SheetField });
