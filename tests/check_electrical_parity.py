"""Deterministic identity parity audit; not electrical topology approval.
Run from any cwd. Exit 0 requires BOM/CSV/pin identities AND a valid matrix.
The matrix is never created or repaired by this checker.
"""
import csv
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MECHANICAL = {'HS1', 'TIM1', 'M1'}
FIELDS = {'source_ref', 'source_pin', 'source_net', 'destination_ref',
          'destination_pin', 'destination_net', 'electrical_role',
          'power_domain', 'criticality'}


def audit():
    paths = ['data/PLEL_R1_MASTER_BOM.json', 'data/PLEL_R1_MASTER_BOM.csv',
             'eda/parts/PLEL_R1_PIN_MAP.json']
    bom = json.loads((ROOT / paths[0]).read_text())['components']
    pins = json.loads((ROOT / paths[2]).read_text())['pin_maps']
    with (ROOT / paths[1]).open(newline='') as f:
        rows = list(csv.DictReader(f))
    by_ref = {c['reference_designator']: c for c in bom}
    by_csv = {c['reference_designator']: c for c in rows}
    errors = []
    if len(by_ref) != len(bom) or len(by_csv) != len(rows):
        errors.append('Duplicate component references')
    if by_ref.keys() != by_csv.keys():
        errors.append('BOM JSON/CSV reference sets differ')
    if set(pins) != set(by_ref) - MECHANICAL:
        errors.append('BOM/pin-map electrical reference sets differ')
    for ref, c in by_ref.items():
        r = by_csv.get(ref, {})
        for field in ['exact_MPN', 'package', 'value', 'manufacturer']:
            if c.get(field, '') != r.get(field, ''):
                errors.append(f'{ref}: JSON/CSV {field} mismatch')
        try:
            if c['pins'] != json.loads(r.get('pins', 'null')):
                errors.append(f'{ref}: JSON/CSV pins mismatch')
        except (ValueError, TypeError):
            errors.append(f'{ref}: CSV pins are not JSON')
        if ref not in MECHANICAL:
            identity = lambda pp: sorted((str(x['pin']), x['name']) for x in pp)
            if identity(c['pins']) != identity(pins.get(ref, [])):
                errors.append(f'{ref}: BOM/pin-map pin identity mismatch')
    identity_errors = list(errors)
    matrix = ROOT / 'eda/connections/PLEL_CONNECTION_MATRIX.csv'
    matrix_errors = []
    if not matrix.exists():
        matrix_errors.append('Connection matrix absent; topology is not release-closed')
    else:
        with matrix.open(newline='') as f:
            reader = csv.DictReader(f)
            if not FIELDS.issubset(set(reader.fieldnames or [])):
                matrix_errors.append('Matrix schema mismatch')
            connections = list(reader)
        if not connections:
            matrix_errors.append('Matrix empty')
        endpoint_nets = {}
        for i, row in enumerate(connections, 2):
            if any(not row.get(k, '').strip() for k in FIELDS):
                matrix_errors.append(f'Matrix row {i}: missing required field')
            if row.get('source_net') != row.get('destination_net'):
                matrix_errors.append(f'Matrix row {i}: wire endpoints have different nets')
            for end in ['source', 'destination']:
                ref = row.get(f'{end}_ref')
                pin = row.get(f'{end}_pin')
                if ref not in pins or pin not in {str(p['pin']) for p in pins[ref]}:
                    matrix_errors.append(f'Matrix row {i}: unknown {end} {ref}.{pin}')
                key = (ref, pin)
                net = row.get(f'{end}_net')
                if key in endpoint_nets and endpoint_nets[key] != net:
                    matrix_errors.append(f'Matrix row {i}: conflicting net on {ref}.{pin}')
                endpoint_nets[key] = net
        for ref, pp in pins.items():
            if '-' in ref:
                matrix_errors.append(f'{ref}: grouped references must be expanded before matrix release')
            for p in pp:
                key = (ref, str(p['pin']))
                nc = p['name'] in {'NC', 'DNC'} or 'no-connect' in p.get('role', '').lower()
                if not nc and key not in endpoint_nets:
                    matrix_errors.append(f'{ref}.{p["pin"]}: missing connection')
                if nc and key in endpoint_nets:
                    matrix_errors.append(f'{ref}.{p["pin"]}: explicitly NC pin connected')
    return {
        'scope': 'identity audit; no analog or safety approval inferred',
        'source_sha256': {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths},
        'BOM_CSV_PIN_IDENTITIES': 'PASS' if not identity_errors else 'FAIL',
        'identity_errors': identity_errors,
        'CONNECTION_MATRIX': 'PASS' if not matrix_errors else 'BLOCKED',
        'matrix_errors': matrix_errors,
        'identity_and_endpoint_parity': not identity_errors and not matrix_errors,
    }


if __name__ == '__main__':
    result = audit()
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['identity_and_endpoint_parity'] else 1)
