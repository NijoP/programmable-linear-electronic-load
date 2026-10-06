"""Mutation tests for real validation failure paths, using only Python stdlib."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from check_repository import (ROOT, PDF_DOCUMENT, EXPECTED_PDF_HASH, check_pdf,
                              check_repository, compute_pdf_hash, load_registry,
                              validate_registry)


class RegistryTests(unittest.TestCase):
    def setUp(self):
        self.registry = load_registry(ROOT / "data/parameters.json")

    def reject(self, transform):
        data = copy.deepcopy(self.registry)
        transform(data)
        self.assertTrue(validate_registry(data), "Mutation was incorrectly accepted")

    def test_valid_registry(self):
        self.assertEqual(validate_registry(self.registry), [])

    def test_malformed_top_level(self):
        for value in (None, [], True, 1, "registry"):
            with self.subTest(value=value):
                self.assertTrue(validate_registry(value))

    def test_schema_version(self):
        for value in (None, True, 1.0, 0, 2, "1", [], {}):
            with self.subTest(value=value):
                self.reject(lambda d: d.update(schema_version=value))
        self.reject(lambda d: d.pop("schema_version"))

    def test_parameters_container(self):
        for value in (None, [], True, 1, "entries", {}):
            with self.subTest(value=value):
                self.reject(lambda d: d.update(parameters=value))
        self.reject(lambda d: d.pop("parameters"))

    def test_bad_entry_types(self):
        for value in (None, [], True, 42, "entry"):
            with self.subTest(value=value):
                self.reject(lambda d: d["parameters"].append(value))

    def test_every_required_field(self):
        for field in ("id", "value", "unit", "classification", "context", "source", "notes"):
            with self.subTest(field=field):
                self.reject(lambda d: d["parameters"][0].pop(field))

    def test_invalid_id_types_and_shapes(self):
        for value in (None, [], {}, 42, True, "", "Bad", "1bad", "bad-id", "x\n", "a" * 64, "for"):
            with self.subTest(value=value):
                self.reject(lambda d: d["parameters"][0].update(id=value))

    def test_duplicate_id(self):
        self.reject(lambda d: d["parameters"].append(copy.deepcopy(d["parameters"][0])))

    def test_enum_types(self):
        for field in ("classification", "context"):
            for value in (None, [], {}, True, "", "invented"):
                with self.subTest(field=field, value=value):
                    self.reject(lambda d: d["parameters"][0].update({field: value}))

    def test_resolved_value_rejections(self):
        # Use a non-critical field so rejection cannot hide behind a reference-value check.
        index = next(i for i, e in enumerate(self.registry["parameters"]) if e["id"] == "shunt_power_rating_W")
        for value in (None, True, False, [], {}, [1], "", "  ", float("nan"), float("inf"), -float("inf"), 10**400):
            with self.subTest(value=str(value)[:25]):
                self.reject(lambda d: d["parameters"][index].update(value=value))

    def test_tbd_contract(self):
        index = next(i for i, e in enumerate(self.registry["parameters"]) if e["classification"] == "TBD")
        for value in (0, False, [], "TBD", float("nan")):
            with self.subTest(value=value):
                self.reject(lambda d: d["parameters"][index].update(value=value))
        self.reject(lambda d: d["parameters"][index].update(context="nominal"))
        self.reject(lambda d: d["parameters"][0].update(context="unknown"))

    def test_text_fields_nonblank(self):
        for field in ("unit", "notes"):
            for value in (None, [], True, 5, "", " \t"):
                with self.subTest(field=field, value=value):
                    self.reject(lambda d: d["parameters"][0].update({field: value}))

    def test_source_object(self):
        for value in (None, [], True, 1, "PDF"):
            with self.subTest(value=value):
                self.reject(lambda d: d["parameters"][0].update(source=value))

    def test_source_fields(self):
        for field in ("document", "section", "physical_page"):
            with self.subTest(missing=field):
                self.reject(lambda d: d["parameters"][0]["source"].pop(field))
        for field in ("document", "section"):
            for value in (None, [], {}, True, 1, "", " "):
                with self.subTest(field=field, value=value):
                    self.reject(lambda d: d["parameters"][0]["source"].update({field: value}))

    def test_source_page(self):
        for value in (None, True, False, "10", [], {}, 0, -1, 35, 10.5):
            with self.subTest(value=value):
                self.reject(lambda d: d["parameters"][0]["source"].update(physical_page=value))

    def test_frozen_wrong_document(self):
        self.reject(lambda d: d["parameters"][0]["source"].update(document="external.pdf"))

    def test_critical_value_page_and_provenance(self):
        self.reject(lambda d: d["parameters"].pop(0))
        self.reject(lambda d: d["parameters"][0].update(value=10.000000001))
        self.reject(lambda d: d["parameters"][0]["source"].update(physical_page=11))
        self.reject(lambda d: d["parameters"][0].update(classification="DATASHEET"))
        index = next(i for i, e in enumerate(self.registry["parameters"]) if e["id"] == "dac_transfer_denominator")
        self.reject(lambda d: d["parameters"][index].update(classification="FROZEN_FROM_PDF"))

    def test_json_rejects_nonstandard_constants_and_duplicate_keys(self):
        with tempfile.TemporaryDirectory() as directory:
            file = Path(directory) / "bad.json"
            for text in ('{"x":NaN}', '{"x":Infinity}', '{"x":-Infinity}', '{"x":1,"x":2}', '{broken'):
                with self.subTest(text=text):
                    file.write_text(text, encoding="utf-8")
                    with self.assertRaises(ValueError):
                        load_registry(file)


class IntegrityTests(unittest.TestCase):
    def test_pdf_exact_hash(self):
        self.assertEqual(compute_pdf_hash(), EXPECTED_PDF_HASH)
        self.assertEqual(check_pdf(ROOT / PDF_DOCUMENT), [])

    def test_hash_tampering_is_actually_rejected(self):
        original = (ROOT / PDF_DOCUMENT).read_bytes()
        with tempfile.TemporaryDirectory() as directory:
            file = Path(directory) / "changed.pdf"
            file.write_bytes(original[:-1] + bytes([original[-1] ^ 1]))
            errors = check_pdf(file)
            self.assertTrue(any("mismatch" in error for error in errors))
            self.assertTrue(check_pdf(Path(directory) / "missing.pdf"))

    def test_repository_layout_and_integrity(self):
        self.assertEqual(check_repository(), [])

    def test_checker_from_unrelated_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run([sys.executable, str(ROOT / "tests/check_repository.py")],
                                    cwd=directory, capture_output=True, text=True, check=False)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("PASS:", result.stdout)


if __name__ == "__main__":
    unittest.main()
