# Dependencies — [NNN-slug]

## Graph

```mermaid
graph TD
  T1["T-1 Sign-up"]
  T2["T-2 Login Flow"]
  T3["T-3 Login Screen"]
  T1 --> T2
  T2 --> T3
```

## Waves

Tasks in the same wave do not depend on each other and can run in parallel.

| Wave | Tasks |
| --- | --- |
| 1 | T-1 |
| 2 | T-2 |
| 3 | T-3 |

## Coverage

| Requirement | Priority | Tasks |
| --- | --- | --- |
| FR-1 | Must | T-1 |
