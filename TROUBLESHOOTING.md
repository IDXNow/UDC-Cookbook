# Troubleshooting

This guide covers the issues teams hit most often and the exact fix we use in production.  If your issue is not listed, check the [UDC01 README](https://github.com/IDXNow/UDC01) or open an issue.

---

## Setup & Dependencies

Start here when a recipe fails before conversion begins.  These checks remove environment drift first.

### `ModuleNotFoundError: No module named 'pdfplumber'`

**Cause:** The `pdf-to-json` recipe requires `pdfplumber` for PDF text extraction.

**Fix:**
```bash
pip install pdfplumber
```

### `ModuleNotFoundError: No module named 'openpyxl'`

**Cause:** The `xlsx-to-pipe` recipe requires `openpyxl` for reading Excel input files.  Also required when saving output as `.xlsx` or `.xls` (Excel output support).

**Fix:**
```bash
pip install openpyxl
```

### `ModuleNotFoundError: No module named 'yaml'`

**Cause:** Missing core dependency.

**Fix:**
```bash
pip install pyyaml
```

### Install all dependencies at once

```bash
pip install pandas pyyaml requests openpyxl pdfplumber
```

Or from the UDC01 repo:
```bash
pip install -r requirements.txt
```

---

## API Key Issues

Use this section when requests reach the provider but authentication or quota rules block execution.

### `401 Unauthorized` or `Authentication error`

**Cause:** Missing or invalid API key for the cloud provider you're using.

**Fix:** Set the environment variable for your provider:

```bash
# Linux/Mac
export OPENAI_API_KEY="sk-proj-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export GOOGLE_API_KEY="..."
```

```powershell
# Windows PowerShell
$env:OPENAI_API_KEY="sk-proj-..."
$env:ANTHROPIC_API_KEY="sk-ant-..."
$env:GOOGLE_API_KEY="..."
```

**Verify it's set:**
```bash
# Linux/Mac
echo $OPENAI_API_KEY

# Windows PowerShell
echo $env:OPENAI_API_KEY
```

### `429 Rate limit exceeded` or `Too Many Requests`

**Cause:** You're hitting the API provider's rate limit, especially common when running batch conversions with `--folder`.

**Fix:**
- Reduce `max_parallel_workers` in your config file (default is `2`)
- Wait a moment and retry - UDC01 has built-in retry with exponential backoff (`api_retry_attempts` and `api_retry_backoff` in config)
- Check your provider's rate limit tier and consider upgrading if you're doing batch work

### Agent is using the wrong provider or model

**Cause:** UDC01 uses a named provider profiles system.  The `provider` value on an agent must exactly match a key in the `providers` section of your config.  A mismatch silently falls back to the global `default_provider`.

**Fix:** Confirm your config has a matching entry:
```json
"providers": {
  "anthropic": { "base_url": "...", "request_format": "anthropic", ... }
},
"agents": {
  "data_conversion": { "provider": "anthropic", ... }
}
```
Provider keys are case-sensitive (`"anthropic"` ≠ `"Anthropic"`).

---

## Connection Issues

These errors mean UDC01 cannot reliably reach a model endpoint. Resolve transport before tuning prompts.

### `Connection refused` (local model)

**Cause:** UDC01 can't reach the local LLM server.

**Fix:**
1. Make sure your local LLM server is running (e.g., LM Studio, Ollama, etc.)
2. Check that the URL in your config matches the server's address (default: `http://localhost:1234`)
3. Verify the port number - different servers use different defaults

### `Timeout` or `api_timeout` errors

**Cause:** The API call took longer than the configured timeout, usually with complex conversions like EDI 835.

**Fix:** Increase the `api_timeout` value in your config file:
```json
"api_timeout": 600
```
The default is 600 seconds (10 minutes). For very large files or complex recipes, you may need more.

---

## Conversion Issues

This section covers runs that execute but produce weak, incomplete, or inconsistent results.

### Conversion succeeds but output is wrong or incomplete

**Cause:** The model may not be capable enough for the recipe's complexity.

**Fix:**
- Check the recipe's **Model Requirements** section - some recipes (especially EDI 835) require high-end models
- Switch to a more capable model - current frontier tiers are GPT-5.x, Claude 5 (Opus/Sonnet), and Gemini 3.x
- You can set the provider per-agent in your config file to use a stronger model for the conversion agent specifically

UDC01 does not validate model IDs - whatever you put in the config is sent to the vendor verbatim, so a newly released model works without a code change.

### Validation fails but the conversion looks correct

**Cause:** UDC01's 2/3 majority voting mechanism flagged a discrepancy. This is more common with smaller models where validators may disagree.

**Fix:**
- Try running again - LLM outputs vary between runs
- Increase `max_retries` in your config (default: `3`) for more attempts
- Turn on `include_prior_output_on_retry` so the conversion agent sees what it produced last time, not just the rejection message - complex recipes often converge a retry sooner with it
- Use a stronger model - validation consistency improves with model quality
- Check the log files in `logs/` for details on what the validators disagreed about

### `Validation failed after N retries`

**Cause:** The conversion couldn't pass validation within the configured retry limit.

**Fix:**
1. Check the log file for specifics on what failed
2. If using a local/smaller model, switch to a cloud provider with a more capable model
3. Increase `max_retries` in your config:
   ```json
   "max_retries": 5
   ```
4. Feed the failed output back into the next attempt - set `include_prior_output_on_retry: true` in your config, as a top-level key in the recipe YAML, or pass `--include-prior-output-on-retry` at the command line (the CLI wins over both)
5. If the input comes from a controlled source and pre-conversion verification is the stage that keeps failing, skip it for that recipe:
   ```yaml
   verification:
     enabled: false
   ```
6. For EDI recipes: high-end cloud models (GPT-5.x, Claude 5 Opus/Sonnet, Gemini 3.x Pro) are strongly recommended

### `thinking_budget` has no effect / model rejects `budget_tokens`

**Cause:** `thinking_budget` is now the **legacy** way to control reasoning depth.  It still works on older Anthropic and Google models, but current Claude models reject `budget_tokens` outright, and it was never supported on OpenAI or local endpoints.  On models that do still accept it, Anthropic forces `temperature: 1` internally whenever thinking is on - any other temperature in the config is overridden.

**Fix:** Use `reasoning_effort` instead - it works across every provider:
```json
{ "name": "Ted Sagan", "provider": "anthropic", "reasoning_effort": "high", "max_tokens": 16000 }
```
If you set both keys on the same agent, `reasoning_effort` wins and a warning is written to the log.  UDC01 never sends both on one request.

**If you are staying on `thinking_budget`** for an older model, remember the budget covers thinking *and* output on Anthropic - `max_tokens` has to be large enough for both.

### `reasoning_effort` has no effect

**Cause:** `reasoning_effort` works on **all** providers - Anthropic, Google, OpenAI, and local endpoints on the OpenAI wire format - but the accepted values differ by vendor, and a value the vendor does not recognize is generally ignored rather than rejected.

| Provider | Accepted values |
|---|---|
| Anthropic | `low`, `medium`, `high`, `xhigh`, `max` |
| Google | `minimal`, `low`, `medium`, `high` |
| OpenAI | `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max` (varies by model) |
| Local / Ollama | Passed through on the OpenAI wire format; gpt-oss honours it, other models may ignore it |

**Fix:** Check the value against the table above, and set it at whichever level you actually intended - provider profile, role-group, or individual agent (most specific wins):
```json
{ "name": "Ted Sagan", "provider": "openai", "model": "gpt-5.4-mini", "reasoning_effort": "high" }
```

On OpenAI, setting `reasoning_effort` omits `temperature` from the request automatically - the two are mutually exclusive once reasoning is on, so you do not need to remove the key yourself.

Note that whether a hybrid model reasons *at all* (Qwen3.5's `enable_thinking`, for one) is not reachable from config.

### `Response was entirely reasoning, no answer returned`

**Cause:** Nearly every current open model reasons before answering, and that reasoning is charged against the same output budget as the answer.  If the token budget is too low, the model spends all of it thinking, gets cut off before writing anything, and returns empty content.

**Fix:** Raise the output budget.  The shipped `local` and `ollama` profiles set `16000` for exactly this reason:
```json
"local": { "base_url": "http://localhost:1234", "default_max_tokens": 16000 }
```
Lowering `reasoning_effort` also leaves more of the budget for the answer.

UDC01 strips reasoning content before it parses any tags, so `<think>` blocks and `reasoning_content` fields do not corrupt the `<o>` extraction or the validators' verdicts.  Set `"strip_reasoning": false` on the profile when you want to see exactly what the model emitted.

### `Conversion response missing <o> section`

**Cause:** The conversion agent returned text but did not wrap its output in `<o>...</o>` tags, so there was nothing to extract.  UDC01 logs a warning, reminds the agent about the tags, and retries.

**Fix:**
- Confirm the recipe's `data_conversion_system_msg` states the `<o></o>` output format explicitly - every cookbook recipe does, and a custom recipe must too
- Small models are the usual culprit; they drop the wrapper when the output runs long.  Move the conversion agent to a stronger model
- If it happens on every attempt, check the prompt does not also name a *different* tag - UDC01 extracts `<o>` literally

### Excel output file is saved as `.txt` with a warning

**Cause:** UDC01 tried to save as `.xlsx` but couldn't parse the converted output as tabular data (pipe-delimited, CSV, or JSON array).

**Fix:**
- Check that the conversion recipe produces tabular output (rows and columns), not freeform text
- Verify the model is generating valid delimited output inside the `<o>` tags
- For non-tabular outputs, use a text-based `file_extension` (`txt`, `json`) instead of `xlsx`

---

## File & Path Issues

Use these checks when commands are valid but inputs are not being discovered or loaded correctly.

### `FileNotFoundError` for the conversion YAML

**Cause:** The path to the conversion YAML is relative to where you're running `udc01.py` from.

**Fix:** Make sure you're specifying the path relative to your current working directory, or use an absolute path:
```bash
# If running from the UDC01 directory with the cookbook alongside:
python udc01.py --conversion "UDC-Cookbook/conversion/csv-to-pipe/sales_invoice_conv.yaml" \
                --file "UDC-Cookbook/conversion/csv-to-pipe/sales_invoice.csv"
```

### `--folder` finds no files

**Cause:** The `--pattern` doesn't match any files in the specified folder.

**Fix:**
- Double-check the folder path exists and contains files
- Make sure the pattern matches your files (e.g., `*.csv`, `*.edi`, `*.pdf`)
- Patterns are case-sensitive on Linux/Mac - `*.CSV` won't match `file.csv`

### PDF extraction returns empty or garbled text

**Cause:** The PDF is a scanned image, not text-based. `pdfplumber` extracts text from text-layer PDFs, not images.

**Fix:**
- OCR preprocessing is needed for scanned documents (e.g., using Tesseract or a cloud OCR service) before running through UDC01
- Check if the PDF has a text layer: if you can select and copy text in a PDF viewer, it should work

---

## Performance Tips

These tuning patterns help you balance throughput, cost, and reliability for larger workloads.

### Slow conversions

- **Enable parallel execution** for cloud APIs:
  ```bash
  python udc01.py --file "your_file.csv" --parallel-agents
  ```
  Or set it in config: `"parallel_agents": true`

- **Batch processing** with `--folder` and `--pattern` is faster than running one file at a time in a loop

- **Adjust parallel workers** in config: `"max_parallel_workers": 3` (increase for cloud APIs with generous rate limits, decrease if hitting rate limits)

### `parallel_agents` doesn't speed anything up on a local model

**Cause:** `parallel_agents: true` fires two verification or validation agents at once.  Against a hosted API that roughly halves wall time, because the service handles concurrency.  Against a single loaded local model it does not - the server queues the second request behind the first, and both requests race the same `api_timeout`.

**Fix:** On a single local instance, either turn parallelism off:
```json
"parallel_agents": false
```
or give `api_timeout` enough room to cover two full generations back to back.

### High API costs on batch jobs

- Start with a single file to verify the recipe works before running a full batch
- Use `--pattern` to target specific files rather than processing everything in a folder
- Consider using a cheaper model for simple conversions (csv-to-pipe, xml-to-pipe) and reserving high-end models for complex recipes (EDI, enrichment)

---

## Still Stuck?

If the quick fixes do not resolve the issue, use the escalation path below so we can isolate root cause quickly.

1. Check the log files in `logs/` for detailed error messages and agent responses
2. Review the recipe's README for model requirements and known constraints
3. Try the sample files included with each recipe first - if those work, the issue is with your input file
4. Open an issue on the [UDC-Cookbook repo](https://github.com/IDXNow/UDC-Cookbook/issues) or the [UDC01 repo](https://github.com/IDXNow/UDC01/issues)

