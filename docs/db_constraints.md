# Database constraints and uniqueness policy

This project enforces several important database-level constraints. This document summarizes them and describes how we handle case-insensitive uniqueness.

Key constraints

- subjects.title: unique (case-insensitive)
  - Implemented via a functional unique index on `LOWER(title)`.
  - Application validation: `validates :title, uniqueness: { case_sensitive: false }` in `Subject` model.

- proposals: unique per subject on `term` (case-insensitive)
  - Implemented via a functional unique index on `(subject_id, LOWER(term))`.
  - Application validation: `validates :term, uniqueness: { scope: :subject_id, case_sensitive: false }` in `Proposal` model.

- votes: unique per (user_id, proposal_id)
  - Implemented with a composite unique index on `(user_id, proposal_id)`.
  - Application validation: `validates :user_id, uniqueness: { scope: :proposal_id }` in `Vote` model.

Self-referential foreign key

- comments.parent_comment_id references comments.id with `ON DELETE SET NULL` behavior.

Migration notes

- Migrations that change uniqueness semantics to be case-insensitive perform the following safely:
  1. Trim / normalize values.
  2. Detect case-only duplicates and resolve them by appending a unique suffix ("_dup<id>") to later rows so an index can be created.
  3. Create a functional unique index (e.g. `LOWER(title)`).

If you need different conflict resolution (for example, prompt users to choose a canonical term), do not run the normalization migrations; instead handle conflicts manually.

Testing / CI

- Make sure the `RAILS_MASTER_KEY` secret is present in CI (this repo stores it as a repo secret). GitHub Actions workflows should set `RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}`.
- To create the test DB locally:

```bash
bin/rails db:create RAILS_ENV=test
bin/rails db:migrate RAILS_ENV=test
```

Contact

If you have questions about constraint choices or want a different conflict resolution strategy, open an issue or ping the team.
