# Execution: [Task Name from plan title]

**Status:** In Progress | Blocked | Complete | Partial

> Results are annotated inline: `-- **value**` for discovered values, `-- **passes/FAILED**` for verification.

## Phase 1: [Phase Name]

Depends on: nothing | Parallel with: none | Type: implementation | Projects: [repo-name]

- [ ] [Description from Files Modified table] — `projects/<repo>/path/to/file.ext`

### Phase 1 Verification

- [ ] [Command from plan] — expected: [outcome]

## Phase 2: [Phase Name]

Depends on: Phase 1 | Parallel with: Phase 3 (different repos) | Type: jsonnet | Projects: cluster-monitoring-operator

- [ ] Edit jsonnet source — `projects/cluster-monitoring-operator/jsonnet/components/<component>.libsonnet`
- [ ] Run `make jsonnet-fmt generate` — regenerate assets
- [ ] Verify assets diff is consistent with jsonnet change

### Phase 2 Verification

- [ ] `make jsonnet-fmt generate` produces no additional diff
- [ ] [Command] — expected: [outcome]

---

*Phases 3 and 4 can run in parallel after Phase 2*

---

## Phase 3: [Phase Name]

Depends on: Phase 2 | Parallel with: Phase 4 (different repo) | Type: configuration | Projects: [repo-name]

- [ ] [Description] — `projects/<repo>/path/to/file.ext`

### Phase 3 Verification

- [ ] [Command] — expected: [outcome]

---

## Summary

*N of M phases done. Update the **Status** field at the top of this document to reflect final state.*

### Outstanding items

- [ ] [Items requiring human action]
- [ ] [Items blocked on external dependencies]

### Decisions and Notes

- [Decisions made during execution that deviated from the plan]
- [Issues discovered that may affect future work]
- [Emergent phases added and why]

### Commits and PRs

| Repo | PR/Commit | Branch | Description |
|------|-----------|--------|-------------|
