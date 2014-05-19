--	FAF.004 - 12-jan-2014, Fabio Ferreira, 	Corre��es de datas e outros campos
--*******************************************************************************************************************************************
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
--	ORDERS.DELIVERYDATE DATA_ESTIMADA_ENTREGA,																--#FAF.004.o
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
--	ORDERS.ORDERDATE DATA_EMISSAO_PEDIDO,																	--#FAF.004.o
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
--	ORDERS.ORDERDATE DATA_REGISTRO,																			--#FAF.004.o
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
--	(SELECT MAX(orderstatushistory.adddate) FROM WMWHSE1.orderstatushistory orderstatushistory				--#FAF.004.o
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE1.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	
--	orders.openqty QUANTIDADE_ITENS,																		--#FAF.004.o
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
--	orders.SCHEDULEDSHIPDATE DATA_MINIMA_EXPEDICAO,															--#FAF.004.o
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
--	orders.REQUESTEDSHIPDATE DATA_LIMITE_ORIGINAL,															--#FAF.004.o
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE1.ORDERS ORDERS 
      LEFT JOIN WMWHSE1.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE1.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS
UNION
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE2.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE2.ORDERS ORDERS 
      LEFT JOIN WMWHSE2.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE2.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS

UNION
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE3.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE3.ORDERS ORDERS 
      LEFT JOIN WMWHSE3.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE3.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS

UNION
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE4.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE4.ORDERS ORDERS 
      LEFT JOIN WMWHSE4.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE4.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS

UNION
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE5.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE5.ORDERS ORDERS 
      LEFT JOIN WMWHSE5.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE5.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS

UNION
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE6.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE6.ORDERS ORDERS 
      LEFT JOIN WMWHSE6.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE6.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS

UNION
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE7.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE7.ORDERS ORDERS 
      LEFT JOIN WMWHSE7.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE7.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS

UNION
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE8.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE8.ORDERS ORDERS 
      LEFT JOIN WMWHSE8.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE8.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS

UNION
SELECT	
	ORDERS.ORDERKEY COD_PEDIDO_WMS,
	ORDERS.REFERENCELOCATION COD_FILIAL,
	ORDERS.WHSEID COD_PLANTA,
	' ' COD_PROGRAMA, 								-- *** AGUARDANDO DUVIDA ***
	ORDERS.CONSIGNEEKEY COD_CLIENTE,
	WAVEDETAIL.wavekey COD_ONDA,					
	ORDERS.EXTERNORDERKEY NUM_ENTREGA,
	' ' COD_RESTRICAO,								-- *** AGUARDANDO DUVIDA ***
	' ' COD_IDENTIFICADO_PRE_VOLUME,				-- *** AGUARDANDO DUVIDA ***
	ORDERS.ROUTE COD_ROTA,
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.SCHEDULEDDELVDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 	--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_ESTIMADA_ENTREGA,										--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_EMISSAO_PEDIDO,											--#FAF.004.en
	CAST((FROM_TZ(CAST(TO_CHAR(ORDERS.ORDERDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 			--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_REGISTRO,												--#FAF.004.en		
	ORDERSTATUSSETUP.DESCRIPTION SITUACAO,
	(SELECT 																								--#FAF.004.sn
		CAST((FROM_TZ(CAST(TO_CHAR(MAX(orderstatushistory.adddate), 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 
			AT time zone sessiontimezone) AS DATE)
	FROM WMWHSE9.orderstatushistory orderstatushistory														--#FAF.004.en				
	WHERE orderstatushistory.ORDERKEY=ORDERS.ORDERKEY
	AND orderstatushistory.STATUS=ORDERSTATUSSETUP.CODE) DATA_SITUACAO,
	orders.TOTALQTY QUANTIDADE_ITENS,																		--#FAF.004.n
	orders.CARRIERCODE COD_TRANSPORTADORA,
	orders.route COD_CONTRATO_TRANSPORTADORA,
	orders.SCHEDULEDSHIPDATE DATA_LIMITE_EXPEDICAO,
	' ' COD_CANAL_VENDAS_PEDIDO,						-- *** AGUARDANDO DUVIDA ***
	orders.C_ZIP CEP_ENTREGA,
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_MINIMA_EXPEDICAO,										--#FAF.004.en
	' ' COD_REGIAO,										-- *** AGUARDANDO DUVIDA ***
	 ORDERS.C_VAT COD_MEGA_ROTA,				
	CAST((FROM_TZ(CAST(TO_CHAR(orders.DELIVERYDATE, 'DD-MON-YYYY HH:MI:SS AM') AS TIMESTAMP), 'GMT') 		--#FAF.004.sn
		AT time zone sessiontimezone) AS DATE) DATA_LIMITE_ORIGINAL,										--#FAF.004.en	
	' ' COD_ORIGEM_PEDIDO,								-- *** AGUARDANDO DUVIDA ***
	orders.EDITDATE DT_HR_ATUALIZACAO
FROM 	WMWHSE9.ORDERS ORDERS 
      LEFT JOIN WMWHSE9.WAVEDETAIL WAVEDETAIL ON WAVEDETAIL.ORDERKEY=ORDERS.ORDERKEY, 
      WMWHSE9.ORDERSTATUSSETUP ORDERSTATUSSETUP
WHERE	ORDERSTATUSSETUP.CODE=ORDERS.STATUS