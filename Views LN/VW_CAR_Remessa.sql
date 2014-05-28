SELECT DISTINCT
	tfcmg948.t$bank$l CD_BANCO,
	tfcmg948.t$btno$l NR_REMESSA,
	tfcmg948.t$docd$l DT_REMESSA,
	tfcmg011.t$agcd$l NR_AGENCIA,
	tfcmg948.t$acco$l NR_CONTA,
    201 CD_CIA,
	tfcmg948.t$stat$l CD_SITUACAO_ARQUIVO,
	tfcmg948.t$send$l CD_SITUACAO_REMESSA,
	CAST((FROM_TZ(CAST(TO_CHAR(tfcmg948.t$lach$l, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE) DT_ATUALZACAO
FROM
	ttfcmg948201 tfcmg948
	LEFT JOIN ttfcmg001201 tfcmg001
	ON  tfcmg001.t$bank=tfcmg948.t$bank$l
	LEFT JOIN ttfcmg011201 tfcmg011
	ON  tfcmg011.t$bank=tfcmg001.t$brch