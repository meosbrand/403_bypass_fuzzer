# 403_bypass_fuzzer

A lightweight Bash script designed to automate 403 Forbidden and 401 Unauthorized bypass testing. It dynamically mutates a target endpoint using various path traversal, URL encoding, case mutation, and character injection techniques.

---

## Key Features

* **Dynamic Endpoint Parsing:** Automatically extracts the domain and endpoint from any input URL to apply payloads accurately.
* **Comprehensive Mutation:** Tests over 70 distinct fuzzing patterns including semi-colon path insertion (`..;/`), null bytes (`%00`), Unicode characters, and case alterations.
* **Clean, Scannable Output:** Displays real-time HTTP status codes alongside each attempted URL string.
* **Zero Dependencies:** Built purely in native Bash using standard `curl`, `sed`, and `grep` utilities.

---

## Usage

### 1. Make the script executable
```bash
chmod +x bypass_fuzzer.sh

```

### 2. Execute against a target URL

```bash
./bypass_fuzzer.sh [https://example.com/admin](https://example.com/admin)

```

### 3. Filter results for success/interest (Optional)

```bash
# Hide 403 Forbidden responses to quickly spot anomalies
./bypass_fuzzer.sh [https://example.com/admin](https://example.com/admin) | grep -v "[403]"

```

```

```
