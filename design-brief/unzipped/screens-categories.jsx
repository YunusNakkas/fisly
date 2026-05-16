// screens-categories.jsx — Kategoriler ayar ekranı

const SYSTEM_CATS = ["market", "ulasim", "faturalar", "yeme", "saglik", "eglence", "diger"];
const CUSTOM_CATS = [
  { id: 1, label: "Spor", icon: "bolt", color: "#F97316" },
  { id: 2, label: "Eğitim", icon: "shapes", color: "#0EA5E9" },
  { id: 3, label: "Hediye", icon: "sparkle", color: "#EC4899" },
];

function ScrCategories() {
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<IconButton icon="chevron_left" />}
        title="Kategoriler"
        trailing={<IconButton icon="search" />}
      />
      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 110px" }}>
        <SectionLabel>Sistem kategorileri</SectionLabel>
        <Card padding={0} radius={18} style={{ marginBottom: 24 }}>
          {SYSTEM_CATS.map((c, i) => (
            <CategorySettingsRow key={c} cat={c} divider={i < SYSTEM_CATS.length - 1} system />
          ))}
        </Card>

        <SectionLabel
          action={<span style={{ fontSize: 12, color: "var(--accent)", fontWeight: 600 }}>+ Yeni</span>}
        >
          Kendi kategorilerin
        </SectionLabel>
        <Card padding={0} radius={18} style={{ marginBottom: 18 }}>
          {CUSTOM_CATS.map((c, i) => (
            <CustomCatRow key={c.id} {...c} divider={i < CUSTOM_CATS.length - 1} />
          ))}
        </Card>

        {/* Color picker preview */}
        <SectionLabel>Renk paleti</SectionLabel>
        <Card padding={16} radius={18}>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(6, 1fr)", gap: 12 }}>
            {Object.values(CATEGORY_COLORS).map((c, i) => (
              <div key={i} style={{
                aspectRatio: "1 / 1", borderRadius: 12,
                background: c, position: "relative",
              }}>
                {i === 5 && (
                  <div style={{
                    position: "absolute", inset: 0,
                    display: "flex", alignItems: "center", justifyContent: "center",
                  }}>
                    <Icon name="check" size={18} color="#FFF" weight={3} />
                  </div>
                )}
              </div>
            ))}
          </div>
        </Card>
      </div>
      <FAB icon="plus" />
    </div>
  );
}

function CategorySettingsRow({ cat, divider, system }) {
  const c = CATEGORIES[cat];
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: "12px 14px",
      borderBottom: divider ? "1px solid var(--n-outline-soft)" : "none",
    }}>
      <CategoryAvatar cat={cat} size={38} radius={12} />
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 15, fontWeight: 600 }}>{c.label}</div>
        {system && <div style={{ fontSize: 11, color: "var(--n-text-lo)", marginTop: 2 }}>Sistem · değiştirilemez</div>}
      </div>
      <Icon name={system ? "lock" : "more_v"} size={16} color="var(--n-text-lo)" />
    </div>
  );
}

function CustomCatRow({ label, icon, color, divider }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: "12px 14px",
      borderBottom: divider ? "1px solid var(--n-outline-soft)" : "none",
    }}>
      <div style={{
        width: 38, height: 38, borderRadius: 12,
        background: tint(color, 0.14),
        display: "flex", alignItems: "center", justifyContent: "center",
      }}>
        <Icon name={icon} size={18} color={color} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 15, fontWeight: 600 }}>{label}</div>
        <div style={{ fontSize: 11, color: "var(--n-text-lo)", marginTop: 2 }}>Özel kategori</div>
      </div>
      <Icon name="more_v" size={16} color="var(--n-text-lo)" />
    </div>
  );
}

Object.assign(window, { ScrCategories, CategorySettingsRow, CustomCatRow });
