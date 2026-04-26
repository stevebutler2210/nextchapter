# ADR-015: Email Address Encryption at Rest

**Date:** 2026-04-26
**Status:** Accepted
**Branch:** feat/encrypt_email

---

## Context

`email_address` is personally identifiable information (PII). Prior to this
change it was stored as plaintext in the `users` table, meaning anyone with
read access to the database (a leaked backup, a compromised replica, a
misconfigured export) could trivially enumerate all user emails.

Email encryption was explicitly deferred during Day 6 UI polish work
(see [JOURNAL.md entry](../JOURNAL.md)) and tracked as a separate hardening
ticket. That ticket is addressed here.

---

## Decision

Encrypt `email_address` at rest using **Active Record Encryption** with
**deterministic AES-256-GCM** encryption:

```ruby
# app/models/user.rb
encrypts :email_address, deterministic: true
```

The three required keys (`primary_key`, `deterministic_key`,
`key_derivation_salt`) are stored in Rails encrypted credentials under the
`active_record_encryption` namespace. They were already present in the
credentials file.

No migration is required — Active Record Encryption stores ciphertext in the
existing `email_address` string column. New writes are encrypted immediately;
any plaintext rows already present in a production database would need a
one-time re-encryption rake task before the key material is rotated, but right now
all environments start from seeds or fixtures as not live yet, so this is fine.

---

## Why deterministic encryption

Active Record Encryption defaults to _non-deterministic_ (randomised IV)
encryption, which provides stronger confidentiality. However, non-deterministic
encrypted values cannot be used in exact-match WHERE clauses — every encryption
of the same value produces a different ciphertext.

`email_address` is used as a lookup key in several places:

- `User.find_by(email_address: ...)` — session sign-in (web + API)
- `User.find_by(email_address: params[:email_address])` — password reset
- `validates :email_address, uniqueness:` — duplicate check

`deterministic: true` instructs Active Record Encryption to use a fixed IV
derived from the `deterministic_key`, so the same plaintext always yields the
same ciphertext. Rails transparently encrypts the search term before issuing
the WHERE clause, so all existing lookup patterns continue to work without
change.

The trade-off accepted here is that deterministic encryption leaks whether two
rows share the same email address (ciphertext equality). Given that email
addresses must be unique in this application, that is already public information
and the trade-off is acceptable.

---

## What is NOT encrypted

`password_digest` is left unencrypted. bcrypt already stores only a slow,
salted hash — not recoverable plaintext — so encrypting the digest column
would add complexity and overhead with no meaningful security benefit.

---

## Consequences

**Benefits**

- Email addresses are encrypted at rest. A read-only database leak no longer
  exposes user email addresses in cleartext.
- All existing query patterns (`find_by`, uniqueness validation, mailer
  recipient) continue to work without modification.

**Costs / considerations**

- **Fixture setup:** Test fixtures must be encrypted consistently. This is
  handled by `config.active_record.encryption.encrypt_fixtures = true` already
  set in `config/environments/test.rb`.
- **Slight query overhead:** Each lookup encrypts the search term before
  issuing SQL. For this application's scale this is negligible.
- **Key management:** Losing the deterministic key means email-based lookups
  fail. Keys must be included in backup and rotation procedures with the same
  care as `secret_key_base`.
- **Re-encryption on key rotation:** Rotating the deterministic key requires
  re-encrypting all existing rows. Active Record Encryption supports this via
  `ActiveRecord::Encryption.rotate` helpers but it was not needed here.

---

## Alternatives considered

| Option                                                             | Reason rejected                                                                                                             |
| ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Non-deterministic encryption                                       | Cannot be used in WHERE clauses; would break sign-in and password reset without significant query refactoring               |
| Application-level hashing (e.g. SHA-256 of email)                  | One-way — prevents displaying the address back to the user; also vulnerable to rainbow-table attacks on known email formats |
| Database-level encryption (e.g. SQLCipher / Fly volume encryption) | Encrypts the whole DB file, not individual columns; does not protect against application-layer data exposure                |
| Third-party gem (e.g. `attr_encrypted`)                            | Active Record Encryption is the Rails-native solution since 7.1; no additional dependency needed                            |
