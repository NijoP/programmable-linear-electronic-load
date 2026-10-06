#!/usr/bin/env python3
"""Portable standard-library integrity/schema checks; does not execute MATLAB."""
from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PDF_DOCUMENT = "docs/source/design-source.pdf"
EXPECTED_PDF_HASH = "d5d3f6f7f6a32840420885086f70b0aabb32814908d797de05d47f65864094d3"
ALLOWED_CLASSIFICATIONS = {"FROZEN_FROM_PDF", "DATASHEET", "MEASURED", "CALIBRATED", "TBD"}
ALLOWED_CONTEXTS = {"specification", "nominal", "provisional", "illustrative", "unknown"}
ID_PATTERN = re.compile(r"[a-z][a-zA-Z0-9_]{0,62}")
MATLAB_KEYWORDS = set("break case catch classdef continue else elseif end for function global if otherwise parfor persistent return spmd switch try while".split())
MODULES = "project main hardware electrical control thermal power sensors protection firmware battery simulation validation analysis plotting".split()
# Independently reviewed source values/page anchors, not read from the registry under test.
CRITICAL_PARAMETERS = {
    "vin_min_V": (10, 10), "vin_max_V": (15, 10), "current_max_A": (2, 10),
    "power_peak_W": (30, 10), "power_initial_continuous_W": (24, 10),
    "shunt_ohm": (0.01, 10), "sense_gain_V_V": (100, 11), "dac_bits": (12, 11),
    "dac_code_cap": (2482, 12), "dac_transfer_denominator": (4096, 19),
    "divider_high_ohm": (33000, 12), "divider_low_ohm": (7500, 12),
    "ntc_r0_ohm": (10000, 19), "ntc_beta_K": (3950, 19), "ntc_t0_C": (25, 19),
    "pcb_layers": (2, 10), "reset_pin": ("EN", 21), "t_shutdown_C": (85, 20),
    "num_mosfets": (4, 10), "ballast_ohm": (0.1, 14),
    "current_filter_ohm": (10000, 13), "current_filter_F": (1e-7, 13),
    "voltage_filter_F": (47e-9, 13), "t_fan_high_C": (60, 20), "t_derating_C": (75, 20),
}


def nonempty_text(value):
    return isinstance(value, str) and bool(value.strip())


def finite_number(value):
    if type(value) not in (int, float):
        return False
    try:
        return math.isfinite(value)
    except OverflowError:
        return False


def validate_registry(data) -> list[str]:
    """Return errors for JSON-compatible inputs without trusting field types."""
    if not isinstance(data, dict):
        return ["Registry must be an object"]
    errors = []
    if type(data.get("schema_version")) is not int or data["schema_version"] != 1:
        errors.append("schema_version must be integer 1 (not boolean)")
    params = data.get("parameters")
    if not isinstance(params, list) or not params:
        return errors + ["parameters must be a nonempty array"]
    by_id = {}
    required = {"id", "value", "unit", "classification", "source", "context", "notes"}
    for index, entry in enumerate(params):
        label = f"Entry {index}"
        if not isinstance(entry, dict):
            errors.append(f"{label}: must be an object")
            continue
        missing = required - entry.keys()
        if missing:
            errors.append(f"{label}: missing fields {sorted(missing)}")
        key = entry.get("id")
        if not isinstance(key, str) or not ID_PATTERN.fullmatch(key) or key in MATLAB_KEYWORDS:
            errors.append(f"{label}: invalid MATLAB parameter ID")
        else:
            label = key
            if key in by_id:
                errors.append(f"{label}: duplicate parameter ID")
            by_id[key] = entry
        classification, context = entry.get("classification"), entry.get("context")
        if not isinstance(classification, str) or classification not in ALLOWED_CLASSIFICATIONS:
            errors.append(f"{label}: invalid classification")
        if not isinstance(context, str) or context not in ALLOWED_CONTEXTS:
            errors.append(f"{label}: invalid context")
        for field in ("unit", "notes"):
            if not nonempty_text(entry.get(field)):
                errors.append(f"{label}: {field} must be nonempty text")
        value = entry.get("value")
        if classification == "TBD":
            if value is not None or context != "unknown":
                errors.append(f"{label}: TBD requires null value and unknown context")
        else:
            if not (finite_number(value) or nonempty_text(value)):
                errors.append(f"{label}: resolved value must be finite numeric scalar or nonempty text, not boolean")
            if context == "unknown":
                errors.append(f"{label}: resolved context cannot be unknown")
        source = entry.get("source")
        if not isinstance(source, dict):
            errors.append(f"{label}: source must be an object")
            continue
        for field in ("document", "section"):
            if not nonempty_text(source.get(field)):
                errors.append(f"{label}: source.{field} must be nonempty text")
        doc, page = source.get("document"), source.get("physical_page")
        if type(page) is not int or page < 1 or (doc == PDF_DOCUMENT and page > 34):
            errors.append(f"{label}: invalid 1-based physical page")
        if classification == "FROZEN_FROM_PDF" and doc != PDF_DOCUMENT:
            errors.append(f"{label}: FROZEN_FROM_PDF must cite the archived PDF")
    for key, (expected_value, expected_page) in CRITICAL_PARAMETERS.items():
        entry = by_id.get(key)
        if entry is None:
            errors.append(f"Missing critical parameter {key}")
            continue
        if entry.get("value") != expected_value:
            errors.append(f"{key}: expected source value {expected_value!r}")
        source = entry.get("source")
        if not isinstance(source, dict) or source.get("physical_page") != expected_page:
            errors.append(f"{key}: expected physical page {expected_page}")
        expected_class = "DATASHEET" if key == "dac_transfer_denominator" else "FROZEN_FROM_PDF"
        if entry.get("classification") != expected_class:
            errors.append(f"{key}: expected classification {expected_class}")
    return errors


def compute_pdf_hash(path=None) -> str:
    return hashlib.sha256(Path(path or ROOT / PDF_DOCUMENT).read_bytes()).hexdigest()


def check_pdf(path) -> list[str]:
    try:
        actual = compute_pdf_hash(path)
    except OSError as exc:
        return [f"Cannot read source PDF: {exc}"]
    return [] if actual == EXPECTED_PDF_HASH else [f"PDF SHA-256 mismatch: {actual}"]


def load_registry(path):
    def reject_constant(token):
        raise ValueError(f"Nonstandard JSON numeric constant: {token}")

    def unique_object(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f"Duplicate JSON object key: {key}")
            result[key] = value
        return result

    return json.loads(Path(path).read_text(encoding="utf-8"),
                      parse_constant=reject_constant, object_pairs_hook=unique_object)


def check_repository(root=ROOT) -> list[str]:
    root = Path(root)
    errors = check_pdf(root / PDF_DOCUMENT)
    try:
        errors.extend(validate_registry(load_registry(root / "data/parameters.json")))
    except (OSError, ValueError) as exc:
        errors.append(f"Cannot load registry: {exc}")
    try:
        text = (root / "docs/source/design-source.txt").read_text(encoding="utf-8")
        if sum(bool(page.strip()) for page in text.split("\f")) != 34:
            errors.append("Source extraction must have 34 nonempty physical pages")
    except (OSError, UnicodeError) as exc:
        errors.append(f"Cannot read UTF-8 source extraction: {exc}")
    required_files = ["README.md", "data/parameters.json", "docs/IMPLEMENTATION_PLAN.md",
                      "docs/SPECIFICATION.md", "docs/PARAMETERS.md", "docs/ARCHITECTURE.md",
                      "docs/DISCREPANCIES.md", "docs/DATASHEET_EVIDENCE.md", "docs/source/README.md",
                      "matlab/project/plel_setup.m", "matlab/project/plel_parameters.m",
                      "matlab/project/plel_parameter.m", "tests/test_foundation.m",
                      "measurements/README.md", "results/README.md"]
    for module in MODULES:
        if not (root / "matlab" / module).is_dir():
            errors.append(f"Missing module directory: matlab/{module}")
        if module != "project":
            required_files.append(f"matlab/{module}/README.md")
    for file in required_files:
        if not (root / file).is_file():
            errors.append(f"Missing required file: {file}")
    if (root / ".git").exists() and shutil.which("git"):
        result = subprocess.run(["git", "check-ignore", "--no-index", "data/parameters.json",
                                 "measurements/README.md", "results/README.md"],
                                cwd=root, text=True, capture_output=True, check=False)
        if result.returncode == 0:
            errors.append(f"Engineering source incorrectly ignored: {result.stdout.strip()}")
        elif result.returncode != 1:
            errors.append(f"git check-ignore failed: {result.stderr.strip()}")
    return errors


def main() -> int:
    errors = check_repository()
    if errors:
        print("\n".join(f"ERROR: {error}" for error in errors))
        return 1
    print(f"PASS: PDF SHA-256 {EXPECTED_PDF_HASH}; UTF-8/34 pages; registry; layout; ignore rules.")
    print("MATLAB execution and hardware qualification are separate checks.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
