AdapTo: Scoring & AI Generator Rework
1. Game Scoring Rebalance
Currently, the scoring economy is heavily skewed. Players are incentivized to farm points on Games 1, 4, and 5 because the effort-to-point ratio is much lower than Games 2 and 3. We need to implement a Difficulty Weighting System and mechanic-specific adjustments.

Proposed Game Adjustments
Game 1 (2-Option MCQ) - Difficulty: Easy

Change: Drastically reduce the base score per correct answer.

Addition: Implement a strict time-bonus multiplier. Players only get meaningful points if they answer quickly, reducing the viability of random guessing.

Game 2 (Jeopardy) - Difficulty: Very Hard

Change: Increase the base score to be the highest in the system.

Addition: Implement a Levenshtein distance check (string similarity) to award partial points (e.g., 50%) for minor typos. Introduce a "Give Hint" button that reveals a portion of the word but immediately slashes the potential points by 60%.

Game 3 (Crossword) - Difficulty: Hard

Change: Assign a high base reward for word completion.

Addition: Apply a flat point penalty for every 2-letter hint requested. Add a "Flawless" bonus for completing a word with zero hints.

Game 4 (Matching) - Difficulty: Medium

Change: Remove any partial points for hovering or testing matches.

Addition: Award moderate points per successful match, but introduce a combo multiplier that resets to 1x the moment they make an incorrect match.

Game 5 (Hangman) - Difficulty: Medium/Easy

Change: Remove the "per-letter" scoring metric, which allows farming on long words.

Addition: Award a flat score for completing the word. Multiply that flat score by the percentage of lives remaining. (e.g., A flawless guess yields 100% of the points; 1 life left yields 10%).

2. Gemini API Prompt Architecture Rework
Our current .tres files are generating surface-level trivia. To fully utilize the context window and capabilities of the model, we need to shift from simple extraction to a structured, higher-order thinking prompt pipeline.

The New Prompt Strategy
We need to update the generator script to use a strict JSON schema that maps perfectly to our .tres Godot resource structure, while forcing the LLM to act as an expert educator.

Key Updates to the System Prompt:

Enforce Bloom's Taxonomy: Instruct the API to generate questions aimed at "Application" and "Analysis" rather than just "Knowledge" (recall).

Plausible Distractors: For Game 1 and Game 4, explicitly command the AI to generate distractors (wrong answers) that address common misconceptions, rather than randomly generated incorrect terms.

Dynamic Clue Generation: For Games 2, 3, and 5, require the AI to generate an array of 3 clues per term, scaling from "vague/conceptual" to "highly specific."