DECLARE @DTFEC	VARCHAR(8);
DECLARE @DTINI	VARCHAR(8);
DECLARE @DTFIM	VARCHAR(8);
DECLARE @CODINI	VARCHAR(6);
DECLARE @CODFIM	VARCHAR(6);

SET @DTFEC = '20200430'
SET @DTINI = '20200501'
SET @DTFIM = '20200531'
SET @CODINI = ''
SET @CODFIM = 'ZZZZZZ'


SELECT B9_COD, SUM(INICIAL) INICIAL, SUM(SD1) SD1, SUM(SD2) SD2, SUM(SD3E) SD3E, SUM(SD3S) SD3S, SUM(FINAL) FINAL,SUM(INICIAL+SD1+SD3E-SD2-SD3S) MOV,ROUND(SUM(INICIAL+SD1+SD3E-SD2-SD3S-FINAL),2) DIF
FROM
(SELECT B9_COD,SUM(B9_VINI1) INICIAL,0 SD1,0 SD2,0 SD3E,0 SD3S,0 FINAL
FROM SB9010 A
WHERE	A.D_E_L_E_T_=''
		AND A.B9_DATA = @DTFEC
		AND A.B9_QINI!=0
		--AND (A.B9_QINI!=0 OR A.B9_VINI1!=0)
		AND A.B9_COD BETWEEN @CODINI AND @CODFIM
GROUP BY B9_COD
UNION ALL
SELECT D1_COD,0,SUM(D1_CUSTO) SD1,0,0,0,0
FROM SD1010 A
INNER JOIN SF4010 B ON B.D_E_L_E_T_='' AND B.F4_CODIGO=A.D1_TES AND B.F4_ESTOQUE = 'S'
WHERE	A.D_E_L_E_T_=''
		AND D1_DTDIGIT BETWEEN @DTINI AND @DTFIM
		AND D1_COD BETWEEN @CODINI AND @CODFIM 
GROUP BY D1_COD
UNION ALL
SELECT D2_COD,0,0,SUM(D2_CUSTO1) SD2,0,0,0
FROM SD2010 A
INNER JOIN SF4010 B ON B.D_E_L_E_T_='' AND B.F4_CODIGO=A.D2_TES AND B.F4_ESTOQUE = 'S'
WHERE	A.D_E_L_E_T_=''
		AND D2_EMISSAO BETWEEN @DTINI AND @DTFIM
		AND D2_COD BETWEEN @CODINI AND @CODFIM 
GROUP BY D2_COD
UNION ALL
SELECT D3_COD,0,0,0,SUM(CASE WHEN D3_TM <'500' THEN D3_CUSTO1 ELSE 0 END) SD3E,SUM(CASE WHEN D3_TM >'499' THEN D3_CUSTO1 ELSE 0 END) SD3S,0
FROM SD3010 A
WHERE	A.D_E_L_E_T_=''
		AND D3_EMISSAO BETWEEN @DTINI AND @DTFIM
		AND D3_COD BETWEEN @CODINI AND @CODFIM 
		AND (D3_TM NOT IN ('499','999') OR D3_CF='RE1')
		AND D3_ESTORNO=''
GROUP BY D3_COD
UNION ALL
/*SELECT B9_COD,0,0,0,0,0,SUM(B9_VINI1) FINAL
FROM SB9010 A
WHERE	A.D_E_L_E_T_=''
		AND A.B9_DATA = @DTFIM
		--AND A.B9_QINI!=0
		AND A.B9_COD BETWEEN @CODINI AND @CODFIM
GROUP BY B9_COD*/
SELECT B2_COD,0,0,0,0,0,SUM(B2_VFIM1) FINAL
FROM SB2010 A
WHERE	A.D_E_L_E_T_=''
		AND A.B2_QFIM!=0
		AND A.B2_COD BETWEEN @CODINI AND @CODFIM
GROUP BY B2_COD) AS T1
GROUP BY B9_COD
HAVING ROUND(SUM(INICIAL+SD1+SD3E-SD2-SD3S-FINAL),2) != 0
ORDER BY 1