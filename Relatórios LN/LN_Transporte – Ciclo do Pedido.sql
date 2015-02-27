SELECT
		ZNFMD630.T$FILI$C						ID_FILIAL,
		ZNFMD001.T$DSCA$C						DESCR_FILIAL,
		ZNSLS401.T$UNEG$C						ID_UNEG,
		ZNINT002.T$DESC$C						DESCR_UNEG,
		ZNSLS401.T$ENTR$C						ENTREGA,
		ZNSLS401.T$PECL$C						PEDIDO,
		SHO.INVOICENUMBER						NOTA,
		SHO.LANE								SERIE,
		OXV.NOTES1								ETIQUETA,
		ZNSLS401.T$NOME$C						CLIENTE,
		ZNSLS401.T$ICLE$C						CPF_CNPJ,
		ZNSLS401.T$LOGE$C						ENDERECO,
		ZNSLS401.T$NUME$C						NUMERO,
		ZNSLS401.T$BAIE$C						BAIRRO,
		ZNSLS401.T$REFE$C						REFERENCIA,
		ZNSLS401.T$EMAE$C						EMAIL,
		ZNSLS401.T$TELE$C						TELEFONE_1,
		ZNSLS401.T$TE1E$C						TELEFONE_2,
		ZNSLS401.T$TE2E$C						TELEFONE_3,
		ZNSLS410.T$CONO$C						CONTRATO,
		SHD.ORIGINALQTY							QTD_VOL,
		ZNSLS401.T$ITPE$C						ID_TIPO_ENFTREGA,
		ZNSLS002.T$DSCA$C						DESCR_TIPO_ENTREGA,
		SHD.PRODUCT_WEIGHT						PESO,
		SHD.PRODUCT_CUBE						VOLUME,
		ZNSLS401.T$VLUN$C*SHD.ORIGINALQTY		VL_SEM_FRETE,
		ZNFMD630.T$VLFC$C						FRETE,
		--										FRETE_MODIF			*** NÃO TEMOS ESTA INFORMAÇÃO
		ZNSLS401.T$VLFR$C						FRETE_SITE,
		(ZNSLS401.T$VLUN$C*SHD.ORIGINALQTY)+
		ZNSLS401.T$VLFR$C+ZNSLS401.T$VLDE$C-
		ZNSLS401.T$VLDI$C						VL_TOTAL,
		TCMCS080.T$DSCA							TRANSPOORTADORA,
		TCMCS080.T$SEAK							APELIDO,
		ZNSLS401.T$CEPE$C						CEP,
		ZNSLS401.T$CIDE$C						CIDADE,
		ZNSLS401.T$UFEN$C						UF,
		ZNSLS400.T$IDCA$C						CANAL,
		ZNFMD630.T$CFRW$C						ID_TRANSP,
		ZNSLS401.T$DTEP$C-ZNSLS401.T$PZCD$C		DT_LIMITE,
		ZNSLS401.T$PZCD$C						PZ_CD,
		ZNSLS401.T$PZTR$C						PZ_TRANSIT,
		ZNSLS401.T$DTEP$C						DT_PROMET,
		--										DT_AJUST			*** NÃO TEMOS ESTA INFORMAÇÃO
		ZNSLS410.T$DTOC$C						DT_ETR,
		ZNFMD630.T$NCAR$C						CARGA,
		ZNSLS401.T$MGRT$C						CAPITAL_INTERIOR,
		SKU.DESCR								DESCRICAO
FROM
					WMWHSE5.ORDERDETAIL			SHD
		INNER JOIN	WMWHSE5.ORDERDETAILXVAS		OXV			ON	OXV.ORDERKEY				=	SHD.ORDERKEY
															AND	OXV.ORDERLINENUMBER			=	SHD.ORDERLINENUMBER
		INNER JOIN	WMWHSE5.ORDERS				SHO			ON	SHO.ORDERKEY				=	SHD.ORDERKEY
		INNER JOIN	WMWHSE5.SKU					SKU			ON	SKU.SKU						=	SHD.SKU
		 LEFT JOIN	BAANDB.TWHINH431301@PLN01	WHINH431	ON	WHINH431.T$SHPM				=	SUBSTR(SHD.EXTERNORDERKEY,5,9)
															AND	TO_CHAR(WHINH431.T$PONO)	=	TO_CHAR(SHD.EXTERNLINENO)
		 LEFT JOIN	BAANDB.TZNSLS004301@PLN01	ZNSLS004	ON	ZNSLS004.T$ORNO$C			=	WHINH431.T$WORN
															AND	ZNSLS004.T$PONO$C			=	WHINH431.T$WPON
		 LEFT JOIN	BAANDB.TZNSLS401301@PLN01	ZNSLS401	ON	ZNSLS401.T$NCIA$C			=	ZNSLS004.T$NCIA$C
                                                            AND	ZNSLS401.T$UNEG$C           =	ZNSLS004.T$UNEG$C
                                                            AND	ZNSLS401.T$PECL$C           =	ZNSLS004.T$PECL$C
                                                            AND	ZNSLS401.T$SQPD$C           =	ZNSLS004.T$SQPD$C
                                                            AND	ZNSLS401.T$ENTR$C           =	ZNSLS004.T$ENTR$C
		                                                    AND	ZNSLS401.T$SEQU$C           =	ZNSLS004.T$SEQU$C
		 LEFT JOIN	BAANDB.TZNSLS400301@PLN01	ZNSLS400	ON	ZNSLS400.T$NCIA$C			=	ZNSLS004.T$NCIA$C
		                                                    AND	ZNSLS400.T$UNEG$C           =	ZNSLS004.T$UNEG$C
		                                                    AND	ZNSLS400.T$PECL$C           =	ZNSLS004.T$PECL$C
		                                                    AND	ZNSLS400.T$SQPD$C           =	ZNSLS004.T$SQPD$C
		 LEFT JOIN	(	SELECT A.T$NCIA$C,
		                        A.T$UNEG$C,
		                        A.T$PECL$C,
		                        A.T$SQPD$C,
		                        A.T$ENTR$C,
							    MIN(A.T$DTOC$C) T$DTOC$C,
							    MIN(A.T$CONO$C) T$CONO$C
						 FROM BAANDB.TZNSLS410301@PLN01 A
						 WHERE A.T$POCO$C='ETR'
						 GROUP BY A.T$NCIA$C,
						          A.T$UNEG$C,
						          A.T$PECL$C,
						          A.T$SQPD$C,
						          A.T$ENTR$C)	ZNSLS410	ON	ZNSLS410.T$NCIA$C			=	ZNSLS004.T$NCIA$C
						                                    AND	ZNSLS410.T$UNEG$C           =	ZNSLS004.T$UNEG$C
		                                                    AND	ZNSLS410.T$PECL$C           =	ZNSLS004.T$PECL$C
		                                                    AND	ZNSLS410.T$SQPD$C           =	ZNSLS004.T$SQPD$C
                                                            AND	ZNSLS410.T$ENTR$C           =	ZNSLS004.T$ENTR$C
		 LEFT JOIN	BAANDB.TZNFMD630301@PLN01	ZNFMD630	ON	ZNFMD630.T$ORNO$C			=	WHINH431.T$WORN
		 LEFT JOIN	BAANDB.TZNFMD001301@PLN01	ZNFMD001	ON	ZNFMD001.T$FILI$C			=	ZNFMD630.T$FILI$C
		 LEFT JOIN	BAANDB.TZNINT002301@PLN01	ZNINT002	ON	ZNINT002.T$NCIA$C			=	ZNSLS401.T$NCIA$C
															AND	ZNINT002.T$UNEG$C			=	ZNSLS401.T$UNEG$C
		 LEFT JOIN	BAANDB.TZNSLS002301@PLN01	ZNSLS002	ON	ZNSLS002.T$TPEN$C			=	ZNSLS401.T$ITPE$C
		 LEFT JOIN	BAANDB.TTCMCS080301@PLN01	TCMCS080	ON	TCMCS080.T$CFRW				=	ZNFMD630.T$CFRW$C
 WHERE
			ZNSLS410.T$DTOC$C 	IS NOT NULL
		AND OXV.NOTES1 			IS NOT NULL