# Math Notation to MathML - Formula Conversion

*We use this recipe to get formulas into HTML5 and EPUB as real markup, so they stay accessible and reflowable instead of shipping as images.*

> Converts a plain-text (ASCII) math formula into a Presentation MathML `<math>` element, with validation that checks element arity, XML well-formedness, and semantic equivalence.

## What This Solves

Formulas rendered as images break screen readers, do not reflow, and blur when a reader zooms. Presentation MathML solves all three - browsers and EPUB readers render it natively, and assistive technology can read it aloud. The obstacle is that MathML is verbose and structurally strict: `<mfrac>` takes exactly two children, `<msubsup>` exactly three, and compound groups have to be wrapped in `<mrow>` or the layout silently comes out wrong.

This recipe applies a fixed element mapping table, then validates three separate things: that the XML is well-formed with the MathML namespace present, that only valid Presentation MathML elements appear with the right child counts, and that the markup denotes the same mathematics as the source. Structural errors are caught before the output reaches your document.

Presentation MathML (rendering-oriented) is emitted rather than Content MathML (semantics-oriented) - Presentation is what browsers and EPUB readers actually display.

## Input

A text file containing one formula in plain ASCII notation - the same input format as the [math-to-latex](../math-to-latex/) recipe:

```
x = (-b +/- sqrt(b^2 - 4*a*c)) / (2*a)
```

## Output

A single `<math>` element carrying the MathML namespace, ready to drop into HTML5 or EPUB:

```xml
<math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
  <mi>x</mi>
  <mo>=</mo>
  <mfrac>
    <mrow>
      <mo>-</mo>
      <mi>b</mi>
      <mo>&#xB1;</mo>
      <msqrt>
        <mrow>
          <msup><mi>b</mi><mn>2</mn></msup>
          <mo>-</mo>
          <mn>4</mn>
          <mi>a</mi>
          <mi>c</mi>
        </mrow>
      </msqrt>
    </mrow>
    <mrow>
      <mn>2</mn>
      <mi>a</mi>
    </mrow>
  </mfrac>
</math>
```

Your run may differ cosmetically - the validator accepts explicit `<mo>&#x22C5;</mo>` versus implicit multiplication, `<mfenced>` versus explicit parentheses, and whitespace differences as equivalent. It fails only on changes to the mathematics. `expected_output_quadratic.xml` is a verified engine output, not the only correct answer.

Special symbols use numeric character references (`&#xB1;`, `&#x3C0;`, `&#x221E;`) rather than raw non-ASCII characters or named entities, so the output survives any encoding and parses without a DTD.

## How to Run

```bash
# Single file
python udc01.py --conversion "conversion/math-to-mathml/math_formula_mathml_conv.yaml" \
                --file "conversion/math-to-mathml/quadratic_formula.txt"

# Folder + search pattern - batch a whole formula library
python udc01.py --conversion "conversion/math-to-mathml/math_formula_mathml_conv.yaml" \
                --folder "conversion/math-to-mathml" \
                --pattern "*.txt"
```

`--folder` and `--pattern` are documented in the [UDC01 README](https://github.com/IDXNow/UDC01) under Command Line Options.

**Output file extension:** UDC01 writes results using `file_save.file_extension` from your config (default `txt`). Override it to `xml` or `mml` if your toolchain keys off the extension - the output is a bare `<math>` element either way, so the choice is cosmetic.

## Files

| File | Description |
|---|---|
| `math_formula_mathml_conv.yaml` | UDC01 conversion configuration |
| `quadratic_formula.txt` | Quadratic formula - `mfrac`, `msqrt`, `msup` nesting |
| `sum_of_integers.txt` | Summation - `munderover` with bounds |
| `gaussian_integral.txt` | Definite integral - `msubsup` with infinite bounds |
| `derivative_definition.txt` | Limit definition of the derivative - `munder`, prime notation |
| `expected_output_quadratic.xml` | Expected MathML for `quadratic_formula.txt` |

## Model Requirements

- **Recommended tier or better** (GPT-5.x, Claude 5, Gemini 3.x, or a capable local model)
- This is the harder of the two math recipes. Small models produce plausible-looking MathML with the wrong child counts - an `<mfrac>` with three children, or a compound numerator not wrapped in `<mrow>` - which renders incorrectly rather than failing loudly
- The validator catches arity violations, so a weak model shows up as repeated retries rather than bad output

## Adapt This Recipe

This example covers standard algebra and calculus notation, but the pattern works for any plain-text-to-MathML conversion. In the YAML:

- **Switch to inline rendering** - Change `display="block"` to `display="inline"` in the output format and worked example for formulas that sit in running text
- **Extend the element mapping table** - Add rows for `<mtable>`/`<mtr>`/`<mtd>` matrices, `<mover>` accents (bars, hats, vectors), or `<mmultiscripts>` for tensor notation
- **Adjust the allowed element list** - Validation rule 2 enumerates the accepted element names; extend it whenever you extend the mapping table, or the validator will reject your new constructs
- **Change symbol encoding** - Structural rule 4 mandates numeric character references. Switch to raw UTF-8 if your pipeline is encoding-safe and you prefer readable source
- **Emit a wrapper** - Have the prompt wrap the `<math>` element in a `<figure>` or a `<div class="equation">` if your publishing template expects one
