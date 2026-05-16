// screens-main.jsx — Harcamalar, Özet, Abonelikler, Ayarlar (main 4 tabs)

// ─── Mock data ─────────────────────────────────────────────────────
const MOCK_EXPENSES = [
  { id: 1, merchant: "lunapark",   cat: "eglence",  amount: 500.00, date: "15 Mayıs", time: "21:14" },
  { id: 2, merchant: "Migros",     cat: "market",   amount: 342.80, date: "14 Mayıs", time: "18:02" },
  { id: 3, merchant: "Özbal",      cat: "yeme",     amount: 210.00, date: "11 Mayıs", time: "13:45" },
  { id: 4, merchant: "BİM",        cat: "market",   amount: 187.45, date: "09 Mayıs", time: "19:30" },
  { id: 5, merchant: "Marti",      cat: "ulasim",   amount: 24.50,  date: "08 Mayıs", time: "08:20" },
  { id: 6, merchant: "Eczane Çağdaş", cat: "saglik", amount: 145.20, date: "06 Mayıs", time: "11:10" },
];

const MOCK_CAT_TOTALS = [
  { cat: "eglence",   total: 500.00 },
  { cat: "market",    total: 530.25 },
  { cat: "yeme",      total: 210.00 },
  { cat: "saglik",    total: 145.20 },
  { cat: "ulasim",    total: 24.50 },
  { cat: "faturalar", total: 0 },
  { cat: "diger",     total: 0 },
];

const TOTAL_SPEND = MOCK_CAT_TOTALS.reduce((a, b) => a + b.total, 0);

// ─── Screen 1: Harcamalar ──────────────────────────────────────────
function ScrExpenses() {
  const maxCat = Math.max(...MOCK_CAT_TOTALS.map((c) => c.total)) || 1;
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<MonthPicker value="Mayıs 2026" />}
        title=""
        trailing={<IconButton icon="search" />}
      />

      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 132px" }}>
        {/* Hero total card — dark */}
        <Card dark padding={18} radius={22} style={{
          background: "linear-gradient(135deg, var(--hero-bg) 0%, #232336 100%)",
          marginBottom: 16,
        }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
            <div>
              <div style={{ fontSize: 12, fontWeight: 600, color: "var(--hero-accent)", textTransform: "uppercase", letterSpacing: "0.1em" }}>Toplam Harcama</div>
              <div style={{
                marginTop: 4,
                fontSize: 38, fontWeight: "var(--fw-display)",
                fontFamily: "var(--font-display)",
                letterSpacing: "-0.025em", lineHeight: 1.1,
              }}>{fmtTRY(TOTAL_SPEND)}</div>
              <div style={{ marginTop: 6, fontSize: 13, color: "rgba(255,255,255,0.65)" }}>
                {MOCK_EXPENSES.length} harcama · 5 kategori
              </div>
            </div>
            <div style={{
              padding: "5px 10px", borderRadius: 999,
              background: "rgba(255,255,255,0.08)",
              fontSize: 12, fontWeight: 700,
              display: "inline-flex", alignItems: "center", gap: 4,
              color: "var(--hero-accent)",
            }}>
              <Icon name="arrow_down" size={12} color="var(--hero-accent)" weight={2.4} /> 12%
            </div>
          </div>

          {/* Stacked horizontal segments by category */}
          <div style={{ marginTop: 18 }}>
            <div style={{
              display: "flex", height: 10, borderRadius: 999, overflow: "hidden",
              background: "rgba(255,255,255,0.08)",
            }}>
              {MOCK_CAT_TOTALS.filter((c) => c.total > 0).map((c) => (
                <div key={c.cat} title={CATEGORIES[c.cat].label} style={{
                  width: `${(c.total / TOTAL_SPEND) * 100}%`,
                  background: CATEGORIES[c.cat].color,
                }} />
              ))}
            </div>
            <div style={{ marginTop: 10, display: "flex", flexWrap: "wrap", gap: 8 }}>
              {MOCK_CAT_TOTALS.filter((c) => c.total > 0).slice(0, 4).map((c) => (
                <div key={c.cat} style={{ display: "flex", alignItems: "center", gap: 5, fontSize: 11, color: "rgba(255,255,255,0.8)", fontWeight: 500 }}>
                  <div style={{ width: 8, height: 8, borderRadius: 999, background: CATEGORIES[c.cat].color }} />
                  {CATEGORIES[c.cat].label}
                </div>
              ))}
            </div>
          </div>
        </Card>

        {/* Quick filter chips */}
        <div style={{ display: "flex", gap: 8, marginBottom: 14, overflowX: "auto", paddingBottom: 2 }}>
          {[
            { label: "Tümü", active: true },
            { label: "Market" }, { label: "Eğlence" }, { label: "Yeme-İçme" }, { label: "Faturalar" },
          ].map((f, i) => (
            <div key={i} style={{
              padding: "8px 14px", borderRadius: 999, whiteSpace: "nowrap",
              background: f.active ? "var(--n-text-hi)" : "var(--n-surface)",
              color: f.active ? "#FFF" : "var(--n-text-hi)",
              border: f.active ? "none" : "1px solid var(--n-outline)",
              fontSize: 13, fontWeight: 600,
            }}>{f.label}</div>
          ))}
        </div>

        {/* Expense list grouped by day */}
        <ExpenseDayGroup label="Bugün · 15 Mayıs" total={500.00} items={MOCK_EXPENSES.filter(e => e.date === "15 Mayıs")} />
        <ExpenseDayGroup label="14 Mayıs" total={342.80} items={MOCK_EXPENSES.filter(e => e.date === "14 Mayıs")} />
        <ExpenseDayGroup label="11 Mayıs" total={210.00} items={MOCK_EXPENSES.filter(e => e.date === "11 Mayıs")} />
        <ExpenseDayGroup label="Daha eski" total={357.15} items={MOCK_EXPENSES.filter(e => !["15 Mayıs", "14 Mayıs", "11 Mayıs"].includes(e.date))} />
      </div>

      <FAB icon="plus" />
      <BottomNav active="expenses" />
    </div>
  );
}

function ExpenseDayGroup({ label, total, items }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{
        display: "flex", justifyContent: "space-between", alignItems: "baseline",
        padding: "4px 4px 8px",
      }}>
        <div style={{ fontSize: 12, fontWeight: 700, color: "var(--n-text-mid)", textTransform: "uppercase", letterSpacing: "0.08em" }}>{label}</div>
        <div style={{ fontSize: 12, fontWeight: 600, color: "var(--n-text-lo)", fontFamily: "var(--font-mono)" }}>{fmtTRY(total)}</div>
      </div>
      <Card padding={0} radius={18}>
        {items.map((e, i) => (
          <ExpenseRow key={e.id} {...e} divider={i < items.length - 1} />
        ))}
      </Card>
    </div>
  );
}

function ExpenseRow({ merchant, cat, amount, date, time, divider = true }) {
  const c = CATEGORIES[cat];
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: "12px 14px",
      borderBottom: divider ? "1px solid var(--n-outline-soft)" : "none",
    }}>
      <CategoryAvatar cat={cat} size={40} radius={12} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: "var(--n-text-hi)", letterSpacing: "-0.005em" }}>{merchant}</div>
        <div style={{ fontSize: 12, color: "var(--n-text-mid)", marginTop: 1, display: "flex", alignItems: "center", gap: 6 }}>
          <span>{c.label}</span> <span style={{ opacity: 0.5 }}>·</span> <span>{time}</span>
        </div>
      </div>
      <div style={{ textAlign: "right" }}>
        <div style={{ fontSize: 15, fontWeight: 700, fontFamily: "var(--font-display)", letterSpacing: "-0.01em", color: "var(--n-text-hi)" }}>
          {fmtTRY(amount)}
        </div>
      </div>
    </div>
  );
}

function IconButton({ icon, onClick, color = "var(--n-text-hi)" }) {
  return (
    <div onClick={onClick} style={{
      width: 40, height: 40, borderRadius: 999,
      display: "flex", alignItems: "center", justifyContent: "center",
      background: "var(--n-surface-c)", cursor: "pointer",
    }}>
      <Icon name={icon} size={20} color={color} weight={2} />
    </div>
  );
}

// ─── Screen 2: Özet (Reports) ──────────────────────────────────────
function ScrReports() {
  const positiveCatTotals = MOCK_CAT_TOTALS.filter((c) => c.total > 0).sort((a, b) => b.total - a.total);

  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar
        leading={<MonthPicker value="Mayıs 2026" />}
        title=""
        trailing={<IconButton icon="filter" />}
      />

      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 132px" }}>
        {/* Hero summary card */}
        <Card dark padding={20} radius={22} style={{ marginBottom: 16,
          background: "linear-gradient(135deg, var(--hero-bg) 0%, #232336 100%)",
        }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: "var(--hero-accent)", textTransform: "uppercase", letterSpacing: "0.1em" }}>
            Mayıs 2026 Toplam
          </div>
          <div style={{
            marginTop: 4,
            fontSize: 44, fontWeight: "var(--fw-display)",
            fontFamily: "var(--font-display)",
            letterSpacing: "-0.03em", lineHeight: 1.05,
          }}>{fmtTRY(TOTAL_SPEND)}</div>
          <div style={{ marginTop: 12, display: "flex", gap: 16, color: "rgba(255,255,255,0.7)", fontSize: 13 }}>
            <span><strong style={{ color: "#FFF", fontWeight: 700 }}>6</strong> harcama</span>
            <span><strong style={{ color: "#FFF", fontWeight: 700 }}>5</strong> kategori</span>
            <span style={{ display: "inline-flex", alignItems: "center", gap: 4 }}>
              <Icon name="arrow_down" size={12} color="var(--hero-accent)" weight={2.4} />
              <strong style={{ color: "var(--hero-accent)", fontWeight: 700 }}>12%</strong> ay'a göre
            </span>
          </div>
        </Card>

        {/* 6-month trend */}
        <SectionLabel action={<span style={{ fontSize: 12, color: "var(--accent)", fontWeight: 600 }}>Detay →</span>}>
          Son 6 Ay
        </SectionLabel>
        <Card padding={16} radius={18} style={{ marginBottom: 16 }}>
          <TrendBars />
        </Card>

        {/* Budgets */}
        <SectionLabel action={<span style={{ display: "inline-flex", alignItems: "center", gap: 4, fontSize: 13, color: "var(--accent)", fontWeight: 600 }}><Icon name="filter" size={14} color="var(--accent)" /> Yönet</span>}>
          Bütçeler
        </SectionLabel>
        <div style={{ display: "flex", flexDirection: "column", gap: 10, marginBottom: 16 }}>
          <BudgetRow icon="wallet" iconColor="var(--accent)" label="Genel" spent={1411.95} limit={5000} />
          <BudgetRow cat="market" label="Market" spent={530.25} limit={1500} />
          <BudgetRow cat="yeme" label="Yeme-İçme" spent={210} limit={250} />
        </div>

        {/* Donut */}
        <SectionLabel>Kategori Dağılımı</SectionLabel>
        <Card padding={20} radius={18} style={{ marginBottom: 16 }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
            <DonutChart data={positiveCatTotals} total={TOTAL_SPEND} />
          </div>
        </Card>

        {/* Category breakdown */}
        <Card padding={4} radius={18}>
          {positiveCatTotals.map((c, i) => (
            <CategoryBreakdownRow key={c.cat} cat={c.cat} amount={c.total} percent={c.total / TOTAL_SPEND}
              divider={i < positiveCatTotals.length - 1} />
          ))}
        </Card>
      </div>

      <BottomNav active="reports" />
    </div>
  );
}

function TrendBars() {
  const data = [
    { m: "Ara", v: 0.45 },
    { m: "Oca", v: 0.62 },
    { m: "Şub", v: 0.58 },
    { m: "Mar", v: 0.74 },
    { m: "Nis", v: 0.81 },
    { m: "May", v: 0.69, active: true },
  ];
  const max = 1;
  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", height: 120, gap: 8 }}>
        {data.map((d, i) => (
          <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
            <div style={{ flex: 1, width: "100%", display: "flex", alignItems: "flex-end", justifyContent: "center" }}>
              <div style={{
                width: "70%",
                height: `${(d.v / max) * 100}%`,
                background: d.active ? "var(--accent)" : "var(--accent-c)",
                borderRadius: "6px 6px 4px 4px",
                position: "relative",
              }}>
                {d.active && (
                  <div style={{
                    position: "absolute", top: -22, left: "50%", transform: "translateX(-50%)",
                    fontSize: 10, fontWeight: 700, color: "var(--n-text-hi)",
                    background: "var(--n-surface)", padding: "2px 6px", borderRadius: 6,
                    border: "1px solid var(--n-outline)", whiteSpace: "nowrap",
                  }}>₺1.412</div>
                )}
              </div>
            </div>
            <div style={{ fontSize: 11, fontWeight: 600, color: d.active ? "var(--n-text-hi)" : "var(--n-text-mid)" }}>{d.m}</div>
          </div>
        ))}
      </div>
      <div style={{ marginTop: 14, paddingTop: 14, borderTop: "1px solid var(--n-outline-soft)", display: "flex", justifyContent: "space-between", fontSize: 12 }}>
        <div style={{ color: "var(--n-text-mid)" }}>Ortalama: <strong style={{ color: "var(--n-text-hi)" }}>₺1.587</strong></div>
        <div style={{ color: "var(--n-text-mid)" }}>En yüksek: <strong style={{ color: "var(--n-text-hi)" }}>₺1.892 (Nis)</strong></div>
      </div>
    </div>
  );
}

function BudgetRow({ cat, icon, iconColor, label, spent, limit }) {
  const pct = spent / limit;
  const left = limit - spent;
  const status = pct >= 1 ? "danger" : pct >= 0.8 ? "warn" : "ok";
  const color = status === "danger" ? "var(--n-danger)" : status === "warn" ? "var(--n-warn)" : "var(--n-ok)";
  return (
    <Card padding={14} radius={16}>
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 10 }}>
        {cat ? <CategoryAvatar cat={cat} size={36} radius={10} /> : (
          <div style={{
            width: 36, height: 36, borderRadius: 10,
            background: tint(iconColor === "var(--accent)" ? "#5B5BD6" : iconColor, 0.14),
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <Icon name={icon} size={18} color={iconColor} />
          </div>
        )}
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 14, fontWeight: 600, color: "var(--n-text-hi)" }}>{label}</div>
          <div style={{ fontSize: 11, color: "var(--n-text-mid)", marginTop: 1 }}>{fmtTRY(spent)} / {fmtTRY(limit)}</div>
        </div>
        <div style={{ textAlign: "right" }}>
          <div style={{ fontSize: 14, fontWeight: 700, color }}>{Math.round(pct * 100)}%</div>
          <div style={{ fontSize: 10, color: "var(--n-text-lo)", marginTop: 1, fontWeight: 500 }}>
            {left >= 0 ? `Kalan ${fmtTRY(left)}` : `Aşım ${fmtTRY(-left)}`}
          </div>
        </div>
      </div>
      <ProgressBar value={Math.min(1, pct)} color={color} height={6} />
    </Card>
  );
}

function DonutChart({ data, total }) {
  const size = 200;
  const stroke = 28;
  const r = (size - stroke) / 2;
  const cx = size / 2, cy = size / 2;
  const circumference = 2 * Math.PI * r;
  let offset = 0;
  return (
    <div style={{ position: "relative", width: size, height: size }}>
      <svg width={size} height={size}>
        <circle cx={cx} cy={cy} r={r} fill="none" stroke="var(--n-outline-soft)" strokeWidth={stroke} />
        {data.map((d, i) => {
          const pct = d.total / total;
          const len = pct * circumference;
          const dasharray = `${len} ${circumference - len}`;
          const dashoffset = -offset;
          offset += len;
          return (
            <circle key={i} cx={cx} cy={cy} r={r} fill="none"
              stroke={CATEGORIES[d.cat].color}
              strokeWidth={stroke}
              strokeDasharray={dasharray}
              strokeDashoffset={dashoffset}
              transform={`rotate(-90 ${cx} ${cy})`}
            />
          );
        })}
      </svg>
      <div style={{
        position: "absolute", inset: 0,
        display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
        textAlign: "center",
      }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: "var(--n-text-mid)", letterSpacing: "0.08em", textTransform: "uppercase" }}>Toplam</div>
        <div style={{ fontSize: 22, fontWeight: 700, fontFamily: "var(--font-display)", letterSpacing: "-0.02em", marginTop: 2 }}>
          {fmtTRY(total)}
        </div>
        <div style={{ fontSize: 10, color: "var(--n-text-lo)", marginTop: 2 }}>{data.length} kategori</div>
      </div>
    </div>
  );
}

function CategoryBreakdownRow({ cat, amount, percent, divider }) {
  const c = CATEGORIES[cat];
  return (
    <div style={{ padding: "12px 14px", borderBottom: divider ? "1px solid var(--n-outline-soft)" : "none" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 8 }}>
        <CategoryAvatar cat={cat} size={32} radius={10} />
        <div style={{ flex: 1, fontSize: 14, fontWeight: 600 }}>{c.label}</div>
        <div style={{ fontSize: 12, color: "var(--n-text-mid)", fontVariantNumeric: "tabular-nums" }}>{(percent * 100).toFixed(1)}%</div>
        <div style={{ fontSize: 14, fontWeight: 700, fontFamily: "var(--font-display)", letterSpacing: "-0.01em", minWidth: 80, textAlign: "right" }}>{fmtTRY(amount)}</div>
      </div>
      <ProgressBar value={percent} color={c.color} height={4} />
    </div>
  );
}

// ─── Screen 3: Abonelikler ──────────────────────────────────────────
const MOCK_SUBS = [
  { id: 1, name: "Netflix", color: "#E50914", amount: 149.99, period: "Aylık", nextDate: "17.05.2026", daysUntil: 2, cat: "eglence" },
  { id: 2, name: "Spotify Family", color: "#1DB954", amount: 79.99, period: "Aylık", nextDate: "22.05.2026", daysUntil: 7, cat: "eglence" },
  { id: 3, name: "Claude Pro", color: "#D97706", amount: 800.00, period: "Aylık", nextDate: "10.06.2026", daysUntil: 26 },
  { id: 4, name: "Disney+", color: "#0E51A8", amount: 89.99, period: "Aylık", nextDate: "01.06.2026", daysUntil: 17, cat: "eglence" },
  { id: 5, name: "iCloud+", color: "#999999", amount: 19.99, period: "Aylık", nextDate: "28.05.2026", daysUntil: 13 },
];

const MOCK_SUBS_CANCELLED = [
  { id: 9, name: "YouTube Premium", color: "#FF0000", amount: 57.99, period: "Aylık" },
];

function ScrSubscriptions() {
  const monthlyTotal = MOCK_SUBS.reduce((a, s) => a + s.amount, 0);
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar title="Abonelikler" />

      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 132px" }}>
        {/* Total banner */}
        <Card dark padding={20} radius={22} style={{ marginBottom: 18,
          background: "linear-gradient(135deg, var(--hero-bg) 0%, #232336 100%)",
        }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: "var(--hero-accent)", textTransform: "uppercase", letterSpacing: "0.1em" }}>
            Aylık Abonelik Toplamı
          </div>
          <div style={{
            marginTop: 4,
            fontSize: 38, fontWeight: "var(--fw-display)",
            fontFamily: "var(--font-display)",
            letterSpacing: "-0.025em", lineHeight: 1.1,
          }}>{fmtTRY(monthlyTotal)}</div>

          {/* Upcoming this week mini section */}
          <div style={{
            marginTop: 16, paddingTop: 14, borderTop: "1px solid rgba(255,255,255,0.1)",
            display: "flex", justifyContent: "space-between", alignItems: "center",
          }}>
            <div>
              <div style={{ fontSize: 11, color: "rgba(255,255,255,0.6)", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.06em" }}>Bu hafta</div>
              <div style={{ fontSize: 13, color: "#FFF", marginTop: 2, fontWeight: 500 }}>2 ödeme · ₺229,98</div>
            </div>
            <Icon name="bell" size={20} color="var(--hero-accent)" />
          </div>
        </Card>

        <SectionLabel>Aktif ({MOCK_SUBS.length})</SectionLabel>
        <Card padding={0} radius={18} style={{ marginBottom: 18 }}>
          {MOCK_SUBS.map((s, i) => (
            <SubscriptionRow key={s.id} {...s} divider={i < MOCK_SUBS.length - 1} />
          ))}
        </Card>

        <SectionLabel>İptal edilmiş</SectionLabel>
        <Card padding={0} radius={18}>
          {MOCK_SUBS_CANCELLED.map((s, i) => (
            <SubscriptionRow key={s.id} {...s} divider={false} cancelled />
          ))}
        </Card>
      </div>

      <FAB icon="plus" />
      <BottomNav active="subscriptions" />
    </div>
  );
}

function SubscriptionRow({ name, color, amount, period, nextDate, daysUntil, cat, cancelled, divider }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: "14px 14px",
      borderBottom: divider ? "1px solid var(--n-outline-soft)" : "none",
      opacity: cancelled ? 0.55 : 1,
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 12,
        background: color, color: "#FFF",
        display: "flex", alignItems: "center", justifyContent: "center",
        fontWeight: 700, fontSize: 15, fontFamily: "var(--font-display)",
        flexShrink: 0,
      }}>{name.charAt(0)}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
          <span style={{
            fontSize: 15, fontWeight: 600, color: "var(--n-text-hi)",
            textDecoration: cancelled ? "line-through" : "none",
          }}>{name}</span>
          {!cancelled && daysUntil !== undefined && <DaysPill days={daysUntil} />}
        </div>
        <div style={{ fontSize: 12, color: "var(--n-text-mid)", marginTop: 2 }}>
          {cancelled ? `${period} · İptal edildi` : `${period} · Sonraki: ${nextDate}`}
        </div>
      </div>
      <div style={{ textAlign: "right", display: "flex", alignItems: "center", gap: 10 }}>
        <div style={{ fontSize: 15, fontWeight: 700, fontFamily: "var(--font-display)", letterSpacing: "-0.01em" }}>
          {fmtTRY(amount)}
        </div>
        <Icon name="more_v" size={18} color="var(--n-text-lo)" />
      </div>
    </div>
  );
}

// ─── Screen 4: Ayarlar ──────────────────────────────────────────────
function ScrSettings() {
  return (
    <div style={{ height: "100%", overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <AppBar title="Ayarlar" />

      <div style={{ flex: 1, overflowY: "auto", padding: "0 16px 132px" }}>
        {/* Profile card */}
        <Card padding={16} radius={18} style={{ marginBottom: 18, display: "flex", alignItems: "center", gap: 14 }}>
          <div style={{
            width: 56, height: 56, borderRadius: 999,
            background: "linear-gradient(135deg, var(--accent) 0%, var(--accent-dim) 100%)",
            display: "flex", alignItems: "center", justifyContent: "center",
            color: "#FFF", fontSize: 22, fontWeight: 700, fontFamily: "var(--font-display)",
            flexShrink: 0,
          }}>A</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 16, fontWeight: 700, color: "var(--n-text-hi)", letterSpacing: "-0.01em" }}>Aysel Yıldırım</div>
            <div style={{ fontSize: 13, color: "var(--n-text-mid)", marginTop: 2 }}>aysel@fişly.app</div>
            <div style={{ marginTop: 8, display: "flex", gap: 6 }}>
              <span style={{
                padding: "2px 8px", borderRadius: 999,
                background: "var(--accent-c)", color: "var(--accent-onc)",
                fontSize: 10, fontWeight: 700,
                display: "inline-flex", alignItems: "center", gap: 4,
              }}>
                <Icon name="sparkle" size={10} color="var(--accent-onc)" />
                Pro
              </span>
              <span style={{ padding: "2px 8px", borderRadius: 999, background: "var(--n-surface-c)", color: "var(--n-text-mid)", fontSize: 10, fontWeight: 600 }}>
                12 / 30 tarama
              </span>
            </div>
          </div>
          <Icon name="chevron_right" size={20} color="var(--n-text-lo)" weight={2.2} />
        </Card>

        <SectionLabel>Hesap</SectionLabel>
        <Card padding={0} radius={18} style={{ marginBottom: 18 }}>
          <SettingsRow icon="user" title="Profil" subtitle="İsim ve e-posta" />
          <SettingsRow icon="lock" title="Şifre değiştir" />
          <SettingsRow icon="bell" title="Bildirimler" subtitle="Hatırlatıcılar açık" last />
        </Card>

        <SectionLabel>Bütçe</SectionLabel>
        <Card padding={0} radius={18} style={{ marginBottom: 18 }}>
          <SettingsRow icon="wallet" title="Bütçeler" subtitle="Aylık ve kategori bazlı limitler" />
          <SettingsRow icon="shapes" title="Kategoriler" subtitle="Sistem ve özel kategoriler" last />
        </Card>

        <SectionLabel>Destek</SectionLabel>
        <Card padding={0} radius={18} style={{ marginBottom: 18 }}>
          <SettingsRow icon="feedback" title="Geri bildirim / Şikayet" subtitle="Görüş, öneri ve hata bildirimi" />
          <SettingsRow icon="chat" title="Yardım merkezi" last />
        </Card>

        {/* Sign out */}
        <Card padding={0} radius={18}>
          <div style={{
            display: "flex", alignItems: "center", gap: 12,
            padding: "16px",
            color: "var(--n-danger)",
            fontWeight: 600, fontSize: 15,
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 12,
              background: "rgba(220,38,38,0.1)",
              display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <Icon name="logout" size={18} color="var(--n-danger)" />
            </div>
            Hesaptan çıkış
          </div>
        </Card>

        <div style={{ marginTop: 16, textAlign: "center", fontSize: 11, color: "var(--n-text-lo)", fontWeight: 500 }}>
          Fişly v1.2.0 · Made in İstanbul
        </div>
      </div>

      <BottomNav active="settings" />
    </div>
  );
}

function SettingsRow({ icon, title, subtitle, last = false, trailing }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: "14px 16px",
      borderBottom: last ? "none" : "1px solid var(--n-outline-soft)",
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 12,
        background: "var(--n-surface-c)",
        display: "flex", alignItems: "center", justifyContent: "center",
      }}>
        <Icon name={icon} size={18} color="var(--n-text-hi)" />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: "var(--n-text-hi)" }}>{title}</div>
        {subtitle && <div style={{ fontSize: 12, color: "var(--n-text-mid)", marginTop: 2 }}>{subtitle}</div>}
      </div>
      {trailing ?? <Icon name="chevron_right" size={20} color="var(--n-text-lo)" weight={2.2} />}
    </div>
  );
}

Object.assign(window, {
  ScrExpenses, ScrReports, ScrSubscriptions, ScrSettings,
  ExpenseRow, BudgetRow, DonutChart, TrendBars, SubscriptionRow,
  SettingsRow, IconButton, ExpenseDayGroup, CategoryBreakdownRow,
  MOCK_EXPENSES, MOCK_CAT_TOTALS, TOTAL_SPEND, MOCK_SUBS,
});
