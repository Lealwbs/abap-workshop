*&---------------------------------------------------------------------*
*& Report Z08_EXERC1_4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc1_4.

DATA: v_dt_hoje          TYPE sy-datum,
      v_dias_dist        TYPE i,
      v_new_cod_user(80) TYPE c,
      v_cond_nome(40)    TYPE c,
      v_cond_sbnome(30)  TYPE c.

PARAMETERS: v_nome(40)   TYPE c OBLIGATORY,
            v_sbnome(30) TYPE c OBLIGATORY,
            v_dt_ini     TYPE sy-datum OBLIGATORY,
            v_dt_fim     TYPE sy-datum,
            v_check      AS CHECKBOX.

INITIALIZATION.
  v_dt_ini = sy-datum.
  v_check = ' '.
  v_dt_hoje = sy-datum.

AT SELECTION-SCREEN.

  IF v_dt_ini < v_dt_hoje.
    MESSAGE e001(z08) WITH v_dt_ini v_dt_hoje. "ERRO: A data inicial deve ser maior ou igual a data atual.
    STOP.
  ENDIF.

  IF v_dt_fim < v_dt_ini AND v_dt_fim <> '00000000'.
    MESSAGE e002(z08) WITH v_dt_fim v_dt_ini. "ERRO: Data final deve ser maior ou igual a data inicial.
    STOP.
  ENDIF.

START-OF-SELECTION.

  v_cond_nome = condense( v_nome ).
  v_cond_sbnome = condense( v_sbnome ).

  IF v_check = 'X'.
    CONCATENATE v_cond_sbnome+0(5) v_dt_ini+4(2) v_dt_ini+2(2) INTO v_new_cod_user.
  ELSE.
    CONCATENATE v_cond_nome+0(1) v_cond_sbnome INTO v_new_cod_user.
  ENDIF.

  v_new_cod_user = condense( v_new_cod_user ).

  IF v_dt_fim IS NOT INITIAL.
    v_dias_dist = v_dt_fim - v_dt_ini.
    WRITE: / 'Dias entre a data inicial e a data final:', v_dias_dist.
  ENDIF.

  WRITE:
  / 'Código do usuário:', v_new_cod_user,
  / 'Data atual:', sy-datum,
  / 'Hora atual:', sy-uzeit,
  / 'Nome do programa:', sy-repid,
  / 'Transação em execução:', sy-tcode.

END-OF-SELECTION.