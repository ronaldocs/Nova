SELECT DISTINCT
        wmsCODE.UDF1            FILIAL,
       wmsCODE.UDF2         DSC_PLANTA,
       TDSLS400.T$ORNO           PEDIDO_LN,
       ZNSLS004.T$PECL$C         PEDIDO_SITE,
       OWMS.ORDERKEY             ORDEM_WMS,
       TDSLS400.T$CBRN         	 ID_UNEG,
       TCMCS031.T$DSCA         	 DESCR_UNEG,
       TDSLS420.T$HREA         	 ID_ULT_PONTO,
       TDSLS090.T$DSCA           DESCR_ULT_PONTO,
       TRIM(ZNSLS004.T$ITEM$C)   ITEM, 
     SYSDATE -
	   (SELECT MAX(A.T$DTBL)
		FROM BAANDB.TTDSLS421301 A
		WHERE A.T$ORNO = TDSLS420.T$ORNO
		AND A.T$PONO = TDSLS420.T$PONO
		AND A.T$SQNB = TDSLS420.T$SQNB
		AND A.T$CSQN = TDSLS420.T$CSQN
		AND A.T$HREA = TDSLS420.T$HREA) 
                                 TEMPO_STAUS
     
FROM BAANDB.TTDSLS400301 TDSLS400

 INNER JOIN	BAANDB.TTDSLS401301	TDSLS401
		ON	TDSLS401.T$ORNO = TDSLS400.T$ORNO

 LEFT JOIN ( select A.T$NCIA$C,
                    A.T$UNEG$C,
                    A.T$PECL$C,
                    A.T$SQPD$C,
                    A.T$ENTR$C,
                    A.T$ORNO$C,
                    B.T$ITEM$C,
                    B.T$CWRL$C,
                    MIN(B.T$DTAP$C) T$DTAP$C
               from BAANDB.TZNSLS004301 A
         inner join BAANDB.TZNSLS401301 B 
                 on B.T$NCIA$C = A.T$NCIA$C
                and B.T$UNEG$C = A.T$UNEG$C
                and B.T$PECL$C = A.T$PECL$C
                and B.T$SQPD$C = A.T$SQPD$C
                and B.T$ENTR$C = A.T$ENTR$C
                and B.T$SEQU$C = A.T$SEQU$C
           group by A.T$NCIA$C,
                    A.T$UNEG$C,
                    A.T$PECL$C,
                    A.T$SQPD$C,
                    A.T$ENTR$C,
                    A.T$ORNO$C,
                    B.T$ITEM$C,
                    B.T$CWRL$C) ZNSLS004
        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO
    
 LEFT JOIN BAANDB.TTCMCS031301 TCMCS031
        ON TCMCS031.T$CBRN = TDSLS400.T$CBRN
    
 LEFT JOIN BAANDB.TTDSLS420301 TDSLS420
		ON	TDSLS420.T$ORNO	=	TDSLS401.T$ORNO

    
  LEFT JOIN BAANDB.TTDSLS090301 TDSLS090
    ON  TDSLS090.T$HREA = TDSLS420.T$HREA
 
 INNER JOIN BAANDB.TTCEMM300301 TCEMM300
	ON	TCEMM300.T$COMP = 301
	AND	TCEMM300.T$TYPE = 20
	AND	TRIM(TCEMM300.T$CODE) = TRIM(TDSLS401.T$CWAR)
	

 INNER JOIN ( SELECT 	A.LONG_VALUE,
						UPPER(A.UDF1) UDF1,
						A.UDF2
			  FROM	ENTERPRISE.CODELKUP@DL_LN_WMS A
			  WHERE A.LISTNAME = 'SCHEMA') wmsCODE
	ON	wmsCODE.LONG_VALUE = TCEMM300.T$LCTN
	
 LEFT JOIN ( SELECT MAX(B.ORDERKEY) ORDERKEY,
					B.REFERENCEDOCUMENT
			 FROM WMWHSE5.ORDERS@DL_LN_WMS B
			 GROUP BY B.REFERENCEDOCUMENT) OWMS 
	ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO
				
		
 WHERE TDSLS420.T$HREA IN ('AES', 'PRD', 'TNA', 'AEW')
   AND TDSLS400.T$HDST NOT IN (30, 35)
--   AND wmsCODE.FILIAL :Table



"SELECT wmsCODE.FILIAL            FILIAL,          " &
"       wmsCODE.ID_FILIAL         DSC_PLANTA,      " &
"       TDSLS400.T$ORNO           PEDIDO_LN,       " &
"       ZNSLS004.T$PECL$C         PEDIDO_SITE,     " &
"       OWMS.ORDERKEY             ORDEM_WMS,       " &
"       ZNSLS004.T$UNEG$C         ID_UNEG,         " &
"       ZNINT002.T$DESC$C         DESCR_UNEG,      " &
"       ZNSLS410.T$POCO$C         ID_ULT_PONTO,    " &
"       ZNMCS002.T$DESC$C         DESCR_ULT_PONTO, " &
"       TRIM(ZNSLS004.T$ITEM$C)   ITEM,            " &
"       ZNSLS410.T$DTOC$C -                        " &
"     ( SELECT MAX(B.T$DTOC$C)                     " &
"         FROM BAANDB.TZNSLS410301@PLN01 B         " &
"        WHERE B.T$NCIA$C = ZNSLS410.T$NCIA$C      " &
"          AND B.T$UNEG$C = ZNSLS410.T$UNEG$C      " &
"          AND B.T$PECL$C = ZNSLS410.T$PECL$C      " &
"          AND B.T$POCO$C != ZNSLS410.T$POCO$C     " &
"          AND B.T$DTOC$C < ZNSLS410.T$DTOC$C )    " &
"                                 TEMPO_STAUS      " &
"                                                  " &
"FROM BAANDB.TTDSLS400301@PLN01 TDSLS400           " &
"                                                  " &
" LEFT JOIN ( select A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C,                   " &
"                    MIN(B.T$DTAP$C) T$DTAP$C      " &
"               from BAANDB.TZNSLS004301@PLN01 A   " &
"         inner join BAANDB.TZNSLS401301@PLN01 B   " &
"                 on B.T$NCIA$C = A.T$NCIA$C       " &
"                and B.T$UNEG$C = A.T$UNEG$C       " &
"                and B.T$PECL$C = A.T$PECL$C       " &
"                and B.T$SQPD$C = A.T$SQPD$C       " &
"                and B.T$ENTR$C = A.T$ENTR$C       " &
"                and B.T$SEQU$C = A.T$SEQU$C       " &
"           group by A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C) ZNSLS004          " &
"        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO    " &
"                                                  " &
" LEFT JOIN BAANDB.TZNINT002301@pln01 ZNINT002     " &
"        ON ZNINT002.T$NCIA$C = ZNSLS004.T$NCIA$C  " &
"       AND ZNINT002.T$UNEG$C = ZNSLS004.T$UNEG$C  " &
"                                                  " &
" LEFT JOIN ( select MAX(C.T$POCO$C) KEEP          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$POCO$C, " &
"                    MAX(C.T$DTOC$C) KEEP                                          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$DTOC$C, " &
"                    C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"               from BAANDB.TZNSLS410301@pln01 C    " &
"           group by C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"                    ) ZNSLS410                     " &
"        ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C   " &
"       AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C   " &
"       AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C   " &
"       AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C   " &
"       AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C   " &
"                                                   " &
" LEFT JOIN BAANDB.TZNMCS002301@pln01 ZNMCS002      " &
"        ON ZNMCS002.T$POCO$C = ZNSLS410.T$POCO$C   " &
"                                                   " &
"INNER JOIN ( select upper(wmsCODE.UDF1) Filial,    " &
"                   wmsCODE.UDF2 ID_FILIAL,         " &
"                   a.t$code cwar                   " &
"              from baandb.ttcemm300301@PLN01 a     " &
"         left join ENTERPRISE.CODELKUP wmsCode     " &
"                on UPPER(TRIM(wmsCode.DESCRIPTION)) = a.t$lctn " &
"               and wmsCode.LISTNAME = 'SCHEMA'     " &
"             where a.t$type = 20                   " &
"               and wmsCODE.UDF1 is not null        " &
"          group by upper(wmsCODE.UDF1),            " &
"                   wmsCODE.UDF2,                   " &
"                   a.t$code)  wmsCODE              " &
"        ON wmsCODE.CWAR = ZNSLS004.T$CWRL$C              " &
"                                                         " &
" LEFT JOIN  " + Parameters!Table.Value + ".ORDERS OWMS   " &
"        ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO      " &
"		                                                  " &
" WHERE ZNSLS410.T$POCO$C IN ('AES', 'PRD', 'TNA', 'AEW') " &
"   AND CASE WHEN ZNSLS410.T$POCO$C = 'PRD'               " &
"             AND ( SELECT COUNT(A.ORDERKEY)              " &
"                     FROM " + Parameters!Table.Value + ".ORDERS A    " &
"                    WHERE A.REFERENCEDOCUMENT = OWMS.REFERENCEDOCUMENT " &
"                      AND A.STATUS != '100' ) >= 1       " &
"              THEN 1                                     " &
"            ELSE 0                                       " &
"        END = 0                                          " &
"   AND TDSLS400.T$HDST NOT IN (30, 35)                   " &
"   AND wmsCODE.FILIAL = '" + Parameters!Table.Value + "' " &
"                                                         " &
"Order by 2,3,4                                           "

,
   
"SELECT wmsCODE.FILIAL            FILIAL,          " &
"       wmsCODE.ID_FILIAL         DSC_PLANTA,      " &
"       TDSLS400.T$ORNO           PEDIDO_LN,       " &
"       ZNSLS004.T$PECL$C         PEDIDO_SITE,     " &
"       OWMS.ORDERKEY             ORDEM_WMS,       " &
"       ZNSLS004.T$UNEG$C         ID_UNEG,         " &
"       ZNINT002.T$DESC$C         DESCR_UNEG,      " &
"       ZNSLS410.T$POCO$C         ID_ULT_PONTO,    " &
"       ZNMCS002.T$DESC$C         DESCR_ULT_PONTO, " &
"       TRIM(ZNSLS004.T$ITEM$C)   ITEM,            " &
"       ZNSLS410.T$DTOC$C -                        " &
"     ( SELECT MAX(B.T$DTOC$C)                     " &
"         FROM BAANDB.TZNSLS410301@PLN01 B         " &
"        WHERE B.T$NCIA$C = ZNSLS410.T$NCIA$C      " &
"          AND B.T$UNEG$C = ZNSLS410.T$UNEG$C      " &
"          AND B.T$PECL$C = ZNSLS410.T$PECL$C      " &
"          AND B.T$POCO$C != ZNSLS410.T$POCO$C     " &
"          AND B.T$DTOC$C < ZNSLS410.T$DTOC$C )    " &
"                                 TEMPO_STAUS      " &
"                                                  " &
"FROM BAANDB.TTDSLS400301@PLN01 TDSLS400           " &
"                                                  " &
" LEFT JOIN ( select A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C,                   " &
"                    MIN(B.T$DTAP$C) T$DTAP$C      " &
"               from BAANDB.TZNSLS004301@PLN01 A   " &
"         inner join BAANDB.TZNSLS401301@PLN01 B   " &
"                 on B.T$NCIA$C = A.T$NCIA$C       " &
"                and B.T$UNEG$C = A.T$UNEG$C       " &
"                and B.T$PECL$C = A.T$PECL$C       " &
"                and B.T$SQPD$C = A.T$SQPD$C       " &
"                and B.T$ENTR$C = A.T$ENTR$C       " &
"                and B.T$SEQU$C = A.T$SEQU$C       " &
"           group by A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C) ZNSLS004          " &
"        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO    " &
"                                                  " &
" LEFT JOIN BAANDB.TZNINT002301@pln01 ZNINT002     " &
"        ON ZNINT002.T$NCIA$C = ZNSLS004.T$NCIA$C  " &
"       AND ZNINT002.T$UNEG$C = ZNSLS004.T$UNEG$C  " &
"                                                  " &
" LEFT JOIN ( select MAX(C.T$POCO$C) KEEP          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$POCO$C, " &
"                    MAX(C.T$DTOC$C) KEEP                                          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$DTOC$C, " &
"                    C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"               from BAANDB.TZNSLS410301@pln01 C    " &
"           group by C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"                    ) ZNSLS410                     " &
"        ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C   " &
"       AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C   " &
"       AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C   " &
"       AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C   " &
"       AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C   " &
"                                                   " &
" LEFT JOIN BAANDB.TZNMCS002301@pln01 ZNMCS002      " &
"        ON ZNMCS002.T$POCO$C = ZNSLS410.T$POCO$C   " &
"                                                   " &
"INNER JOIN ( select upper(wmsCODE.UDF1) Filial,    " &
"                   wmsCODE.UDF2 ID_FILIAL,         " &
"                   a.t$code cwar                   " &
"              from baandb.ttcemm300301@PLN01 a     " &
"         left join ENTERPRISE.CODELKUP wmsCode     " &
"                on UPPER(TRIM(wmsCode.DESCRIPTION)) = a.t$lctn " &
"               and wmsCode.LISTNAME = 'SCHEMA'     " &
"             where a.t$type = 20                   " &
"               and wmsCODE.UDF1 is not null        " &
"          group by upper(wmsCODE.UDF1),            " &
"                   wmsCODE.UDF2,                   " &
"                   a.t$code)  wmsCODE              " &
"        ON wmsCODE.CWAR = ZNSLS004.T$CWRL$C              " &
"                                                         " &
" LEFT JOIN WMWHSE1.ORDERS OWMS                           " &
"        ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO      " &
"		                                                  " &
" WHERE ZNSLS410.T$POCO$C IN ('AES', 'PRD', 'TNA', 'AEW') " &
"   AND CASE WHEN ZNSLS410.T$POCO$C = 'PRD'               " &
"             AND ( SELECT COUNT(A.ORDERKEY)              " &
"                     FROM WMWHSE1.ORDERS A               " &
"                    WHERE A.REFERENCEDOCUMENT = OWMS.REFERENCEDOCUMENT " &
"                      AND A.STATUS != '100' ) >= 1       " &
"              THEN 1                                     " &
"            ELSE 0                                       " &
"        END = 0                                          " &
"   AND TDSLS400.T$HDST NOT IN (30, 35)                   " &
"   AND wmsCODE.FILIAL = 'WMWHSE1'                        " &
"                                                         " &
"Union                                                    " &
"                                                         " &
"SELECT wmsCODE.FILIAL            FILIAL,          " &
"       wmsCODE.ID_FILIAL         DSC_PLANTA,      " &
"       TDSLS400.T$ORNO           PEDIDO_LN,       " &
"       ZNSLS004.T$PECL$C         PEDIDO_SITE,     " &
"       OWMS.ORDERKEY             ORDEM_WMS,       " &
"       ZNSLS004.T$UNEG$C         ID_UNEG,         " &
"       ZNINT002.T$DESC$C         DESCR_UNEG,      " &
"       ZNSLS410.T$POCO$C         ID_ULT_PONTO,    " &
"       ZNMCS002.T$DESC$C         DESCR_ULT_PONTO, " &
"       TRIM(ZNSLS004.T$ITEM$C)   ITEM,            " &
"       ZNSLS410.T$DTOC$C -                        " &
"     ( SELECT MAX(B.T$DTOC$C)                     " &
"         FROM BAANDB.TZNSLS410301@PLN01 B         " &
"        WHERE B.T$NCIA$C = ZNSLS410.T$NCIA$C      " &
"          AND B.T$UNEG$C = ZNSLS410.T$UNEG$C      " &
"          AND B.T$PECL$C = ZNSLS410.T$PECL$C      " &
"          AND B.T$POCO$C != ZNSLS410.T$POCO$C     " &
"          AND B.T$DTOC$C < ZNSLS410.T$DTOC$C )    " &
"                                 TEMPO_STAUS      " &
"                                                  " &
"FROM BAANDB.TTDSLS400301@PLN01 TDSLS400           " &
"                                                  " &
" LEFT JOIN ( select A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C,                   " &
"                    MIN(B.T$DTAP$C) T$DTAP$C      " &
"               from BAANDB.TZNSLS004301@PLN01 A   " &
"         inner join BAANDB.TZNSLS401301@PLN01 B   " &
"                 on B.T$NCIA$C = A.T$NCIA$C       " &
"                and B.T$UNEG$C = A.T$UNEG$C       " &
"                and B.T$PECL$C = A.T$PECL$C       " &
"                and B.T$SQPD$C = A.T$SQPD$C       " &
"                and B.T$ENTR$C = A.T$ENTR$C       " &
"                and B.T$SEQU$C = A.T$SEQU$C       " &
"           group by A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C) ZNSLS004          " &
"        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO    " &
"                                                  " &
" LEFT JOIN BAANDB.TZNINT002301@pln01 ZNINT002     " &
"        ON ZNINT002.T$NCIA$C = ZNSLS004.T$NCIA$C  " &
"       AND ZNINT002.T$UNEG$C = ZNSLS004.T$UNEG$C  " &
"                                                  " &
" LEFT JOIN ( select MAX(C.T$POCO$C) KEEP          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$POCO$C, " &
"                    MAX(C.T$DTOC$C) KEEP                                          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$DTOC$C, " &
"                    C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"               from BAANDB.TZNSLS410301@pln01 C    " &
"           group by C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"                    ) ZNSLS410                     " &
"        ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C   " &
"       AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C   " &
"       AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C   " &
"       AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C   " &
"       AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C   " &
"                                                   " &
" LEFT JOIN BAANDB.TZNMCS002301@pln01 ZNMCS002      " &
"        ON ZNMCS002.T$POCO$C = ZNSLS410.T$POCO$C   " &
"                                                   " &
"INNER JOIN ( select upper(wmsCODE.UDF1) Filial,    " &
"                   wmsCODE.UDF2 ID_FILIAL,         " &
"                   a.t$code cwar                   " &
"              from baandb.ttcemm300301@PLN01 a     " &
"         left join ENTERPRISE.CODELKUP wmsCode     " &
"                on UPPER(TRIM(wmsCode.DESCRIPTION)) = a.t$lctn " &
"               and wmsCode.LISTNAME = 'SCHEMA'     " &
"             where a.t$type = 20                   " &
"               and wmsCODE.UDF1 is not null        " &
"          group by upper(wmsCODE.UDF1),            " &
"                   wmsCODE.UDF2,                   " &
"                   a.t$code)  wmsCODE              " &
"        ON wmsCODE.CWAR = ZNSLS004.T$CWRL$C              " &
"                                                         " &
" LEFT JOIN WMWHSE2.ORDERS OWMS                           " &
"        ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO      " &
"		                                                  " &
" WHERE ZNSLS410.T$POCO$C IN ('AES', 'PRD', 'TNA', 'AEW') " &
"   AND CASE WHEN ZNSLS410.T$POCO$C = 'PRD'               " &
"             AND ( SELECT COUNT(A.ORDERKEY)              " &
"                     FROM WMWHSE2.ORDERS A               " &
"                    WHERE A.REFERENCEDOCUMENT = OWMS.REFERENCEDOCUMENT " &
"                      AND A.STATUS != '100' ) >= 1       " &
"              THEN 1                                     " &
"            ELSE 0                                       " &
"        END = 0                                          " &
"   AND TDSLS400.T$HDST NOT IN (30, 35)                   " &
"   AND wmsCODE.FILIAL = 'WMWHSE2'                        " &
"                                                         " &
"Union                                                    " &
"                                                         " &
"SELECT wmsCODE.FILIAL            FILIAL,          " &
"       wmsCODE.ID_FILIAL         DSC_PLANTA,      " &
"       TDSLS400.T$ORNO           PEDIDO_LN,       " &
"       ZNSLS004.T$PECL$C         PEDIDO_SITE,     " &
"       OWMS.ORDERKEY             ORDEM_WMS,       " &
"       ZNSLS004.T$UNEG$C         ID_UNEG,         " &
"       ZNINT002.T$DESC$C         DESCR_UNEG,      " &
"       ZNSLS410.T$POCO$C         ID_ULT_PONTO,    " &
"       ZNMCS002.T$DESC$C         DESCR_ULT_PONTO, " &
"       TRIM(ZNSLS004.T$ITEM$C)   ITEM,            " &
"       ZNSLS410.T$DTOC$C -                        " &
"     ( SELECT MAX(B.T$DTOC$C)                     " &
"         FROM BAANDB.TZNSLS410301@PLN01 B         " &
"        WHERE B.T$NCIA$C = ZNSLS410.T$NCIA$C      " &
"          AND B.T$UNEG$C = ZNSLS410.T$UNEG$C      " &
"          AND B.T$PECL$C = ZNSLS410.T$PECL$C      " &
"          AND B.T$POCO$C != ZNSLS410.T$POCO$C     " &
"          AND B.T$DTOC$C < ZNSLS410.T$DTOC$C )    " &
"                                 TEMPO_STAUS      " &
"                                                  " &
"FROM BAANDB.TTDSLS400301@PLN01 TDSLS400           " &
"                                                  " &
" LEFT JOIN ( select A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C,                   " &
"                    MIN(B.T$DTAP$C) T$DTAP$C      " &
"               from BAANDB.TZNSLS004301@PLN01 A   " &
"         inner join BAANDB.TZNSLS401301@PLN01 B   " &
"                 on B.T$NCIA$C = A.T$NCIA$C       " &
"                and B.T$UNEG$C = A.T$UNEG$C       " &
"                and B.T$PECL$C = A.T$PECL$C       " &
"                and B.T$SQPD$C = A.T$SQPD$C       " &
"                and B.T$ENTR$C = A.T$ENTR$C       " &
"                and B.T$SEQU$C = A.T$SEQU$C       " &
"           group by A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C) ZNSLS004          " &
"        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO    " &
"                                                  " &
" LEFT JOIN BAANDB.TZNINT002301@pln01 ZNINT002     " &
"        ON ZNINT002.T$NCIA$C = ZNSLS004.T$NCIA$C  " &
"       AND ZNINT002.T$UNEG$C = ZNSLS004.T$UNEG$C  " &
"                                                  " &
" LEFT JOIN ( select MAX(C.T$POCO$C) KEEP          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$POCO$C, " &
"                    MAX(C.T$DTOC$C) KEEP                                          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$DTOC$C, " &
"                    C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"               from BAANDB.TZNSLS410301@pln01 C    " &
"           group by C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"                    ) ZNSLS410                     " &
"        ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C   " &
"       AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C   " &
"       AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C   " &
"       AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C   " &
"       AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C   " &
"                                                   " &
" LEFT JOIN BAANDB.TZNMCS002301@pln01 ZNMCS002      " &
"        ON ZNMCS002.T$POCO$C = ZNSLS410.T$POCO$C   " &
"                                                   " &
"INNER JOIN ( select upper(wmsCODE.UDF1) Filial,    " &
"                   wmsCODE.UDF2 ID_FILIAL,         " &
"                   a.t$code cwar                   " &
"              from baandb.ttcemm300301@PLN01 a     " &
"         left join ENTERPRISE.CODELKUP wmsCode     " &
"                on UPPER(TRIM(wmsCode.DESCRIPTION)) = a.t$lctn " &
"               and wmsCode.LISTNAME = 'SCHEMA'     " &
"             where a.t$type = 20                   " &
"               and wmsCODE.UDF1 is not null        " &
"          group by upper(wmsCODE.UDF1),            " &
"                   wmsCODE.UDF2,                   " &
"                   a.t$code)  wmsCODE              " &
"        ON wmsCODE.CWAR = ZNSLS004.T$CWRL$C              " &
"                                                         " &
" LEFT JOIN WMWHSE3.ORDERS OWMS                           " &
"        ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO      " &
"		                                                  " &
" WHERE ZNSLS410.T$POCO$C IN ('AES', 'PRD', 'TNA', 'AEW') " &
"   AND CASE WHEN ZNSLS410.T$POCO$C = 'PRD'               " &
"             AND ( SELECT COUNT(A.ORDERKEY)              " &
"                     FROM WMWHSE3.ORDERS A               " &
"                    WHERE A.REFERENCEDOCUMENT = OWMS.REFERENCEDOCUMENT " &
"                      AND A.STATUS != '100' ) >= 1       " &
"              THEN 1                                     " &
"            ELSE 0                                       " &
"        END = 0                                          " &
"   AND TDSLS400.T$HDST NOT IN (30, 35)                   " &
"   AND wmsCODE.FILIAL = 'WMWHSE3'                        " &
"                                                         " &
"Union                                                    " &
"                                                         " &
"SELECT wmsCODE.FILIAL            FILIAL,          " &
"       wmsCODE.ID_FILIAL         DSC_PLANTA,      " &
"       TDSLS400.T$ORNO           PEDIDO_LN,       " &
"       ZNSLS004.T$PECL$C         PEDIDO_SITE,     " &
"       OWMS.ORDERKEY             ORDEM_WMS,       " &
"       ZNSLS004.T$UNEG$C         ID_UNEG,         " &
"       ZNINT002.T$DESC$C         DESCR_UNEG,      " &
"       ZNSLS410.T$POCO$C         ID_ULT_PONTO,    " &
"       ZNMCS002.T$DESC$C         DESCR_ULT_PONTO, " &
"       TRIM(ZNSLS004.T$ITEM$C)   ITEM,            " &
"       ZNSLS410.T$DTOC$C -                        " &
"     ( SELECT MAX(B.T$DTOC$C)                     " &
"         FROM BAANDB.TZNSLS410301@PLN01 B         " &
"        WHERE B.T$NCIA$C = ZNSLS410.T$NCIA$C      " &
"          AND B.T$UNEG$C = ZNSLS410.T$UNEG$C      " &
"          AND B.T$PECL$C = ZNSLS410.T$PECL$C      " &
"          AND B.T$POCO$C != ZNSLS410.T$POCO$C     " &
"          AND B.T$DTOC$C < ZNSLS410.T$DTOC$C )    " &
"                                 TEMPO_STAUS      " &
"                                                  " &
"FROM BAANDB.TTDSLS400301@PLN01 TDSLS400           " &
"                                                  " &
" LEFT JOIN ( select A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C,                   " &
"                    MIN(B.T$DTAP$C) T$DTAP$C      " &
"               from BAANDB.TZNSLS004301@PLN01 A   " &
"         inner join BAANDB.TZNSLS401301@PLN01 B   " &
"                 on B.T$NCIA$C = A.T$NCIA$C       " &
"                and B.T$UNEG$C = A.T$UNEG$C       " &
"                and B.T$PECL$C = A.T$PECL$C       " &
"                and B.T$SQPD$C = A.T$SQPD$C       " &
"                and B.T$ENTR$C = A.T$ENTR$C       " &
"                and B.T$SEQU$C = A.T$SEQU$C       " &
"           group by A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C) ZNSLS004          " &
"        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO    " &
"                                                  " &
" LEFT JOIN BAANDB.TZNINT002301@pln01 ZNINT002     " &
"        ON ZNINT002.T$NCIA$C = ZNSLS004.T$NCIA$C  " &
"       AND ZNINT002.T$UNEG$C = ZNSLS004.T$UNEG$C  " &
"                                                  " &
" LEFT JOIN ( select MAX(C.T$POCO$C) KEEP          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$POCO$C, " &
"                    MAX(C.T$DTOC$C) KEEP                                          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$DTOC$C, " &
"                    C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"               from BAANDB.TZNSLS410301@pln01 C    " &
"           group by C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"                    ) ZNSLS410                     " &
"        ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C   " &
"       AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C   " &
"       AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C   " &
"       AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C   " &
"       AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C   " &
"                                                   " &
" LEFT JOIN BAANDB.TZNMCS002301@pln01 ZNMCS002      " &
"        ON ZNMCS002.T$POCO$C = ZNSLS410.T$POCO$C   " &
"                                                   " &
"INNER JOIN ( select upper(wmsCODE.UDF1) Filial,    " &
"                   wmsCODE.UDF2 ID_FILIAL,         " &
"                   a.t$code cwar                   " &
"              from baandb.ttcemm300301@PLN01 a     " &
"         left join ENTERPRISE.CODELKUP wmsCode     " &
"                on UPPER(TRIM(wmsCode.DESCRIPTION)) = a.t$lctn " &
"               and wmsCode.LISTNAME = 'SCHEMA'     " &
"             where a.t$type = 20                   " &
"               and wmsCODE.UDF1 is not null        " &
"          group by upper(wmsCODE.UDF1),            " &
"                   wmsCODE.UDF2,                   " &
"                   a.t$code)  wmsCODE              " &
"        ON wmsCODE.CWAR = ZNSLS004.T$CWRL$C              " &
"                                                         " &
" LEFT JOIN WMWHSE4.ORDERS OWMS                           " &
"        ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO      " &
"		                                                  " &
" WHERE ZNSLS410.T$POCO$C IN ('AES', 'PRD', 'TNA', 'AEW') " &
"   AND CASE WHEN ZNSLS410.T$POCO$C = 'PRD'               " &
"             AND ( SELECT COUNT(A.ORDERKEY)              " &
"                     FROM WMWHSE4.ORDERS A               " &
"                    WHERE A.REFERENCEDOCUMENT = OWMS.REFERENCEDOCUMENT " &
"                      AND A.STATUS != '100' ) >= 1       " &
"              THEN 1                                     " &
"            ELSE 0                                       " &
"        END = 0                                          " &
"   AND TDSLS400.T$HDST NOT IN (30, 35)                   " &
"   AND wmsCODE.FILIAL = 'WMWHSE4'                        " &
"                                                         " &
"Union                                                    " &
"                                                         " &
"SELECT wmsCODE.FILIAL            FILIAL,          " &
"       wmsCODE.ID_FILIAL         DSC_PLANTA,      " &
"       TDSLS400.T$ORNO           PEDIDO_LN,       " &
"       ZNSLS004.T$PECL$C         PEDIDO_SITE,     " &
"       OWMS.ORDERKEY             ORDEM_WMS,       " &
"       ZNSLS004.T$UNEG$C         ID_UNEG,         " &
"       ZNINT002.T$DESC$C         DESCR_UNEG,      " &
"       ZNSLS410.T$POCO$C         ID_ULT_PONTO,    " &
"       ZNMCS002.T$DESC$C         DESCR_ULT_PONTO, " &
"       TRIM(ZNSLS004.T$ITEM$C)   ITEM,            " &
"       ZNSLS410.T$DTOC$C -                        " &
"     ( SELECT MAX(B.T$DTOC$C)                     " &
"         FROM BAANDB.TZNSLS410301@PLN01 B         " &
"        WHERE B.T$NCIA$C = ZNSLS410.T$NCIA$C      " &
"          AND B.T$UNEG$C = ZNSLS410.T$UNEG$C      " &
"          AND B.T$PECL$C = ZNSLS410.T$PECL$C      " &
"          AND B.T$POCO$C != ZNSLS410.T$POCO$C     " &
"          AND B.T$DTOC$C < ZNSLS410.T$DTOC$C )    " &
"                                 TEMPO_STAUS      " &
"                                                  " &
"FROM BAANDB.TTDSLS400301@PLN01 TDSLS400           " &
"                                                  " &
" LEFT JOIN ( select A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C,                   " &
"                    MIN(B.T$DTAP$C) T$DTAP$C      " &
"               from BAANDB.TZNSLS004301@PLN01 A   " &
"         inner join BAANDB.TZNSLS401301@PLN01 B   " &
"                 on B.T$NCIA$C = A.T$NCIA$C       " &
"                and B.T$UNEG$C = A.T$UNEG$C       " &
"                and B.T$PECL$C = A.T$PECL$C       " &
"                and B.T$SQPD$C = A.T$SQPD$C       " &
"                and B.T$ENTR$C = A.T$ENTR$C       " &
"                and B.T$SEQU$C = A.T$SEQU$C       " &
"           group by A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C) ZNSLS004          " &
"        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO    " &
"                                                  " &
" LEFT JOIN BAANDB.TZNINT002301@pln01 ZNINT002     " &
"        ON ZNINT002.T$NCIA$C = ZNSLS004.T$NCIA$C  " &
"       AND ZNINT002.T$UNEG$C = ZNSLS004.T$UNEG$C  " &
"                                                  " &
" LEFT JOIN ( select MAX(C.T$POCO$C) KEEP          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$POCO$C, " &
"                    MAX(C.T$DTOC$C) KEEP                                          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$DTOC$C, " &
"                    C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"               from BAANDB.TZNSLS410301@pln01 C    " &
"           group by C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"                    ) ZNSLS410                     " &
"        ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C   " &
"       AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C   " &
"       AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C   " &
"       AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C   " &
"       AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C   " &
"                                                   " &
" LEFT JOIN BAANDB.TZNMCS002301@pln01 ZNMCS002      " &
"        ON ZNMCS002.T$POCO$C = ZNSLS410.T$POCO$C   " &
"                                                   " &
"INNER JOIN ( select upper(wmsCODE.UDF1) Filial,    " &
"                   wmsCODE.UDF2 ID_FILIAL,         " &
"                   a.t$code cwar                   " &
"              from baandb.ttcemm300301@PLN01 a     " &
"         left join ENTERPRISE.CODELKUP wmsCode     " &
"                on UPPER(TRIM(wmsCode.DESCRIPTION)) = a.t$lctn " &
"               and wmsCode.LISTNAME = 'SCHEMA'     " &
"             where a.t$type = 20                   " &
"               and wmsCODE.UDF1 is not null        " &
"          group by upper(wmsCODE.UDF1),            " &
"                   wmsCODE.UDF2,                   " &
"                   a.t$code)  wmsCODE              " &
"        ON wmsCODE.CWAR = ZNSLS004.T$CWRL$C              " &
"                                                         " &
" LEFT JOIN WMWHSE5.ORDERS OWMS                           " &
"        ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO      " &
"		                                                  " &
" WHERE ZNSLS410.T$POCO$C IN ('AES', 'PRD', 'TNA', 'AEW') " &
"   AND CASE WHEN ZNSLS410.T$POCO$C = 'PRD'               " &
"             AND ( SELECT COUNT(A.ORDERKEY)              " &
"                     FROM WMWHSE5.ORDERS A               " &
"                    WHERE A.REFERENCEDOCUMENT = OWMS.REFERENCEDOCUMENT " &
"                      AND A.STATUS != '100' ) >= 1       " &
"              THEN 1                                     " &
"            ELSE 0                                       " &
"        END = 0                                          " &
"   AND TDSLS400.T$HDST NOT IN (30, 35)                   " &
"   AND wmsCODE.FILIAL = 'WMWHSE5'                        " &
"                                                         " &
"Union                                                    " &
"                                                         " &
"SELECT wmsCODE.FILIAL            FILIAL,          " &
"       wmsCODE.ID_FILIAL         DSC_PLANTA,      " &
"       TDSLS400.T$ORNO           PEDIDO_LN,       " &
"       ZNSLS004.T$PECL$C         PEDIDO_SITE,     " &
"       OWMS.ORDERKEY             ORDEM_WMS,       " &
"       ZNSLS004.T$UNEG$C         ID_UNEG,         " &
"       ZNINT002.T$DESC$C         DESCR_UNEG,      " &
"       ZNSLS410.T$POCO$C         ID_ULT_PONTO,    " &
"       ZNMCS002.T$DESC$C         DESCR_ULT_PONTO, " &
"       TRIM(ZNSLS004.T$ITEM$C)   ITEM,            " &
"       ZNSLS410.T$DTOC$C -                        " &
"     ( SELECT MAX(B.T$DTOC$C)                     " &
"         FROM BAANDB.TZNSLS410301@PLN01 B         " &
"        WHERE B.T$NCIA$C = ZNSLS410.T$NCIA$C      " &
"          AND B.T$UNEG$C = ZNSLS410.T$UNEG$C      " &
"          AND B.T$PECL$C = ZNSLS410.T$PECL$C      " &
"          AND B.T$POCO$C != ZNSLS410.T$POCO$C     " &
"          AND B.T$DTOC$C < ZNSLS410.T$DTOC$C )    " &
"                                 TEMPO_STAUS      " &
"                                                  " &
"FROM BAANDB.TTDSLS400301@PLN01 TDSLS400           " &
"                                                  " &
" LEFT JOIN ( select A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C,                   " &
"                    MIN(B.T$DTAP$C) T$DTAP$C      " &
"               from BAANDB.TZNSLS004301@PLN01 A   " &
"         inner join BAANDB.TZNSLS401301@PLN01 B   " &
"                 on B.T$NCIA$C = A.T$NCIA$C       " &
"                and B.T$UNEG$C = A.T$UNEG$C       " &
"                and B.T$PECL$C = A.T$PECL$C       " &
"                and B.T$SQPD$C = A.T$SQPD$C       " &
"                and B.T$ENTR$C = A.T$ENTR$C       " &
"                and B.T$SEQU$C = A.T$SEQU$C       " &
"           group by A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C) ZNSLS004          " &
"        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO    " &
"                                                  " &
" LEFT JOIN BAANDB.TZNINT002301@pln01 ZNINT002     " &
"        ON ZNINT002.T$NCIA$C = ZNSLS004.T$NCIA$C  " &
"       AND ZNINT002.T$UNEG$C = ZNSLS004.T$UNEG$C  " &
"                                                  " &
" LEFT JOIN ( select MAX(C.T$POCO$C) KEEP          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$POCO$C, " &
"                    MAX(C.T$DTOC$C) KEEP                                          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$DTOC$C, " &
"                    C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"               from BAANDB.TZNSLS410301@pln01 C    " &
"           group by C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"                    ) ZNSLS410                     " &
"        ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C   " &
"       AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C   " &
"       AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C   " &
"       AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C   " &
"       AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C   " &
"                                                   " &
" LEFT JOIN BAANDB.TZNMCS002301@pln01 ZNMCS002      " &
"        ON ZNMCS002.T$POCO$C = ZNSLS410.T$POCO$C   " &
"                                                   " &
"INNER JOIN ( select upper(wmsCODE.UDF1) Filial,    " &
"                   wmsCODE.UDF2 ID_FILIAL,         " &
"                   a.t$code cwar                   " &
"              from baandb.ttcemm300301@PLN01 a     " &
"         left join ENTERPRISE.CODELKUP wmsCode     " &
"                on UPPER(TRIM(wmsCode.DESCRIPTION)) = a.t$lctn " &
"               and wmsCode.LISTNAME = 'SCHEMA'     " &
"             where a.t$type = 20                   " &
"               and wmsCODE.UDF1 is not null        " &
"          group by upper(wmsCODE.UDF1),            " &
"                   wmsCODE.UDF2,                   " &
"                   a.t$code)  wmsCODE              " &
"        ON wmsCODE.CWAR = ZNSLS004.T$CWRL$C              " &
"                                                         " &
" LEFT JOIN WMWHSE6.ORDERS OWMS                           " &
"        ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO      " &
"		                                                  " &
" WHERE ZNSLS410.T$POCO$C IN ('AES', 'PRD', 'TNA', 'AEW') " &
"   AND CASE WHEN ZNSLS410.T$POCO$C = 'PRD'               " &
"             AND ( SELECT COUNT(A.ORDERKEY)              " &
"                     FROM WMWHSE6.ORDERS A               " &
"                    WHERE A.REFERENCEDOCUMENT = OWMS.REFERENCEDOCUMENT " &
"                      AND A.STATUS != '100' ) >= 1       " &
"              THEN 1                                     " &
"            ELSE 0                                       " &
"        END = 0                                          " &
"   AND TDSLS400.T$HDST NOT IN (30, 35)                   " &
"   AND wmsCODE.FILIAL = 'WMWHSE6'                        " &
"                                                         " &
"Union                                                    " &
"                                                         " &
"SELECT wmsCODE.FILIAL            FILIAL,          " &
"       wmsCODE.ID_FILIAL         DSC_PLANTA,      " &
"       TDSLS400.T$ORNO           PEDIDO_LN,       " &
"       ZNSLS004.T$PECL$C         PEDIDO_SITE,     " &
"       OWMS.ORDERKEY             ORDEM_WMS,       " &
"       ZNSLS004.T$UNEG$C         ID_UNEG,         " &
"       ZNINT002.T$DESC$C         DESCR_UNEG,      " &
"       ZNSLS410.T$POCO$C         ID_ULT_PONTO,    " &
"       ZNMCS002.T$DESC$C         DESCR_ULT_PONTO, " &
"       TRIM(ZNSLS004.T$ITEM$C)   ITEM,            " &
"       ZNSLS410.T$DTOC$C -                        " &
"     ( SELECT MAX(B.T$DTOC$C)                     " &
"         FROM BAANDB.TZNSLS410301@PLN01 B         " &
"        WHERE B.T$NCIA$C = ZNSLS410.T$NCIA$C      " &
"          AND B.T$UNEG$C = ZNSLS410.T$UNEG$C      " &
"          AND B.T$PECL$C = ZNSLS410.T$PECL$C      " &
"          AND B.T$POCO$C != ZNSLS410.T$POCO$C     " &
"          AND B.T$DTOC$C < ZNSLS410.T$DTOC$C )    " &
"                                 TEMPO_STAUS      " &
"                                                  " &
"FROM BAANDB.TTDSLS400301@PLN01 TDSLS400           " &
"                                                  " &
" LEFT JOIN ( select A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C,                   " &
"                    MIN(B.T$DTAP$C) T$DTAP$C      " &
"               from BAANDB.TZNSLS004301@PLN01 A   " &
"         inner join BAANDB.TZNSLS401301@PLN01 B   " &
"                 on B.T$NCIA$C = A.T$NCIA$C       " &
"                and B.T$UNEG$C = A.T$UNEG$C       " &
"                and B.T$PECL$C = A.T$PECL$C       " &
"                and B.T$SQPD$C = A.T$SQPD$C       " &
"                and B.T$ENTR$C = A.T$ENTR$C       " &
"                and B.T$SEQU$C = A.T$SEQU$C       " &
"           group by A.T$NCIA$C,                   " &
"                    A.T$UNEG$C,                   " &
"                    A.T$PECL$C,                   " &
"                    A.T$SQPD$C,                   " &
"                    A.T$ENTR$C,                   " &
"                    A.T$ORNO$C,                   " &
"                    B.T$ITEM$C,                   " &
"                    B.T$CWRL$C) ZNSLS004          " &
"        ON ZNSLS004.T$ORNO$C = TDSLS400.T$ORNO    " &
"                                                  " &
" LEFT JOIN BAANDB.TZNINT002301@pln01 ZNINT002     " &
"        ON ZNINT002.T$NCIA$C = ZNSLS004.T$NCIA$C  " &
"       AND ZNINT002.T$UNEG$C = ZNSLS004.T$UNEG$C  " &
"                                                  " &
" LEFT JOIN ( select MAX(C.T$POCO$C) KEEP          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$POCO$C, " &
"                    MAX(C.T$DTOC$C) KEEP                                          " &
"                      (DENSE_RANK LAST ORDER BY C.T$DTOC$C, C.T$SEQN$C) T$DTOC$C, " &
"                    C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"               from BAANDB.TZNSLS410301@pln01 C    " &
"           group by C.T$NCIA$C,                    " &
"                    C.T$UNEG$C,                    " &
"                    C.T$PECL$C,                    " &
"                    C.T$SQPD$C,                    " &
"                    C.T$ENTR$C                     " &
"                    ) ZNSLS410                     " &
"        ON ZNSLS410.T$NCIA$C = ZNSLS004.T$NCIA$C   " &
"       AND ZNSLS410.T$UNEG$C = ZNSLS004.T$UNEG$C   " &
"       AND ZNSLS410.T$PECL$C = ZNSLS004.T$PECL$C   " &
"       AND ZNSLS410.T$SQPD$C = ZNSLS004.T$SQPD$C   " &
"       AND ZNSLS410.T$ENTR$C = ZNSLS004.T$ENTR$C   " &
"                                                   " &
" LEFT JOIN BAANDB.TZNMCS002301@pln01 ZNMCS002      " &
"        ON ZNMCS002.T$POCO$C = ZNSLS410.T$POCO$C   " &
"                                                   " &
"INNER JOIN ( select upper(wmsCODE.UDF1) Filial,    " &
"                   wmsCODE.UDF2 ID_FILIAL,         " &
"                   a.t$code cwar                   " &
"              from baandb.ttcemm300301@PLN01 a     " &
"         left join ENTERPRISE.CODELKUP wmsCode     " &
"                on UPPER(TRIM(wmsCode.DESCRIPTION)) = a.t$lctn " &
"               and wmsCode.LISTNAME = 'SCHEMA'     " &
"             where a.t$type = 20                   " &
"               and wmsCODE.UDF1 is not null        " &
"          group by upper(wmsCODE.UDF1),            " &
"                   wmsCODE.UDF2,                   " &
"                   a.t$code)  wmsCODE              " &
"        ON wmsCODE.CWAR = ZNSLS004.T$CWRL$C              " &
"                                                         " &
" LEFT JOIN WMWHSE7.ORDERS OWMS                           " &
"        ON OWMS.REFERENCEDOCUMENT = TDSLS400.T$ORNO      " &
"		                                                  " &
" WHERE ZNSLS410.T$POCO$C IN ('AES', 'PRD', 'TNA', 'AEW') " &
"   AND CASE WHEN ZNSLS410.T$POCO$C = 'PRD'               " &
"             AND ( SELECT COUNT(A.ORDERKEY)              " &
"                     FROM WMWHSE7.ORDERS A               " &
"                    WHERE A.REFERENCEDOCUMENT = OWMS.REFERENCEDOCUMENT " &
"                      AND A.STATUS != '100' ) >= 1       " &
"              THEN 1                                     " &
"            ELSE 0                                       " &
"        END = 0                                          " &
"   AND TDSLS400.T$HDST NOT IN (30, 35)                   " &
"   AND wmsCODE.FILIAL = 'WMWHSE7'                        " &
"                                                         " &
"Order by 2,3,4                                           "
