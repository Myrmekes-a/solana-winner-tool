#!/usr/bin/env bash
set -e

# Number of lamports to allocate to each validator
lamports=17179869184

cd "$(dirname "$0")"

rm -f validators/all.md
shopt -s nullglob
for keybase_file in validators/keybase-usernames.*; do
  section=${keybase_file##*.}
  echo "## $section" >> validators/all.md
  yml=${keybase_file/keybase-usernames./}.yml
  rm -f $yml
  touch $yml
  for username in $(cat "$keybase_file"); do
    echo "Processing $username..."
    declare pubkeyDir=/keybase/public/"$username"/solana/
    if [[ ! -d "$pubkeyDir" ]]; then
      echo "Warn: $username: $pubkeyDir does not exist"
      continue
    fi

    declare validatorPubkey=
    for file in "$pubkeyDir"validator-*; do
      validatorPubkey=$file
      break;
    done

    if [[ -z $validatorPubkey ]]; then
      echo "Warn: $username: no validator pubkey found"
      continue
    fi

    if [[ $validatorPubkey =~ .*validator-([1-9A-HJ-NP-Za-km-z]+)$ ]]; then
      declare pubkey="${BASH_REMATCH[1]}"
      echo "$pubkey registered"
      echo "$pubkey: $lamports" >> $yml
      echo "1. [$username](https://keybase.io/$username): \`$pubkey\`" >> validators/all.md
    else
      echo "Warn: $username: invalid validator pubkey: $validatorPubkey"
    fi
  done
  echo Wrote $yml
done

echo
yml=validators/all.yml
rm -f $yml
cat validators/*.yml > $yml
echo Wrote $yml
