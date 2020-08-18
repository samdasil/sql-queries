SELECT DISTINCT D1_FILIAL,
        D1_TES,F4_FINALID,
        CASE 
                WHEN A.D1_TES = '003'THEN '217'
                WHEN A.D1_TES = '007'THEN '219'
                WHEN A.D1_TES = '004'THEN '218'
                WHEN A.D1_TES = '065'THEN '220'
                WHEN A.D1_TES = '200'THEN '221'
                WHEN A.D1_TES = '201'THEN '222'
                WHEN A.D1_TES = '204'THEN '223'
                WHEN A.D1_TES = '210'THEN '224'
                WHEN A.D1_TES = '300'THEN '303'
                WHEN A.D1_TES = '050'THEN '225'
        END 'NOVA TES'
-- UPDATE A SET A.D1_TES = CASE 
--                 WHEN A.D1_TES = '003'THEN '217'
--                 WHEN A.D1_TES = '007'THEN '219'
--                 WHEN A.D1_TES = '004'THEN '218'
--                 WHEN A.D1_TES = '065'THEN '220'
--                 WHEN A.D1_TES = '200'THEN '221'
--                 WHEN A.D1_TES = '201'THEN '222'
--                 WHEN A.D1_TES = '204'THEN '223'
--                 WHEN A.D1_TES = '210'THEN '224'
--                 WHEN A.D1_TES = '300'THEN '303'
--                 WHEN A.D1_TES = '050'THEN '225'
--         END
FROM SD1010 A
INNER JOIN SF4010 B ON B.D_E_L_E_T_='' AND B.F4_FILIAL='' AND B.F4_CODIGO=A.D1_TES AND B.F4_ESTOQUE='S'
WHERE   A.D_E_L_E_T_=''
        AND A.D1_DTDIGIT BETWEEN '20200301' AND '20200331'
        AND D1_TES IN ('003','007','004','065','200','201','204','210','300','050')
ORDER BY 1

