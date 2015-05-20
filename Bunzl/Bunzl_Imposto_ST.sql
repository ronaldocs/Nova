--*********************************************************************************************************************
--	LISTA TODOS AS ENTREGAS INTEGRADAS E OS PRODUTOS IDEPENDDDENTE DO STATUS
--*********************************************************************************************************************
SELECT
		ZNSLS004.T$ENTR$C														PEDIDO,
		CISLI940.T$DATE$L														DATA_FATURAMENTO,
		CISLI940.T$DOCN$L														NF,
		CISLI940.T$SERI$L														SERIE,
		TRIM(CISLI941.T$ITEM$L)													PRODUTO,
		CISLI941.T$DQUA$L														QTD_FAT,
		CISLI941.T$PRIC$L														PRECO,
			CASE WHEN COUNTDT.CTDT>1
				THEN
				CAST((FROM_TZ(TO_TIMESTAMP(TO_CHAR(ZNSLS401.T$DTEP$C, 
				'DD-MON-YYYY HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS'), 'GMT')
				AT time zone 'America/Sao_Paulo') AS DATE)
				ELSE NULL END													DT_ENTREGA,		
		ICMS_ST.T$BASE$L														BASE_CALCULO,
		ICMS_ST.T$NMRG$L														IVA,
		ICMS_ST.T$RATE$L														ALIQUOTA


FROM
		(	SELECT	A.T$FIRE$L,
					A.T$LINE$L,
					A.T$SLSO,
					A.T$PONO
			FROM	BAANDB.TCISLI245301 A
			WHERE	A.T$SLCP=301
			AND		A.T$ORTP=1
			AND		A.T$KOOR=3
			GROUP BY A.T$FIRE$L,
			         A.T$LINE$L,
			         A.T$SLSO,
			         A.T$PONO)	CISLI245
					 
INNER JOIN (SELECT	B.T$NCIA$C,
					B.T$UNEG$C,
					B.T$PECL$C,
					B.T$SQPD$C,
					B.T$ENTR$C,
					B.T$SEQU$C,
					B.T$ORNO$C,
					B.T$PONO$C
			FROM 	BAANDB.TZNSLS004301 B
			GROUP BY B.T$NCIA$C,
			         B.T$UNEG$C,
                     B.T$PECL$C,
                     B.T$SQPD$C,
					 B.T$ENTR$C,
					 B.T$SEQU$C,
                     B.T$ORNO$C,
					 B.T$PONO$C) ZNSLS004	ON	ZNSLS004.T$ORNO$C	=	CISLI245.T$SLSO
											AND	ZNSLS004.T$PONO$C	=	CISLI245.T$PONO
					 
INNER JOIN 	BAANDB.TCISLI940301	CISLI940	ON	CISLI940.T$FIRE$L	=	CISLI245.T$FIRE$L

INNER JOIN 	BAANDB.TCISLI941301	CISLI941	ON	CISLI941.T$FIRE$L	=	CISLI245.T$FIRE$L
											AND	CISLI941.T$LINE$L	=	CISLI245.T$LINE$L
											
INNER JOIN	BAANDB.TZNSLS401301	ZNSLS401	ON	ZNSLS401.T$NCIA$C	=	ZNSLS004.T$NCIA$C
											AND ZNSLS401.T$UNEG$C	=	ZNSLS004.T$UNEG$C
											AND ZNSLS401.T$PECL$C	=	ZNSLS004.T$PECL$C
											AND ZNSLS401.T$SQPD$C	=	ZNSLS004.T$SQPD$C
                                            AND ZNSLS401.T$ENTR$C	=	ZNSLS004.T$ENTR$C
                                            AND ZNSLS401.T$SEQU$C	=	ZNSLS004.T$SEQU$C

INNER JOIN (SELECT	C.T$NCIA$C,
                    C.T$UNEG$C,
                    C.T$PECL$C,
                    C.T$SQPD$C,
					COUNT(DISTINCT TRUNC(C.T$DTEP$C)) CTDT
			FROM	BAANDB.TZNSLS401301 C
			GROUP BY C.T$NCIA$C,
			         C.T$UNEG$C,
			         C.T$PECL$C,
			         C.T$SQPD$C) COUNTDT	ON	COUNTDT.T$NCIA$C	=	ZNSLS004.T$NCIA$C
					                        AND COUNTDT.T$UNEG$C   	=	ZNSLS004.T$UNEG$C
					                        AND COUNTDT.T$PECL$C   	=	ZNSLS004.T$PECL$C
					                        AND COUNTDT.T$SQPD$C   	=	ZNSLS004.T$SQPD$C	

LEFT JOIN (	SELECT	A.T$FIRE$L,
					A.T$LINE$L,
					A.T$RATE$L,
					A.T$BASE$L,
					A.T$NMRG$L
			FROM	BAANDB.TCISLI943301 A
			WHERE 	A.T$BRTY$L=2) ICMS_ST	ON	ICMS_ST.T$FIRE$L	=	CISLI941.T$FIRE$L
											AND	ICMS_ST.T$LINE$L	=	CISLI941.T$LINE$L