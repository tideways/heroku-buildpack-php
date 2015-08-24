#!/usr/bin/env bash

# Not callable in custom buildpack context without binaries
install_tideways_ext() {
    TIDEWAYS_APIKEY=${TIDEWAYS_APIKEY:-}
    TIDEWAYS_FRAMEWORK=${TIDEWAYS_FRAMEWORK:-}
    TIDEWAYS_SAMPLERATE=${TIDEWAYS_SAMPLERATE:-30}

    if [[ ( ${#exts[@]} -eq 0 || ! ${exts[*]} =~ "tideways" ) && -n "$TIDEWAYS_APIKEY" ]]; then
        install_ext "tideways" "add-on detected"
        exts+=("tideways")
    fi
}

install_tideways_daemon() {
    cat > $BUILD_DIR/.profile.d/tideways.sh <<"EOF"
if [[ -n "$TIDEWAYS_APIKEY" ]]; then
    if [[ -f "/app/.heroku/php/bin/tideways-daemon" ]]; then
        chmod a+x /app/.heroku/php/bin/tideways-daemon
        mkdir /app/.heroku/php/var/tideways/run -p
        touch /app/.heroku/php/var/tideways/run/daemon.sock
        /app/.heroku/php/bin/tideways-daemon -address="/app/.heroku/php/var/tideways/run/daemon.sock" &
    else
        echo >&2 "WARNING: Add-on 'tideways' detected, but PHP extension not yet installed. Push an update to the application to finish installation of the add-on; an empty change ('git commit --allow-empty') is sufficient."
    fi
fi
EOF
}
