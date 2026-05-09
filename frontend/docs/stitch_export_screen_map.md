# Stitch `code.html` → Flutter ekran haritası (referans)

Kaynak: `stitch-export/stitch_tur_i_zim_premium_pass/*/code.html`  
Hedef: `frontend/lib` içindeki mevcut `GoRouter` ekranları. HTML **kopyalanmaz**; yalnızca görsel/layout referansı.

| Stitch klasörü | Flutter hedefi | Rota / widget |
|----------------|----------------|---------------|
| `ho_geldiniz` | Karşılama | [`welcome_screen.dart`](../lib/features/auth/presentation/welcome_screen.dart) — `AppRoutes.welcome` |
| `a_k_turlar` | Creator açık ilanlar | [`creator_open_tours_screen.dart`](../lib/features/tours/presentation/creator_open_tours_screen.dart) — `AppRoutes.creatorHome` |
| `tur_detaylar` | Tur detayı | [`creator_tour_detail_screen.dart`](../lib/features/tours/presentation/creator_tour_detail_screen.dart) — `AppRoutes.creatorTour` |
| `ba_vuru_formu` | Başvuru formu | [`creator_application_form_screen.dart`](../lib/features/applications/presentation/creator_application_form_screen.dart) |
| `ba_vurular_m` | Başvurularım | [`creator_my_applications_screen.dart`](../lib/features/applications/presentation/creator_my_applications_screen.dart) |
| `g_revlerim` | Görevler / atamalar | [`creator_my_assignments_screen.dart`](../lib/features/assignments/presentation/creator_my_assignments_screen.dart) |
| `depozito_onay` | Depozito taahhüt | Creator assignment hub alt akışı — `AppRoutes.creatorDeposit` |
| `i_erik_teslimi` | Taslak URL | [`creator_assignment_hub_screen.dart`](../lib/features/assignments/presentation/creator_assignment_hub_screen.dart) / `creatorDraft` |
| `yay_n_bildirimi` | Yayın URL | `creatorPublication` |
| `yay_n_i_nceleme` | Yayın inceleme | Acente / atama hub (mock) |
| `acente_paneli` | Acente özet | [`agency_board_screen.dart`](../lib/features/agency_dashboard/presentation/agency_board_screen.dart) — `AppRoutes.agencyHome` |
| `ba_vuru_s_ralamas` / `aday_de_erlendirme` | Başvuran sıralaması | [`agency_tour_applicants_screen.dart`](../lib/features/applications/presentation/agency_tour_applicants_screen.dart) |
| `aday_detay` | Aday detayı | Henüz ayrı rota yok; başvuran kartı içinde özet |
| `tur_olu_tur` | Tur oluşturma | Henüz tam rota yok; ileride acente tur editörü |
| `i_erik_kriterleri_belirleme` | İçerik kriterleri | Tur oluşturma / gereksinim seçimi ile hizalanır (ileri slice) |
| `i_erik_i_nceleme` | İçerik inceleme | Teslim onay akışı (assignment hub / agency) |
| `acente_onay_ekran` | Acente onayı (admin öncesi) | Admin / agency onboarding — admin akışıyla ilişkili |
| `admin_paneli` | Admin panel | [`admin_placeholder_dashboard_screen.dart`](../lib/features/admin_dashboard/presentation/admin_placeholder_dashboard_screen.dart) |
| `i_hlal_bildirimi` | İhlal bildirimi | Violation feature (mock) |
| `i_hlal_i_nceleme_karar` | İhlal kararı | Admin inceleme (mock) |

**Not:** `creator_shell` / `agency_shell` içinde `NavigationBar` kullanımı varsa, tema [`theme.dart`](../lib/app/theme.dart) içindeki `NavigationBarTheme` ile hizalanır.
