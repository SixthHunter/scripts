# scripts

## GENERAL

NAME | DESCRIPTION
:-------------|:-----------
[ala.sh](ala.sh) | Arch Linux Archives (aka ALA) explorer
[anta.sh](anta.sh) | Explorador do sítio (website spider) &lt;oantagonista.com&gt;
[aur.sh](aur.sh) | List packages from AUR
[bcalc.sh](bcalc.sh) | Simple wrapper for Bash Bc and Zsh maths that keeps a record of results
_bcalc_ext.bc_ | *bcalc.sh* extensions for bash bc
[cep.sh](cep.sh) | CEP por nome de rua e vice-versa via api dos Correios brasileiros
[ctemp.sh](ctemp.sh) | Convert amongst temperature units (Celsius, Fahrenheit and Kelvin)
[datediff.sh](datediff.sh) | Calculate time ranges in different units (was `ddate.sh` )
[faster_sh.txt](faster_sh.txt) | Tips for improving script performances, specific for some use cases, text document
[grep.sh](grep.sh) |  Grep files with shell built-ins
[inmet.sh](inmet.sh) | Download satellite images from Brazilian Instituto Nacional de Meteorologia
[ipmet.sh](ipmet.sh) | Download radar images from Brazilian IPMET/SIMEPAR.
[ul.sh](ul.sh) |  Generate html lists from URLs
[urlgrep.sh](urlgrep.sh) | Grep full-text content from URL list
[wc.sh](wc.sh) |  Print line, word and character count for files with shell built-ins
[wf.sh](wf.sh) |  Weather forecast (Norway Meteorological Institute)


## MARKET-RELATED

NAME | DESCRIPTION
:-------------|:-----------
[bakkt.sh](bakkt.sh) | Price and contract/volume tickers from bakkt public api
[binance.sh](binance.sh) |  Binance public API, crypto converter, prices, book depth, coin ticker
[binfo.sh](binfo.sh) | Blockchain explorer for bitcoin; uses <blockchain.info> and <blockchair.com> public apis; notification on new block found
[brasilbtc.sh](brasilbtc.sh) | Fetches bitcoin rates from brazilian exchanges public apis. Puxa cotações de bitcoin de agências de câmbio brasileiras de apis públicas
[cgk.sh](cgk.sh) | <Coinggecko.com> public api, convert one crypto, bank/fiat currency or metal into any another, market ticker, cryptocurrency ticker. This is my favorite everyday-use script for all-currency rates!
[cmc.sh](cmc.sh) |  <Coinmarketcap.com> convert any amount of one crypto, bank/fiat currency or metal into any another, NON-public api access
[myc.sh](myc.sh) | <Mycurrency.net> public api, central bank currency rate converter
[novad.sh](novad.sh) | puxa dados das apis públicas da NovaDax brasileira. fetch public api data from NovaDax brazilian enchange
[ourominas.sh](ourominas.sh) | Ourominas (precious metals exchange) rates public api. Pega taxas da api pública da Ouro Minas
[parmetal.sh](parmetal.sh) | Parmetal (precious metals exchange) rates public api. Pega taxas da api pública da Parmetal
[stocks.sh](stocks.sh) | <Financialmodelingprep.com> latest and historical stock and major index rates
[uol.sh](uol.sh) | Fetches rates from uol service provider public api. Puxa dados de páginas da api pública do uol economia
[whalealert.sh](whalealert.sh) | Data from whale-alert.io free api with the latest whale transactions.
[yahooscrape.sh](yahooscrape.sh) | Scrape some Yahoo! Finance tickers


## BITCOIN BLOCKCHAIN-RELATED

NAME | DESCRIPTION
:-------------|:-----------
[bitcoin.blk.sh](bitcoin.blk.sh) | Bitcoin block and blockchain information
[bitcoin.hx.sh](bitcoin.hx.sh) | Create base58 address types from public key and WIF from private keys
[bitcoin.tx.sh](bitcoin.tx.sh) |  Parse transactions by hash or transaction json data
[blockchair.btcoutputs.sh](blockchair.btcoutputs.sh) |  Download blockchair output dump files systematically
_zzz.bitcoin.parsedTxs.txt_ | Example of parsed transactions from block 714176

Bitcoin scripts warp about `bitcoin-cli` (bitcoind) and try to parse data.
`bitcoin.tx.sh` is transaction-centred while `bitcoin.blk.sh` is block-centred.

_Make sure bitcoin-dameon is **fully synchonised**_, otherwise some
functions may not work properly!

___Tip___: have bitcoind set with transaction indexes (option 'txindex=1'),
otherwise user may need supply block id hash manually and
some vin transaction information is not going to be retrievable.

These wrappers require `bash`, `bitcoin-cli` and `jq`.
Some scripts have got [grondilu's bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)
functions embedded.

Transaction parsing time depends on the number of vins and vouts.
Parsing a few hendred or thousand transactions
seems quite feasible for personal use.


## FURTHER HELP AND EXAMPLES / MAIS AJUDA E EXEMPLOS

Check script help pages with option -h.

Veja as páginas de ajuda dos scripts com a opção -h. 


## ANDROID TERMUX TIPS / DICAS PRA TERMUX

These scripts can run under Termux, however some of them need a web socket such as `websocat`.

Vi's `websocat` bincaries for Android (ARM), MacOS and FreeBSD [can be downloaded from here](https://github.com/vi/websocat/releases).

Hroptatyr's [`dateutils`](https://github.com/hroptatyr/dateutils) can be compiled in Termux. I suggest installing the following packes before trying to [build `dateutils` as per developer intructions](https://github.com/hroptatyr/dateutils/blob/master/INSTALL) in Termux `v0.118.0`:

```bash
 pkg install gperf flex bison python python2 cmake automake libtool build-essential binutils cmake ctags
 ```
 
I compiled `dateutils` binaries a few days ago and I cannot remember specific details.
In general, if needed, check that `$TMPD` is set properly (should be set automatically) and review source code for `/tmp` references and change to hard location under Termux `$PREFIX` or set something like `$PREFIX/tmp` in shell scripts.
On other tips, if software is not in the official repos and you cannot compile it from source, try to look for compiled binaries of the software for your platform.


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


<br/>

<p align="center">
  <img width="120" height="120" alt="Silly Software Company logo" src="logo_ssc.jpg">
</p>


<br/>

    Please consider sending me a nickle!  = )

        bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


