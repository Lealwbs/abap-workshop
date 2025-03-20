*&---------------------------------------------------------------------*
*& Report z_isantos_ex03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_isantos_03.

SELECTION-SCREEN BEGIN OF BLOCK b_option WITH FRAME TITLE msg_1.
  PARAMETERS: o_pdf TYPE c RADIOBUTTON GROUP g1 DEFAULT 'X',
              o_alv TYPE c RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b_option.

START-OF-SELECTION.

  DATA: relatorio      TYPE REF TO zcl_isantos_03_test_relatorio,
        tipo_relatorio TYPE REF TO zif_isantos_03_tipo_relatorio.

  CASE 'X'.
    WHEN o_pdf.
      CREATE OBJECT tipo_relatorio TYPE zcl_isantos_03_pdf.
    WHEN o_alv.
      CREATE OBJECT tipo_relatorio TYPE zcl_isantos_03_alv.
  ENDCASE.


  CREATE OBJECT relatorio
    EXPORTING
      tipo_escolhido = tipo_relatorio.

  relatorio->gerar_relatorio( modelo_novo = abap_true ).

end-of-selection.