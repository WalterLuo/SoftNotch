#!/usr/bin/env python3
"""Sign SoftNotch and its helper with the same private local certificate.

Creates an app-specific keychain; does not change system certificate trust.
Private keys and passwords stay outside the repository.
"""
from pathlib import Path
import os, plistlib, secrets, subprocess, sys, tempfile

app = Path(sys.argv[1]).expanduser().resolve()
with (app / 'Contents/Info.plist').open('rb') as f:
    info = plistlib.load(f)
if info.get('CFBundleIdentifier') != 'com.walterluo.softnotch':
    raise SystemExit('Expected com.walterluo.softnotch')
base = Path.home() / 'Library/Application Support/SoftNotchLocalSigning'
base.mkdir(parents=True, exist_ok=True, mode=0o700)
keychain = base / 'SoftNotchLocalSigning.keychain-db'
password_file = base / 'keychain-password'
certificate = base / 'certificate.pem'

def run(args):
    result = subprocess.run([str(x) for x in args], capture_output=True, text=True)
    if result.returncode:
        # Never include arguments: some security commands contain the password.
        raise RuntimeError(result.stderr.strip() or 'Local signing command failed')
    return result.stdout

if not keychain.exists():
    password = secrets.token_urlsafe(36)
    password_file.write_text(password)
    password_file.chmod(0o600)
    previous_search_list = run(['/usr/bin/security', 'list-keychains', '-d', 'user'])
    import shlex
    previous_keychains = shlex.split(previous_search_list)
    try:
        run(['/usr/bin/security', 'create-keychain', '-p', password, keychain])
        run(['/usr/bin/security', 'set-keychain-settings', '-lut', '21600', keychain])
        with tempfile.TemporaryDirectory(prefix='softnotch-signing-') as tmp:
            temp = Path(tmp)
            key = temp / 'key.pem'
            p12 = temp / 'identity.p12'
            config = temp / 'certificate.cnf'
            config.write_text('''[req]
distinguished_name=dn
x509_extensions=extensions
prompt=no
[dn]
CN=SoftNotch Local Development
O=Walter Luo
[extensions]
basicConstraints=critical,CA:false
keyUsage=critical,digitalSignature
extendedKeyUsage=critical,codeSigning
subjectKeyIdentifier=hash
''')
            run(['/usr/bin/openssl', 'req', '-new', '-newkey', 'rsa:2048', '-nodes', '-x509', '-days', '3650', '-config', config, '-keyout', key, '-out', certificate])
            # Passphrase is provided through the subprocess environment, never logs.
            env = os.environ.copy()
            env['SOFTNOTCH_P12_PASSWORD'] = password
            subprocess.run(['/usr/bin/openssl', 'pkcs12', '-export', '-inkey', str(key), '-in', str(certificate), '-out', str(p12), '-passout', 'env:SOFTNOTCH_P12_PASSWORD'], env=env, check=True, capture_output=True)
            run(['/usr/bin/security', 'import', p12, '-k', keychain, '-P', password, '-T', '/usr/bin/codesign'])
        run(['/usr/bin/security', 'set-key-partition-list', '-S', 'apple-tool:,apple:,codesign:', '-s', '-k', password, keychain])
    finally:
        if previous_keychains:
            run(['/usr/bin/security', 'list-keychains', '-d', 'user', '-s', *previous_keychains])
else:
    password = password_file.read_text().strip()
fingerprint = run(['/usr/bin/openssl', 'x509', '-in', certificate, '-noout', '-sha1', '-fingerprint']).strip().split('=', 1)[1].replace(':', '')
try:
    run(['/usr/bin/security', 'unlock-keychain', '-p', password, keychain])
    # Copies from Finder may carry metadata which codesign forbids. Do not
    # remove quarantine or other security attributes.
    for attribute in ['com.apple.FinderInfo', 'com.apple.ResourceFork']:
        subprocess.run(['/usr/bin/xattr', '-rd', attribute, str(app)], capture_output=True)
    run(['/usr/bin/codesign', '--force', '--deep', '--sign', fingerprint, '--keychain', keychain, '--timestamp=none', app])
    run(['/usr/bin/codesign', '--verify', '--deep', '--strict', app])
finally:
    run(['/usr/bin/security', 'lock-keychain', keychain])
print('SoftNotch locally signed and verified; private keychain locked.')
