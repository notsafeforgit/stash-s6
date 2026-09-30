"""Validate resolved bake output before allowing a native preview publication."""
import json
from pathlib import Path
import re
import sys

source = sys.argv[2]
if not re.fullmatch(r'ghcr\.io/notsafeforgit/stash@sha256:[0-9a-f]{64}', source):
    raise SystemExit('Invalid pinned source image')
targets = json.loads(Path(sys.argv[1]).read_text())['target']
expected = {'alpine-native-preview', 'hwaccel-native-preview', 'hwaccel-alpine-native-preview'}
if set(targets) != expected:
    raise SystemExit('Unexpected publication targets')
for name, target in targets.items():
    if target['args'].get('UPSTREAM_STASH') != source:
        raise SystemExit('Unpinned source for ' + name)
    if target.get('platforms') != ['linux/amd64']:
        raise SystemExit('Unexpected native platform for ' + name)
    prefix = 'ghcr.io/notsafeforgit/stash-s6:' + name
    if not target.get('tags') or any(tag != prefix and not tag.startswith(prefix + '-') for tag in target['tags']):
        raise SystemExit('Native build could overwrite a compatible image tag')
print('All native targets use the selected digest and isolated preview tags.')
