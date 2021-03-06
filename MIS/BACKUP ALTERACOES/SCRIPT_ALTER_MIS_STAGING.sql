﻿--Banco MIS_STAGING
------------------------------------------------------------------------------------------------------------------------
--Script Alteracao Data Type

--DE VARCHAR(30) PARA VARCHAR(60)
ALTER TABLE MIS_STAGING.SIGE.STG_DEPT
ALTER COLUMN DS_DEPT VARCHAR(60)

--DE VARCHAR(1) PARA VARCHAR(3)
ALTER TABLE MIS_STAGING.SIGE.STG_PRODUCT
ALTER COLUMN DS_STATUS VARCHAR(3)

--DE VARCHAR(1) PARA VARCHAR(3)
ALTER TABLE MIS_STAGING.SIGE.STG_PRODUCT
ALTER COLUMN DS_ABC VARCHAR(3)

--NUMERIC(9) PARA BIGINT
ALTER TABLE MIS_STAGING.SIGE.STG_PRODUCT
ALTER COLUMN nr_product BIGINT

--NUMERIC(9) PARA BIGINT
ALTER TABLE MIS_STAGING.SIGE.STG_PRODUCT
ALTER COLUMN nr_item BIGINT


--de NUMERIC(2) PARA NUMERIC(4)
ALTER TABLE MIS_STAGING.SIGE.STG_CATEGORIA
ALTER COLUMN nr_cia NUMERIC(4)

-- de VARCHAR(1) PARA VARCHAR(3)
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ALTER COLUMN DS_STATUS VARCHAR(3)

--de VARCHAR(15) para VARCHAR(20)
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ALTER COLUMN DS_APELIDO VARCHAR(20)

--DE NUMERIC(2) PARA NUMERIC(3)
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ALTER COLUMN NR_CIA NUMERIC(3)

--DE NUMERIC(9) PARA NUMERIC(15)
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ALTER COLUMN NR_ID_ITEM NUMERIC(15)

--DE NUMERIC(13) PARA NUMERIC(15)
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ALTER COLUMN DS_EAN NUMERIC(15)

--DE NUMERIC(10) PARA NUMERIC(15)
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ALTER COLUMN NR_NBM NUMERIC(15)

--DE INT para NUMERIC(15)
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ALTER COLUMN NR_SKU_ITEM_VINCULADO NUMERIC(15)

alter table fin.stg_sige_fin_documento
alter column DOFI_ID_MODULO varchar(3)

alter table fin.stg_sige_fin_documento
alter column DOFI_ID_DOCUMENTO varchar(3)

-------------------------------------------------------------------
ALTER TABLE FIN.stg_sige_titulo_receber
ALTER COLUMN TITC_ID_CENTRO_CUSTO NUMERIC(9)

ALTER TABLE FIN.stg_sige_titulo_receber
ALTER COLUMN TITC_ID_MODULO VARCHAR(3)

ALTER TABLE FIN.stg_sige_titulo_receber
ALTER COLUMN TITC_ID_CIA NUMERIC(3)

ALTER TABLE FIN.stg_sige_titulo_receber
ALTER COLUMN TITC_ID_CARTEIRA VARCHAR(3)

ALTER TABLE FIN.stg_sige_titulo_receber
ALTER COLUMN TITC_ID_DOCUMENTO VARCHAR(3)

ALTER TABLE FIN.stg_sige_titulo_receber
ALTER COLUMN TITC_ID_CENTRO_CUSTO VARCHAR(20)

---------------------------------------------------------------------------
ALTER TABLE FIN.stg_sige_titulo_receber_movimento
ALTER COLUMN MOCO_ID_CIA numeric(3)

alter table FIN.stg_sige_titulo_receber_movimento
alter column MOCO_ID_MODULO varchar(3)

ALTER TABLE FIN.stg_sige_titulo_receber_movimento
ALTER COLUMN MOCO_ID_TRANSACAO varchar(3)

ALTER TABLE FIN.stg_sige_titulo_receber_movimento
ALTER COLUMN MOCO_SINAL NUMERIC(2)

ALTER TABLE FIN.stg_sige_titulo_receber_movimento
ALTER COLUMN MOCO_ID_MODULO_REF varchar(3)

ALTER TABLE FIN.stg_sige_titulo_receber_movimento
add MOCO_SQ_MOVIMENTO int, 
	CD_TIPO_MOVIMENTO smallint,
	NR_PARCELA smallint

--------------------------------------------------------------------
--DE NUMERIC(2) para NUMERIC(3)
ALTER TABLE MIS_STAGING.fin.stg_sige_titulo_pagamento
ALTER COLUMN TIPA_ID_TRANSACAO numeric(3)

--------------------------------------------------------------------
--DE varchar(30) para varchar(35)
ALTER TABLE MIS_STAGING.FIN.STG_SIGE_FORNECEDOR_CONTATO
ALTER COLUMN TCON_NOME VARCHAR(35)

--------------------------------------------------------------------
--DE NUMERIC(2) para NUMERIC(3)
ALTER TABLE MIS_STAGING.FIN.aux_ods_sige_titulo_pagamento
ALTER COLUMN NR_ID_TRANSACAO NUMERIC(3)

------------------------------------------------------------------------------------------------------------------------
--Inclus�o de Atributo

--ADICIONAR COLUNA DE CODIGO CATEGORIA
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ADD nr_categoria int

--INCLUS�O DO CAMPO YN MKTPLACE
--Tratamento direto na origem
ALTER TABLE MIS_STAGING.SIGE.STG_ITEM
ADD YN_MARKETPLACE BIT


--INCLUSAO DA COLUNA DE CODIGO DEPARTAMENTO LN
ALTER TABLE MIS_STAGING.SIGE.STG_DEPT
ADD nr_dept_ln VARCHAR(6)

--CRIAÇÃO DA TABELA TEMPORÁRIA para o Relatório Minha Casa Minha Vida
CREATE TABLE [dbo].[stg_rel_pedidos_minha_casa_amc](
	[IdCliente] [int] NULL,
	[Nome] [varchar](50) NULL,
	[IdCanalVenda] [varchar](20) NULL,
	[Data] [datetime] NULL,
	[IdCompra] [int] NULL,
	[_ValorTotalComDesconto] [money] NULL,
	[ped_externo] [varchar](50) NULL,
	[_nr_id_unidade_negocio] [int] NULL,
	[ds_unidade_negocio] [varchar](50) NULL,
	[CpfCnpj] [varchar](50) NULL,
	[DataStatus] [datetime] NULL
) ON [PRIMARY]
GO

------------------------------------------------------------------------------------------------------

--INCLUSÃO DE TABELAS SURROGATE KEY

CREATE TABLE ln.stg_companhia_ref (
  nr_id_companhia_sige INTEGER NULL,
  nr_id_companhia_ln INTEGER NULL
);

CREATE TABLE ln.stg_condicao_pagamento_ref (
  nr_id_condicao_pagamento INT NOT NULL IDENTITY,
  nr_id_companhia INT NULL,
  ds_id_condicao_pagamento VARCHAR(6) NULL,
  ds_condicao_pagamento VARCHAR(60) NULL,
  PRIMARY KEY(nr_id_condicao_pagamento)
);

CREATE TABLE ln.stg_departamento_ref (
  nr_id_departamento BIGINT NOT NULL IDENTITY,
  ds_id_departamento VARCHAR(6) NULL,
  ds_departamento VARCHAR(60) NULL,
  PRIMARY KEY(nr_id_departamento)
);

CREATE TABLE ln.stg_deposito_estoque_ref (
  nr_id_deposito BIGINT NOT NULL IDENTITY,
  nr_id_companhia INT NULL,
  ds_id_filial VARCHAR(12) NULL,
  ds_id_deposito VARCHAR(255) NULL,
  PRIMARY KEY(nr_id_deposito)
);

CREATE TABLE ln.stg_nota_recebimento_ref (
  nr_id_nota_recebimento BIGINT NOT NULL IDENTITY,
  nr_id_compania INTEGER NULL,
  ds_id_filial VARCHAR(12) NULL,
  ds_id_nota_recebimento VARCHAR(18) NULL,
  PRIMARY KEY(nr_id_nota_recebimento)
);

CREATE TABLE ln.stg_pedido_compra_cabecalho_ref (
  nr_id_pedido_compra BIGINT NOT NULL IDENTITY,
  nr_id_cia INT NULL,
  ds_id_filial VARCHAR(12) NULL,
  ds_num_ped_compra VARCHAR(18) NULL,
  PRIMARY KEY(nr_id_pedido_compra)
);

CREATE TABLE ln.stg_titulo_cap_ref (
  nr_id_titulo BIGINT NOT NULL IDENTITY,
  ds_id_titulo VARCHAR(50) NULL,
  ds_tipo_transacao VARCHAR(10) NULL,
  PRIMARY KEY(nr_id_titulo)
);

CREATE TABLE ln.stg_titulo_car_ref (
  nr_id_titulo BIGINT NOT NULL IDENTITY,
  ds_id_titulo VARCHAR(50) NULL,
  ds_tipo_transacao VARCHAR(10) NULL,
  PRIMARY KEY(nr_id_titulo)
);

------------------------------------------------------------------------------------------------------
--de numeric(7) para numeric(10)
ALTER TABLE fin.stg_sige_centro_custo
ALTER COLUMN CCUS_ID_CENTROCUSTOS numeric(10)

--DE NUMERIC(2) PARA NUMERIC(3)
ALTER TABLE FIN.stg_sige_titulo_complemento_nf
ALTER COLUMN NFCA_ID_CIA NUMERIC(3)

--DE NUMERIC(2) PARA NUMERIC(3)
ALTER TABLE FIN.stg_sige_contas_receber_campanha
ALTER COLUMN PEDC_ID_CIA NUMERIC(3)

-----------------------------------------------------------------------
ALTER TABLE fin.aux_ods_sige_titulo_receber
ALTER COLUMN nr_id_cia numeric(3)

ALTER TABLE fin.aux_ods_sige_titulo_receber
ALTER COLUMN DS_ID_MODULO VARCHAR(3)

ALTER TABLE fin.aux_ods_sige_titulo_receber
ALTER COLUMN DS_ID_documento VARCHAR(3)

ALTER TABLE fin.aux_ods_sige_titulo_receber
ALTER COLUMN nr_id_centro_custo VARCHAR(20)

------------------------------------------------------------------------
--DE NUMERIC(2) PARA NUMERIC(3)
ALTER TABLE FIN.aux_ods_sige_titulo_receber_complemento
ALTER COLUMN NR_ID_CIA NUMERIC(3)


alter table sige.stg_item
ADD nr_id_filial_venda numeric(3)

alter table sige.stg_item
ADD nr_dt_cadastro numeric(8)

alter table sige.stg_item
add ds_modelo_fabricante varchar(60)

alter table sige.stg_item
add ds_kit_wms varchar(20)



USE [MIS_STAGING]
GO

/****** Object:  Table [com].[stg_cliente_venda_vendedor_samsung]    Script Date: 07/07/2014 14:38:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[com].[stg_cliente_venda_vendedor_samsung]') AND type in (N'U'))
DROP TABLE [com].[stg_cliente_venda_vendedor_samsung]
GO

USE [MIS_STAGING]
GO

/****** Object:  Table [com].[stg_cliente_venda_vendedor_samsung]    Script Date: 07/07/2014 14:38:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [com].[stg_cliente_venda_vendedor_samsung](
	[VENR_CPF] [numeric](11, 0) NULL,
	[VENR_NOME] [nvarchar](40) NULL,
	[FILI_CGC] [numeric](14, 0) NULL,
	[VENDEDOR] [nvarchar](8) NULL,
	[NFCA_ID_PED] [numeric](12, 0) NULL,
	[ITEG_EAN] [numeric](13, 0) NULL,
	[NFCA_DT_EMISSAO] [datetime] NULL,
	[VENR_MATRICULA] [nvarchar](30) NULL,
	[CLIE_ID_TERCEIRO] [numeric](14, 0) NULL,
	[TIPO_FATURAMENTO] [nvarchar](2) NULL,
	[NFDE_QT_VOLUMES] [numeric](18, 9) NULL,
	[NFDE_PR_UNIT] [numeric](16, 3) NULL,
	[NFDE_VL_TOTAL_ITEM] [numeric](15, 2) NULL,
	[VALOR_LIQUIDO] [numeric](15, 2) NULL,
	[NFDE_PERC_ICMS] [numeric](5, 2) NULL,
	[NFCA_SITUACAO] [nvarchar](1) NULL,
	[ITEG_COD_FORNEC] [nvarchar](50) NULL,
	[VENDA] [nvarchar](5) NULL,
	[CLIE_TEL] [nvarchar](15) NULL,
	[CLEN_CEP] [numeric](8, 0) NULL,
	[MUNI_ID_ESTADO] [nvarchar](2) NULL,
	[MUNI_NOME] [nvarchar](60) NULL,
	[CLEN_END] [nvarchar](80) NULL,
	[CLIE_NOME] [nvarchar](40) NULL,
	[CLIE_EMAIL] [nvarchar](45) NULL,
	[CLASSIFICACAO_VENDA] [nvarchar](1) NULL,
	[CLIENTE] [nvarchar](7) NULL
) ON [PRIMARY]

GO

USE [MIS_STAGING]
GO

/****** Object:  Table [com].[stg_estoque_samsung]    Script Date: 07/07/2014 14:39:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[com].[stg_estoque_samsung]') AND type in (N'U'))
DROP TABLE [com].[stg_estoque_samsung]
GO

USE [MIS_STAGING]
GO

/****** Object:  Table [com].[stg_estoque_samsung]    Script Date: 07/07/2014 14:39:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [com].[stg_estoque_samsung](
	[ITEG_EAN] [numeric](13, 0) NULL,
	[DATASELECT] [datetime] NULL,
	[FILI_CGC] [numeric](14, 0) NULL,
	[QT_FISICA] [numeric](38, 4) NULL,
	[TIPO_ESTOQUE] [nvarchar](2) NULL,
	[ITEG_COD_FORNEC] [nvarchar](50) NULL
) ON [PRIMARY]

GO


----------------------------------------

alter table fin.aux_contas_receber_transacao
alter column ds_id_documento varchar(3)

alter table fin.aux_contas_receber_transacao
alter column ds_id_modulo varchar(3)


USE [MIS_STAGING]
GO

/****** Object:  Table [com].[stg_relatorio_vpc]    Script Date: 08/21/2014 17:49:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [com].[stg_relatorio_vpc](
	[COMPRADOR] [varchar](255) NULL,
	[DT_EMISSAO] [datetime] NULL,
	[TP_CONTRATO] [varchar](50) NULL,
	[ID_CONTRATO] [int] NULL,
	[CNPJ] [varchar](100) NULL,
	[RAZAO_SOCIAL] [varchar](255) NULL,
	[VALOR_CONTRATO] [numeric](20, 2) NULL,
	[ID_DEPTO] [varchar](10) NULL,
	[NOME_DEPTO] [varchar](100) NULL,
	[TITULO] [text] NULL,
	[VEICULO] [varchar](100) NULL,
	[COMPETENCIA] [int] NULL,
	[ASSINADO] [varchar](3) NULL,
	[DT_ASSINATURA] [datetime] NULL,
	[ASSINATURA_FORNEC] [text] NULL,
	[ASSINATURA_CIA] [datetime] NULL,
	[TIPO_PAGAMENTO] [varchar](100) NULL,
	[ID_MODALIDADE] [varchar](4) NULL,
	[DESC_MODALIDADE] [varchar](100) NULL,
	[INICIO_VIGENCIA] [datetime] NULL,
	[DT_VENCIMENTO] [datetime] NULL,
	[DT_CONTRATO] [datetime] NULL,
	[DT_ALTERACAO] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

--===========================================================

USE [MIS_STAGING]
GO
/****** Object:  StoredProcedure [loja].[sp_ultimo_id_compra_boleto_prazo]    Script Date: 10/07/2014 14:38:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [loja].[sp_ultimo_id_compra_boleto_prazo] as
 
select
 MAX(nr_id_compra) nr_id_compra
from
 mis_ods.loja.ods_compra_boleto_prazo


--===========================================================

--gestão icms
alter table com.stg_gestao_icms_endereco_ent
alter column nfca_situacao nvarchar(3)

alter table com.stg_gestao_icms_endereco_ent
alter column nfca_serie nvarchar(8)

alter table com.stg_sige_devolucao_fornecedor
alter column fat_nr_cia int

alter table com.stg_sige_devolucao_fornecedor
alter column fat_nr_ITEM NVARCHAR(47)

--de bigint para nvarchar(47)
alter table com.ods_devolucao_fornecedor
alter column nr_item_sku nvarchar(47)

--de bigint para nvarchar(47)
alter table com.ods_devolucao_fornecedor
alter column nr_product_sku nvarchar(47)

--alteracao collation
Alter TAble sige.stg_sector
Alter Column ds_sector VarChar(30) Collate Latin1_General_CI_AS
 
alter table sige.stg_family
alter column ds_family varchar(80) Collate Latin1_General_CI_AS
 
alter table sige.stg_sige_sub_familia
alter column ds_sub_familia varchar(80) Collate Latin1_General_CI_AS

/*
--======================================================
-- copiei os dados do cosmos, pois no criciuma essa tabela
-- também estava vazia

alter table fin.stg_sige_transacao
alter column FTRA_ID_MODULO varchar(3)

insert into fin.stg_sige_transacao
values
('CB','1','Inclusão'),
('CB','2','Cancelamento'),
('CB','3','Estorno'),
('CB','4','Transferência'),
('CB','5','Dinheiro'),
('CB','6','Financeiro'),
('CAP','7','Baixa Especial'),
('CAP','1','Inclusao'),
('CAP','2','Cancelamento'),
('CAP','3','Pagamento'),
('CAP','4','Est.Pagamento'),
('CAP','5','Transferencia'),
('CAP','6','Estorno Transferencia'),
('CAP','9','Baixa LN - SC'),
('CAP','10','Est. Baixa LN - SC'),
('CAP','8','Estorno Baixa Especial'),
('CAR','9','Baixa Titulo ST indevido'),
('CAR','10','Est. Baixa Titulo ST indevido'),
('CAR','13','Baixa LN'),
('CAR','14','Est. Baixa LN - SC'),
('CAR','15','Baixa LN - SC'),
('CAR','11','Baixa Especial'),
('CAR','12','Estorno Baixa Especial'),
('CAR','1','Inclusao'),
('CAR','2','Cancelamento'),
('CAR','3','Pagamento'),
('CAR','4','Estorno Pagamento'),
('CAR','5','Transferencia'),
('CAR','6','Estorno Transferencia'),
('CAR','7','Pagamento'),
('CAR','8','Estorno Pagamento')
*/

--=========================
ALTER TABLE com.stg_hist_ati_can
ALTER COLUMN ds_status_atual VARCHAR(3)

ALTER TABLE com.stg_hist_ati_can2
ALTER COLUMN ds_status VARCHAR(3)

--=============================
alter table log.stg_entrada_fluxo_pedidos
add PECAS int null,
	M3 numeric(18,6) null

-==========================================
drop table [log].[stg_saida_fluxo_pedidos]
go

CREATE TABLE [log].[stg_saida_fluxo_pedidos](
	[FILIAL] [varchar](20) NULL,
	[ID_FILIAL] [int] NULL,
	[DT_EMISSAO] [date] NULL,
	[PERIODO] [time](7) NULL,
	[PEDV_ID_UNINEG] [int] NULL,
	[ITEG_ID_DEPTO] [int] NULL,
	[PEDV_CEP_ENTREGA] [numeric](8, 0) NULL,
	[PEDIDOS] [numeric](18, 0) NULL,
	[VL_TOTAL] [money] NULL,
	[PECAS] [int] NULL,
	[M3] [numeric](18, 6) NULL
) ON [PRIMARY]

GO

--=============================================
CREATE TABLE [log].[stg_caixa_fluxo_pedidos](
	[FILIAL] [nvarchar](10) NULL,
	[ID_FILIAL] [int] NULL,
	[DT_EMISSAO] [date] NULL,
	[PERIODO] [time](7) NULL,
	[PEDV_ID_UNINEG] [int] NULL,
	[ITEG_ID_DEPTO] [int] NULL,
	[PEDV_CEP_ENTREGA] [numeric](8, 0) NULL,
	[PEDIDOS] [numeric](18, 0) NULL,
	[PECAS] [int] NULL,
	[M3] [numeric](18, 6) NULL
) ON [PRIMARY]

GO

--===================================================
alter table log.stg_caixa_fluxo_pedidos
alter column FILIAL varchar(10)

--==================================================

alter table log.aux_fluxo_pedidos_entrada
add nr_qtde_pecas int, nr_vl_m3 numeric(18,6)

alter table log.aux_fluxo_pedidos_saida
add nr_qtde_pecas int, nr_vl_m3 numeric(18,6)

alter TABLE [log].[aux_fact_fluxo_pedidos_entrada]
add	[nr_qtde_pecas] [int] NULL,
	[nr_vl_m3] [numeric](18, 6) NULL

--===================================================
CREATE TABLE [log].[aux_fluxo_pedidos_caixa](
	[nr_dt_emissao] [int] NULL,
	[nr_hora] [int] NULL,
	[ds_filial] [nvarchar](5) NULL,
	[nr_id_planta] [int] NULL,
	[nr_id_filial] [int] NULL,
	[nr_id_unidade_negocio] [int] NULL,
	[nr_id_localidade] [int] NULL,
	[nr_id_departamento] [int] NULL,
	[nr_qtde_pedido] [numeric](18, 0) NULL,
	[nr_qtde_pecas] [int] NULL,
	[nr_vl_m3] [numeric](18, 6) NULL
) ON [PRIMARY]

--======================================================
CREATE TABLE [log].[aux_fact_fluxo_pedidos_caixa](
	[nr_dt_emissao] [int] NULL,
	[nr_hora] [int] NULL,
	[nr_id_planta] [int] NULL,
	[nr_id_unidade_negocio] [int] NULL,
	[nr_id_localidade] [int] NULL,
	[nr_id_departamento] [int] NULL,
	[nr_qtde_pedido] [numeric](18, 0) NULL,
	[nr_qtde_pecas] [int] NULL,
	[nr_vl_m3] [numeric](18, 6) NULL
) ON [PRIMARY]
