# Question format

## Channel

- **Up to 3 questions:** ask them directly in the conversation. Use the native multiple-choice question mechanism when the harness has one; otherwise write the questions as text in the format below. Once answered, save questions and answers to a round file, in the same format.
- **More than 3 questions:** create the round file in the phase folder, give the user the path, and wait. The user answers in the file itself and tells you when done. Do not repeat the questions in the conversation.

Recommendation: at most 8 questions per round.

## Round file

Name: `question-<phase>-<NN>.md`, in the phase folder, with `<phase>` equal to the folder name (`ideation`, `fr`, `nfr`) and `NN` a two-digit sequence. Example: `ideation/question-ideation-02.md`.

Questions are numbered `Q1`, `Q2`... within each file. Template in `KIT/templates/question.md`.

Questions asked outside the loop phases (profile confirmation, conflict resolution, plan approval, unblocking a task) do not create a round file: they are recorded only in `AUDIT.md`, with the options and the choice.

## Template for each question

```markdown
Q1 - [Question for the user]

Context: [Why the question matters and what it affects]
Door Type: [One-way | Two-way]

Options:
A. (Suggested) [Option recommended by the agent]
B. [Option B]
C. [Option C]
X. Other option. Describe.

Answer:
```

Rules:

- Option A is always the one you suggest. Base the suggestion on the project context and the decisions already made, not on a generic default.
- The option `X. Other option. Describe.` is always present.
- The `Answer:` field is left empty for the user to fill in with the letter or with free text.
- If the question accepts multiple choices, the wording says so explicitly.
- `Context` says what the decision affects in concrete terms (which flows, which screens, what cost), in one or two sentences.
- One question, one decision. Do not combine two decisions in the same question.

In the harness's native mechanism, keep the same content: the suggested option comes first and is marked as suggested, the context and door type appear in the description, and the user can always answer with free text.

## Door Type

The door type is **informational only**: it helps the user calibrate how much attention each decision deserves. It does not change the flow. Ask everything that is relevant and never decide on your own because a decision is two-way.

- **One-way:** hard or expensive to reverse later (data model, database, public API contract, authentication provider).
- **Two-way:** easy to change later (button text, field order, utility library).

## Reading the answers

- Letter: the corresponding option.
- Free text: it is the answer, even if it comes with a letter. In `AUDIT.md`, it goes in the `Input` field.
- Empty: unanswered question. Ask once whether the user wants to answer or leave it open; do not insist.
- An answer that admits more than one reading: it is an ambiguity and follows `conflicts.md`.
