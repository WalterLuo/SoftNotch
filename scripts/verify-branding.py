#!/usr/bin/env python3
"""Verify fork identities, localized keys, icon coverage and a built app."""
from pathlib import Path
import json, plistlib, subprocess, sys, re
root = Path(__file__).resolve().parents[1]
source = root / 'SoftNotch'

def require(condition, message):
    if not condition:
        raise SystemExit(message)

project = (root/'SoftNotch.xcodeproj/project.pbxproj').read_text()
require('PRODUCT_BUNDLE_IDENTIFIER = com.walterluo.softnotch;' in project, 'Incorrect app identity')
require('com.cshariq.sapphire' not in project and 'com.shariq.' not in project, 'Upstream product identity remains')
for p in [source/'App/Info.plist',root/'com.walterluo.softnotchHelper/com.walterluo.softnotchHelper.plist']:
    data=plistlib.loads(p.read_bytes())
    require('com.cshariq' not in str(data) and 'com.shariq.' not in str(data),'Upstream identity in plist')
strings = {}
for lang in ['en','zh-Hans']:
    p=source/f'{lang}.lproj/Localizable.strings'
    data=subprocess.run(['/usr/bin/plutil','-convert','json','-o','-',str(p)],capture_output=True,check=True).stdout
    strings[lang] = json.loads(data)
require(strings['en'].keys() == strings['zh-Hans'].keys(), 'Localized keys differ')
for key in strings['en']:
    tokens=lambda s:sorted(re.findall(r'%(?:\d+\$)?(?:@|lld|ld|lu|d|u|f|s)',s))
    require(tokens(strings['en'][key]) == tokens(strings['zh-Hans'][key]),f'Format mismatch: {key}')
icons=source/'Assets.xcassets/AppIcon.appiconset'
contents=json.loads((icons/'Contents.json').read_text())
require(len(contents['images'])==10,'Missing icon size')
for item in contents['images']:
    require(item['filename'].startswith('softnotch-') and (icons/item['filename']).is_file(),'Missing independent icon')
if len(sys.argv)>1:
    app=Path(sys.argv[1]).resolve()
    info=plistlib.loads((app/'Contents/Info.plist').read_bytes())
    require(info['CFBundleIdentifier']=='com.walterluo.softnotch','Wrong built bundle ID')
    require(info['CFBundleExecutable']=='SoftNotch','Wrong executable name')
    require(info['CFBundleShortVersionString']=='1.0.0','Wrong version')
    require('softnotch' in str(info['CFBundleURLTypes']) and 'sapphire' not in str(info['CFBundleURLTypes']),'Wrong URL scheme')
    helper=app/'Contents/MacOS/com.walterluo.softnotchHelper'
    require(helper.is_file(),'Missing helper')
    require((app/'Contents/Library/LaunchDaemons/com.walterluo.softnotchHelper.plist').is_file(),'Missing helper launch daemon')
    require((app/'Contents/Resources/SoftNotch-Guide.txt').is_file(),'Missing guide')
    media=app/'Contents/Resources/MediaRemoteAdapter.framework/MediaRemoteAdapter'
    require(media.exists(),'Media framework symlink is broken')
    subprocess.run(['/usr/bin/codesign','--verify','--deep','--strict',str(app)],check=True)
    print(f'Built app and signature passed: {app}')
print(f'Source identity, {len(strings["en"])} bilingual keys, format tokens and 10 icon representations passed.')
