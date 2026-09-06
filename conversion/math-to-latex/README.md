# Math Notation to LaTeX - Formula Conversion

*We use this recipe to turn a library of plain-text formulas into render-ready LaTeX without hand-typing backslashes.*

> Converts a plain-text (ASCII) math formula into a bare LaTeX math-mode expression, with validation that checks semantic equivalence rather than style.

## What This Solves

Math written in plain ASCII - in a spec, a legacy textbook file, a spreadsheet cell, a code comment - has to become LaTeX before it can be typeset. Doing that by hand is slow and error-prone in exactly the places that matter: the scope of a `sqrt`, the extent of a numerator, the bounds on a sum.

This recipe applies a fixed notation mapping table mechanically, then puts the result through a validator that compares the LaTeX back against the source formula. The validator is deliberately built to accept style variation (`\frac{a}{b}` vs `a/b`, implicit vs explicit multiplication) and fail on anything that changes the mathematics - a dropped term, a shifted exponent, a resized fraction. Style differences do not trip retries; meaning changes do.

## Input

A text file containing one formula in plain ASCII notation:

```
x = (-b +/- sqrt(b^2 - 4*a*c)) / (2*a)
```

The recipe handles `sqrt`, `^`, `_`, grouped division, `+/-`, Greek letter names, `infinity`, `->`, `<=`/`>=`/`!=`, and the `integral from ... to ... of`, `sum from ... to ... of`, `product from ... to ... of`, and `lim as ... -> ... of` forms.

## Output

The bare LaTeX expression - no `$`, `\[`, or `\begin{equation}` delimiters, so you can drop it into whatever wrapper your document uses:

```latex
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
```

Your run may differ cosmetically - the validator accepts `\frac{a}{b}` versus `a/b`, implicit versus `\cdot` multiplication, `\left(...\right)` versus plain parentheses, and `x^{2}` versus `x^2` as equivalent. It fails only on changes to the mathematics.
ight)` versus plain parentheses, and `x^{2}` versus `x^2` as equivalent. It fails only on changes to the mathematics.

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/math-to-latex/math_formula_latex_conv.yaml" \
                --file "conversion/math-to-latex/quadratic_formula.txt"

# Folder + search pattern - batch a whole formula library
python udc01.py --conversion "conversion/math-to-latex/math_formula_latex_conv.yaml" \
                --folder "conversion/math-to-latex" \
                --pattern "*.txt"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

**Output file extension:** UDC01 writes results using `file_save.file_extension` from your config (default `txt`). The recipe works fine that way; override the extension to `tex` if you want the output to open directly in a LaTeX editor.

## Files

| File | Description |
|---|---|
| `math_formula_latex_conv.yaml` | UDC01 conversion configuration |
| `quadratic_formula.txt` | Quadratic formula - fraction, sqrt, plus-minus |
| `sum_of_integers.txt` | Summation with bounds |
| `gaussian_integral.txt` | Definite integral with infinite bounds |
| `derivative_definition.txt` | Limit definition of the derivative - prime notation, `lim`, `->` |
| `expected_output_quadratic.txt` | Expected LaTeX for `quadratic_formula.txt` |

## Model Requirements

- Works with any supported LLM provider (local, OpenAI, Anthropic, Google)
- The mapping table is mechanical, so smaller models handle the common forms well
- Longer multi-line derivations benefit from a stronger conversion agent - the failure mode is grouping scope, not notation

## Adapt This Recipe

This example covers standard algebra and calculus notation, but the pattern works for any plain-text-to-LaTeX conversion. In the YAML:

- **Extend the notation mapping table** - Add rows for the constructs your source material uses: matrices (`\begin{pmatrix}`), piecewise definitions (`\begin{cases}`), text inside math (`\text{}`), or your own domain shorthand
- **Change the output wrapper** - Structural rule 6 forbids delimiters; relax it if you want `$...$` or a full `equation` environment emitted instead
- **Tune the equivalence accept-list** - The validator's ACCEPT list decides what counts as style rather than meaning. Move `\frac{a}{b}` versus `a/b` to the FAIL list if you need one canonical form
- **Add worked examples** - The three examples in the conversion prompt anchor the model's formatting. Adding examples from your own corpus is the highest-leverage change you can make
- **Handle multi-formula files** - The prompt assumes one formula per file; adjust it to emit one LaTeX line per input line for bulk conversion
