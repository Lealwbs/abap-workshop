*&---------------------------------------------------------------------*
*& Report Z08_EXERC8_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc8_2.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  PARAMETERS: v_novokm TYPE i OBLIGATORY,
              v_rngrev TYPE i OBLIGATORY DEFAULT 0.
SELECTION-SCREEN END OF BLOCK b_input.

AT SELECTION-SCREEN.
  IF v_novokm < 0 OR v_rngrev < 0.
    MESSAGE e025(z08). "Digite apenas valores positivos.
  ENDIF.

  IF v_rngrev > v_novokm.
    MESSAGE e024(z08). "A kilometragem da última revisão não pode ser maior que a nova kilom.
  ENDIF.

START-OF-SELECTION.

  DATA(c1) = NEW zcl_08_carro(
        marca          = 'Fiat'
        modelo         = 'Uno'
        cor            = 'Vermelho'
        kilometragem   = 102500
        ultima_revisao = 100000 ).

  DATA(c2) = NEW zcl_08_carro(
        marca          = 'Renault'
        modelo         = 'Kwid'
        cor            = 'Branco'
        kilometragem   = 156000
        ultima_revisao = 150000 ).


  DATA: v_ultima_revisao TYPE i.
  c1->get_ultima_revisao( IMPORTING dt_ultima_revisao = v_ultima_revisao ).

  WRITE: / |{ c1->get_identificacao( )-vtp_marca  }|,
  |{ c1->get_identificacao( )-vtp_modelo }|,
  |{ c1->get_identificacao( )-vtp_cor    }|,
  / |Hodômetro: { c1->get_km( ) }km|,
  / |Última Revisão: { v_ultima_revisao }km|.

  ULINE.

  c1->atualiza_km( v_novokm ).
  c2->atualiza_km( v_novokm ).

  DATA: c1_bool_vrev,
        c2_bool_vrev.

  c1_bool_vrev = c1->verify_revisao( v_rngrev ).
  c2_bool_vrev = c2->verify_revisao( v_rngrev ).

  PERFORM f_write_verify_revisao USING c1_bool_vrev.
  PERFORM f_write_verify_revisao USING c2_bool_vrev.

END-OF-SELECTION.

FORM f_write_verify_revisao USING bool TYPE char1.
  IF bool = 'X'.
    WRITE: / |ATENÇÃO: O carro atingiu a kilometragem da próxima revisão.|.
  ELSE.
    WRITE: / |O carro ainda NÃO atingiu a kilom. da próxima revisão.|.
  ENDIF.
ENDFORM.