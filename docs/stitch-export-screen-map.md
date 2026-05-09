# Stitch Export Screen Map

Kaynak klasör: `stitch-export/stitch_tur_izim_premium_pass`

Bu belge, Google Stitch HTML export ekranlarının Flutter ekran/flow karşılıklarını ve implementasyon öncesi iş kuralı düzeltmelerini listeler. HTML dosyaları taşınmamış, yeniden adlandırılmamış veya değiştirilmemiştir.

Yerel screenshot/image dosyası bulunamadı. Bu nedenle tüm ekranlarda `original screenshot path` alanı `Yok` olarak işaretlenmiştir. HTML içindeki uzak Google görsel URL'leri referans niteliğindedir; proje içine asset olarak alınmamıştır.

## Genel İş Kuralı Düzeltmeleri

- `Kapora` yerine `Depozito` kullanılmalı.
- Tur İzim otel/uçuş rezervasyon ürünü değildir.
- Flight marketplace dili veya uçuş ikonları kullanılmamalı; rota/ulaşım için nötr `route`, `location`, `calendar`, `directions_bus` gibi ikonlar tercih edilmeli.
- Social feed yok.
- Chat yok.
- Video upload yok; içerik teslimi harici cloud/link ile yapılmalı.
- Gerçek ödeme entegrasyonu veya ödeme sağlayıcı UI'ı yok.
- Automatic matching, random assignment veya sistem tarafından otomatik seçim yok.
- Aday Uygunluk Endeksi yalnızca karar destek bilgisidir; final seçim acenteye aittir.
- Yayın public kalma süresi 30 gündür; 6 ay ifadeleri kullanılmamalı.
- Teknik gereksinimler objektif checkbox/radio kriterleri olmalı; subjektif sanatsal beklentiler zorunlu kriter gibi sunulmamalı.

## 01-welcome

- Proposed screen reference name: `01-welcome`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/hoşgeldiniz/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: `WelcomeScreen`
- Role: public
- Important visual patterns: Full-screen premium coastal/sky hero, Warm White overlay, centered serif italic `Tur İzim`, coral/indigo accent divider, glassmorphism button card, Royal Indigo primary CTA, rounded secondary CTA, quiet admin action.
- Important business rule corrections needed: Description copy must remain Tur İzim's operation platform copy; avoid "premium seyahat ağına katılın" if it implies travel agency/network marketplace beyond MVP. Keep no social/feed/chat/booking/payment note where needed.

## 02-creator-open-tours

- Proposed screen reference name: `02-creator-open-tours`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/açık_turlar/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Creator open tours list / creator home tour discovery
- Role: creator
- Important visual patterns: Fixed translucent top app bar, horizontal filter chips, large image-header tour cards, gradient overlay on image, rounded card body, details grid, pill CTA, Deep Navy bottom navigation with Soft Coral active dot.
- Important business rule corrections needed: `Kapora` labels must become `Depozito`. Bottom nav labels should be Turkish. Avoid travel marketplace/booking language; CTA should remain application/detail oriented, not purchase/reservation.

## 03-creator-applications

- Proposed screen reference name: `03-creator-applications`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/başvurularım/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Creator applications list
- Role: creator
- Important visual patterns: Page header with serif display title, segmented control for active/history, compact application cards with thumbnail, status pill, agency/title/date metadata, soft card shadows and bottom navigation.
- Important business rule corrections needed: Statuses must follow application/assignment/deposit lifecycle in source docs. No social feed interactions. Bottom navigation labels should be Turkish.

## 04-creator-application-form

- Proposed screen reference name: `04-creator-application-form`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/başvuru_formu/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Creator tour application form
- Role: creator
- Important visual patterns: Gradient page background, fixed translucent app bar, single rounded form card, label-caps field labels, textarea, URL input, stacked mandatory checkboxes, pill primary submit.
- Important business rule corrections needed: Required consent checkboxes must never be pre-selected. The three required gates must remain: 30-day publication commitment, agency content usage permission, and tour fee request condition if post is removed early. Form criteria must stay objective.

## 05-creator-deposit-confirmation

- Proposed screen reference name: `05-creator-deposit-confirmation`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/depozito_onay/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Creator mock deposit confirmation
- Role: creator
- Important visual patterns: Centered confirmation card, soft background orbs, security icon, large rounded white card, amount summary, selected method row, primary pill CTA and quiet back action.
- Important business rule corrections needed: Remove real payment provider UI language. Do not show credit card, SSL, saved card or real payment wording. This must represent `MockDeposit`: agency acceptance -> `PENDING`, creator final approval -> `HELD`, published post URL submission -> release.

## 06-agency-dashboard

- Proposed screen reference name: `06-agency-dashboard`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/acente_paneli/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency dashboard / agency home
- Role: agency
- Important visual patterns: Header stats chips, primary `Yeni Tur Oluştur` CTA, active tour image cards with category chips, compact new applicant rows, rounded Deep Navy bottom navigation.
- Important business rule corrections needed: Replace "Katılımcı" wording with creator/application/assignment terminology where relevant. Agency manages tours and manually reviews applications; do not imply automatic selection.

## 07-agency-applicants-review

- Proposed screen reference name: `07-agency-applicants-review`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/başvuru_sıralaması/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency applicants review / ranked application list
- Role: agency
- Important visual patterns: Serif display title, applicant cards with avatar, verified badge, AUE number, pill `İncele` action, soft card border, info disclaimer below list.
- Important business rule corrections needed: AUE must be labeled as decision support only. Ranking must not become automatic matching. Final selection belongs to agency.

## 07b-agency-applicants-review-alt

- Proposed screen reference name: `07b-agency-applicants-review-alt`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/aday_değerlendirme/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency applicants review alternate card layout
- Role: agency
- Important visual patterns: Applicant cards with left status stripe, AUE percent, objective criteria rows, warning chips for missing requirements, review CTA, explicit decision-support disclaimer.
- Important business rule corrections needed: Keep objective criteria only. Do not make score an automatic decision. Use `Aday Uygunluk Endeksi` consistently rather than generic "Uygunluk Endeksi" where product docs require AUE.

## 08-agency-candidate-detail

- Proposed screen reference name: `08-agency-candidate-detail`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/aday_detay/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency candidate detail / application detail
- Role: agency
- Important visual patterns: Creator profile header, circular avatar with gradient border, AUE bento card with circular progress, stat cards, portfolio preview grid, approve/reject actions, mobile bottom navigation.
- Important business rule corrections needed: Candidate copy mentions "lüks konaklama"; avoid hotel/accommodation marketplace implication. Portfolio preview must not become social feed. Approval must create/advance an `Assignment` through manual agency decision, not a match.

## 09-admin-dashboard

- Proposed screen reference name: `09-admin-dashboard`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/admin_paneli/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Admin dashboard
- Role: admin
- Important visual patterns: Admin bento stats, pending agency approval list, violation list, icon circles, low-shadow list cards, error accents for violation items.
- Important business rule corrections needed: Typo `Aksiyom Al` should become `Aksiyon Al`. Violation actions must route to manual admin review; no automatic enforcement or automatic payment collection.

## 10-admin-agency-approval

- Proposed screen reference name: `10-admin-agency-approval`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/acente_onay_ekran/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Admin agency approval detail
- Role: admin
- Important visual patterns: Glassmorphism document review layout, bento grid, company info card, documents panel, status pill, approve/reject actions.
- Important business rule corrections needed: Document preview can be UI reference only. Approval flow remains admin/manual. Avoid implying TÜRSAB validation is automated unless backend rules later define it.

## 11-creator-content-delivery

- Proposed screen reference name: `11-creator-content-delivery`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/içerik_teslimi/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Creator content delivery / draft link submission
- Role: creator
- Important visual patterns: Two-column responsive layout, link input card, requirements checklist, gradient info panel, primary submit CTA, fixed app bar and mobile bottom navigation.
- Important business rule corrections needed: This screen is correct directionally because it asks for external cloud/link. Do not add in-app upload. Requirement text may include video format as external deliverable criteria, not upload UI.

## 12-agency-violation-report

- Proposed screen reference name: `12-agency-violation-report`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/ihlal_bildirimi/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency violation report form
- Role: agency
- Important visual patterns: Focused form page, mobile back header, warning badge, large white form card, select, textarea, evidence URL input, warning box, destructive red submit CTA.
- Important business rule corrections needed: Violation should be for post deletion/hidden/archive/inaccessible before 30 days or other defined manual review cases. Avoid broad subjective reasons if not supported by business rules. Admin review remains manual.

## 13-admin-violation-review

- Proposed screen reference name: `13-admin-violation-review`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/ihlal_inceleme_karar/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Admin violation review detail and decision
- Role: admin
- Important visual patterns: Case overview with priority pill, agency report card, creator defense card, system/evidence review list, decision action area with destructive and neutral buttons.
- Important business rule corrections needed: Remove/avoid "ceza kesintisi otomatik yapılacak" implication. MVP has no real money collection. Admin decision is manual; MockDeposit release/hold behavior must follow MVP rules.

## 14-creator-tour-detail

- Proposed screen reference name: `14-creator-tour-detail`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/tur_detaylar/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Creator tour detail
- Role: creator
- Important visual patterns: Large hero image header, glass back/share buttons, title over background transition, chips, agency identity row, route/date cards, financial details card, requirement cards, fixed bottom CTA.
- Important business rule corrections needed: `Gerekli Kapora` must become `Gerekli Depozito`. Avoid flight/hotel booking meaning. Technical requirements like `Drone çekimi zorunludur` should only be allowed if objectively supported by agency criteria and MVP rules.

## 15-agency-create-tour-step-1

- Proposed screen reference name: `15-agency-create-tour-step-1`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/tur_oluştur/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency create tour step 1 / base tour info
- Role: agency
- Important visual patterns: Step indicator, rounded form sections, large rounded inputs with leading icons, financial info section, pill next CTA.
- Important business rule corrections needed: Replace `flight_takeoff` and `flight_land` icons with non-flight travel/route icons. Product is not a flight marketplace. Use `Depozito`, not payment/kapora language. Keep tour creation operational, not booking checkout.

## 16-creator-assignments

- Proposed screen reference name: `16-creator-assignments`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/görevlerim/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Creator assignments / assigned tasks
- Role: creator
- Important visual patterns: Image-header assignment cards, progress stepper, status/action rows, card-level CTA, rounded bottom navigation.
- Important business rule corrections needed: `Ödeme bekleniyor` must not imply real payment. Use `Depozito onayı bekleniyor` or mock deposit state language. `Görevlerim` should correspond to `Assignment`, not match.

## 17-agency-content-review

- Proposed screen reference name: `17-agency-content-review`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/içerik_inceleme/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency draft content review
- Role: agency
- Important visual patterns: Preview card with vertical content mock, external link badge, creator info card, checklist card, approve/revision buttons.
- Important business rule corrections needed: Do not implement video player/upload. Preview should be external-link preview or placeholder only. Checklist items such as visual quality/music are subjective; convert to objective, agreed criteria where possible.

## 18-agency-create-tour-step-2

- Proposed screen reference name: `18-agency-create-tour-step-2`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/içerik_kriterleri_belirleme/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency create tour step 2 / content criteria
- Role: agency
- Important visual patterns: Centered step header, rounded bento form cards, radio cards for format, platform checkbox rows, commitment info panel, pill publish CTA.
- Important business rule corrections needed: `Yayınlanan içeriklerin en az 6 ay platformda kalması` must become 30 days. Avoid disabled/prechecked commitment checkboxes unless they represent fixed platform rules outside creator consent. Criteria must stay objective.

## 19-creator-publication-submit

- Proposed screen reference name: `19-creator-publication-submit`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/yayın_bildirimi/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Creator publication URL submission
- Role: creator
- Important visual patterns: Centered success-style header icon, glass form card, live publication URL input, reminder banner, primary submit button, small visual anchor image/gradient.
- Important business rule corrections needed: Correctly state that published post must remain public for at least 30 days. Submitting URL should trigger mock deposit release flow only when business rules allow it.

## 20-agency-publication-review

- Proposed screen reference name: `20-agency-publication-review`
- Original file path: `stitch-export/stitch_tur_izim_premium_pass/yayın_inceleme/code.html`
- Original screenshot path: Yok
- Flutter screen/flow: Agency publication review / published post verification
- Role: agency
- Important visual patterns: Publication review grid, glass content preview card, URL/platform/date metadata, 30-day commitment progress card, action panel for deposit release approval or violation report.
- Important business rule corrections needed: Do not implement automatic social media monitoring. Publication URL is reviewed manually. If content is deleted/hidden/archive/inaccessible before 30 days, agency can report violation; admin reviews manually.

## Duplicate or Alternate References

Two export folders represent agency applicant review concepts:

- `başvuru_sıralaması/code.html` maps cleanly to `07-agency-applicants-review`.
- `aday_değerlendirme/code.html` is an alternate applicant-card layout and is documented as `07b-agency-applicants-review-alt`.

No duplicate `code.html` files were renamed or moved. Duplicate names are preserved by documenting their parent folder paths.
