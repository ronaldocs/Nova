-- em 19/02/2015 o F�bio da INFOR informou que pod�amos deixar
-- apenas um SELECT pois os c�digos e descri��es ser�o unificados
-- pelos usu�rios. A view original est� trazendo c�digos iguais 
-- com descri��es diferentes - Rosana
SELECT DISTINCT COD_EVENTO as ETRK_ID_EVENTO, NOME_EVENTO as ETRK_NOME 
FROM
		(SELECT    
				  OSS.CODE COD_EVENTO,
				  OSS.DESCRIPTION NOME_EVENTO
		FROM      WMWHSE1.ORDERSTATUSSETUP OSS)
--		UNION SELECT    
--				  OSS.CODE COD_EVENTO,
--				  OSS.DESCRIPTION NOME_EVENTO
--		FROM      WMWHSE2.ORDERSTATUSSETUP OSS
--		UNION SELECT    
--				  OSS.CODE COD_EVENTO,
--				  OSS.DESCRIPTION NOME_EVENTO
--		FROM      WMWHSE3.ORDERSTATUSSETUP OSS
--		UNION SELECT    
--				  OSS.CODE COD_EVENTO,
--				  OSS.DESCRIPTION NOME_EVENTO
--		FROM      WMWHSE4.ORDERSTATUSSETUP OSS
--		UNION SELECT    
--				  OSS.CODE COD_EVENTO,
--				  OSS.DESCRIPTION NOME_EVENTO
--		FROM      WMWHSE5.ORDERSTATUSSETUP OSS
--		UNION SELECT    
--				  OSS.CODE COD_EVENTO,
--				  OSS.DESCRIPTION NOME_EVENTO
--		FROM      WMWHSE6.ORDERSTATUSSETUP OSS
--		UNION SELECT    
--				  OSS.CODE COD_EVENTO,
--				  OSS.DESCRIPTION NOME_EVENTO
--		FROM      WMWHSE7.ORDERSTATUSSETUP OSS
--		UNION SELECT    
--				  OSS.CODE COD_EVENTO,
--				  OSS.DESCRIPTION NOME_EVENTO
--		FROM      WMWHSE8.ORDERSTATUSSETUP OSS
--		UNION SELECT    
--				  OSS.CODE COD_EVENTO,
--				  OSS.DESCRIPTION NOME_EVENTO
--		FROM      WMWHSE9.ORDERSTATUSSETUP OSS)