SELECT 
        A.D1_CUSTO,
        B.D1_CUSTO,
        A.D1_TOTAL - A.D1_VALDESC CALCULADO,
        ROUND(A.D1_CUSTO - (ROUND(A.D1_TOTAL,10)-ROUND(A.D1_VALDESC,10)),10) DIFF,
        A.D1_TOTAL,
        A.D1_VALDESC,
        A.D1_TES,
        B.D1_TES 
FROM SD1010 A
INNER JOIN SD1010_SUBVENCAO B ON B.R_E_C_N_O_=A.R_E_C_N_O_
WHERE A.D_E_L_E_T_=''
        AND A.D1_TES!=B.D1_TES
        AND A.D1_DTDIGIT BETWEEN '20200201' AND '20200229'
        -- AND A.D1_TES NOT IN ('219')