# scripts
## GENERAL INDEX


SCRIPT NAME | DESCRIPTION
:-------------|:-----------
__ala.sh__ | Arch Linux Archives (aka ALA) explorer and a pkg downloader
__anta.sh__ | Explorador do site &lt;oantagonista.com&gt;; spider of the website &lt;oantagonista.com&gt;
__bcalc.sh__ | Simple wrapper for Bash Bc that keeps a record of results; compatible with bash and z-shell
__bcalc_ext.bc__ | *bcalc.sh* extensions for bash bc
__conkykiller.sh__ | Start/restart conkies regularly to deal with terrible IO ops memory leaks
__ctemp.sh__ | Convert amongst temperature units (Celsius, Fahrenheit and Kelvin)
__ddate.sh__ | Calculate time ranges in different units; convert between human and UNIX time formats (requires `GNU date` and `datediff` \[dateutils])
__diffcp.sh__ | Copy FILES from PWD to TARGET directory when both exist and differ.
__faster_sh.txt__ | Tips for improving script performances, specific for some use cases, text document
__grep.sh__ |  Grep files with shell built-ins
__inmet.sh__ | Download satellite images from Brazilian Instituto Nacional de Meteorologia
__ipmet.sh__ | Download radar images from Brazilian Instituto de Pesquisas Meteorológicas (UNESP)
__skel.sh__ | My skel script and tips
__urlgrep.sh__ | Grep full-text content from a URL list (useful for searching web history and bookmarks)
__wc.sh__ |  Print line, word and character count for files with shell built-ins
__wf.sh__ |  Weather forecast from Norway Meteorological Institute API endpoints (rough implementation)

Print line, word and character count for files with shell built-ins

---

## BITCOIN-CLI WRAPPER AND BITCOIN-RELATED SCRIPTS

These scripts wrap `bitcoin-cli` (bitcoind) and try to parse data.
They are transaction-centred.

_Make sure bitcoin-dameon is **fully synchonised**_, otherwise some
functions may not work properly!

___Tip___: have bitcoind set with transaction indexes (option 'txindex=1'),
otherwise user must supply block id hash manually plus
some vin transaction information is not going to be retrievable.

Depends on `bitcoin-cli` _RPC_ call output.
That is good as we can be dependable on a set of minimally-parsed data
to start with.

These wrapper scripts require `bash`, `bitcoin-cli` and `jq`.
Some scripts have got [grondilu's bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)
functions embedded.

Transaction parsing time really depends on the number of
vins and vouts. Parsing a few hendred or thousand transactions
seems quite feasible for personal use. `bitcoin.tx.sh` has got option -f, which is fast and delivers basic transaction info.

SCRIPT NAME | DESCRIPTION
:-------------|:-----------
__bitcoin.blk.sh__ | Bitcoin block information and functions
__bitcoin.hx.sh__ | Create base58 address types from public key and WIF from private keys
__bitcoin.tx.sh__ |  Parse transactions by hash or transaction json data
__blockchair.btcoutputs.sh__ |  Download blockchair output dump files systematically, see also [this repo](https://github.com/mountaineerbr/bitcoin-all-addresses)
__zzz.bitcoin.parsedTxs..__ | Example of parsed transactions from block 638200

---

## USAGE EXAMPLES

Check script help pages with option -h.

---

## SEE ALSO

[binfo.sh](https://github.com/mountaineerbr/markets/blob/master/binfo.sh)
is bitcoin blockchain explorer.

There are many shell functions to get data from many API points
at my [markets repo](https://github.com/mountaineerbr/markets/)

Grondilu's [bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)

Kristapsk's [bitcoin scripts](https://github.com/kristapsk/bitcoin-scripts)

---

## DEPRECATION NOTICE

If I were to write these scripts from ground up again, they would be much different (hopefully simpler and faster).
Time for maintaining them became scarse and ended, now moving onto other things.

---

> Please consider sending me a nickle!  = )
>
>    bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr

