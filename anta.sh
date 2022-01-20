#!/bin/bash
# anta.sh -- puxa artigos da homepage de <oantagonista.com>
# v0.18.19  jan/2022  by mountaineerbr

#padrões

#intervalo de tempo entre reacessos opção -r:
TEMPO=( 6m 2${RANDOM: -1} )  #240s
#curl/wget connection-timeout
TOUT=30
#curl/wget retries
RETRIES=2
#tentativas do script
TENTATIVAS=6
#obs: tentativas total = (( RETRIES * TENTATIVAS ))

#caminho do script para funão de update
SCRIPT="${BASH_SOURCE[0]}"
#não inunde o servidor (espera entre chamadas, em segundos)
FLOOD=0.4

#update url
UPURL=https://raw.githubusercontent.com/mountaineerbr/scripts/master/anta.sh
#<https://raw.githubusercontent.com/mountaineerbr/mountaineerbr.github.io/master/repo/scripts/anta.sh>#

#date regex
DREGEX='[0-3][0-9]\.[0-1][0-9]\.[1-2][0-9].*[0-2][0-9]:[0-5][0-9]'

#assuntos/categorias
SUBLIST=(brasil cultura economia eleicoes2020 entretenimento especial esportes mundo opiniao sociedade reuniao-de-pauta videos tudo-sobre tv opiniao despertador sem-categoria)
#tag

#Ref tapir art: http://www.ascii-art.de/ascii/t/tapir.txt
HELP="Anta.sh -- Puxa os artigos de <oantagonista.com>

                         _,.,.__,--.__,-----.
                      ,\"\"   '))              \`.
                    ,'   e                    ))
                   (  .='__,                  ,
                    \`~\`     \`-\  /._____,/   /
                             | | )    (  (   ;
                             | | |    / / / /
                     vvVVvvVvVVVvvVVVvvVVvVvvvVvPhSv


SINOPSE
	anta.sh  [-af] [ÍNDICE..|URL..]
	anta.sh  [-af] [-sNUM|-pNUM]
	anta.sh  [-af] -r [-sNUM]
	anta.sh  [-af] [ASSUNTO] [ÍNDICE..]
	anta.sh  [-huuv]


	Este script puxa os textos resumidos e integrais dos artigos do
	site <www.oantagonista.com>. Por padrão, se nenhuma opção for
	inserida, o script puxará a primeira página inicial com os re-
	sumos dos artigos e sairá. A opção -pNUM ou somente -NUM confi-
	gura quantas páginas iniciais devem ser puxadas.

	O texto integral dos artigos pode ser recuperado com a opção -f .
	Com esta opção, também pode-se especificar URLs de artigos espe-
	cíficos.

	O número de ÍNDICE de uma página inicial de <oantagonista.com>
	corresponde a ordem cronológica da mais recente para a mais an-
	tiga. Assim, a página mais recente tem o número de ÍNDICE igual
	a 1. É possível puxar múltiplas páginas pelos números de ÍNDICES.
	Para isso, use os números de INDICE como argumentos posicionais.

	A opção -r faz um reacesso da primeira página inicial e puxa os
	resumos dos artigos aproximadamente a cada ~${TEMPO[*]} segundos.
	O intervalo de tempo entre reacessos pode ser definido por -sNUM,
	em que NUM é um número natural em segundos, ou -sNUMm, em que
	m está para minutos, sendo aceitos os argumentos comumente pas-
	sados ao comando 'sleep' para esta opção. A opção -r também fun-
	ciona juntamente com a opção -f .

	Ao final da realização de trabalhos, será impresso a data e hora
	e, em seguida, alguns números. Os números entre parenteses, quan-
	do se utiliza a opção -r , são o intervalo de tempo entre reaces-
	sos. Nos demais modos, será impresso entre colchetes o tempo de
	realização da tarefa em segundos.

	Uma outra opção para puxar os links por ASSUNTOS/categorias pode
	ser acionada setando-se o primeiro argumento posicional com
	tag/[ASSUNTO] ou um dos seguintes ASSUNTOS: ${SUBLIST[*]/%/, }.
	Esta opção aceita a opção -[p]NUM ou ÍNDICES das páginas iniciais
	por assuntos e também opção -f, veja exemplo de uso (7) para mais
	informações.

	Use a opção -a para habilitar o uso de servidores alternativos,
	caso observe consecutivos erros ou seja bloqueado pelo limite
	na taxa de acessos.

	Para baixar um grande número de artigos, prefira começar em horá-
	rios de poucas publicações novas, ou seja, finais de semana e
	madrugadas. Ou, use os sitemaps do site (em XML) para pegar o
	endereço de todas as matérias.

	Ainda, pode-se ajustar o tempo de 'timeout' e de retentativas
	configurando-se algumas variáveis cabeça do código-fonte deste
	script.


RSS FEEDS
	RSS FEED
	O site oferece um feed RSS de notícias (as últimas 15 notícias,
	somente a descrição) pelo seguinte endereço:
	<https://www.oantagonista.com/feed/>

	PODCAST FEED
	<https://www.spreaker.com/show/o-antagonista>


LIMITES DE ACESSO
	Nos termos de uso do próprio site, há somente uma limitação
	que eu saiba:

	<< 2.2.1. Você se compromete a não utilizar qualquer sistema
	automatizado, inclusive, mas sem se limitar a 'robôs', 'spiders'
	ou 'offline readers,' que acessem a Plataforma de maneira a en-
	viar mais mensagens de solicitações aos servidores do site O An-
	tagonista em um dado período de tempo do que seja humanamente
	possível responder no mesmo período através de um navegador con-
	vencional. >>

		<oantagonista.com/termos-de-uso>, acesso em set/2019.


GARANTIA E REQUISITOS
	Este programa é software livre e está licenciado sob a GNU GPL 
	versão 3 ou superior e é oferecido sem suporte ou correção de
	bugs.

	Pacotes requeridos: Bash, cURL e/ou Wget2/Wget. É recomendável
	instalar ambos cURL e Wget caso encontre bloqueios de limites de
	acesso do servidor.

	Se achou o script útil, por favor conside me mandar um trocado!
		=)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


BUGS
	Observe que se uma nova notícia for publicada durante o funciona-
	mento do programa ao baixar múltiplas páginas contíguas, irá
	perder-se algum número de reportagens pois elas são rolantes.

	Quando se usa a opção -a , alguns artigos mais recentes (da pri-
	meira e segunda página iniciais) podem estar faltantes. Os ser-
	vidores alternativos podem demorar um pouco para sincronizarem
	com o servidor padrão.
	
	Algumas sobreposições do texto com mensagens de carregamento
	enviadas pelo stderr podem ocorrer.

	Não sendo um erro do script, artigos podem aparecer em duplicata
	devido ao próprio design do site.

	Wget 1.21.2 imprime mensagens de \`SSL_INIT' espúrias em stderr,
	consertado na versão seguinte.


VEJA TAMBÉM
	Para uma cópia histórica em texto das matérias do site até o
	começo de 2020, veja o repositório: 

	<github.com/mountaineerbr/largeFiles/tree/master/oAntaRegistro>


EXEMPLOS DE USO
	( 1 ) Puxar as primeiras quatro páginas iniciais do portal:

		$ anta.sh -p4

		$ anta.sh -4


	( 2 ) Reacesar a página inicial a cada 10 minutos (600 segundos),
	      neste caso também pode-se a opção -f :

		$ anta.sh -r -s10m

		$ anta.sh -r


	(*3 ) Reacesar a página inicial automaticamente e imprimir o
	      texto completo de artigos novos, usar o paginador Les.

		$ anta.sh -fr | less


	( 4 ) Textos completos dos artigos das primeiras 4 páginas
 	      do portal:

		$ anta.sh -f -p4 | less


	( 5 ) Puxar artigos completos das URLs (opção -f é opcional):

		$ anta.sh -f '/brasil/toffoli-nega-ter-recebido-e-acessado-relatorios-do-coaf/'

		$ anta.sh '/brasil/o-que-o-congresso-ressuscitou-na-lei-de-abuso-de-autoridade/' '/brasil/toffoli-nega-ter-recebido-e-acessado-relatorios-do-coaf/'


	( 6 ) Puxar página pelo número de ÍNDICE:

		$ anta.sh 12500        #somente resumos dos artigos

		$ anta.sh -f 12500     #puxa artigos integrais da página
				       #inicial número 12500

		$ anta.sh {10..5}      #da página 10 até a página 5
		$ anta.sh 10 9 8 7 6 5
		

	( 7 ) Puxar páginas as primeiras 3 páginas iniciais por categoria;
	      opção -f para puxar os artigos completos pode ser habilitada:

		$ anta.sh -3 brasil
		$ anta.sh brasil 3 2 1

		$ anta.sh -3f despertador


	      Pode-se usar tag/[ASSUNTO] em que ASSUNTO pode ser: ciencia,
	      educacao, rio, saopaulo, lula, pt, bitcoin e mais.

		$ anta.sh -3f tag/retrospectiva-2020
		                        

OPÇÕES
	-NUM 	  Mesmo que opção -pNUM .
	-a 	  Usar servidores alternativos.
	-f [ÍNDICE..|URL..]
		  Texto integral dos artigos das páginas iniciais.
	-h 	  Mostra esta ajuda.
	-p NUM    Número de páginas a serem puxadas; padrão=1 .
	-r 	  Reacessar a página inicial em intervalos de tempo.
	-s NUM    Intervalo de tempo entre reacessos da opção -r ; 
		  NUMm para minutos e NUMs para segundos; padrão~=380s .
	-u 	  Checar por atualização do script.
	-uu 	  Atualização do script.
	-v 	  Mostra a versão do script."

#Orign servers
SERVERS=(www.oantagonista.com)
ALTSERVERS=(cache.oantagonista.com cms.oantagonista.com m.oantagonista.com wp.oantagonista.com editores.oantagonista.com)
#'52.204.39.109', '3.82.68.200', '18.204.255.62', '52.72.53.233', '34.198.178.99'
#'54.210.110.10', '52.86.216.106', '34.207.47.120', '18.214.96.27'

AGENTS=('User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)' 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1' 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41' 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36' 'User-Agent: Mozilla/5.0 (Linux; Android 6.0.1; SGP771 Build/32.2.A.0.253; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/52.0.2743.9[<0;45;17M8 Safari/537.36' 'User-Agent: Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; RM-1127_16056) AppleWebKit/537.36(KHTML, like Gecko) Chrome/42.0.2311.135 Mobile Safari/537.36 Edge/12.10536' 'User-Agent: Mozilla/5.0 (Linux; Android 6.0.1; SGP771 Build/32.2.A.0.253; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/52.0.2743.98 Safari/537.36' 'User-Agent: Mozilla/5.0 (Linux; Android 7.0; SM-G892A Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/60.0.3112.107 Mobile Safari/537.36' 'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Mobile Safari/537.36' 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Safari/537.36 Edge/13.10586' 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko' 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0' 'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Mobile Safari/537.36')


## Funções
# Filtro HTML e tradução de códigos
#https://ascii.cl/htmlcodes.htm
#https://www.freeformatter.com/html-entities.html
sedhtmlf() {
	sed -E \
		-e 's/<br[ \/]*>/&\n/g' -e 's/\r//g ; s/\xc2\xa0/ /g ; s/&mdash;/--/g' \
		-e 's/\ \ */ /g ; s/\t\t*/\t/g' -e 's/^[\t\ ]*//g' \
		-e 's/<\/?script[^>]*>/\n&\n/g' -e 's/<\/?style[^>]*>/\n&\n/g' \
		| sed \
		-e '/^<script[^>]*>/,/^<\/script>/ d' -e '/^<style[^>]*>/,/^<\/style>/ d' \
		-e '/</{ :loop ;s/<[^<]*>//g ;/</{ N ;b loop } }' \
		| sed -E \
		-e 's/&quot;/"/g' -e "s/&apos;/'/g" \
		-e 's/&#32;/ /g ;s/&#33;/!/g ;s/&#34;/"/g ;s/&#35;/#/g ;s/&#36;/$/g' \
		-e 's/&#37;/%/g' -e "s/&#39;/'/g" -e 's/&#40;/(/g ;s/&#41;/)/g ;s/&#42;/*/g' \
		-e 's/&#43;/+/g ;s/&#44;/,/g ;s/&#45;/-/g ;s/&#46;/./g ;s/&#47;/\//g' \
		-e 's/&#58;/:/g ;s/&#59;/;/g ;s/&#61;/=/g ;s/&#63;/?/g ;s/&#64;/@/g' \
		-e 's/&#91;/[/g ;s/&#92;/\\/g ;s/&#93;/]/g ;s/&#94;/^/g ;s/&#95;/_/g' \
		-e 's/&#96;/`/g ;s/&#123;/{/g ;s/&#124;/|/g ;s/&#125;/}/g ;s/&#126;/~/g' \
		-e 's/(&amp;|&#38;)/\&/g ;s/(&lt;|&#60;)/</g ;s/(&gt;|&#62;)/>/g ;s/(&Agrave;|&#192;)/À/g' \
		-e 's/(&Aacute;|&#193;)/Á/g ;s/(&Acirc;|&#194;)/Â/g ;s/(&Atilde;|&#195;)/Ã/g ;s/(&Auml;|&#196;)/Ä/g' \
		-e 's/(&Aring;|&#197;)/Å/g ;s/(&AElig;|&#198;)/Æ/g ;s/(&Ccedil;|&#199;)/Ç/g ;s/(&Egrave;|&#200;)/È/g' \
		-e 's/(&Eacute;|&#201;)/É/g ;s/(&Ecirc;|&#202;)/Ê/g ;s/(&Euml;|&#203;)/Ë/g ;s/(&Igrave;|&#204;)/Ì/g' \
		-e 's/(&Iacute;|&#205;)/Í/g ;s/(&Icirc;|&#206;)/Î/g ;s/(&Iuml;|&#207;)/Ï/g ;s/(&ETH;|&#208;)/Ð/g' \
		-e 's/(&Ntilde;|&#209;)/Ñ/g ;s/(&Ograve;|&#210;)/Ò/g ;s/(&Oacute;|&#211;)/Ó/g ;s/(&Ocirc;|&#212;)/Ô/g' \
		-e 's/(&Otilde;|&#213;)/Õ/g ;s/(&Ouml;|&#214;)/Ö/g ;s/(&Oslash;|&#216;)/Ø/g ;s/(&Ugrave;|&#217;)/Ù/g' \
		-e 's/(&Uacute;|&#218;)/Ú/g ;s/(&Ucirc;|&#219;)/Û/g ;s/(&Uuml;|&#220;)/Ü/g ;s/(&Yacute;|&#221;)/Ý/g' \
		-e 's/(&THORN;|&#222;)/Þ/g ;s/(&szlig;|&#223;)/ß/g ;s/(&agrave;|&#224;)/à/g ;s/(&aacute;|&#225;)/á/g' \
		-e 's/(&acirc;|&#226;)/â/g ;s/(&atilde;|&#227;)/ã/g ;s/(&auml;|&#228;)/ä/g ;s/(&aring;|&#229;)/å/g' \
		-e 's/(&aelig;|&#230;)/æ/g ;s/(&ccedil;|&#231;)/ç/g ;s/(&egrave;|&#232;)/è/g ;s/(&eacute;|&#233;)/é/g' \
		-e 's/(&ecirc;|&#234;)/ê/g ;s/(&euml;|&#235;)/ë/g ;s/(&igrave;|&#236;)/ì/g ;s/(&iacute;|&#237;)/í/g' \
		-e 's/(&icirc;|&#238;)/î/g ;s/(&iuml;|&#239;)/ï/g ;s/(&eth;|&#240;)/ð/g ;s/(&ntilde;|&#241;)/ñ/g' \
		-e 's/(&ograve;|&#242;)/ò/g ;s/(&oacute;|&#243;)/ó/g ;s/(&ocirc;|&#244;)/ô/g ;s/(&otilde;|&#245;)/õ/g' \
		-e 's/(&ouml;|&#246;)/ö/g ;s/(&oslash;|&#248;)/ø/g ;s/(&ugrave;|&#249;)/ù/g ;s/(&uacute;|&#250;)/ú/g' \
		-e 's/(&ucirc;|&#251;)/û/g ;s/(&uuml;|&#252;)/ü/g ;s/(&yacute;|&#253;)/ý/g ;s/(&thorn;|&#254;)/þ/g' \
		-e 's/(&yuml;|&#255;)/ÿ/g ;s/(&#160;|&nbsp;)/ /g ;s/(&iexcl;|&#161;)/¡/g ;s/(&cent;|&#162;)/¢/g' \
		-e 's/(&pound;|&#163;)/£/g ;s/(&curren;|&#164;)/¤/g ;s/(&yen;|&#165;)/¥/g ;s/(&brvbar;|&#166;)/¦/g' \
		-e 's/(&sect;|&#167;)/§/g ;s/(&uml;|&#168;)/¨/g ;s/(&copy;|&#169;)/©/g ;s/(&ordf;|&#170;)/ª/g' \
		-e 's/(&laquo;|&#171;)/«/g ;s/(&not;|&#172;)/¬/g ;s/(&shy;|&#173;)/­/g ;s/(&reg;|&#174;)/®/g' \
		-e 's/(&macr;|&#175;)/¯/g ;s/(&deg;|&#176;)/°/g ;s/(&plusmn;|&#177;)/±/g ;s/(&sup2;|&#178;)/²/g' \
		-e 's/(&sup3;|&#179;)/³/g ;s/(&acute;|&#180;)/´/g ;s/(&micro;|&#181;)/µ/g ;s/(&para;|&#182;)/¶/g' \
		-e 's/(&cedil;|&#184;)/¸/g ;s/(&sup1;|&#185;)/¹/g ;s/(&ordm;|&#186;)/º/g ;s/(&raquo;|&#187;)/»/g' \
		-e 's/(&frac14;|&#188;)/¼/g ;s/(&frac12;|&#189;)/½/g ;s/(&frac34;|&#190;)/¾/g ;s/(&iquest;|&#191;)/¿/g' \
		-e 's/(&times;|&#215;)/×/g ;s/(&divide;|&#247;)/÷/g ;s/(&circ;|&#710;)/ˆ/g ;s/(&tilde;|&#732;)/˜/g' \
		-e 's/(&ensp;|&#8194;)/ /g ;s/(&emsp;|&#8195;)/ /g ;s/(&thinsp;|&#8201;)/ /g ;s/(&ndash;|&#8211;)/–/g' \
		-e 's/(&mdash;|&#8212;)/—/g ;s/(&lsquo;|&#8216;)/‘/g ;s/(&rsquo;|&#8217;)/’/g ;s/(&sbquo;|&#8218;)/‚/g' \
		-e 's/(&ldquo;|&#8220;)/“/g ;s/(&rdquo;|&#8221;)/”/g ;s/(&bdquo;|&#8222;)/„/g ;s/(&dagger;|&#8224;)/†/g' \
		-e 's/(&Dagger;|&#8225;)/‡/g ;s/(&bull;|&#8226;)/•/g ;s/(&hellip;|&#8230;)/…/g ;s/(&permil;|&#8240;)/‰/g' \
		-e 's/(&prime;|&#8242;)/′/g ;s/(&Prime;|&#8243;)/″/g ;s/(&lsaquo;|&#8249;)/‹/g ;s/(&rsaquo;|&#8250;)/›/g' \
		-e 's/(&oline;|&#8254;)/‾/g ;s/(&euro;|&#8364;)/€/g ;s/(&trade;|&#8482;)/™/g ;s/(&larr;|&#8592;)/←/g' \
		-e 's/(&uarr;|&#8593;)/↑/g ;s/(&rarr;|&#8594;)/→/g ;s/(&darr;|&#8595;)/↓/g ;s/(&harr;|&#8596;)/↔/g' \
		-e 's/(&crarr;|&#8629;)/↵/g' \
		-e '/^\s*var.*"script/d' \
		-e '/^var.*_comscore/ d' \
		-e 's/function\(\).*//' \
		-e 's/setTimeout.*//' \
		-e '/gtag\("event/ d' \
		-e '/^window.*taboola/ d' \
		-e 's/\.dot\{.*//' \
		-e 's/^.live-html.*//' \
		-e '/^Mais lidas\s*$/ d' \
		-e 's/Leia mais:.*//' -e 's/^\s*LEIA AQUI.*//' \
		-e 's/Leia tamb.m:.*//' \
		-e 's/Not.cias? relacionadas?:.*//' \
		-e 's/Em destaque:.*//' \
		-e 's/Urgente:.*//' \
		-e 's/Exclusivo:.*//' \
		-e '/^Voltar para página/ d' \
		-e '/^Ir para página/ d' \
		-e '/^\s*(COMPARTILHAR|SALVAR|LEIA AQUI|Ver mais)/ d' \
		-e '/^\s*(Rua Iguatemi, 192 -|.20[12][0-9] - O Antagonista)/,/^\s*CNPJ 25.163.879\/0001-13/ d'
}

#get antagonista links from initial page
getlinksf()
{
	sed -n "/id=['\"]post_[0-9]/ s|<a |\n&| gp" \
	| sed -nE "/(title=|<h2)/ s|.*href=['\"]([0-9a-zA-Z_.~\!*:;,@&=+/?#-]+)['\"\t ].*|\1| p" \
	| grep -v -e 'www.oantagonista.com/assine' -e "[]\"' {}<>[]" \
	| nl | sort -k2 | uniq -f 1 | sort -n | cut -f2
}
#get links cited in full articles
getlinksfullf()
{
	sed 's|a>|&\n|g' \
		| sed -nE "s|.*href=['\"]([^'\"]+)['\"].*|\1| p" \
		| sed -e "/twitter\.com\// s/\?[^\'\"]*//g" \
		| grep -v -e 'www.oantagonista.com/assine' \
		| nl | sort -k2 | uniq -f 1 | sort -n | cut -f2
}

# Check for errors
#the server does not send consistent error messages, so that is why this
#function is almost useless..
cerrf()
{
	NOTFOUND=
	if grep -aiq -e 'Você será redirecionado para a página inicial' \
		     -e 'Page not found' -e 'p.gina n.o encontrada' \
		     -e 'Error processing request' <<< "$PAGE" >&2
	then
		printf 'anta.sh: erro: página não encontrada -- %s\n' "$COMP" >&2
		NOTFOUND=1
	elif [[ -z "$PAGE" ]] || grep -aFiq -e 'has been limited' -e 'you were blocked' \
		-e 'to restrict access' -e 'access denied' -e 'temporarily limited' \
		-e 'you have been blocked' -e 'has been blocked' <<< "$PAGE" >&2
	then
		printf 'anta.sh: erro: acesso limitado ou página não encontrada -- %s\n' "$COMP" >&2
		return 1
	elif ! grep -aq '[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]' <<< "$PAGE" >&2
	then
		printf 'anta.sh: erro: não parece ser artigo de <oantagonista> -- %s\n' "$COMP" >&2
		NOTFOUND=1
	fi
	return 0
}

# Cheque por update
updatef() {
	trap updatecleanf EXIT TERM INT
	TMPFILE=$(mktemp)

	#download script from url
	${YOURAPP[0]} "${AGENTS[0]}" "$UPURL" >"$TMPFILE"

	#check diff
	if diff "$SCRIPT" "$TMPFILE" &>/dev/null; then
		echo 'anta.sh: aviso: o script está atualizado'
		((UPOPT<2))
	else
		#check if the two files headers are a bash SHEBANG
		#is that a script or html error page?
		if read HEADA <"$TMPFILE" && [[ $HEADA = \#\!*bash* ]]
		then
			#only check or install?
			if ((UPOPT>1))
			then 	install "$TMPFILE" "$SCRIPT"
			else 	echo -e "anta.sh: aviso: atualização disponível\n$UPURL"
				false
			fi
		else
			#print page with error
			[[ -e "$TMPFILE" ]] && cat "$TMPFILE"
			echo "$UPURL"
			false
		fi
	fi
}
#update clean up
updatecleanf() { 
	#disable trap
	trap \  EXIT TERM INT
	[[ -e "$TMPFILE" ]] && rm "$TMPFILE"
	exit
}

# Puxar páginas iniciais e testar por erros;
#tamanho: até ~2020 =~ 650KB; mar/2020 = 34KB, compressed 8.7KB; may/2021 = 372KB
puxarpgsf() {
	#skip if $COMP is only numbers
	[[ "$COMP" = +([0-9,.]) ]] && return 0
	# Se for só uma página inicial, acesse site sem 'pagina=1' (evita bloqueios)
	(( PAGINAS == 1 )) && [[ -z "$FULLOPT" ]] && COMP='/'

	SLEEP=5
	# Tentar puxar quantas páginas iniciais quiser e testar por erros
	for ((N=2 ;N<=TENTATIVAS ;N++))
	do
		#puxar a página
		#PAGE="$( ${YOURAPP[${RANDOM} % ${#YOURAPP[@]}]}  "${AGENTS[${RANDOM} % ${#AGENTS[@]}]}" "${SERVERS[${RANDOM} % ${#SERVERS[@]}]}/${COMP#/}" )"
		#make sure to get links from original server
		PAGE="$( ${YOURAPP[${RANDOM} % ${#YOURAPP[@]}]}  "${AGENTS[${RANDOM} % ${#AGENTS[@]}]}" "${SERVERS[0]}${SUBJECT}/${COMP#/}" )"

		#erros?
		cerrf && return 0
		#havendo erros, chamar curl mais uma vez
		printf '\ranta.sh: tentativa %s\n' "$N" 1>&2
		sleep "$SLEEP"
		(( SLEEP = SLEEP + 2 )) 
	done

	# Check if it was succesfull at last or exit with error
	if cerrf
	then 	return 0
	else 	return 1
	fi
}

# Pegar os textos curtos das Página(s) Inicial(is)
anta() {
	#timer de tempo de tarefa
	SECONDS=0
	# O for loop para pegar quantas páginas quiser
	for ((i=PAGINAS;i>=1;i--)); do
		#barra de acompanhamento
		printf '\r\033[2KPágina %s/%s\r' "$i" "$PAGINAS" 1>&2

		#puxar a página
		COMP="/pagina/${i}/"
		if ! puxarpgsf; then
			printf '\nanta.sh: erro -- acesso limitado  [%s]\n' "$SECONDS" 1>&2
			return 1
		#page not found?
		elif ((NOTFOUND))
		then 	return 0
		fi

		#imprime a página e processa
		POSTS="$( <<<"$PAGE" sed -nE '/<div id="p[0-9]+"/,/id="mais-lidas"/ p' | sed  '$d' | sed -n '/<article.*/,/<\/article/ p' )"

		#continue if $OLDPOSTS and $POSTS are the same (-r OPTION)
		if ((ROLLOPT)) && [[ "$POSTS" = "$OLDPOSTS" ]]
		then 	:
		#process posts
		else 	#print links
			getlinksf <<<"$PAGE" | tac
			echo '==='
			<<<"$POSTS" sed -E \
				-e '/class="timer-icon"><\/span>[0-9]+ (ano|dia|semana|me|mese|hora|minuto|segundo)s? atr.s/d' \
				-e 's/[^pagm]>/&\n/g ;s/<\/article[^>]*>/&\n===/g' \
				-e '/id="noa_carregarmais/,$ d' \
			    	-e 's/>Not.cias relacionadas:.*/>/' \
				-e 's/>Mais lidas:?<.*/>/' \
				-e 's/>Leia mais:?<.*/>/' \
				-e 's/>LEIA AQUI<.*/>/' \
				-e 's/>Leia tamb.m:?<.*/>/' \
				-e 's/>Not.cias? relacionadas?:?<.*/>/' \
				-e 's/>Em destaque:?<.*/>/' \
				-e 's/>Urgente:?<.*/>/' \
				-e 's/>Exclusivo:?<.*/>/' \
				| sedhtmlf \
				| tac -r -s'^===' \
				| awk NF
				#-e '/id="noa_carregarmais/,/id="collect/ d'
		fi
		OLDPOSTS="$POSTS"
		
		#parar se foi especificado número de index de pg específica
		(( ONLYONE )) && break
		#dont flood the server
		sleep "$FLOOD"
	done

	#hora que terminou
	(( ROLLOPT )) && PRINTT="(${TEMPO[*]})"
	printf '>Puxado em %s  %s [%s]\n' "$(date -R)" "$PRINTT" "$SECONDS"
}
#also works: grep -F -B13 '<p>' <<<"$PAGE" | sedhtmlf | awk NF
#for the FEED, check
#https://www.oantagonista.com/feed/

# -f Artigos inteiros
fulltf() {
	local cab art hrefs p auth grav
	
	#ver se notícia é do MoneyTimes
	#ou outros domínios
	if [[ "$COMP" = *moneytimes/* ]] || [[ "$COMP" = */portalig/* ]]
	then
		[[ -t 1 ]] && echo -e '\033[2K' >&2
		echo -e '====        '
		echo 'anta.sh: aviso: possível redireção a site de outro domínio'
		echo "$COMP"
		return 0
	else
		#puxa página do artigo texto integral
		if ! puxarpgsf
		then 	printf '\nanta.sh: erro: acesso limitado -- %s  [%s]\n' "$COMP" "$SECONDS" >&2
			return 1
		#page not found?
		elif ((NOTFOUND))
		then 	return 0
		fi
	fi


	#cabeçalho
	cab="$( 
		<<<"$PAGE" grep -aF \
			-e '="entry-title' \
			-e 'entry-date published' \
			-e '"entry-author' \
			-e '<div class="gravata' \
			| grep -aFv 'class="timer-icon' \
			| sed -E -e 's/^#breadcrumbs.*}\s?//' \
			-e 's/.*<div class="gravata.*/[&]\n<layout>\n/'
	)"
	auth=$(<<<"$PAGE" grep -FA20 'id="noa_mini_author"' | sed -En 's/.*<span>(.*)<\/span>.*/\1/p'|sed -n 's/<[^>]*>//g ;1p')
	grav="$( <<<"$PAGE" grep -cF '<div class="gravata' )"

	#artigo
	art="$(
		#processa página

		#processa página
		#get all lines with <p>
		if [[ "$COMP" = */podcast/* ]]
		then 	#if podcast grep only description line
			<<<"$PAGE" sed -n '/^\s*<p>/p'
		else 	#get all lines with <p> for all other pages
			<<<"$PAGE" sed -E \
				-e '/class="timer-icon"><\/span>[0-9]+ (ano|dia|semana|me|mese|hora|minuto|segundo)s? atr.s/d' \
				-e '/(class=.*contato_reda..o|class="reda..o)/ d' \
			    	-e 's/>Not.cias relacionadas:.*/>/' \
				-e 's/>Mais lidas:?<.*/>/' \
				-e 's/>Leia mais:?<.*/>/' \
				-e 's/>LEIA AQUI<.*/>/' \
				-e 's/>Leia tamb.m:?<.*/>/' \
				-e 's/>Not.cias? relacionadas?:?<.*/>/' \
				-e 's/>Em destaque:?<.*/>/' \
				-e 's/>Urgente:?<.*/>/' \
				-e 's/>Exclusivo:?<.*/>/' \
				| sed -n 's/<p>/\n&/gp' | sed -n 's/<\/p>/\n&/gp'
		fi | sed -e '/>Leia também[<:]/d' \
			    -e 's/>Assine a <strong>Crusoé<.*/>/' \
			    -e '/id="comentarios"/,$ d' \
			    -e '/>LEIA MAIS</d' \
			    -e '/>Leia mais:*</d' \
			    -e '/>Mais lidas</d' \
			    -e 's/<[^<]*next_prev_title.*//' \
			    -e 's/>Usamos cookies.*/>/' \
			    -e '/>Política de Cookies/d' \
			    -e '/^Acompanhe nossas notícias/d' \
			    -e '/^Acesse nossa página no/d' \
			    -e 's/<.*id="linkcopy".*>//g' \
			    -e '/>Not.cias relacionadas:/d' \
			    -e 's/class="fraseleiamais.*/>/' \
			    -e 's|<a|[*][&|g ;s|</a|]&|g' \
			    -e 's|\[\*\]\[\s*\]\s*||g' \
			    -e 's/<\/li>/&\n/g ;s/<\/[ou]l>/&\n<layout>\n/g' 
	)"
	#https://stackoverflow.com/questions/5315464/email-formatting-basics-links-in-plain-text-emails
	
	#get link references
	hrefs=( $(getlinksfullf <<<"$art") )
	
	#remove html tags, more processing of article
	art="$(
		sedhtmlf <<<"$art"
	)"

	#contar parágrafos
	par="$(p=$grav ;while read; do [[ -n "${REPLY// }" ]] || continue; ((++p)); done <<<"$art"; echo "$p")"

	{
		#print header and add the number of paragraphs
		[[ -t 1 ]] && echo -e '\033[2K' >&2
		echo '====        '
		#print article
		sedhtmlf <<<"$cab" | sed "/^[0-9][0-9]\.[0-9][0-9]\./ s/$/ [\$\$ $par]\n$auth\n/"
		echo "$art"

		#print article refs
		(( ${#hrefs[@]} )) &&
			printf '\n* %s' "Refs[${#hrefs[@]}]:" "${hrefs[@]}"

		#print footer
		printf '\nhttps://www.oantagonista.com/%s\n' "${COMP#/}"

	} | awk '!NF {if (++n <= 1) print; next}; {n=0;print}'
	    #^collapse multiple bank lines

	return 0
}
#article index number?
#https://www.oantagonista.com/brasil/399950/
#https://www.oantagonista.com/brasil/bolsonarista-preso-ontem-e-apontado-como-financiador-de-acampamentos/
#try not to break html processing at
#www.oantagonista.com/brasil/como-votou-cada-deputado-no-destaque-da-facada-em-paulo-guedes/
#https://www.oantagonista.com/frases-da-semana/as-frases-da-semana-em-que-o-ministro-interino-da-saude-rezou/
#https://www.oantagonista.com/podcast/podcast-viva-la-muerte/
#https://www.oantagonista.com/brasil/o-stf-esta-disposto-a-ajudar-davi-alcolumbre/
#https://www.oantagonista.com/brasil/renan-calheiros-anuncia-lista-de-14-investigados-pela-cpi/

# Puxar links das páginas iniciais
# e puxar artigos completos
linksf() {
	local ret
	#timer de tempo execução de tarefa
	SECONDS=0
	# Check for user-suppplied links
	if [[ "$*" = */* ]]
	then
		for i
		do 	# Arrumar variável para passar nos testes da 'puxarpgsf'
			PAGINAS=0
			COMP="${i,,}"
			COMP="${COMP//https:\/\/www.oantagonista.com}"
			fulltf ;((ret+=$?))
		done
	else
		# Get Links from initial pages
		for ((i=PAGINAS;i>=1;i--))
		do 	#barra de acompanhamento
			printf '\r\033[2KLinks %s/%s\r' "$i" "$PAGINAS" 1>&2

			#prepara o link da página inicial a ser puxada
			export COMP="/pagina/${i}/"

			#puxa pgs iniciais
			puxarpgsf

			#pega links para artigos integrais
			LINKS=$(getlinksf <<<"$PAGE")

			#crawl each link
			while read COMP
			do 	#avoid duplicate articles links
				if [[ "${LINKSBUFFER[*]}" = *"$COMP"* ]]
				then 	continue
				else 	LINKSBUFFER+=("$COMP")
				fi

				#get full article page
				fulltf || { ((ret+=1)) ;continue ;}
				#dont flood the server
				sleep "$FLOOD"

			done <<<"$(tac <<<"${LINKS//https:\/\/www.oantagonista.com/}" )"
			
			sleep "$FLOOD"

			#parar se foi especificado número de index de pg específica
			(( ONLYONE )) && break
		done

		#hora que terminou tarefa
		(( ROLLOPT )) && PRINTT="(${TEMPO[*]})"
		printf '>Puxado em %s  %s [%s]\n' "$(date -R)" "$PRINTT" "$SECONDS"
	fi
	return $ret
}

## Puxar funções das opções
selectf()
{
	#opção padrão
	#se tiver args posicionais (índices de páginas inciais)
	#ou setado -NUM, ou se for opção padrão
	#(puxar somente a primeira página inicial)
	if (($#)) || (( PAGINAS )) || {
		 (( ROLLOPT + PAGINAS == 0 )) && PAGINAS=1
	}
	then 	#opção -f, textos completo
		if (( FULLOPT ))
		then 	#index opt
			if (( ONLYONE ))
			then 	#indicies de pgs como arg posicionais
				for PAGINAS
				do 	linksf ;((RET+=$?))
				done
			else 	#opção padrão, puxar primeira pg e sair, ou -NUM
				linksf "$@"
				((RET+=$?))
			fi
		else
			#só os resumos das matérias das pgs iniciais, index opt
			if (( ONLYONE ))
			then 	#indices de pgs como arg posicionais
				for PAGINAS
				do 	anta ;((RET+=$?))
				done
			else 	#opção padrão, puxar primeira pg e sair, ou -NUM
				anta ;((RET+=$?))
			fi
		fi
	fi

	# -r Anta Rolante
	if (( ROLLOPT ))
	then
		echo "anta.sh: opção antagonista rolante" >&2

		#loop forever
		#then set to always get first page
		XAGAIN=780  AGAIN="$XAGAIN"
		[[ "$PAGINAS" = 0 ]] || PAGINAS=1
		while :
		do 	# Loop para puxar as notícias
			while :
			do 	if (( FULLOPT ))
				then 	linksf || break
				else 	anta || break
				fi
				
				sleep "${TEMPO[@]}"
				[[ "$PAGINAS" = 0 ]] && PAGINAS=1
			done

			#grand retry timer
			((AGAIN > 980)) && AGAIN="$XAGAIN"
			AGAIN="$((AGAIN+180))"

			#grand retry
			printf '\nanta.sh: aviso -- aguardando %s minutos..\n' "$((AGAIN/60))" 1>&2
			sleep "$AGAIN"
		done
	fi
}


## Parse options
while getopts :afwhlp:rs:uv0123456789 opt
do
	case $opt in
		[0-9]) 	PAGINAS="${PAGINAS}${opt}"
			;;
		a) 	#use alternative servers
			OPTALT=1
			;;
		f|w) 	# Textos completos (Full text)
			FULLOPT=1
			;;
		h) 	# Print Help
			echo "$HELP" ;exit 0
			;;
		l) 	echo "${0##*/}: warning -- option -l is deprecated."$'\n'"Pipe to \`less' manually." >&2 ;;
		p) 	PAGINAS="$OPTARG"
			;;
		r) 	# Anta Rolante
			ROLLOPT=1
			;;
		s) 	#tempo entre reacessos
			TEMPO=($OPTARG)
			;;
		u) 	# Checar update ou realizar o update
			((++UPOPT))
			;;
		v) 	# Version of Script
			grep -Fm1 '# v' "${BASH_SOURCE[0]}" ;exit
			;;
		\?) 	# Invalid opt
			echo "anta.sh: erro: opção inválida -- -$OPTARG" >&2 ;exit 1
			;;
	esac
done
shift $((OPTIND -1))

# Test if cURL and Wget are available
if command -v curl &>/dev/null
then YOURAPP=("curl --compressed -s --retry $RETRIES --max-time $TOUT -L -b non-existing -H")
fi
if command -v wget2 &>/dev/null
then YOURAPP+=("wget2 -t$RETRIES -T$TOUT -qO- --header")
elif command -v wget &>/dev/null
then YOURAPP+=("wget -t$RETRIES -T$TOUT -qO- --header")
fi
if ((${#YOURAPP[@]}==0))
then echo 'anta.sh: erro: curl e/ou wget é necessário' >&2 ;exit 1
fi

#-a use alternative servers, too?
if (( OPTALT ))
then SERVERS=( "${SERVERS[@]}" "${ALTSERVERS[@]}" )
#opção de checagem ou realização da atualização do script
elif ((UPOPT))
then updatef ;exit
fi

#lista de assuntos/categorias
[[ "${1//\/}" = podcast ]] && set -- videos "${@:2}"
if [[ \ "${SUBLIST[*]}"\  = *\ "${1//\/}"\ * ]]
then
	echo 'anta.sh: assunto detectado' >&2
	SUBJECT=/"${1//\/}" ;shift
elif [[ "$1" = ?(http?(s)://www.oantagonista.com/|/)tag/?* ]]
then
	echo 'anta.sh: tag/assunto detectado' >&2
	SUBJECT="${1#https://www.oantagonista.com}"  SUBJECT=/"${SUBJECT#/}"
	SUBJECT="${SUBJECT%/}" ;shift
elif [[ "$1" = *(/)tag*(/) ]]
then
	echo "anta.sh: tag/ requer um ASSUNTO" >&2
	exit 1
fi

#setar variáveis das próximas opções
#usar opção -f se especificar uma URL
if [[ "$*" = */* ]]; then
	echo 'anta.sh: link detectado' >&2
	FULLOPT=1
	unset ROLLOPT
#pegar só uma página por número
elif [[ "$*" = +([0-9\ ]) ]]; then
	echo 'anta.sh: índice detectado' >&2
	ONLYONE=1
	#unset ROLLOPT
fi

#selecionar opção
selectf "$@"
exit $RET
