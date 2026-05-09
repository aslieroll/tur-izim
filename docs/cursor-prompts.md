# Cursor prompts (Tur İzim)

Bu dosyadaki promptlar Cursor’a verilecek **teknik talimatlardır**. Ürün kararları için öncelikli kaynak **Türkçe** `prd.md`, `business-rules.md` ve `user-flows.md` dokümanlarıdır.

The prompts below may be English for copy-paste into Cursor during implementation.

---

Reusable prompts. Paste and adjust when starting a task.

## Frontend first (Flutter)

> Start with Flutter only. Feature-based clean architecture with repository interfaces; use **mock implementations** returning DTO shapes that match future REST responses from `docs/api-contract.md`. **Do NOT embed authoritative business logic** (suitability math, revision limits, deposit state machine, assignment creation rules) inside UI layer—mirror server decisions from mocked JSON or later real API. Turkish UI labels per `docs/design-system.md`. No in-app upload for draft media—URL fields only.

## Backend (Spring Boot)

> Implement REST slice per `docs/api-contract.md` and entities/migrations aligned to `docs/database-schema.md`. Layered Controller → Service → Repository. Rules in **service layer**: no Match entity; Assignment created only after agency manually accepts Application; creator quota enforced; mock deposit statuses `PENDING`/`HELD`/`RELEASED_AFTER_PUBLICATION`/`FORFEITED`; single revision tied to technical checklist; no Stripe/Iyzico. City-based MVP: agencies provide city and tour departure city manually; student creators provide university, department, class year, and campus/city. No GPS, maps, or automatic location verification.

## Scoring endpoint

> Compute and persist `applications.suitability_score`, `technical_fit_score`, `publication_fit_score`, counts and `missing_requirements_text` per `docs/suitability-score.md` using `tour_requirement_type` vs `creators.capability_*`. List sorted by suitability score descending; **never auto-assign**.

## Stitch

> UI may reference Google Stitch visuals only—do not derive backend or business flows from Stitch. Preserve clean architecture files; forbid feed/chat/booking/streaming layouts.

---

**Project guardrails:** No automatic matching/auto-selection of creators; no social feed/product chat; no hotel/flight booking flows; MVP no real payment providers; link-only drafts/publications.
