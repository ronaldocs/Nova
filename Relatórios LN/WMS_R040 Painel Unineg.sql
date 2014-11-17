SELECT 
		CASE WHEN NVL(TDSLS400.T$CREG,' ') = ' ' 
			THEN 'INT'
			ELSE TDSLS400.T$CREG END 											CANAL,
		ORDERS.whseid                											ID_FILIAL,
        CODELKUP.UDF2                											DESCR_FILIAL,
		TRUNC(CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ORDERS.SCHEDULEDSHIPDATE, 
			'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
			AT time zone sessiontimezone) AS DATE),'DD')						DATA_LIMITE,	
		ORDERS.SUSR4															UNEG,
		OH.STATUS																ULT_EVENTO,
		OS.DESCRIPTION															ULT_EVENTO_DESCR,
		COUNT(DISTINCT ORDERS.ORDERKEY)											PEDIDOS,
		CASE WHEN ORDERS.SCHEDULEDSHIPDATE<ORDERS.ADDDATE
			THEN 'ATRASO TERCEIRO'
			WHEN CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ORDERS.SCHEDULEDSHIPDATE, 
					'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
					AT time zone sessiontimezone) AS DATE)<SYSDATE
			THEN 'ATRASO OP'
			ELSE ' ' END														TESTE
FROM
		WMWHSE5.ORDERS
	LEFT JOIN 	BAANDB.TTDSLS400301@pln01	TDSLS400	ON	TDSLS400.T$ORNO = ORDERS.REFERENCEDOCUMENT
	LEFT JOIN (	select a.orderkey, a.status from WMWHSE5.orderstatushistory a
				where a.serialkey = (select max(b.serialkey) from WMWHSE5.orderstatushistory b
									 where b.orderkey=a.orderkey)) OH
														ON	OH.ORDERKEY = ORDERS.ORDERKEY
	LEFT JOIN	WMWHSE5.ORDERSTATUSSETUP OS				ON	OS.CODE = OH.STATUS
	LEFT JOIN	WMWHSE5.CODELKUP						ON	UPPER(CODELKUP.UDF1) = UPPER(ORDERS.WHSEID)
														AND	CODELKUP.LISTNAME='SCHEMA'
GROUP BY
	CASE WHEN NVL(TDSLS400.T$CREG,' ') = ' ' 
    	THEN 'INT'
    	ELSE TDSLS400.T$CREG END, 											
    ORDERS.whseid,                											
    CODELKUP.UDF2,                											
    TRUNC(CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ORDERS.SCHEDULEDSHIPDATE, 
    	'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
    	AT time zone sessiontimezone) AS DATE),'DD'),
	ORDERS.SUSR4,
    OH.STATUS,
	OS.DESCRIPTION,
    CASE WHEN ORDERS.SCHEDULEDSHIPDATE<ORDERS.ADDDATE
    	THEN 'ATRASO TERCEIRO'
    	WHEN CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ORDERS.SCHEDULEDSHIPDATE, 
    			'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
    			AT time zone sessiontimezone) AS DATE)<SYSDATE
    	THEN 'ATRASO OP'
    	ELSE ' ' END														