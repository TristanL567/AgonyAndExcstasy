# Contains learnings from previous slides

# Important Considerations

- Ein Absatz beginnt mit einem Topic Sentence, der klar angibt, was im Absatz behandelt wird
- Ein Absatz stellt einen vollständigen und eigenständigen Sinnabschnitt dar

# Abstract

- Themenbereich, ggf. Forschungslücke
- Spezifische Forschungsfrage
- Hauptargument(e), d.h. abhängig von der Art der Arbeit Informationen zu Theorie/Methode/Daten
- Resultate
- Fazit/Implikationen

# Introduction

- Angaben zum Ziel und Nutzen der Arbeit (d.h. Angaben zur wissenschaftlichen Fragestellung; typische
Sätze hierzu wären „Ziel der vorliegenden Arbeit ist es...“, „Diese Arbeit analysiert...“)
- Identifizierung und Benennung der Forschungslücke
- Erforderliche Hintergrundinformationen (d.h. Informationen zum Themenbereich, Hinweis auf die
bestehende Literatur, Herausarbeiten einer Forschungslücke)
- Angaben zur inhaltlichen Abgrenzung und Positionierung der Arbeit (d.h. Angaben zu verwendeten
Theorien und/oder Methoden; Informationen zum Datensatz und der verwendeten Stichprobe)
- Ggf. weitere Angaben zu Resultaten oder der Struktur der Arbeit
Hinweis: Weiterführende Informationen dazu finden sich in Reid (2018, S. 157-166)
Wichtig: Die Einleitung soll beim Leser nur Erwartungen wecken, die beim Lesen der anderen Kapitel dann auch
erfüllt werden

- Ziel: Leser ins Thema/wissenschaftliche Fragestellung/methodisches Vorgehen einführen und zum Lesen der
Arbeit motivieren

# Main Part

- Theorie: theoretische Grundlagen und ggfl. Hypothesen zu theoretisch erwarteten 
Zusammenhängen/Effekten (implizit oder explizit)
- Literaturrückblick: Aufarbeitung des aktuellen Stands der Forschung (oft auch kein eigenes Kapitel sondern 
Teil der Einleitung)
- Methode: Methodisches Vorgehen
- Daten: Datensatz, Stichprobe, Variablen und Operationalisierungen
- Resultate: Zentrale Ergebnisse und Interpretation (hinsichtlich Fragestellung und im Vergleich bestehender 
Literatur)
- Ziel: Leser mit einer gut strukturierten Argumentationsabfolge auf die Schlussfolgerung hinführen. Oder nach
Reid (2018, S. 168): „After reading the entire body of a paper, the reader should be convinced that your
argument is the only argument — or the best. In other words, by the time the reader reaches the conclusions,
the reader should already know or have guessed what those conclusions are and be convinced of their
accuracy.

# Draft structure

## Evaluation of current brainstorm

The current draft already captures the main empirical blocks: methodology, robustness checks, modelling, and index construction. However, it is still organized mainly by project workflow rather than by thesis argument. The risk is that the thesis becomes a chronological project report instead of a structured academic argument.

The most important missing elements are:

- **Research gap and contribution:** The draft needs an explicit statement of what the thesis adds beyond Tewari et al. (2024), bankruptcy-prediction papers, and concentrated-stock-risk papers.
- **Literature integration:** Papers should not be summarized separately. Each paper should support, qualify, or challenge a thesis claim.
- **Label logic and data audit:** The cleaned observable firm-year panel, removal of scaffold rows, and treatment of unresolved labels are central enough to be part of the methodology story.
- **Metric interpretation:** AP, AUC, and fixed-FPR recall need to be explained as rare-event metrics, especially relative to base prevalence.
- **Prediction vs portfolio distinction:** Strong model ranking does not automatically imply index alpha. The thesis needs a clear bridge from ML scores to portfolio rules.
- **Alternative explanations:** Index performance may reflect reweighting, factor exposure, volatility, quality, distress, size, or value effects rather than pure CSI avoidance.
- **Sensitivity and robustness logic:** Robustness should be framed around why the conclusions survive changes in label parameters, model choices, and index-construction assumptions.

The revised structure below keeps the empirical workflow, but turns it into an argument-driven thesis outline.

# Abstract

The abstract should be written last. It should contain:

- Topic and research gap.
- Research question.
- Data and methodology.
- Key model results.
- Key index-construction results.
- Contribution and limitations.

# Introduction

## Motivation

- Concentrated stock losses and catastrophic stock implosions are economically relevant for investors.
- Cembalest (2014, 2024) motivates the practical importance of avoiding extreme single-stock losses.
- The thesis frames CSI not only as a prediction task, but as a potential index-construction input.

## Research gap

- Prior distress and bankruptcy literature shows that severe firm outcomes are partly predictable.
- Existing work mainly focuses on bankruptcy/default prediction or statistical classification performance.
- Less is known about whether market-based CSI risk scores improve investable index construction after turnover, transaction costs, and attribution analysis.

## Research question

Suggested main research question:

> Can market-based Catastrophic Stock Implosion risk scores improve benchmark-relative index construction after accounting for prediction quality, transaction costs, and portfolio reweighting effects?

Possible subquestions:

- How reliably can Temporary-CSI and Permanent-CSI labels be predicted using firm-level, market-based, macroeconomic, and latent features?
- Which model families provide the strongest rare-event ranking performance?
- Do CSI-based exclusion strategies improve index performance after transaction costs?
- Are gains driven by avoiding true CSI events, or by broader reweighting and distress-quality effects?

## Contribution

The thesis contribution should be stated explicitly:

- Reconstructs Temporary-CSI and Permanent-CSI labels on a cleaned CRSP/Compustat/FRED dataset.
- Removes artificial scaffold rows and evaluates models on observable firm-years.
- Benchmarks AutoGluon and XGBoost for rare-event CSI prediction.
- Separates statistical prediction metrics from portfolio-level economic usefulness.
- Converts CSI risk scores into index-construction rules and evaluates performance, turnover, transaction costs, and attribution.

# Main Part

## 1. Literature and Conceptual Positioning

This section should not be a paper-by-paper literature review. It should be a claim-based review. Each paper should support a specific thesis claim.

### 1.1 Paper-to-thesis contribution ladder

Create a table that classifies the role of each paper:

| Paper | Motivation | Label construction | Feature design | Model choice | Validation | Index construction | Limitations |
|---|---:|---:|---:|---:|---:|---:|---:|
| Cembalest2014 | Yes | Partial | No | No | No | Yes | Yes |
| Cembalest2024 | Yes | Partial | No | No | No | Yes | Yes |
| Shumway1997 | No | Yes | No | No | Partial | No | Yes |
| Shumway2001 | No | Partial | Yes | Partial | Yes | No | Yes |
| Campbell2008 | No | Partial | Yes | No | Yes | No | Yes |
| Barboza2017 | No | No | Yes | Yes | Yes | No | Partial |
| AlanisChavaSha2022 | No | No | Yes | Yes | Yes | No | Yes |
| Grinsztajn2022 | No | No | No | Yes | Partial | No | Yes |
| Penman2018 | No | No | Yes | No | No | Yes | Yes |
| Hutton2009 | No | No | Partial | No | No | Partial | Yes |

For each paper, write one sentence:

> This paper is used to justify [X], but it does not establish [Y].

### 1.2 Methodological inheritance map

Use this section to show which parts of the thesis are inherited, adapted, or newly contributed.

| Thesis component | Literature source | What the literature gives | What this thesis changes |
|---|---|---|---|
| Concentrated stock loss motivation | Cembalest2014, Cembalest2024 | Economic relevance of large single-stock losses | Connects the motivation to CSI prediction and index construction |
| CSI crash/non-recovery label | Tewari2024 | Market-path crash and non-recovery framework | Rebuilds the label on cleaned CRSP data |
| Bankruptcy/delisting evidence | Shumway1997, Shumway2001 | Delisting and distress prediction foundations | Uses delisting evidence as confirmation, not as a standalone label |
| Market-based distress predictors | Campbell2008, Shumway2001 | Market and accounting variables predict distress | Combines CRSP, Compustat, FRED, and engineered features |
| ML model choice | Barboza2017, AlanisChavaSha2022 | Tree models and ML are strong in bankruptcy prediction | Benchmarks AutoGluon, XGBoost, and VAE-augmented feature sets |
| Rare-event validation | AlanisChavaSha2022 | Time-ordered validation and rare-event setup | Uses AP, AUC, and fixed-FPR recall |
| Portfolio application | Cembalest2014, Penman2018 | Economic relevance of avoiding weak or distressed firms | Tests investable exclusion rules with transaction costs and attribution |

### 1.3 Claim-evidence matrix

Use this section to build the thesis red-line.

| Claim ID | Thesis claim | Type | Supporting papers | Qualifying papers | Thesis implication |
|---|---|---|---|---|---|
| C1 | Catastrophic single-stock losses are economically important. | Motivation | Cembalest2014, Cembalest2024 | Penman2018 | Motivates CSI as an investor-relevant problem |
| C2 | Severe firm distress is partly predictable using market and accounting data. | Core | Shumway2001, Campbell2008 | Hutton2009 | Justifies predictive modelling |
| C3 | ML models are suitable for rare distress prediction. | Method | Barboza2017, AlanisChavaSha2022 | Grinsztajn2022 | Justifies AutoGluon and XGBoost |
| C4 | CSI is related to, but not identical with, bankruptcy. | Core | Tewari2024, Shumway1997 | Campbell2008 | Justifies separate Temporary-CSI and Permanent-CSI labels |
| C5 | Strong statistical prediction does not automatically imply index alpha. | Limitation | AlanisChavaSha2022, Penman2018 | Cembalest2014 | Requires portfolio-level evaluation |
| C6 | Index gains may reflect reweighting or factor exposure. | Limitation | Penman2018, Hutton2009 | JiangMaZhu2024 | Requires attribution and robustness checks |

### 1.4 Theme synthesis memos

Before writing the final literature section, create short synthesis memos for:

- Market-based distress labels.
- Rare-event ML prediction.
- Model validation metrics.
- Temporary-CSI vs Permanent-CSI.
- Prediction vs index construction.
- Limitations and alternative explanations.

Each memo should follow this template:

```markdown
## Core argument

## Literature evidence

## Tension or gap

## Thesis position

## Thesis-ready paragraph
```

This process converts papers into thesis arguments instead of isolated summaries.

## 2. Empirical Methodology

### Machine-Learning Problem

- Define the prediction task as an annual rare-event classification problem.
- The model estimates the probability that firm `i` receives a CSI label in the next labelled period.
- Explain that the task is mainly a ranking problem because index construction uses predicted risk scores.

### Optimization metrics and models

- Explain why accuracy is not useful for rare events.
- Explain AP relative to base prevalence.
- Explain AUC as broad ranking quality.
- Explain recall at fixed FPR as an economically interpretable screening metric.
- Describe AutoGluon and XGBoost as non-linear tree-based approaches suited to tabular financial data.

### WRDS (CRSP and Compustat) and FRED

- CRSP defines prices, returns, delistings, market capitalization, and the investable equity universe.
- Compustat provides accounting fundamentals.
- FRED provides macroeconomic variables.
- The final panel is annual, but labelling uses monthly price paths.
- Include the cleaned observable firm-year panel and explain why scaffold rows were removed.

### Classification Methodology

- Present Temporary-CSI and Permanent-CSI separately.
- Define wealth index, trailing peak, drawdown, crash threshold `C`, recovery threshold `M`, and confirmation window `T`.
- Explain annual label alignment: event year minus one.
- Explain unresolved labels and why they are not forced to `y = 0`.

### Feature Construction

- Group features into market variables, accounting variables, macro variables, interaction terms, and latent VAE features.
- Explain why each feature family is theoretically relevant.
- Link feature families to the literature:
  - Market variables: Campbell2008, Shumway2001.
  - Accounting variables: Altman-style and bankruptcy literature.
  - Macro variables: distress-cycle and regime motivation.
  - Latent features: dimensionality reduction and non-linear representation.

## 3. Robustness Checks

### Bankruptcy and delisting validation

- Explain how CRSP delisting codes validate or qualify CSI events.
- Make clear that bankruptcy/delisting is not a standalone label.

### Recovery bucket analysis

- Explain whether CSI-classified firms recover over the five-year horizon.
- Use this to test whether CSI captures persistent decline rather than short-lived volatility.

### Revisions to Temporary-CSI

- Explain why the revised Temporary-CSI label includes additional terminal-failure logic.
- Show how the revision changes coverage and interpretation.

### Permanent-CSI robustness

- Explain why Permanent-CSI is rarer and stricter.
- Discuss unresolved labels and the role of long-horizon capital loss.

### Sensitivity analysis

- Use alternative `C`, `M`, and `T` combinations to show whether conclusions depend on one parameter choice.
- Interpret sensitivity as label robustness, not as model optimization.

## 4. Modelling

### CV-method

- Explain the time-ordered training, validation, and test setup.
- Explain why random splits are inappropriate in finance.
- Explain the role of OOS years: primarily index construction, not the central model-selection statement.

### Modelling results: Temporary-CSI

- Present AP, AUC, and fixed-FPR recall.
- Interpret AP relative to the base prevalence.
- Compare raw, expanded, latent, and VAE-augmented datasets.
- State whether the best model is a clear winner or only a marginal improvement.

### Modelling results: Permanent-CSI

- Emphasize that Permanent-CSI is harder because positives are rarer.
- Compare AP to lower base prevalence.
- Explain why similar AUC can coexist with lower AP.
- Avoid overclaiming if models are close in performance.

## 5. Index Construction

### Methodology

- Convert annual risk scores into exclusion or downweighting rules.
- Define thresholds: FPR-based, Youden, or other chosen rules.
- Explain rebalancing frequency, benchmark universe, transaction costs, and turnover.
- Make clear that this is an economic test beyond pure prediction.

### Index-Construction results: Temporary-CSI

- Report benchmark-relative returns, volatility, Sharpe ratio, drawdowns, turnover, and transaction-cost-adjusted results.
- Interpret whether gains come from true CSI avoidance or broader screening.

### Active Contribution and Error-Cost Analysis

- Decompose performance into true-positive avoidance, false-positive cost, and retained-stock reweighting.
- This is crucial for answering whether the model creates value through CSI detection or through generic reweighting.

### Index-Construction results: Permanent-CSI

- Treat Permanent-CSI separately because events are rarer and true-positive benchmark weights may be small.
- Avoid claiming pure event avoidance if alpha mainly comes from reweighting.

### Active Contribution and Error-Cost Analysis

- Repeat the attribution logic for Permanent-CSI.
- Discuss whether the result is economically meaningful despite low event frequency.

### Sensitivity Analysis

- Test whether index results survive alternative label parameters, thresholds, and cost assumptions.
- Connect this back to the robustness checks.

## 6. Discussion and Limitations

### Main interpretation

- The thesis should distinguish three statements:
  1. CSI labels can be predicted to some degree.
  2. CSI scores can be used for index construction.
  3. Index performance may or may not be caused by direct CSI avoidance.

### Alternative explanations

- Reweighting effects.
- Size, quality, value, volatility, or distress factor exposure.
- Low benchmark weight of true-positive CSI firms.
- Threshold sensitivity.
- Data and label-construction choices.

### Relation to literature

- Compare findings to Tewari et al. (2024), but avoid direct one-to-one claims if datasets, denominators, or metric definitions differ.
- Use bankruptcy-prediction literature as adjacent evidence, not direct CSI evidence.
- Use index and concentrated-stock literature to justify economic relevance.

## 7. Conclusion

- Answer the research question directly.
- Summarize prediction findings and index-construction findings separately.
- State the main contribution.
- State the main limitation.
- Suggest future work: factor attribution, alternative labels, international data, higher-frequency rebalancing, or broader robustness grids.

# Final red-line

The thesis argument should follow this logic:

1. Catastrophic stock losses are economically relevant for investors.
2. Prior literature shows that firm distress is partly predictable.
3. CSI extends this idea from formal bankruptcy to market-path collapse and non-recovery.
4. Temporary-CSI and Permanent-CSI capture related but distinct forms of distress.
5. Because CSI is rare, AP and fixed-FPR recall are more informative than accuracy.
6. ML models are suitable because distress patterns are non-linear and interaction-heavy.
7. However, prediction quality alone does not imply investable index alpha.
8. Therefore, the thesis tests CSI risk scores in an index-construction setting.
9. Any positive index result must be interpreted through attribution, costs, turnover, and alternative explanations.
10. The thesis contribution is the cleaned CRSP implementation, model benchmark, and portfolio-level evaluation.
