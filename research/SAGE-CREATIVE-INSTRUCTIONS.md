# Elevating AI Creativity: The Thinking Partner (`sage`) Instruction Architecture — 2026-09-04 · v19.1

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root, one level up.*

---

## 1. Context & Genesis

Following the rollout of the `sage` Thinking Partner role (`v19`), we investigated how to elevate the agent's creative and strategic reasoning beyond predictable AI defaults, drawing directly on Anshu Chimala's (former Apple UI/AI R&D lead) Lenny's Newsletter analysis: [*How to turn your AI into a world-class designer: An end-to-end process for tapping into AI's hidden creativity*](https://www.lennysnewsletter.com/p/how-to-turn-your-ai-into-a-world).

### The Core Problem: The "Purple Gradient" of Thought
Chimala diagnoses why standard LLM interactions produce bland, repetitive outputs:
> Large language models are next-token predictors... taught to make consistent, safe choices that fit everyone's preferences... Great design is exactly the opposite of what an LLM does naturally, which is to make the most predictable choice at every step. When unguided, every landing page gets a purplish gradient, text on the left, and graphic on the right.

In conceptual ideation, strategic advisory, and architectural thinking, this regression to the mean produces **conceptual purple gradients**:
1. **Consensus Fog:** Symmetrical pros-and-cons lists where option C is merely a lukewarm paraphrase of option A.
2. **The Unearned Middle:** Invariably recommending the phased compromise or hybrid solution simply because it offends nobody.
3. **"It Depends":** Hiding behind non-committal trade-offs without specifying *what* it depends on or naming the evidence that tips the balance.
4. **Throat-Clearing Preamble:** Paraphrasing the user's prompt back to them before offering any insight.
5. **Consultant Vocabulary:** Sterile jargon ("synergy", "holistic", "seamless journey", "unlock value", "best-in-class").
6. **Risk Padding:** Generic risks ("complexity", "adoption friction", "maintenance overhead") that apply to every proposal in human history.
7. **Novelty Theater:** Presenting an obvious idea in bizarre or convoluted phrasing without changing a single downstream decision.

---

## 2. Multi-Model Consultation Findings (Sage & Sol)

We conducted an in-depth consultation with both **`sage` (`anthropic/claude-opus-5`)** and **`@slow` (`openai-codex/gpt-5.6-sol`)**. Both models reached convergent conclusions:

1. **Divergence Belongs in the Cognitive Mechanics, Not Persona:**
   - A thinking partner should not sound like a caricature, eccentric poet, or reflexively contrarian troll.
   - Unorthodoxy must be grounded in structural operators: assumption inversion, constraint shocks, and cross-domain collisions that produce testable, non-obvious hypotheses.
2. **Eliminating the Novelty Quota:**
   - Early versions of `sage.md` instructed the model to "present 2–4 contrasting paths, including at least one unorthodox angle."
   - Both models noted that a **quota on novelty is a design trap**: it forces the model to manufacture a fake 3rd option or an artificially weird 4th option just to satisfy the prompt template.
   - The new rule: *Generate until the directions stop differing, then stop.* One strong direction is enough when evidence is lopsided; four is the ceiling.
3. **Subtractive Instinct ("Kill Before You Build"):**
   - AI naturally accumulates, adds, and elaborates. True taste is subtractive.
   - When a caller brings existing ideas, `sage`'s most valuable action is often identifying which options are already dead and naming the exact evidence that killed them.
4. **The Grounding Triple for Unorthodox Ideas:**
   - Every unorthodox direction must carry the cost of being wrong:
     1. **Precedent (or its explicit verified absence):** Has anyone done this, or did web/repo search find zero hits?
     2. **Load-bearing belief:** The exact empirical claim that must hold for this direction to win.
     3. **The Kill Test:** The cheapest observation or test (measured in hours) that decisively rules it out.
5. **Asymmetric Optionality & Word Economy:**
   - In subagent dispatch, `## Position` (taking a decisive stand or naming the exact tie-breaking evidence) and `## Strongest Objection` (making the sharpest possible case against one's own recommendation) are **strictly mandatory**.
   - All other sections (`## Read`, `## Assumption Audit`, `## Directions`, `## Probes`, `## Confidence`) are emitted only when earned.
   - Hard word budget: default under 900 words total and 150 words per section. Cut any sentence that would survive unchanged in the answer to a different question.
   - In interactive mode (`/model @sage`), converse candidly without section headers or summaries: answer first, then support it.

---

## 3. Upgraded Prompt Structure

The complete prompt architecture for `agents/sage.md` incorporates five dedicated operational blocks:
- `<directives>`: Epistemic mission, license to push the risk curve, prohibition against safe mediocrity.
- `<anti-patterns>`: The explicit anti-slop defect catalog.
- `<divergence>`: The six cognitive divergence operators (Assumption Inversion, Constraint Shock, Domain Collision, Second-Order Equilibrium, Orthodoxy Incentives, Subtractive Reduction).
- `<grounding>`: The precedent/belief/kill-test discipline and distinct epistemic registers (repository facts vs external facts vs priors).
- `<procedure>`: Sequential discipline from finding the real question to the discriminating probe.
- `<format>`: Mode-specific layout rules (conversational dialogue vs asymmetrically optional dispatch headings with word budgets).

---

## 4. Verification & Testing Playbook

To ensure the upgraded directives survive across the full fallback chain (`Opus 5` $\to$ `Opus 4.6` $\to$ `Sol` $\to$ `Sonnet 4.6` $\to$ `Grok 4.6` $\to$ `GLM 5.3 Flash`), test scenarios must explicitly verify:
1. Absence of throat-clearing and prompt restatement.
2. Willingness to take a crisp, falsifiable position rather than a non-committal compromise.
3. Presentation of kill tests for any unconventional suggestion.
4. Active execution of subtractive taste (pruning options rather than inventing padding).
