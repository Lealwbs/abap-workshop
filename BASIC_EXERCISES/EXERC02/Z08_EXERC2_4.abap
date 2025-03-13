*&---------------------------------------------------------------------*
*& Report Z08_EXERC2_4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc2_4.

DATA: v_scarr_carrid TYPE scarr-carrid,
      v_query_id     TYPE i,
      v_operation_id TYPE i.


TYPES: BEGIN OF tp_carr,
         vtp_cid   TYPE scarr-carrid,
         vtp_cname TYPE scarr-carrname,
         vtp_url   TYPE scarr-url,
       END OF tp_carr.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE text-001.
  PARAMETERS: v_cid   TYPE scarr-carrid OBLIGATORY,
              v_cname TYPE scarr-carrname,
              v_url   TYPE scarr-url.
SELECTION-SCREEN END OF BLOCK b_input.

SELECTION-SCREEN BEGIN OF BLOCK b_operation WITH FRAME TITLE text-002.
  PARAMETERS: v_create RADIOBUTTON GROUP rg_1,
              v_modify RADIOBUTTON GROUP rg_1 DEFAULT 'X',
              v_delete RADIOBUTTON GROUP rg_1.
SELECTION-SCREEN END OF BLOCK b_operation.

AT SELECTION-SCREEN.

  SELECT SINGLE carrid
    FROM scarr
    INTO v_scarr_carrid
    WHERE carrid = v_cid.
  v_query_id = sy-subrc. "=0: found / <>0: not found

  IF v_create = 'X'.
    IF v_query_id = 0.
      MESSAGE e014(z08) WITH v_cid. "Companhia aérea & já cadastrada.
    ENDIF.
    IF v_cname IS INITIAL.
      MESSAGE e016(z08).            "O nome é obrigatório para esta operação.
    ENDIF.
  ENDIF.

  IF v_modify  = 'X'.
    IF v_query_id <> 0.
      MESSAGE e015(z08) WITH v_cid. "Companhia aérea & inexistente.
    ENDIF.
    IF v_cname IS INITIAL.
      MESSAGE e016(z08).            "O nome é obrigatório para esta operação.
    ENDIF.
  ENDIF.

  IF v_delete = 'X'.
    IF v_query_id <> 0.
      MESSAGE e015(z08) WITH v_cid. "Companhia aérea & inexistente.
    ENDIF.
  ENDIF.

START-OF-SELECTION.

  DATA: v_carr TYPE tp_carr.
  v_carr-vtp_cid = v_cid.
  v_carr-vtp_cname = v_cname.
  v_carr-vtp_url = v_url.

  IF v_create = 'X'.
    PERFORM f_create USING v_carr.
  ENDIF.

  IF v_modify  = 'X'.
    PERFORM f_modify USING v_carr.
  ENDIF.

  IF v_delete = 'X'.
    PERFORM f_delete USING v_carr.
  ENDIF.

END-OF-SELECTION.

FORM f_create USING f_carr TYPE tp_carr.

  INSERT INTO scarr
  VALUES @( VALUE #(
    carrid   = f_carr-vtp_cid
    carrname = f_carr-vtp_cname
    url      = f_carr-vtp_url ) ).
  PERFORM f_command_status USING sy-subrc.

ENDFORM.

FORM f_modify USING f_carr TYPE tp_carr.

  UPDATE scarr
  SET carrname = @f_carr-vtp_cname,
      url      = @f_carr-vtp_url
  WHERE carrid = @f_carr-vtp_cid.
  PERFORM f_command_status USING sy-subrc.

ENDFORM.

FORM f_delete USING f_carr TYPE tp_carr.

  DELETE FROM scarr
  WHERE carrid = f_carr-vtp_cid.
  PERFORM f_command_status USING sy-subrc.

ENDFORM.

FORM f_command_status USING f_operation_id TYPE i.
  IF f_operation_id = 0.
    WRITE: / |Operação executada com sucesso!|.
  ELSE.
    WRITE: / |Não foi possível executar a operação.|.
  ENDIF.
ENDFORM.