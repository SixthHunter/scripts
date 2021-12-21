# scripts

## GENERAL INDEX


SCRIPT NAME | DESCRIPTION
:-------------|:-----------
__ala.sh__ | Arch Linux Archives (aka ALA) explorer
__anta.sh__ | Explorador do site &lt;oantagonista.com&gt;; spider of the website &lt;oantagonista.com&gt;
__bcalc.sh__ | Simple wrapper for Bash Bc that keeps a record of results
__bcalc_ext.bc__ | *bcalc.sh* extensions for bash bc
__cep.sh__ | CEP por Nome de Rua e Vice-Versa
__conkykiller.sh__ | Start/restart conkies regularly to deal with terrible IO ops memory leaks
__ctemp.sh__ | Convert amongst temperature units (Celsius, Fahrenheit and Kelvin)
__ddate.sh__ | Calculate time ranges in different units (experimental)
__faster_sh.txt__ | Tips for improving script performances, specific for some use cases, text document
__grep.sh__ |  Grep files with shell built-ins
__inmet.sh__ | Download satellite images from Brazilian Instituto Nacional de Meteorologia
__ipmet.sh__ | Download radar images from Brazilian Instituto de Pesquisas Meteorológicas (UNESP)
__skel.sh__ | My skel script and tips
__ul.sh__ |  Generate html lists from URLs
__urlgrep.sh__ | Grep full-text content from URL list
__wc.sh__ |  Print line, word and character count for files with shell built-ins
__wf.sh__ |  Weather forecast (norway meteorological institute)



## BITCOIN-RELATED SCRIPTS

Bitcoin scripts warp about `bitcoin-cli` (bitcoind) and try to parse data.
`bitcoin.tx.sh` is transaction-centred while `bitcoin.blk.sh` is block-centred.

_Make sure bitcoin-dameon is **fully synchonised**_, otherwise some
functions may not work properly!

___Tip___: have bitcoind set with transaction indexes (option 'txindex=1'),
otherwise user may need supply block id hash manually and
some vin transaction information is not going to be retrievable.

<!-- Because they depend on `bitcoin-cli` _RPC_ call output, we can be sure there
is a set of dependable and minimally parsed data to start with. -->

These wrappers require `bash`, `bitcoin-cli` and `jq`.
Some scripts have got [grondilu's bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)
functions embedded.

Transaction parsing time depends on the number of vins and vouts.
Parsing a few hendred or thousand transactions
seems quite feasible for personal use.

SCRIPT NAME | DESCRIPTION
:-------------|:-----------
__bitcoin.blk.sh__ | Bitcoin block information and functions
__bitcoin.hx.sh__ | Create base58 address types from public key and WIF from private keys
__bitcoin.tx.sh__ |  Parse transactions by hash or transaction json data
__blockchair.btcoutputs.sh__ |  Download blockchair output dump files systematically, see also [this repo](https://github.com/mountaineerbr/bitcoin-all-addresses)
__zzz.bitcoin.parsedTxs..__ | Example of parsed transactions from block 638200


## FURTHER HELP AND USAGE EXAMPLES

Check script help pages with option -h.


## SEE ALSO

Grondilu's [bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)

Kristapsk's [bitcoin scripts](https://github.com/kristapsk/bitcoin-scripts)


---

> Please consider sending me a nickle!  = )
>
>    bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


***(ARCHIVAL REPOSITORY)**
