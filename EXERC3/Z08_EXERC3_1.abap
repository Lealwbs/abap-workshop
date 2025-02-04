*&---------------------------------------------------------------------*
*& Report Z08_EXERC3_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc3_1.

DATA: tp_scustom_id TYPE scustom-id.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS v_cid FOR tp_scustom_id OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b_input.

"WRITE: CODIGO, NOME, CIDADE

START-OF-SELECTION.

  PERFORM f_search_data_1.
  ULINE.
  PERFORM f_search_data_2.
  ULINE.
  PERFORM f_search_data_3.
  ULINE.

END-OF-SELECTION.

  TYPES: BEGIN OF tp_custom,
           vtp_scustom_ID   TYPE scustom-id,
           vtp_scustom_name TYPE scustom-name,
           vtp_scustom_city TYPE scustom-city,
         END OF tp_custom.

FORM f_search_data_1. " Usando Work-Area (EVITAR, INEFICIENTE)

  DATA: it_scustom TYPE TABLE OF tp_custom,
        wa_scustom TYPE tp_custom.


  SELECT id, name, city
    FROM scustom
    INTO TABLE @it_scustom
    WHERE id IN @v_cid.
  PERFORM f_command_status USING sy-subrc.

  LOOP AT it_scustom INTO wa_scustom.
    WRITE: / 'ID:', wa_scustom-vtp_scustom_id, ' | ',
             'Nome:', wa_scustom-vtp_scustom_name, ' | ',
             'Cidade:', wa_scustom-vtp_scustom_city.
  ENDLOOP.

ENDFORM.

FORM f_search_data_2. " Usando Linha de Cabeçalho (NUNCA USAR, GERA AMBIGUIDADE)

  DATA: it_scustom TYPE TABLE OF tp_custom WITH HEADER LINE.

  SELECT id, name, city
    FROM scustom
    INTO TABLE @it_scustom
    WHERE id IN @v_cid.
  PERFORM f_command_status USING sy-subrc.

  LOOP AT it_scustom.
    WRITE: / 'ID:', it_scustom-vtp_scustom_ID, ' | ',
             'Nome:', it_scustom-vtp_scustom_name, ' | ',
             'Cidade:', it_scustom-vtp_scustom_city.
  ENDLOOP.

ENDFORM.

FORM f_search_data_3. " Usando Field-Symbol (RECOMENDADO USAR, MAIS EFICIENTE)

  DATA: it_scustom TYPE TABLE OF tp_custom.
  FIELD-SYMBOLS: <fs_line> LIKE LINE OF it_scustom.

  SELECT id, name, city
  FROM scustom
  INTO TABLE @it_scustom
  WHERE id IN @v_cid.
  PERFORM f_command_status USING sy-subrc.

  LOOP AT it_scustom ASSIGNING <fs_line>.
    WRITE: / 'ID:', <fs_line>-vtp_scustom_id, ' | ',
             'Nome:', <fs_line>-vtp_scustom_name, ' | ',
             'Cidade:', <fs_line>-vtp_scustom_city.
  ENDLOOP.

ENDFORM.

FORM f_command_status USING f_operation_id TYPE i.
  IF f_operation_id = 0.
    "WRITE: / |Operação executada com sucesso!|.
  ELSE.
    WRITE: / |Não foi possível executar a operação.|.
  ENDIF.
ENDFORM.