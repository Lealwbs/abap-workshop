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
       END OF tp_l_short_scustom.

TYPES: BEGIN OF tp_l_short_sbook,
         vtp_customid TYPE sbook-customid,
         vtp_identif  TYPE n LENGTH 2,
         vtp_fldate   TYPE sbook-fldate,
       END OF tp_l_short_sbook.

DATA: t_passageiro TYPE TABLE OF tp_l_short_scustom.
DATA: t_reserva_passageiro TYPE TABLE OF tp_l_short_sbook.
DATA: t_individual_flights TYPE TABLE OF tp_l_short_sbook.

SELECT id name email
  FROM scustom
  INTO TABLE t_passageiro.

DATA: v_01_short_sbook TYPE tp_l_short_sbook,
      v_02_short_sbook TYPE tp_l_short_sbook,
      v_01_fldate      TYPE sbook-fldate,     "Data mais antiga (primeiro voo).
      v_02_fldate      TYPE sbook-fldate,     "Data mais recente (último voo).
      v_operation_id   TYPE i.

LOOP AT t_passageiro ASSIGNING FIELD-SYMBOL(<line>).

  CLEAR: v_01_short_sbook,
  v_02_short_sbook,
  v_01_fldate,
  v_02_fldate,
  v_operation_id.

* Se for o contrário: (data mais antiga = último voo) e (data mais recente = primeiro voo)
* Basta trocar a linha abaixo para: SELECT MAX( fldate ), MIN( fldate ).
  SELECT MIN( fldate ), MAX( fldate )
    FROM sbook
    INTO (@v_01_fldate, @v_02_fldate)
    WHERE customid = @<line>-vtp_id.
  v_operation_id = sy-subrc.

  v_01_short_sbook-vtp_customid = <line>-vtp_id.
  v_01_short_sbook-vtp_identif = '01'.
  v_01_short_sbook-vtp_fldate = v_01_fldate.

  v_02_short_sbook-vtp_customid = <line>-vtp_id.
  v_02_short_sbook-vtp_identif = '02'.
  v_02_short_sbook-vtp_fldate = v_02_fldate.

  IF v_operation_id = 0 AND v_01_fldate <> '00000000'.

    IF v_01_fldate <> v_02_fldate.
      APPEND: v_01_short_sbook TO t_reserva_passageiro,
              v_02_short_sbook TO t_reserva_passageiro.
    ELSEIF v_01_fldate = v_02_fldate.
      APPEND v_01_short_sbook TO t_reserva_passageiro.
    ENDIF.

  ELSE.
*    WRITE: / |Não foi possível localizar o passageiro { <line>-vtp_id }.|.
  ENDIF.

ENDLOOP.

END-OF-SELECTION.

  cl_demo_output=>display( t_passageiro ).          "Lista de todos os passageiros.
  cl_demo_output=>display( t_reserva_passageiro ).  "Lista das reservas de cada passageiro.