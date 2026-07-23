export APPWORLD_PROJECT_PATH="."

# Place your API_KEY in appworld/experiments/.env

load_dotenv() {
    local env_file="${1:-.env}"
    if [ -f "$env_file" ]; then
        set -a
        source "$env_file"
        set +a
    else
        echo "Warning: $env_file not found" >&2
        return 1
    fi
}
load_dotenv "appworld/experiments/.env"

# train
appworld run ACE_offline_no_GT_adaptation

# test
appworld run ACE_offline_no_GT_evaluation

# evaluate
appworld evaluate ACE_offline_no_GT_evaluation test_normal