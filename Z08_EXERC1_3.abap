*&---------------------------------------------------------------------*
*& Report Z08_EXERC1_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc1_3.

DATA: v_data_hoje          TYPE sy-datum,
      v_data_ontem         TYPE sy-datum,
      v_data_month(10)     TYPE c,
      v_data_next          TYPE sy-datum,
      v_nome_length        TYPE i,
      v_nome_length_minus2 TYPE i,
      v_dist_datas         TYPE i.


PARAMETERS: v_nome(30) TYPE c OBLIGATORY,
            v_data     TYPE sy-datum OBLIGATORY.

INITIALIZATION.

  v_data = sy-datum + 1.

START-OF-SELECTION.

END-OF-SELECTION.

* Data do dia anterior à data informada:
  v_data_hoje = sy-datum.
  v_data_ontem = v_data_hoje - 1.
  WRITE: / 'Data de ontem:', v_data_ontem.

* Data com o primeiro dia do mês seguinte:
  v_data_next+6(2) = '01'. " DIA 01

  IF v_data+4(2) = '12'.
    v_data_next+4(2) = '01'.             " MÊS 12 -> 01
    v_data_next+0(4) = v_data+0(4) + 1.  " ANO -> ANO + 1
  ELSE.
    v_data_next+4(2) = v_data+4(2) + 1.  " MÊS -> MÊS + 1
    v_data_next+0(4) = v_data+0(4).      " ANO = ANO
  ENDIF.

  WRITE: / 'Próximo primeiro dia do mês:', v_data_next.

* Número de dias entre a data informada e hoje, se data informada > hoje:
  IF v_data > v_data_hoje.
    v_dist_datas = v_data - v_data_hoje.
    WRITE: / v_dist_datas, 'Dias entre', v_data_hoje , 'e', v_data.
  ELSE.
    WRITE: / 'A data é anterior à hoje'.
  ENDIF.

* Tamanho (em caracteres) do nome (função STRLEN):
  v_nome_length = strlen( v_nome ).
  WRITE: / 'Tamanho do nome:', v_nome_length.

* 3 primeiros caracteres do nome informado na tela de seleção:
  WRITE: / '3 primeiros caracteres do nome:', v_nome+0(3).

* 2 últimos caracteres do nome informado na tela de seleção;
  v_nome_length_minus2 = v_nome_length - 2.
  IF v_nome_length_minus2 > 0.
    WRITE: / '2 últimos caracteres do nome:', v_nome+v_nome_length_minus2(2).
  ELSE.
    WRITE: / '2 últimos caracteres do nome:', v_nome.
  ENDIF.

* Imprimir a data informada por extenso:
  CASE v_data_hoje+4(2).
    WHEN '01'.
      v_data_month = 'JANEIRO'.
    WHEN '02'.
      v_data_month = 'FEVEREIRO'.
    WHEN '03'.
      v_data_month = 'MARÇO'.
    WHEN '04'.
      v_data_month = 'ABRIL'.
    WHEN '05'.
      v_data_month = 'MAIO'.
    WHEN '06'.
      v_data_month = 'JUNHO'.
    WHEN '07'.
      v_data_month = 'JULHO'.
    WHEN '08'.
      v_data_month = 'AGOSTO'.
    WHEN '09'.
      v_data_month = 'SETEMBRO'.
    WHEN '10'.
      v_data_month = 'OUTUBRO'.
    WHEN '11'.
      v_data_month = 'NOVEMBRO'.
    WHEN '12'.
      v_data_month = 'DEZEMBRO'.
  ENDCASE.

  WRITE:  / v_data_hoje+6(2),
          'DE',
          v_data_month,
          'DE',
          v_data_hoje+0(4).