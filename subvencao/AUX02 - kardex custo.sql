DECLARE @COD VARCHAR(6);
DECLARE @DTINI VARCHAR(8);
DECLARE @DTFIM VARCHAR(8);
DECLARE @FECHA VARCHAR(8);

SET @COD ='001977                  '
SET @DTINI = '20200701'
SET @DTFIM = '20200731'
SET @FECHA = '20200630'

SELECT D2_CUSTO1/D2_QUANT,D2_CUSTO1,D2_TIPO,*
FROM SD2010 A
WHERE	A.D_E_L_E_T_=''
		AND A.D2_EMISSAO BETWEEN @DTINI AND @DTFIM
	--	AND A.D2_CLIENTE='000800'
		AND A.D2_COD=@COD

SELECT D1_CUSTO/IIF(D1_QUANT=0,1,D1_QUANT),* 
FROM SD1010 A
WHERE	A.D_E_L_E_T_=''
		AND A.D1_DTDIGIT BETWEEN @DTINI AND @DTFIM
		-- AND A.D1_FORNECE!='000010'
		AND A.D1_TES!=''
		AND A.D1_COD=@COD

SELECT D3_CUSTO1/IIF(D3_QUANT=0,1,D3_QUANT),* 
FROM SD3010 A 
WHERE A.D_E_L_E_T_=''
		AND A.D3_EMISSAO BETWEEN @DTINI AND @DTFIM
		AND A.D3_COD=@COD
		AND A.D3_ESTORNO = ''
		-- AND A.D3_TM NOT IN ('499','999')

SELECT B9_VINI1/B9_QINI,* 
FROM SB9010 A
WHERE A.D_E_L_E_T_=''
		AND A.B9_DATA=@FECHA
		AND A.B9_COD=@COD
		AND A.B9_QINI > 0 

SELECT B9_VINI1/B9_QINI,* 
FROM SB9010 A
WHERE A.D_E_L_E_T_=''
		AND A.B9_DATA = @DTFIM
		AND A.B9_COD=@COD
		AND A.B9_QINI != 0 