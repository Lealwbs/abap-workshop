*&---------------------------------------------------------------------*
*& Report Z08_EXERC3_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc3_3.

TYPES: BEGIN OF tp_l_bdcdata,
         vtp_program  TYPE bdcdata-program,
         vtp_dynpro   TYPE bdcdata-dynpro,
         vtp_dynbegin TYPE bdcdata-dynbegin,
         vtp_fnam     TYPE bdcdata-fnam,
         vtp_fval     TYPE bdcdata-fval,
       END OF tp_l_bdcdata.

DATA: it_bdcdata TYPE TABLE OF tp_l_bdcdata.

START-OF-SELECTION.

  DATA: v_tmp_dynpro TYPE bdcdata-dynpro.

  PERFORM f_insert_line USING 'SAPMF02B' '0100' 'X' '' ''.
  PERFORM f_insert_line USING '' '0000' '' 'BDC_OKCODE' '/00'.
  PERFORM f_insert_line USING '' '0000' '' 'BNKA-BANKS' 'BR'.
  PERFORM f_insert_line USING '' '0000' '' 'BNKA-BANKL' '104167824'.
  PERFORM f_insert_line USING 'SAPMF02B' '0110' 'X' '' ''.
  PERFORM f_insert_line USING '' '0000' '' 'BDC_OKCODE' '=UPDA'.
  PERFORM f_insert_line USING '' '0000' '' 'BNKA-BANKA' 'CAIXA ECONÔMICA FEDERAL'.
  PERFORM f_insert_line USING '' '0000' '' 'BNKA-STRAS' 'RUA DA BAHIA, 35'.
  PERFORM f_insert_line USING '' '0000' '' 'BNKA-ORT01' 'CENTRO'.
  PERFORM f_insert_line USING '' '0000' '' 'BNKA-BRNCH' 'CENTRAL'.
  "Obs: O valor 'NULL'/Vazio de bdcdata-dynpro é exatamente '0000'.

*  cl_demo_output=>display( it_bdcdata ). "Exibir a tabela

END-OF-SELECTION.

FORM f_insert_line USING f_v_program  TYPE bdcdata-program
                         f_v_dynpro   TYPE bdcdata-dynpro
                         f_v_dynbegin TYPE bdcdata-dynbegin
                         f_v_fnam     TYPE bdcdata-fnam
                         f_v_fval     TYPE bdcdata-fval.

  DATA: v_l_bdcdata_tmp TYPE tp_l_bdcdata.

  v_l_bdcdata_tmp-vtp_program  = f_v_program.
  v_l_bdcdata_tmp-vtp_dynpro   = f_v_dynpro.
  v_l_bdcdata_tmp-vtp_dynbegin = f_v_dynbegin.
  v_l_bdcdata_tmp-vtp_fnam     = f_v_fnam.
  v_l_bdcdata_tmp-vtp_fval     = f_v_fval.

  APPEND v_l_bdcdata_tmp TO it_bdcdata.

ENDFORM.