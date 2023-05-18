#!/usr/bin/env sh
# shellcheck disable=3034,2155

export GH_TOKEN='${{ github.token }}'
export GH_REPO='codefodder/slashdot-diygest'
export TODAY="$(date +%Y-%m-%d)"

gh run list \
    --created $TODAY \
    --json "startedAt,databaseId,status,conclusion" \
    --workflow slashdot-diygest-email.yml \
    --template '{{range .}}{{tablerow .startedAt .databaseId .status .conclusion}}{{end}}' | tee output

# if we don't have a success today, run.
if [[ ! "$(< output)" =~ "success" ]]; then
    echo "RUN=true" >> "$GITHUB_ENV"
else
    # wait a moment and cancel
    grep 'in_progress' < output | awk '{print $2}' | tee run_id.txt
    run_id=$(< run_id.txt)

    echo "### Run cancelling self id: $run_id"

    gh run cancel $run_id
    sleep 3
fi
