SELECT  201 CD_CIA,
        tcemm030.t$euca CD_FILIAL,
		tcemm112.t$grid CD_UNIDADE_EMPRESARIAL,
        ltrim(rtrim(znwmd200.t$item$c)) CD_ITEM,
        znwmd200.t$qtdf$c - znwmd200.t$sald$c QT_RESERVADA,
        znwmd200.t$qtdf$c QT_ARQUIVO,
        znwmd200.t$sald$c QT_SALDO,
		CAST((FROM_TZ(CAST(TO_CHAR(znwmd200.t$rcd_utc, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
				AT time zone sessiontimezone) AS DATE) DT_ATUALIZACAO
FROM    tznwmd200201 znwmd200,
        ttcemm112201 tcemm112,
		ttcemm030201 tcemm030
WHERE   tcemm112.t$waid = znwmd200.t$cwar$c
AND 	tcemm030.t$eunt=tcemm112.t$grid
