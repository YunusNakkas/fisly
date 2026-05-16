// screens-onboarding.jsx — Onboarding slides + Auth screens

// ─── Onboarding 1: Welcome (hero card centered) ───────────────────
function ScrOnboardingWelcome() {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", padding: "76px 24px 32px" }}>
      {/* Brand mark */}
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <BrandMark />
        <div style={{ fontFamily: "var(--font-display)", fontWeight: 700, fontSize: 18, letterSpacing: "-0.01em" }}>Fişly</div>
      </div>

      {/* Hero illustration — stack of receipt cards */}
      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", position: "relative" }}>
        <ReceiptStack />
      </div>

      {/* Big headline */}
      <div style={{ marginBottom: 24 }}>
        <div style={{
          fontFamily: "var(--font-display)", fontWeight: "var(--fw-display)",
          fontSize: 36, lineHeight: 1.05, letterSpacing: "-0.025em",
          color: "var(--n-text-hi)", textWrap: "balance",
        }}>
          Fişini çek,<br/>gerisini biz halledelim.
        </div>
        <div style={{ marginTop: 12, fontSize: 15, lineHeight: 1.4, color: "var(--n-text-mid)" }}>
          Gemini yapay zekâ fişlerini saniyeler içinde okur, kategorize eder ve bütçeni takip eder.
        </div>
      </div>

      {/* CTA + pagination dots */}
      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        <Button variant="filled" full size="lg" iconRight="arrow_right">Devam</Button>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div style={{ fontSize: 13, color: "var(--n-text-mid)", fontWeight: 500 }}>Zaten hesabın var mı? <span style={{ color: "var(--accent)", fontWeight: 600 }}>Giriş yap</span></div>
          <PageDots active={0} count={3} />
        </div>
      </div>
    </div>
  );
}

function BrandMark({ size = 32 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: 10,
      background: "var(--accent)",
      display: "flex", alignItems: "center", justifyContent: "center",
      boxShadow: "0 4px 10px -2px rgba(91,91,214,0.35)",
    }}>
      <svg width={size * 0.6} height={size * 0.6} viewBox="0 0 24 24" fill="none">
        <path d="M6 3v18l1.5-1.2L9 21l1.5-1.2L12 21l1.5-1.2L15 21l1.5-1.2L18 21V3l-1.5 1.2L15 3l-1.5 1.2L12 3l-1.5 1.2L9 3 7.5 4.2z"
          fill="#FFFFFF" />
        <line x1="8.5" y1="9" x2="15.5" y2="9" stroke="var(--accent)" strokeWidth="1.2" strokeLinecap="round"/>
        <line x1="8.5" y1="13" x2="13.5" y2="13" stroke="var(--accent)" strokeWidth="1.2" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

function PageDots({ active = 0, count = 3 }) {
  return (
    <div style={{ display: "flex", gap: 6 }}>
      {Array.from({ length: count }).map((_, i) => (
        <div key={i} style={{
          width: i === active ? 22 : 6, height: 6, borderRadius: 999,
          background: i === active ? "var(--accent)" : "var(--n-outline)",
          transition: "width .2s",
        }} />
      ))}
    </div>
  );
}

function ReceiptStack() {
  return (
    <div style={{ position: "relative", width: 280, height: 280 }}>
      {/* back receipt - tilted right */}
      <div style={{
        position: "absolute", left: 30, top: 30, width: 200, height: 240,
        background: "var(--n-surface)", borderRadius: 18,
        transform: "rotate(8deg)",
        border: "1px solid var(--n-outline)",
        boxShadow: "0 8px 24px -8px rgba(15,15,30,0.12)",
        padding: 18,
      }}>
        <FakeReceiptContent merchant="Migros" tint="#10B981" />
      </div>
      {/* front receipt - tilted left, slight shift */}
      <div style={{
        position: "absolute", left: 60, top: 50, width: 200, height: 240,
        background: "var(--n-surface)", borderRadius: 18,
        transform: "rotate(-6deg)",
        border: "1px solid var(--n-outline)",
        boxShadow: "0 12px 32px -10px rgba(15,15,30,0.18)",
        padding: 18,
      }}>
        <FakeReceiptContent merchant="Lunapark" tint="#8B5CF6" amount="₺500,00" />
      </div>
      {/* AI sparkle badge */}
      <div style={{
        position: "absolute", right: -4, top: 8,
        width: 48, height: 48, borderRadius: 16,
        background: "var(--accent)",
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: "0 8px 18px -4px rgba(91,91,214,0.45)",
        transform: "rotate(8deg)",
      }}>
        <Icon name="sparkle" size={24} color="#FFFFFF" weight={2.2} />
      </div>
    </div>
  );
}

function FakeReceiptContent({ merchant, tint, amount = "₺234,80" }) {
  return (
    <>
      <div style={{
        width: 44, height: 44, borderRadius: 12, background: window.tint(tint, 0.14),
        display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 14,
      }}>
        <Icon name={merchant === "Migros" ? "shopping_cart" : "movie"} size={22} color={tint} />
      </div>
      <div style={{ fontSize: 12, color: "var(--n-text-mid)", fontWeight: 500 }}>{merchant}</div>
      <div style={{ fontSize: 22, fontWeight: 700, fontFamily: "var(--font-display)", letterSpacing: "-0.02em" }}>{amount}</div>
      <div style={{ marginTop: 18, display: "flex", flexDirection: "column", gap: 8 }}>
        {[0.6, 0.85, 0.45, 0.7].map((w, i) => (
          <div key={i} style={{ height: 6, width: `${w * 100}%`, background: "var(--n-outline)", borderRadius: 3 }} />
        ))}
      </div>
    </>
  );
}

// ─── Onboarding 2: AI receipt scan feature ────────────────────────
function ScrOnboardingScan() {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", padding: "76px 24px 32px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <BrandMark />
        <div style={{ fontFamily: "var(--font-display)", fontWeight: 700, fontSize: 18, letterSpacing: "-0.01em" }}>Fişly</div>
      </div>

      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <ScanIllo />
      </div>

      <div style={{ marginBottom: 24 }}>
        <span style={{
          display: "inline-flex", alignItems: "center", gap: 6,
          padding: "5px 10px", background: "var(--accent-c)", color: "var(--accent-onc)",
          borderRadius: 999, fontSize: 12, fontWeight: 700, marginBottom: 12,
        }}>
          <Icon name="sparkle" size={12} color="var(--accent-onc)" /> Gemini Vision
        </span>
        <div style={{
          fontFamily: "var(--font-display)", fontWeight: "var(--fw-display)",
          fontSize: 30, lineHeight: 1.1, letterSpacing: "-0.02em", textWrap: "balance",
        }}>
          Türk fişlerini tanır,<br/>ürünleri ayırır.
        </div>
        <div style={{ marginTop: 12, fontSize: 15, lineHeight: 1.4, color: "var(--n-text-mid)" }}>
          BİM, Migros, A101, ŞOK — yerel zincirleri ve termal kağıt fişleri okur. Kategorileri otomatik atar.
        </div>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        <Button variant="filled" full size="lg" iconRight="arrow_right">Devam</Button>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div style={{ fontSize: 13, color: "var(--n-text-mid)", fontWeight: 600 }}>Atla</div>
          <PageDots active={1} count={3} />
        </div>
      </div>
    </div>
  );
}

function ScanIllo() {
  return (
    <div style={{ position: "relative", width: 280, height: 280 }}>
      {/* receipt outline */}
      <div style={{
        position: "absolute", left: 60, top: 20, width: 160, height: 230,
        background: "var(--n-surface)", borderRadius: 16,
        border: "1px solid var(--n-outline)",
        padding: 14, display: "flex", flexDirection: "column", gap: 8,
        boxShadow: "0 12px 28px -10px rgba(15,15,30,0.15)",
      }}>
        <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.1em", color: "var(--n-text-mid)" }}>BİM</div>
        <div style={{ fontSize: 10, color: "var(--n-text-lo)" }}>15.05.2026 · 18:32</div>
        <div style={{ height: 1, background: "var(--n-outline)", margin: "6px 0" }} />
        {[
          { name: "Süt 1L", amt: "₺28,50", cat: "market" },
          { name: "Ekmek", amt: "₺12,00", cat: "market" },
          { name: "Çikolata", amt: "₺45,00", cat: "market" },
          { name: "Domates", amt: "₺18,75", cat: "market" },
        ].map((it, i) => (
          <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", fontSize: 11 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
              <CategoryDot cat={it.cat} size={6} />
              <span style={{ color: "var(--n-text-hi)", fontWeight: 500 }}>{it.name}</span>
            </div>
            <span style={{ fontFamily: "var(--font-mono)", fontWeight: 600, fontSize: 10 }}>{it.amt}</span>
          </div>
        ))}
        <div style={{ marginTop: "auto", paddingTop: 8, borderTop: "1px solid var(--n-outline)", display: "flex", justifyContent: "space-between", fontSize: 12, fontWeight: 700 }}>
          <span>Toplam</span><span>₺104,25</span>
        </div>
      </div>
      {/* scanning line */}
      <div style={{
        position: "absolute", left: 50, top: 150, width: 180, height: 3,
        background: "linear-gradient(90deg, transparent, var(--accent), transparent)",
        borderRadius: 999,
        boxShadow: "0 0 12px var(--accent)",
      }} />
      {/* corners */}
      {[[40,5],[245,5],[40,265],[245,265]].map(([x,y], i) => {
        const isTop = y < 100;
        const isLeft = x < 100;
        return (
          <svg key={i} width="20" height="20" style={{ position: "absolute", left: x - 5, top: y - 5 }} viewBox="0 0 20 20">
            <path
              d={isLeft
                ? (isTop ? "M2 8V2h6" : "M2 12v6h6")
                : (isTop ? "M18 8V2h-6" : "M18 12v6h-6")}
              stroke="var(--accent)" strokeWidth="2.5" fill="none" strokeLinecap="round" />
          </svg>
        );
      })}
    </div>
  );
}

// ─── Onboarding 3: Budgets + subscriptions ────────────────────────
function ScrOnboardingBudgets() {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", padding: "76px 24px 32px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <BrandMark />
        <div style={{ fontFamily: "var(--font-display)", fontWeight: 700, fontSize: 18, letterSpacing: "-0.01em" }}>Fişly</div>
      </div>

      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <BudgetIllo />
      </div>

      <div style={{ marginBottom: 24 }}>
        <div style={{
          fontFamily: "var(--font-display)", fontWeight: "var(--fw-display)",
          fontSize: 30, lineHeight: 1.1, letterSpacing: "-0.02em", textWrap: "balance",
        }}>
          Bütçeni aşma,<br/>aboneliklerini unutma.
        </div>
        <div style={{ marginTop: 12, fontSize: 15, lineHeight: 1.4, color: "var(--n-text-mid)" }}>
          Aylık limit koy, kategori bazlı takip et. Yaklaşan abonelik ödemelerini önceden gör.
        </div>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        <Button variant="filled" full size="lg">Hesap oluştur</Button>
        <Button variant="ghost" full size="md">Giriş yap</Button>
        <div style={{ display: "flex", justifyContent: "center" }}>
          <PageDots active={2} count={3} />
        </div>
      </div>
    </div>
  );
}

function BudgetIllo() {
  return (
    <div style={{ position: "relative", width: 280, height: 260 }}>
      {/* Mock budget card */}
      <div style={{
        position: "absolute", left: 0, top: 0, width: 280,
        background: "var(--n-surface)", borderRadius: 18, padding: 16,
        border: "1px solid var(--n-outline)", boxShadow: "0 8px 22px -10px rgba(15,15,30,0.12)",
      }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <CategoryAvatar cat="market" size={32} radius={10} />
            <div>
              <div style={{ fontSize: 14, fontWeight: 600 }}>Market</div>
              <div style={{ fontSize: 11, color: "var(--n-text-mid)" }}>₺2.400 / ₺3.000</div>
            </div>
          </div>
          <div style={{ fontSize: 14, fontWeight: 700, color: "#0E8A5F" }}>80%</div>
        </div>
        <ProgressBar value={0.8} color="#0E8A5F" />
      </div>
      {/* Subscription card */}
      <div style={{
        position: "absolute", left: 14, top: 110, width: 252,
        background: "var(--n-surface)", borderRadius: 18, padding: 14,
        border: "1px solid var(--n-outline)", boxShadow: "0 8px 22px -10px rgba(15,15,30,0.12)",
        display: "flex", alignItems: "center", gap: 12,
      }}>
        <div style={{
          width: 36, height: 36, borderRadius: 999,
          background: "#E50914", color: "#FFF",
          display: "flex", alignItems: "center", justifyContent: "center",
          fontWeight: 700, fontSize: 14, fontFamily: "var(--font-display)",
        }}>N</div>
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
            <span style={{ fontSize: 14, fontWeight: 600 }}>Netflix</span>
            <DaysPill days={2} />
          </div>
          <div style={{ fontSize: 11, color: "var(--n-text-mid)" }}>Aylık · 17.05</div>
        </div>
        <div style={{ fontFamily: "var(--font-mono)", fontWeight: 700, fontSize: 13 }}>₺149,99</div>
      </div>
      {/* Bell badge */}
      <div style={{
        position: "absolute", right: -2, bottom: 0,
        width: 48, height: 48, borderRadius: 999,
        background: "var(--accent)", color: "#FFF",
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: "0 8px 18px -4px rgba(91,91,214,0.45)",
      }}>
        <Icon name="bell" size={20} color="#FFF" weight={2.4} />
      </div>
    </div>
  );
}

// ─── Auth: Login ───────────────────────────────────────────────────
function ScrLogin() {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", padding: "64px 24px 32px" }}>
      {/* Back chevron */}
      <div style={{ position: "absolute", left: 12, top: 44, padding: 8 }}>
        <Icon name="chevron_left" size={24} weight={2.4} />
      </div>

      <div style={{ marginTop: 30, marginBottom: 24 }}>
        <BrandMark size={44} />
        <div style={{
          marginTop: 18,
          fontFamily: "var(--font-display)", fontWeight: "var(--fw-display)",
          fontSize: 32, lineHeight: 1.05, letterSpacing: "-0.02em",
        }}>
          Tekrar hoş geldin.
        </div>
        <div style={{ marginTop: 8, fontSize: 14, color: "var(--n-text-mid)" }}>
          Hesabınla devam et, harcamaların seni bekliyor.
        </div>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 14, marginBottom: 20 }}>
        <TextField label="E-posta" value="aysel@fişly.app" type="email" />
        <TextField label="Şifre" value="••••••••" type="password" trailing={<Icon name="eye" size={18} color="var(--n-text-mid)" />} />
        <div style={{ textAlign: "right" }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: "var(--accent)" }}>Şifremi unuttum</span>
        </div>
      </div>

      <Button variant="filled" full size="lg">Giriş yap</Button>

      <div style={{ display: "flex", alignItems: "center", gap: 12, margin: "20px 0", color: "var(--n-text-lo)", fontSize: 12, fontWeight: 600 }}>
        <div style={{ flex: 1, height: 1, background: "var(--n-outline)" }} /> VEYA <div style={{ flex: 1, height: 1, background: "var(--n-outline)" }} />
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        <SocialButton icon="google" label="Google ile devam et" />
        <SocialButton icon="apple" label="Apple ile devam et" />
      </div>

      <div style={{ marginTop: "auto", textAlign: "center", fontSize: 13, color: "var(--n-text-mid)" }}>
        Hesabın yok mu? <span style={{ color: "var(--accent)", fontWeight: 700 }}>Kayıt ol</span>
      </div>
    </div>
  );
}

function TextField({ label, value, placeholder, type = "text", trailing, leading, error }) {
  const hasValue = !!value;
  return (
    <div>
      <label style={{
        display: "block", fontSize: 12, fontWeight: 600, color: "var(--n-text-mid)", marginBottom: 6,
      }}>{label}</label>
      <div style={{
        display: "flex", alignItems: "center", gap: 10,
        height: 52, padding: "0 14px",
        background: "var(--n-surface)",
        border: `1.5px solid ${error ? "var(--n-danger)" : "var(--n-outline)"}`,
        borderRadius: 14,
      }}>
        {leading}
        <input
          type={type === "password" ? "password" : "text"}
          defaultValue={value}
          placeholder={placeholder}
          style={{
            flex: 1, border: "none", outline: "none", background: "transparent",
            fontSize: 15, fontFamily: "var(--font-body)", color: "var(--n-text-hi)",
            fontWeight: 500,
          }}
        />
        {trailing}
      </div>
      {error && <div style={{ marginTop: 6, fontSize: 12, color: "var(--n-danger)", fontWeight: 500 }}>{error}</div>}
    </div>
  );
}

function SocialButton({ icon, label }) {
  return (
    <button style={{
      display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
      height: 52, padding: "0 16px", width: "100%",
      background: "var(--n-surface)",
      border: "1.5px solid var(--n-outline)",
      borderRadius: 14,
      fontSize: 15, fontWeight: 600, fontFamily: "var(--font-body)",
      color: "var(--n-text-hi)", cursor: "pointer",
    }}>
      <Icon name={icon} size={20} color="var(--n-text-hi)" />
      {label}
    </button>
  );
}

// ─── Auth: Register ─────────────────────────────────────────────────
function ScrRegister() {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", padding: "64px 24px 32px" }}>
      <div style={{ position: "absolute", left: 12, top: 44, padding: 8 }}>
        <Icon name="chevron_left" size={24} weight={2.4} />
      </div>

      <div style={{ marginTop: 30, marginBottom: 24 }}>
        <BrandMark size={44} />
        <div style={{
          marginTop: 18,
          fontFamily: "var(--font-display)", fontWeight: "var(--fw-display)",
          fontSize: 32, lineHeight: 1.05, letterSpacing: "-0.02em",
        }}>
          Hesabını oluştur.
        </div>
        <div style={{ marginTop: 8, fontSize: 14, color: "var(--n-text-mid)" }}>
          30 saniyede başla. İlk 30 fiş tarama ücretsiz.
        </div>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        <TextField label="Ad" placeholder="Adın" />
        <TextField label="E-posta" placeholder="seninadin@mail.com" type="email" />
        <TextField
          label="Şifre" value="••••••••" type="password"
          trailing={<Icon name="eye" size={18} color="var(--n-text-mid)" />}
        />
        <PasswordStrength level={2} />
      </div>

      <div style={{ marginTop: 16, display: "flex", alignItems: "flex-start", gap: 10, fontSize: 12, color: "var(--n-text-mid)", lineHeight: 1.4 }}>
        <div style={{
          width: 18, height: 18, borderRadius: 5,
          background: "var(--accent)",
          display: "flex", alignItems: "center", justifyContent: "center",
          flexShrink: 0,
        }}>
          <Icon name="check" size={12} color="#FFF" weight={3} />
        </div>
        <div>
          <span style={{ color: "var(--accent)", fontWeight: 600 }}>Kullanım koşulları</span> ve <span style={{ color: "var(--accent)", fontWeight: 600 }}>gizlilik politikasını</span> kabul ediyorum.
        </div>
      </div>

      <div style={{ marginTop: 24 }}>
        <Button variant="filled" full size="lg">Hesap oluştur</Button>
      </div>

      <div style={{ marginTop: "auto", textAlign: "center", fontSize: 13, color: "var(--n-text-mid)" }}>
        Hesabın var mı? <span style={{ color: "var(--accent)", fontWeight: 700 }}>Giriş yap</span>
      </div>
    </div>
  );
}

function PasswordStrength({ level = 0 }) {
  const colors = ["var(--n-outline)", "#DC2626", "#D97706", "#0E8A5F"];
  const labels = ["", "Zayıf", "Orta", "Güçlü"];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
      <div style={{ display: "flex", gap: 4 }}>
        {[0, 1, 2].map((i) => (
          <div key={i} style={{
            flex: 1, height: 4, borderRadius: 999,
            background: i < level ? colors[level] : "var(--n-outline)",
          }} />
        ))}
      </div>
      {level > 0 && <div style={{ fontSize: 11, color: colors[level], fontWeight: 600 }}>{labels[level]}</div>}
    </div>
  );
}

// ─── Auth: Forgot password ──────────────────────────────────────────
function ScrForgot() {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", padding: "64px 24px 32px" }}>
      <div style={{ position: "absolute", left: 12, top: 44, padding: 8 }}>
        <Icon name="chevron_left" size={24} weight={2.4} />
      </div>

      <div style={{ marginTop: 30, marginBottom: 24 }}>
        <div style={{
          width: 56, height: 56, borderRadius: 16,
          background: "var(--accent-c)",
          display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 18,
        }}>
          <Icon name="lock" size={26} color="var(--accent-onc)" weight={2.2} />
        </div>
        <div style={{
          fontFamily: "var(--font-display)", fontWeight: "var(--fw-display)",
          fontSize: 30, lineHeight: 1.05, letterSpacing: "-0.02em",
        }}>
          Şifreni mi unuttun?
        </div>
        <div style={{ marginTop: 8, fontSize: 14, color: "var(--n-text-mid)", lineHeight: 1.4 }}>
          E-postanı gir, sıfırlama bağlantısını gönderelim.
        </div>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 14, marginBottom: 24 }}>
        <TextField label="E-posta" value="aysel@fişly.app" type="email" />
      </div>

      <Button variant="filled" full size="lg">Bağlantı gönder</Button>

      <div style={{ marginTop: 16, padding: 14, background: "var(--n-surface-c)", borderRadius: 14, fontSize: 12, color: "var(--n-text-mid)", lineHeight: 1.5 }}>
        <strong style={{ color: "var(--n-text-hi)" }}>İpucu:</strong> Mail gelmediyse spam klasörüne bak veya 60 saniye sonra tekrar dene.
      </div>

      <div style={{ marginTop: "auto", textAlign: "center", fontSize: 13, color: "var(--n-text-mid)" }}>
        Hatırladın mı? <span style={{ color: "var(--accent)", fontWeight: 700 }}>Giriş yap</span>
      </div>
    </div>
  );
}

Object.assign(window, {
  ScrOnboardingWelcome, ScrOnboardingScan, ScrOnboardingBudgets,
  ScrLogin, ScrRegister, ScrForgot,
  BrandMark, TextField, PageDots,
});
