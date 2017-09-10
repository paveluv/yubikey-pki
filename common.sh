
function yubico-piv-tool {
    '/Applications/YubiKey PIV Manager.app/Contents/MacOS/yubico-piv-tool' "$@"
}
function openssl {
    /usr/local/opt/openssl/bin/openssl "$@"
}

function clear_or_gpg_or_empty {
    local F="$1"
    if [ -f "$F" ]; then
        cat "$F"
    elif [ -f "$F.gpg" ]; then
        gpg -d "$F.gpg"
    else
        echo ""
    fi
}

function piv_pin {
    clear_or_gpg_or_empty piv_pin.txt
}

function piv_mgm_key {
    clear_or_gpg_or_empty piv_mgm_key.txt
}

function gen_config {
    cat template.cnf | sed -e "s/{O}/${O}/" -e "s/{OU}/${OU}/" -e "s/{CN}/${CN}/" -e "s/{CA}/${CA}/" 
}