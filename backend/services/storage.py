import json
import os

STORAGE_FILE = 'data/schemes.json'

def _read_storage():
    """Read schemes from JSON file"""
    if not os.path.exists(STORAGE_FILE):
        return []
    
    with open(STORAGE_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def _write_storage(schemes):
    """Write schemes to JSON file"""
    os.makedirs('data', exist_ok=True)
    with open(STORAGE_FILE, 'w', encoding='utf-8') as f:
        json.dump(schemes, f, indent=2, ensure_ascii=False)


def save_scheme(scheme_data):
    """Save a new scheme"""
    schemes = _read_storage()
    schemes.append(scheme_data)
    _write_storage(schemes)
    return scheme_data


def get_all_schemes():
    """Get all schemes"""
    return _read_storage()


def get_scheme_by_id(scheme_id):
    """Get a single scheme by ID"""
    schemes = _read_storage()
    for scheme in schemes:
        if scheme.get('id') == scheme_id:
            return scheme
    return None


def delete_scheme(scheme_id):
    """Delete a scheme by ID"""
    schemes = _read_storage()
    updated_schemes = [s for s in schemes if s.get('id') != scheme_id]
    
    if len(updated_schemes) < len(schemes):
        _write_storage(updated_schemes)
        return True
    return False
