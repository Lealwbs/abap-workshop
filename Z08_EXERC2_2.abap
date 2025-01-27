*&---------------------------------------------------------------------*
*& Report Z08_EXERC2_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc2_2.

SELECTION-SCREEN BEGIN OF BLOCK b_search WITH FRAME TITLE TEXT-004.

  DATA:
    v_scarr_idcomp TYPE scarr-carrname,
    v_scarr_idcomp TYPE scarr-carrname,
    v_scarr_idcomp TYPE scarr-carrname,

    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,
    v_data_nm_fly TYPE spfli-connid,

    v_data_dt_fly TYPE sflight-fldate,
    v_data_dt_fly TYPE sflight-fldate,
    v_data_dt_fly TYPE sflight-fldate,
    v_data_dt_fly TYPE sflight-fldate,
    v_data_dt_fly TYPE sflight-fldate,
    v_data_dt_fly TYPE sflight-fldate,
    v_data_dt_fly TYPE sflight-fldate,
    v_data_dt_fly TYPE sflight-fldate,
    v_data_dt_fly TYPE sflight-fldate,

    v_data_nm_rsv TYPE sbook-bookid,
    v_data_nm_rsv TYPE sbook-bookid,
    v_data_nm_rsv TYPE sbook-bookid,
    v_data_nm_rsv TYPE sbook-bookid,
    v_data_nm_rsv TYPE sbook-bookid,
    v_data_nm_rsv TYPE sbook-bookid.


  PARAMETERS:
    v_idcomp TYPE scarr-carrname OBLIGATORY,
    v_nm_fly TYPE spfli-connid   OBLIGATORY,
    v_dt_fly TYPE sflight-fldate OBLIGATORY,
    v_nm_rsv TYPE sbook-bookid   OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b_search.

INITIALIZATION.
  v_dt_fly = sy-datum.

  IF v_idcomp <= 0.
    MESSAGE e008(z08). "ERRO: ID inválido, digite um ID positivo válido.
  ENDIF.

START-OF-SELECTION.

  SELECT SINGLE scarr-carrname
    FROM scarr
    into v_scarr_idcomp
    WHERE scarr-carrname = v_idcomp.

  IF sy-subrc = 0.
    WRITE: /  .
    código da cia aérea, nome e site;
    ELSE.
      WRITE: / |Cia aérea { v_idcomp } não encontrada.|.
    endif.


END-OF-SELECTION.

  "Cia aérea não encontrada" (SCARR)
  o "Horário de voo não encontrado" (SPFLI)
  o "Voo não encontrado" (SFLIGHT)
  o "Reserva não encontrada" (SBOOK)