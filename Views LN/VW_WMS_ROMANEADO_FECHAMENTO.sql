SELECT
		SUBSTR(CS.LONG_VALUE,3,6)			CD_DEPOSITO,
		TD.SKU								CD_ITEM,
		NVL(HR.STATUS,'WN') 				RESTRICAO,
		SUM(TD.QTY)							QT_ROMANEADA
FROM
				WMWHSE5.TASKDETAIL			TD
	INNER JOIN	WMWHSE5.ORDERDETAIL			OD	ON	OD.ORDERKEY			=	TD.ORDERKEY
											AND	OD.ORDERLINENUMBER	=	TD.ORDERLINENUMBER
	INNER JOIN	(	SELECT	A.ORDERKEY,
							A.ORDERLINENUMBER,
							A.STATUS,
							ROW_NUMBER() OVER (PARTITION BY A.ORDERKEY, A.ORDERLINENUMBER ORDER BY A.ADDDATE DESC) RN
					FROM	WMWHSE5.ORDERSTATUSHISTORY A 
					WHERE	CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(A.ADDDATE, 'DD-MON-YYYY HH24:MI:SS')
						, 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
						AT time zone 'America/Sao_Paulo') AS DATE)<TRUNC(SYSDATE,'DD'))	
											SH	ON	SH.ORDERKEY			=	TD.ORDERKEY
												AND SH.ORDERLINENUMBER	=	TD.ORDERLINENUMBER


					
	INNER JOIN	(	SELECT 	DISTINCT 
							LOC, 
							STATUS 
					FROM 	WMWHSE5.INVENTORYHOLD	)	
											HR	ON	HR.LOC				=	TD.FROMLOC
	INNER JOIN	ENTERPRISE.CODELKUP			CS	ON	UPPER(CS.UDF1)		=	TD.WHSEID
												AND	CS.LISTNAME			=	'SCHEMA'
WHERE
			TD.TASKTYPE	=		'PK'
		AND	SH.STATUS 	NOT IN 	('100', '95', '96', '97', '98', '99', '57')
		AND	SH.RN		=		1
GROUP BY
		SUBSTR(CS.LONG_VALUE,3,6),
		TD.SKU,
		NVL(HR.STATUS,'WN') 