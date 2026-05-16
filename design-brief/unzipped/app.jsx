// app.jsx — Wires everything into a DesignCanvas with sections + Tweaks panel.

function App() {
  const [tweaks, setTweak] = useTweaks(TWEAK_DEFAULTS);

  // Each artboard wraps a PhoneFrame holding one screen.
  const Phone = ({ children }) => (
    <ThemeProvider tw={tweaks}>
      <PhoneFrame>{children}</PhoneFrame>
    </ThemeProvider>
  );

  // Artboard size matches phone w/ bezel (380 × 780).
  const W = PHONE_W + 20;
  const H = PHONE_H + 20;

  return (
    <ThemeProvider tw={tweaks}>
      <DesignCanvas>
        <DCSection id="brand" title="Fişly · Redesign" subtitle="Modern finans (Monzo/Revolut tarzı) · Material 3 uyumlu · Plus Jakarta Sans · TR">
          <DCArtboard id="cover" label="Sistem özeti" width={780} height={780}>
            <Cover />
          </DCArtboard>
        </DCSection>

        <DCSection id="onboarding" title="Onboarding" subtitle="3 slide hoş geldin akışı">
          <DCArtboard id="ob1" label="01 · Hoş geldin" width={W} height={H}><Phone><ScrOnboardingWelcome /></Phone></DCArtboard>
          <DCArtboard id="ob2" label="02 · AI fiş tarama" width={W} height={H}><Phone><ScrOnboardingScan /></Phone></DCArtboard>
          <DCArtboard id="ob3" label="03 · Bütçe & abonelik" width={W} height={H}><Phone><ScrOnboardingBudgets /></Phone></DCArtboard>
        </DCSection>

        <DCSection id="auth" title="Auth" subtitle="Public ekranlar">
          <DCArtboard id="login" label="Giriş yap" width={W} height={H}><Phone><ScrLogin /></Phone></DCArtboard>
          <DCArtboard id="register" label="Kayıt ol" width={W} height={H}><Phone><ScrRegister /></Phone></DCArtboard>
          <DCArtboard id="forgot" label="Şifremi unuttum" width={W} height={H}><Phone><ScrForgot /></Phone></DCArtboard>
        </DCSection>

        <DCSection id="main" title="Ana sekmeler" subtitle="Bottom nav 4 tab + Scan FAB">
          <DCArtboard id="expenses" label="Harcamalar" width={W} height={H}><Phone><ScrExpenses /></Phone></DCArtboard>
          <DCArtboard id="reports" label="Özet — Reports" width={W} height={H}><Phone><ScrReports /></Phone></DCArtboard>
          <DCArtboard id="subs" label="Abonelikler" width={W} height={H}><Phone><ScrSubscriptions /></Phone></DCArtboard>
          <DCArtboard id="settings" label="Ayarlar" width={W} height={H}><Phone><ScrSettings /></Phone></DCArtboard>
        </DCSection>

        <DCSection id="scan" title="Fiş Tara · 3 durum" subtitle="Modal — picker → scanning → result">
          <DCArtboard id="scan1" label="01 · Picker" width={W} height={H}><Phone><ScrScanPicker /></Phone></DCArtboard>
          <DCArtboard id="scan2" label="02 · Scanning" width={W} height={H}><Phone><ScrScanProcessing /></Phone></DCArtboard>
          <DCArtboard id="scan3" label="03 · Result" width={W} height={H}><Phone><ScrScanResult /></Phone></DCArtboard>
        </DCSection>

        <DCSection id="sub-screens" title="Ayar alt ekranları" subtitle="Settings sub-routes">
          <DCArtboard id="profile" label="Profil" width={W} height={H}><Phone><ScrProfile /></Phone></DCArtboard>
          <DCArtboard id="password" label="Şifre değiştir" width={W} height={H}><Phone><ScrPassword /></Phone></DCArtboard>
          <DCArtboard id="budgets" label="Bütçeler" width={W} height={H}><Phone><ScrBudgets /></Phone></DCArtboard>
          <DCArtboard id="categories" label="Kategoriler" width={W} height={H}><Phone><ScrCategories /></Phone></DCArtboard>
          <DCArtboard id="feedback" label="Geri bildirim" width={W} height={H}><Phone><ScrFeedback /></Phone></DCArtboard>
        </DCSection>

        <DCSection id="states" title="Ekstra state'ler" subtitle="Empty, sheets, modal">
          <DCArtboard id="empty" label="Empty · Harcamalar" width={W} height={H}><Phone><ScrEmptyExpenses /></Phone></DCArtboard>
          <DCArtboard id="add" label="Harcama ekle (sheet)" width={W} height={H}><Phone><ScrAddExpense /></Phone></DCArtboard>
        </DCSection>
      </DesignCanvas>

      <Tweaks tweaks={tweaks} setTweak={setTweak} />
    </ThemeProvider>
  );
}

// ─── Cover / system snapshot ───────────────────────────────────────
function Cover() {
  const t = useTheme();
  return (
    <div style={{
      width: 780, height: 780,
      background: t.n.bg,
      padding: 48,
      fontFamily: t.type.body, color: t.n.textHi,
      display: "flex", flexDirection: "column", gap: 32,
    }}>
      {/* Brand + title */}
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <BrandMark size={56} />
          <div>
            <div style={{ fontFamily: t.type.display, fontWeight: 700, fontSize: 32, letterSpacing: "-0.02em" }}>Fişly</div>
            <div style={{ fontSize: 13, color: t.n.textMid, marginTop: 2 }}>Türkçe kişisel finans · Flutter · Material 3</div>
          </div>
        </div>
        <div style={{
          padding: "6px 14px", borderRadius: 999,
          background: t.accent.primaryContainer, color: t.accent.onPrimaryContainer,
          fontSize: 12, fontWeight: 700,
          display: "inline-flex", alignItems: "center", gap: 6,
        }}>
          <Icon name="sparkle" size={12} color={t.accent.onPrimaryContainer} />
          v1.2.0 · redesign
        </div>
      </div>

      {/* Headline */}
      <div>
        <div style={{
          fontFamily: t.type.display, fontWeight: t.type.displayWeight,
          fontSize: 56, lineHeight: 1.0, letterSpacing: "-0.035em",
          maxWidth: 600,
        }}>
          Modern finans estetiği,<br/>Türk pazarına özel.
        </div>
        <div style={{ marginTop: 14, fontSize: 16, color: t.n.textMid, maxWidth: 540, lineHeight: 1.5 }}>
          Açık zemin + koyu hero kartlar, soft tinted kategori kutuları, büyük tipografi. Tüm değerler tweaks panelinden değiştirilebilir.
        </div>
      </div>

      {/* Token grid */}
      <div style={{ display: "grid", gridTemplateColumns: "1.2fr 1fr 1fr", gap: 16, flex: 1 }}>
        {/* Type */}
        <div style={{
          background: t.n.surface, borderRadius: 20, padding: 22,
          border: `1px solid ${t.n.outline}`,
          display: "flex", flexDirection: "column", justifyContent: "space-between",
        }}>
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.1em", color: t.n.textLo, textTransform: "uppercase" }}>Tipografi</div>
            <div style={{ marginTop: 12, fontFamily: t.type.display, fontWeight: t.type.displayWeight, fontSize: 56, lineHeight: 0.95, letterSpacing: "-0.03em" }}>
              ₺710<span style={{ color: t.n.textMid, fontWeight: 500 }}>,00</span>
            </div>
            <div style={{ marginTop: 8, fontSize: 13, color: t.n.textMid }}>Display · {t.type.name}</div>
          </div>
          <div style={{ marginTop: 16, display: "flex", flexDirection: "column", gap: 6 }}>
            <TypeSample size={20} weight={600} label="Title 20/600" />
            <TypeSample size={15} weight={500} label="Body 15/500" />
            <TypeSample size={11} weight={700} label="LABEL 11/700" upper />
          </div>
        </div>

        {/* Categories */}
        <div style={{
          background: t.n.surface, borderRadius: 20, padding: 22,
          border: `1px solid ${t.n.outline}`,
        }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.1em", color: t.n.textLo, textTransform: "uppercase" }}>Kategori avatarı</div>
          <div style={{ marginTop: 14, display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
            {Object.keys(CATEGORIES).slice(0, 6).map((c) => (
              <div key={c} style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <CategoryAvatar cat={c} size={32} radius={10} />
                <div>
                  <div style={{ fontSize: 12, fontWeight: 600 }}>{CATEGORIES[c].label}</div>
                  <div style={{ fontSize: 10, color: t.n.textLo, fontFamily: "var(--font-mono)" }}>{CATEGORIES[c].color}</div>
                </div>
              </div>
            ))}
          </div>
          <div style={{ marginTop: 14, fontSize: 11, color: t.n.textMid, lineHeight: 1.5 }}>
            Soft tinted: bg = renk @ 14% alpha, icon = full renk
          </div>
        </div>

        {/* Accent + hero swatches */}
        <div style={{
          background: t.n.surface, borderRadius: 20, padding: 22,
          border: `1px solid ${t.n.outline}`,
        }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.1em", color: t.n.textLo, textTransform: "uppercase" }}>Theme · {t.accent.name}</div>
          <div style={{ marginTop: 14, display: "flex", flexDirection: "column", gap: 10 }}>
            <Swatch color={t.accent.primary} label="primary" />
            <Swatch color={t.accent.primaryContainer} label="primary-container" border />
            <Swatch color={t.accent.heroBg} label="hero-bg" />
            <Swatch color={t.n.surface} label="surface" border />
            <Swatch color={t.n.bg} label="bg" border />
          </div>
        </div>
      </div>

      {/* Footer hints */}
      <div style={{ display: "flex", gap: 14, fontSize: 12, color: t.n.textMid }}>
        <span style={{ display: "inline-flex", alignItems: "center", gap: 6 }}>
          <span style={{ width: 8, height: 8, borderRadius: 999, background: t.n.ok }} /> Material 3 token uyumu
        </span>
        <span style={{ display: "inline-flex", alignItems: "center", gap: 6 }}>
          <span style={{ width: 8, height: 8, borderRadius: 999, background: t.n.ok }} /> Flutter-uygulanabilir
        </span>
        <span style={{ display: "inline-flex", alignItems: "center", gap: 6 }}>
          <span style={{ width: 8, height: 8, borderRadius: 999, background: t.accent.primary }} /> Tweaks ile değiştirilebilir
        </span>
      </div>
    </div>
  );
}

function TypeSample({ size, weight, label, upper }) {
  const t = useTheme();
  return (
    <div style={{
      fontFamily: t.type.body, fontSize: size, fontWeight: weight,
      color: t.n.textHi,
      textTransform: upper ? "uppercase" : "none",
      letterSpacing: upper ? "0.1em" : "-0.005em",
    }}>{label}</div>
  );
}

function Swatch({ color, label, border }) {
  const t = useTheme();
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
      <div style={{
        width: 28, height: 28, borderRadius: 8,
        background: color,
        border: border ? `1px solid ${t.n.outline}` : "none",
      }} />
      <div>
        <div style={{ fontSize: 12, fontWeight: 600 }}>{label}</div>
        <div style={{ fontSize: 10, color: t.n.textLo, fontFamily: "var(--font-mono)" }}>{color.toUpperCase()}</div>
      </div>
    </div>
  );
}

// ─── Tweaks panel ──────────────────────────────────────────────────
function Tweaks({ tweaks, setTweak }) {
  return (
    <TweaksPanel title="Tweaks">
      <TweakSection label="Accent">
        <TweakColor
          label="Tema rengi"
          value={ACCENT_PALETTES[tweaks.accent]?.primary}
          options={Object.keys(ACCENT_PALETTES).map((k) => ACCENT_PALETTES[k].primary)}
          onChange={(v) => {
            const found = Object.keys(ACCENT_PALETTES).find((k) => ACCENT_PALETTES[k].primary === v) || "indigo";
            setTweak("accent", found);
          }}
        />
        <TweakSelect
          label="Palet adı"
          value={tweaks.accent}
          options={Object.keys(ACCENT_PALETTES).map((k) => ({ value: k, label: ACCENT_PALETTES[k].name }))}
          onChange={(v) => setTweak("accent", v)}
        />
      </TweakSection>

      <TweakSection label="Tipografi">
        <TweakSelect
          label="Aile"
          value={tweaks.typo}
          options={Object.keys(TYPE_STACKS).map((k) => ({ value: k, label: TYPE_STACKS[k].name }))}
          onChange={(v) => setTweak("typo", v)}
        />
      </TweakSection>
    </TweaksPanel>
  );
}

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<App />);
