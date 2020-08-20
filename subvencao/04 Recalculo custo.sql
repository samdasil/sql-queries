DECLARE @COD VARCHAR(MAX);
DECLARE @DTINI VARCHAR(8);
DECLARE @DTFIM VARCHAR(8);
DECLARE @FECHA VARCHAR(8);

SET @COD = N'037243         '
-- SET @COD = N'004650         '
SET @DTINI = '20200501'
SET @DTFIM = '20200531'
SET @FECHA = '20200430'

SELECT	D1_COD,
		IIF(SUM(QTD)>0
		   ,SUM(CUSTO)/SUM(QTD)
		   ,SUM(IIF(ORIGEM!='SD2',CUSTO,0))
		   		/SUM(IIF(ORIGEM!='SD2',QTD,0))
		   ) Medio,
		
		--  PARA ANALISE		
		--    SUM(IIF(ORIGEM!='SD2',CUSTO,0)),
		--    SUM(IIF(ORIGEM!='SD2',QTD,0)),
		
		(SELECT MAX(B9_VINI1/B9_QINI) FROM SB9010 A (NOLOCK) WHERE A.D_E_L_E_T_='' AND A.B9_COD=T1.D1_COD AND A.B9_QINI>0 AND A.B9_DATA=@DTFIM) CUSTO_FECHADO, 
		(SELECT MAX(B9_VINI1/B9_QINI) FROM SB9010 A (NOLOCK) WHERE A.D_E_L_E_T_='' AND A.B9_COD=T1.D1_COD AND A.B9_QINI>0 AND A.B9_DATA=@FECHA) CUSTO_INICIAL
FROM 
(
	-- NOTAS DE ENTRADA
	SELECT 'SD1' ORIGEM,D1_COD,SUM(D1_CUSTO) CUSTO, SUM(D1_QUANT) QTD
	FROM SD1010 A (NOLOCK) 
	INNER JOIN SF4010 B (NOLOCK) ON B.D_E_L_E_T_='' AND B.F4_CODIGO=A.D1_TES AND B.F4_ESTOQUE='S'
	WHERE	A.D_E_L_E_T_=''
			AND A.D1_DTDIGIT BETWEEN @DTINI AND @DTFIM
			AND A.D1_TIPO NOT IN ('B','D')
			AND A.D1_TES!=''
			AND CHARINDEX(RTRIM(A.D1_COD),@COD) > 0
			AND (A.D1_FORNECE!='000010' OR A.D1_EMISSAO < @DTINI OR A.D1_CF = '1949')
	GROUP BY D1_COD

	union all

	-- NOTAS DE DEVOLUCAO
	SELECT 'SD1' ORIGEM,D1_COD,SUM(D1_CUSTO) CUSTO, SUM(D1_QUANT) QTD
	FROM SD1010 A (NOLOCK) 
	INNER JOIN SF4010 B (NOLOCK) ON B.D_E_L_E_T_='' AND B.F4_CODIGO=A.D1_TES AND B.F4_ESTOQUE='S'
	INNER JOIN SF2010 C (NOLOCK) ON C.D_E_L_E_T_='' AND C.F2_FILIAL=A.D1_FILORI AND C.F2_DOC=A.D1_NFORI AND C.F2_SERIE=A.D1_SERIORI
	WHERE	A.D_E_L_E_T_=''
			AND A.D1_DTDIGIT BETWEEN @DTINI AND @DTFIM
			AND A.D1_TIPO = 'D'
			AND A.D1_TES!=''
			AND A.D1_TES!='207'
			AND CHARINDEX(RTRIM(A.D1_COD),@COD) > 0
			AND C.F2_EMISSAO < @DTINI
	GROUP BY D1_COD

	UNION ALL
	--NOTAS DE BENEFICIAMENTO
	SELECT 'SD1' ORIGEM,D1_COD,SUM(D1_CUSTO) CUSTO, SUM(D1_QUANT) QTD
	FROM SD1010 A (NOLOCK) 
	INNER JOIN SF4010 B (NOLOCK) ON B.D_E_L_E_T_='' AND B.F4_CODIGO=A.D1_TES AND B.F4_ESTOQUE='S'
	INNER JOIN SF2010 C (NOLOCK) ON C.D_E_L_E_T_='' AND C.F2_FILIAL=A.D1_FILIAL AND C.F2_DOC=A.D1_NFORI AND C.F2_SERIE=A.D1_SERIORI
	WHERE	A.D_E_L_E_T_=''
			AND A.D1_DTDIGIT BETWEEN @DTINI AND @DTFIM
			AND A.D1_TIPO = 'B'
			AND A.D1_TES!=''
			AND CHARINDEX(RTRIM(A.D1_COD),@COD) > 0
			AND C.F2_EMISSAO < @DTINI
	GROUP BY D1_COD
	-- SALDO INICIAL

	union all
	SELECT 'SB9' ORIGEM,B9_COD D1_COD,SUM(B9_VINI1) CUSTO, SUM(B9_QINI) QTD
	FROM SB9010 A (NOLOCK)
	WHERE	A.D_E_L_E_T_=''
			AND A.B9_DATA = @FECHA
			AND CHARINDEX(RTRIM(A.B9_COD),@COD)>0
			AND A.B9_QINI>0
	GROUP BY B9_COD

	union all

	SELECT 'SD3E' ORIGEM,D3_COD D1_COD,SUM(D3_CUSTO1) CUSTO, SUM(D3_QUANT) QTD
	FROM SD3010 A (NOLOCK)
	WHERE	A.D_E_L_E_T_=''
			AND A.D3_EMISSAO BETWEEN @DTINI AND @DTFIM
			AND CHARINDEX(RTRIM(A.D3_COD),@COD)>0
			AND A.D3_TM<'499'
			AND A.D3_ESTORNO=''
	GROUP BY D3_COD
	union all
	SELECT 'SD3S' ORIGEM,D3_COD D1_COD,SUM(D3_CUSTO1)*(-1) CUSTO, SUM(D3_QUANT)*(-1) QTD
	FROM SD3010 A (NOLOCK)
	WHERE	A.D_E_L_E_T_=''
			AND A.D3_EMISSAO BETWEEN @DTINI AND @DTFIM
			AND CHARINDEX(RTRIM(A.D3_COD),@COD)>0
			AND A.D3_QUANT=0
			AND A.D3_ESTORNO=''
			AND A.D3_TM BETWEEN '500' AND '998'
	GROUP BY D3_COD
	union all
	SELECT 'SD2' ORIGEM,D3_COD D1_COD,SUM(D3_CUSTO1)*(-1) CUSTO, SUM(D3_QUANT)*(-1) QTD
	FROM SD3010 A (NOLOCK)
	WHERE	A.D_E_L_E_T_=''
			AND A.D3_EMISSAO BETWEEN @DTINI AND @DTFIM
			AND CHARINDEX(RTRIM(A.D3_COD),@COD)>0
			AND A.D3_ESTORNO=''
			AND A.D3_QUANT!=0
			AND A.D3_TM = '700'
	GROUP BY D3_COD
	union all
	-- NOTAS DE DEVOLUCAO
	SELECT 'SD2' ORIGEM,D2_COD,SUM(D2_CUSTO1)*(-1) CUSTO, SUM(D2_QUANT)*(-1) QTD
	FROM SD2010 A (NOLOCK) 
	INNER JOIN SF4010 B (NOLOCK) ON B.D_E_L_E_T_='' AND B.F4_CODIGO=A.D2_TES AND B.F4_ESTOQUE='S'
	WHERE	A.D_E_L_E_T_=''
			AND A.D2_EMISSAO BETWEEN @DTINI AND @DTFIM
			AND A.D2_TIPO = 'D'
			AND CHARINDEX(RTRIM(A.D2_COD),@COD) > 0
	GROUP BY D2_COD

) AS T1

GROUP BY D1_COD

ORDER BY 1

