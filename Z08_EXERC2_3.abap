*&---------------------------------------------------------------------*
*& Report Z08_EXERC2_3
*&---------------------------------------------------------------------*
REPORT z08_exerc2_3.

DATA: v_mail_validity TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK b_email WITH FRAME TITLE TEXT-001.
  PARAMETERS: v_csid   TYPE scustom-id OBLIGATORY,   "Código do Passageiro
              v_csmail TYPE scustom-email OBLIGATORY. "Novo email
SELECTION-SCREEN END OF BLOCK b_email.

AT SELECTION-SCREEN.

  SELECT SINGLE id FROM scustom INTO @v_csid WHERE id = @v_csid.
  IF sy-subrc <> 0.
    MESSAGE e010(z08) WITH v_csid. "Passageiro ID & não cadastrado.
  ENDIF.

  PERFORM valida_email USING v_csmail CHANGING v_mail_validity.

  IF v_mail_validity = ' '.
    MESSAGE e011(z08) WITH v_csmail. "E-mail & inválido.
  ENDIF.

START-OF-SELECTION.

  UPDATE scustom SET email = @v_csmail WHERE id = @v_csid.
  IF sy-subrc = 0.
    WRITE: / |ID { v_csid } teve seu email alterado para { v_csmail }.|.
  ELSE.
    MESSAGE e012(z08). "Email não foi atualizado.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Função para validar email usando expressões regulares
*&---------------------------------------------------------------------*
FORM valida_email  USING p_email
CHANGING email_ok.

  DATA: go_regex   TYPE REF TO cl_abap_regex,
        go_matcher TYPE REF TO cl_abap_matcher.

  CREATE OBJECT go_regex
    EXPORTING
      pattern     = '\w+(\.\w+)*@(\w+\.)+(\w{2,4})'
      ignore_case = abap_true.

  go_matcher = go_regex->create_matcher( text = p_email ).

  IF go_matcher->match( ) IS INITIAL.
    CLEAR email_ok.
  ELSE.
    email_ok = 'X'.
  ENDIF.

ENDFORM. "Valida_email