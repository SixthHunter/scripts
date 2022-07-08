#!/bin/bash
# cep.sh  --  cep por nome de rua e vice-versa
# v0.3.9  jun/2022  by mountaineerbr

SN="${0##*/}"
SCRIPT_PATH="$0"

#help page
HELP="NOME
	$SN - CEP por Nome de Rua e Vice-Versa, API dos Correios


SINOPSE
	$SN [-s] [NOME DO LOGRADOURO|CEP] [ESTADO|BAIRRO]
	$SN [-hv]


DESCRIÇÃO
	Puxa o CEP de um logradouro pelo seu nome ou puxa o nome
	do logradouro pelo número de CEP.

	Não utilize acentos, número de casa/apto/lote/prédio ou
	abreviações.


VEJA TAMBÉM
	Site de CEP dos Correios
	<https://buscacepinter.correios.com.br/app/endereco/index.php?t>

	Tópico de fórum onde idea do script apareceu pela primeira vez
	<https://www.vivaolinux.com.br/topico/Sed-Awk-ER-Manipulacao-de-Textos-Strings/CEP-pela-Shell>


GARANTIA
	Licenciado sob a proteção da GNU Public License v3 ou melhor.
	Distribuição ABSOLUTAMENTE SEM SUPORTE.
   	
	Este script requer bash, jq e curl ou wget para funcionar
	corretamente.

	Gorjetas para bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr .


BUGS
	Máximo de 1000 resultados pela API dos Correios.


EXEMPLOS DE USO
	$SN Rua Higienopolis Guarulhos
	$SN 07140-190


OPÇÕES
	-s 	CEP sem hífen.
	-h 	Página de ajuda.
	-v 	Versão do script."


#functions

#convert latin chars to ascii
convf()
{
	local input char n setX setY
	input="$*"

	setX=(
	#ISO Latin 1 character 
	À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ø ù ú û ü ý þ ÿ

	#ISO Latin 1 Extended A character 
	Ā ā Ă ă Ą ą Ć ć Ĉ ĉ Ċ ċ Č č Ď ď Đ đ Ē ē Ĕ ĕ Ė ė Ę ę Ě ě Ĝ ĝ Ğ ğ Ġ ġ Ģ ģ Ĥ ĥ Ħ ħ Ĩ ĩ Ī ī Ĭ ĭ Į į İ ı Ĳ ĳ Ĵ ĵ Ķ ķ ĸ Ĺ ĺ Ļ ļ Ľ ľ Ŀ ŀ Ł ł Ń ń Ņ ņ Ň ň ŉ Ŋ ŋ Ō ō Ŏ ŏ Ő ő Œ œ Ŕ ŕ Ŗ ŗ Ř ř Ś ś Ŝ ŝ Ş ş Š š Ţ ţ Ť ť Ŧ ŧ Ũ ũ Ū ū Ŭ ŭ Ů ů Ű ű Ų ų Ŵ ŵ Ŷ ŷ Ÿ Ź ź Ż ż Ž ž ſ
	)
	setY=(
	a a a a a a a c e e e e i i i i e n o o o o o o u u u u y p s a a a a a a a c e e e e i i i i e n o o o o o o u u u u y p y
	a a a a a a c c c c c c c c d d d d e e e e e e e e e e g g g g g g g g h h h h i i i i i i i i i i i i j j k k k l l l l l l l l l l n n n n n n n n n o o o o o o o o r r r r r r s s s s s s s s t t t t t t u u u u u u u u u u u u w w y y y z z z z z z s
	)
	for char in "${setX[@]}"
	do 	input="${input//"$char"/${setY[n++]}}"
	done
	echo "$input"
}
#https://docs.oracle.com/cd/E29584_01/webhelp/mdex_basicDev/src/rbdv_chars_mapping.html
#https://stackoverflow.com/questions/10207354/how-to-remove-all-of-the-diacritics-from-a-file
#iconv -f utf-8 -t ascii//translit

#main
mainf()
{
	local input pvar pini pfim url data t

	#retirar espaços em branco e acentos do input
	input=$(convf "$@" | tr \  +)
	
	#bucar resultados
	((pvar = 50 ,  pini = 1  , pfim = pvar))
	while
		#url="https://buscacepinter.correios.com.br/app/endereco/carrega-cep-endereco.php?pagina=%2Fapp%2Fendereco%2Findex.php&cepaux=&mensagem_alerta=&endereco=${input}&tipoCEP=ALL&inicio=${pini}&final=${pfim}"
		url='https://buscacepinter.correios.com.br/app/endereco/carrega-cep-endereco.php'
		postd="pagina=%2Fapp%2Fendereco%2Findex.php&cepaux=&mensagem_alerta=&endereco=$input&tipoCEP=ALL$( ((pini>1)) && echo "&inicio=${pini}&final=${pfim}" )"
		data=$(
			if command -v curl &>/dev/null
			then 	curl -L -\# "$url" --data-raw "$postd"
			else 	wget -qO- --show-progress "$url" --post-data="$postd"
			fi | jq -er . 2>/dev/null
		)
	do
		#error message in json?
		if jq -e .erro <<<"$data" &>/dev/null
		then 	jq .mensagem <<<"$data" >&2
			return 1
		fi

		t=$(jq -r .total <<<"$data")
		((pini = pini + pvar))
		((pfim = pfim + pvar))

		#format data in tables
		jq -r '.dados[] | "\(.cep)\t\(.uf)\t\(.localidade)\t\(.bairro)\t\(.logradouroDNEC)\t\(.numeroLocalidade)\t\(.logradouroTextoAdicional)\t\(.nomeUnidade)\t\(.situacao)"' <<<"$data" \
			| column -dts$'\t' -N1,2,3,4,5,6,7,8,9 -T4,7,8,9 \
			| sed ${OPTS[@]} -e 's/\s*$//'
		
		if ((pfim > t))
		then 	jq -r .mensagem <<<"$data" | grep -vi sucesso && return 1
			return 0
		fi

		#tente evitar throttle
		sleep 0.6
	done
}


#ativar cep com hífen: xxxxx-xxx
OPTS=(-r -e 's/^([0-9]{5})([0-9]{3})/\1-\2/')

#parse options
while getopts :hsv c
do case $c in
	s) OPTS=() ;;
	h) echo "$HELP"; exit 0	;;
	v) grep -m1 '^# v[0-9]' "$0" ;exit ;;
   esac
done
shift $(( OPTIND - 1 ))
unset c

#check arguments
if [[ -z "${*// }" ]]
then echo "$HELP" ;exit 1
fi

#required packages
if ! command -v jq &>/dev/null
then echo "$SN: err  -- jq is required" >&2 ;exit 1
fi

#call opt functions
mainf "$@"

