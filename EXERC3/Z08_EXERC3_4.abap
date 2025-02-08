*&---------------------------------------------------------------------*
*& Report Z08_EXERC3_4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc3_4.

TYPES: BEGIN OF tp_l_short_scustom,
         vtp_id   TYPE scustom-id,
         vtp_name TYPE scustom-name,
         vtp_mail TYPE scustom-email,
       END OF tp_l_short_scustom,
       BEGIN OF tp_l_short_sbook,
         vtp_customid TYPE sbook-customid,
         vtp_fldate   TYPE sbook-fldate,
         vtp_bookid   TYPE sbook-bookid,
         vtp_identif  TYPE n LENGTH 2,
       END OF tp_l_short_sbook.

DATA: t_passageiro         TYPE TABLE OF tp_l_short_scustom,
      t_reserva_passageiro TYPE TABLE OF tp_l_short_sbook,
      t_ftemp              TYPE TABLE OF tp_l_short_sbook.

SELECT id name email
  FROM scustom
  INTO TABLE t_passageiro.
 "WHERE id = '4900'.      "Exemplo de teste para passageiro com um único voo: 4900

DATA: v_01_short_sbook TYPE tp_l_short_sbook,
      v_02_short_sbook TYPE tp_l_short_sbook,
      v_operation_id   TYPE i.

LOOP AT t_passageiro ASSIGNING FIELD-SYMBOL(<line>).

  CLEAR: t_ftemp,
  v_01_short_sbook,
  v_02_short_sbook,
  v_operation_id.

  SELECT customid, fldate, bookid
    FROM sbook
    WHERE customid = @<line>-vtp_id
    "AND fldate = '20241224' "Teste para quando fldate 01 = fldate 02.
    ORDER BY fldate, bookid
    INTO TABLE @t_ftemp.
  v_operation_id = sy-subrc.

  IF v_operation_id = 0.

    READ TABLE t_ftemp INTO v_01_short_sbook INDEX 1.
    READ TABLE t_ftemp INTO v_02_short_sbook INDEX lines( t_ftemp ).

    IF v_01_short_sbook = v_02_short_sbook.
      v_02_short_sbook-vtp_fldate = ''.
      v_02_short_sbook-vtp_bookid = ''.
    ENDIF.

    v_01_short_sbook-vtp_identif = '01'.
    v_02_short_sbook-vtp_identif = '02'.

    IF v_01_short_sbook IS NOT INITIAL.
      APPEND: v_01_short_sbook TO t_reserva_passageiro,
              v_02_short_sbook TO t_reserva_passageiro.
    ENDIF.

  ELSE.
*    WRITE: / |Não foi possível localizar o passageiro { <line>-vtp_id }.|.
  ENDIF.

ENDLOOP.

END-OF-SELECTION.

  cl_demo_output=>display( t_passageiro ).          "Lista de todos os passageiros.
  cl_demo_output=>display( t_reserva_passageiro ).  "Lista das reservas de cada passageiro.