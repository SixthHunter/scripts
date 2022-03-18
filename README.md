# scripts

## INDEX

SCRIPT NAME | DESCRIPTION
:-------------|:-----------
__ala.sh__ | Arch Linux Archives (aka ALA) explorer
__anta.sh__ | Explorador do site &lt;oantagonista.com&gt;; spider of the website &lt;oantagonista.com&gt;
__bakkt.sh__ | Price and contract/volume tickers from bakkt public api
__bcalc.sh__ | Simple wrapper for Bash Bc and Zsh maths that keeps a record of results
__bcalc_ext.bc__ | *bcalc.sh* extensions for bash bc
__binance.sh__ |  Binance public API, crypto converter, prices, book depth, coin ticker
__binfo.sh__ | Blockchain explorer for bitcoin; uses <blockchain.info> and <blockchair.com> public apis; notification on new block found
__brasilbtc.sh__ | Fetches bitcoin rates from brazilian exchanges public apis. Puxa cotações de bitcoin de agências de câmbio brasileiras de apis públicas
__cep.sh__ | CEP por Nome de Rua e Vice-Versa
___cgk.sh___ | <Coinggecko.com> public api, convert one crypto, bank/fiat currency or metal into any another, market ticker, cryptocurrency ticker. This is my favorite everyday-use script for all-currency rates!
__cmc.sh__ |  <Coinmarketcap.com> convert any amount of one crypto, bank/fiat currency or metal into any another, NON-public api access
__conkykiller.sh__ | Start/restart conkies regularly to deal with terrible IO ops memory leaks
__ctemp.sh__ | Convert amongst temperature units (Celsius, Fahrenheit and Kelvin)
__datediff.sh__ | Calculate time ranges in different units (was `ddate.sh` )
__faster_sh.txt__ | Tips for improving script performances, specific for some use cases, text document
__grep.sh__ |  Grep files with shell built-ins
__hgbrasil.sh__ | Bovespa and tax rates. Cotações de ações da Bovespa e índices e taxas (CDI e SELIC) do api da hg brasil
__inmet.sh__ | Download satellite images from Brazilian Instituto Nacional de Meteorologia
__ipmet.sh__ | Download radar images from Brazilian Instituto de Pesquisas Meteorológicas (UNESP)
___mkt_func.sh___ | shell functions (bash and z-shell) to get some market data from public apis. Google Finance and Yahoo! Finance hacks.. these functions need improvement; source from this file to make these funtions available in your shell
__myc.sh__ | <Mycurrency.net> public api, central bank currency rate converter
__novad.sh__ | puxa dados das apis públicas da NovaDax brasileira. fetch public api data from NovaDax brazilian enchange
__ourominas.sh__ | Ourominas (precious metals exchange) rates public api. Pega taxas da api pública da Ouro Minas
__parmetal.sh__ | Parmetal (precious metals exchange) rates public api. Pega taxas da api pública da Parmetal
__skel.sh__ | My skel script and tips
__stocks.sh__ | <Financialmodelingprep.com> latest and historical stock and major index rates
__ul.sh__ |  Generate html lists from URLs
__uol.sh__ | Fetches rates from uol service provider public api. Puxa dados de páginas da api pública do uol economia
__urlgrep.sh__ | Grep full-text content from URL list
__wc.sh__ |  Print line, word and character count for files with shell built-ins
__wf.sh__ |  Weather forecast (norway meteorological institute)
__yahooscrape.sh__ | scrape some yahoo! finance tickers


## BITCOIN BLOCKCHAIN-RELATED SCRIPTS

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
__blockchair.btcoutputs.sh__ |  Download blockchair output dump files systematically
__zzz.bitcoin.parsedTxs.txt__ | Example of parsed transactions from block 714176


## ANDROID TERMUX USERS

These scripts can run under Termux, however some of them need a web socket such as `websocat`.

Vi's `websocat` bincaries for Android (ARM), MacOS and FreeBSD [can be downloaded from here](https://github.com/vi/websocat/releases).

Hroptatyr's [`dateutils`](https://github.com/hroptatyr/dateutils) can be compiled in Termux. I suggest installing the following packes before trying to [build `dateutils` as per developer intructions](https://github.com/hroptatyr/dateutils/blob/master/INSTALL) in Termux `v0.118.0`:

```bash
 pkg install gperf flex bison python python2 cmake automake libtool build-essential binutils cmake ctags
 ```
 
I compiled `dateutils` binaries a few days ago and I cannot remember specific details. In general, if needed, check check that `$TMPD` is set properly (should be set automatically) and review source code for `/tmp` references and change to hard location under Termux `$PREFIX` or set something like `$PREFIX/tmp` in shell scripts. On other tips, if software is not in the official repos and you cannot compile it from source, try to look for compiled binaries of the software for your platform.

## FURTHER HELP AND USAGE EXAMPLES / MAIS AJUDA E EXEMPLOS DE USO

Check script help pages with option -h.

Veja as páginas de ajuda dos scripts com a opção -h. 


## API KEYS / CHAVES DE API

Some scripts require API keys.
Please create free API keys and add them to shell environment or set
them in the script head source code. Demo api keys were added to the scripts,
however they may stop working at any time or get rate limited quickly.

Alguns scripts requerem chaves de API.
Por favor, crie chaves de API grátis e as adicione no ambiente da shell
ou as configure na cabeça do código-fonte dos scripts. Chaves para fins
de demonstração foram adicionadas aos scripts, porém elas podem parar 
de funcionar a qualquer momento ou serem limitadas rapidamente.
  

## IMPORTANT / IMPORTANTE

None of these scripts are supposed to be used under truly professional constraints. Do your own research!

Nenhum desses scripts deve ser usado em meio profissional sem análise prévia. Faça sua própria pesquisa!


## SEE ALSO / VEJA TAMBÉM

Grondilu's [bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)

Kristapsk's [bitcoin scripts](https://github.com/kristapsk/bitcoin-scripts)

Alexander Epstein's _currency_bash-snipet.sh_ uses the same API as _erates.sh_

<https://github.com/alexanderepstein>

MiguelMota's _Cointop_ for crypto currency tickers

<https://github.com/miguelmota/cointop>

8go's _CoinBash.sh_ for CoinMarketCap simple tickers (outdated)

<https://github.com/8go/coinbash> 

Brandleesee's _Mop: track stocks the hacker way_

<https://github.com/mop-tracker/mop>


---

> Please consider sending me a nickle!  = )
>
>    bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr

---

***(ARCHIVAL REPOSITORY)***
