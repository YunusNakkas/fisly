// screens-settings-sub.jsx — Settings sub-screens (Profil, Şifre, Bütçeler, Kategoriler, Geri bildirim)

// ─── Sub: Profil ───────────────────────────────────────────────────
function ScrProfile() {
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<IconButton icon="chevron_left" />}
        title="Profil"
      />
      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 32px" }}>
        {/* Avatar */}
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", marginBottom: 24 }}>
          <div style={{ position: "relative" }}>
            <div style={{
              width: 96, height: 96, borderRadius: 999,
              background: "linear-gradient(135deg, var(--accent) 0%, var(--accent-dim) 100%)",
              display: "flex", alignItems: "center", justifyContent: "center",
              color: "#FFF", fontSize: 40, fontWeight: 700, fontFamily: "var(--font-display)",
              boxShadow: "0 12px 28px -8px rgba(91,91,214,0.4)",
            }}>A</div>
            <div style={{
              position: "absolute", bottom: -2, right: -2,
              width: 32, height: 32, borderRadius: 999,
              background: "var(--n-surface)",
              border: "2px solid var(--n-bg)",
              display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <Icon name="camera" size={14} color="var(--n-text-hi)" />
            </div>
          </div>
          <div style={{ marginTop: 10, fontSize: 12, color: "var(--accent)", fontWeight: 600 }}>Fotoğrafı değiştir</div>
        </div>

        <SectionLabel>Kişisel bilgiler</SectionLabel>
        <div style={{ display: "flex", flexDirection: "column", gap: 12, marginBottom: 20 }}>
          <TextField label="Ad Soyad" value="Aysel Yıldırım" />
          <TextField label="E-posta" value="aysel@fişly.app" type="email" />
          <TextField label="Telefon" value="+90 555 123 4567" />
        </div>

        <SectionLabel>Tercihler</SectionLabel>
        <Card padding={0} radius={18} style={{ marginBottom: 24 }}>
          <PrefRow icon="bolt" title="Para birimi" value="₺ TRY" />
          <PrefRow icon="calendar" title="Dil" value="Türkçe" />
          <PrefRow icon="bell" title="Bildirimler" value="Açık" last />
        </Card>

        <Button variant="filled" full size="lg">Değişiklikleri kaydet</Button>
      </div>
    </div>
  );
}

function PrefRow({ icon, title, value, last }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: "14px 16px",
      borderBottom: last ? "none" : "1px solid var(--n-outline-soft)",
    }}>
      <Icon name={icon} size={18} color="var(--n-text-mid)" />
      <div style={{ flex: 1, fontSize: 15, fontWeight: 500 }}>{title}</div>
      <div style={{ fontSize: 14, color: "var(--n-text-mid)", fontWeight: 500 }}>{value}</div>
      <Icon name="chevron_right" size={18} color="var(--n-text-lo)" weight={2.2} />
    </div>
  );
}

// ─── Sub: Şifre değiştir ────────────────────────────────────────────
function ScrPassword() {
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<IconButton icon="chevron_left" />}
        title="Şifre değiştir"
      />
      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 32px" }}>
        <Card padding={18} radius={18} style={{
          marginBottom: 24, background: "var(--accent-c)", border: "none",
        }}>
          <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
            <div style={{
              width: 36, height: 36, borderRadius: 12, flexShrink: 0,
              background: "var(--n-surface)",
              display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <Icon name="lock" size={18} color="var(--accent-onc)" />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: "var(--accent-onc)", letterSpacing: "-0.005em" }}>
                Güçlü bir şifre seç
              </div>
              <div style={{ marginTop: 4, fontSize: 12, color: "var(--accent-onc)", lineHeight: 1.45, opacity: 0.85 }}>
                En az 8 karakter, bir büyük harf, bir rakam ve bir özel karakter içermeli.
              </div>
            </div>
          </div>
        </Card>

        <div style={{ display: "flex", flexDirection: "column", gap: 14, marginBottom: 24 }}>
          <TextField label="Mevcut şifre" value="••••••••" type="password"
            trailing={<Icon name="eye_off" size={18} color="var(--n-text-mid)" />} />
          <TextField label="Yeni şifre" value="" type="password"
            trailing={<Icon name="eye" size={18} color="var(--n-text-mid)" />} />
          <PasswordStrength level={0} />
          <TextField label="Yeni şifreyi tekrarla" value="" type="password"
            trailing={<Icon name="eye" size={18} color="var(--n-text-mid)" />} />
        </div>

        {/* Checklist */}
        <Card padding={14} radius={14} style={{ marginBottom: 24 }}>
          {[
            { label: "En az 8 karakter", ok: false },
            { label: "Bir büyük harf", ok: false },
            { label: "Bir rakam", ok: false },
            { label: "Bir özel karakter (!@#$)", ok: false },
          ].map((c, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 10, padding: "6px 0", fontSize: 13 }}>
              <div style={{
                width: 16, height: 16, borderRadius: 999,
                background: c.ok ? "var(--n-ok)" : "var(--n-outline)",
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                {c.ok && <Icon name="check" size={10} color="#FFF" weight={3} />}
              </div>
              <span style={{ color: c.ok ? "var(--n-text-hi)" : "var(--n-text-mid)" }}>{c.label}</span>
            </div>
          ))}
        </Card>

        <Button variant="filled" full size="lg" disabled>Şifreyi güncelle</Button>
      </div>
    </div>
  );
}

Object.assign(window, { ScrProfile, ScrPassword, PrefRow });
