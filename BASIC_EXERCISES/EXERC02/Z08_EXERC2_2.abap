*&---------------------------------------------------------------------*
*& Report Z08_EXERC2_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc2_2.

TYPES: BEGIN OF tp_l_scarr,
         vtp_CARRID   TYPE scarr-carrid,         "PK  "código da cia aérea
         vtp_CARRNAME TYPE scarr-carrname,            "nome
         vtp_URL      TYPE scarr-url,                 "site
       END OF tp_l_scarr,

       BEGIN OF tp_l_spfli,
         vtp_CARRID        TYPE spfli-carrid,    "PK  "código da cia aérea
         vtp_CONNID        TYPE spfli-connid,    "PK  "número do voo
         vtp_COUNTRYFR     TYPE spfli-countryfr,      "país de origem
         vtp_CITYFROM      TYPE spfli-cityfrom,       "cidade origem
         vtp_COUNTRYTO     TYPE spfli-countryto,      "país de destino
         vtp_CITYTO        TYPE spfli-cityto,         "cidade destino
         vtp_FLTIME        TYPE spfli-fltime,         "duração do voo
         vtp_AIRPFROM      TYPE spfli-airpfrom,       "nome do aeroporto de origem
         vtp_AIRPTO        TYPE spfli-airpto,         "nome do aeroporto de destino
         vtp_AIRPFROM_NAME TYPE sairport-name,        "nome COMPLETO do aeroporto de origem (VIA SELECT)
         vtp_AIRPTO_NAME   TYPE sairport-name,        "nome COMPLETO do aeroporto de destino (VIA SELECT)
       END OF tp_l_spfli,

       BEGIN OF tp_l_sflight,
         vtp_CARRID    TYPE sflight-carrid,      "PK  "código da cia aérea
         vtp_CONNID    TYPE sflight-connid,      "PK  "número do voo
         vtp_FLDATE    TYPE sflight-fldate,      "PK  "data do voo
         vtp_PRICE     TYPE sflight-price,            "preço
         vtp_CURRENCY  TYPE sflight-currency,         "moeda do voo
         vtp_PLANETYPE TYPE sflight-planetype,        "tipo de avião
         vtp_OP_SPEED  TYPE saplane-op_speed,         "velocidade de cruzeiro(VIA SELECT)
         vtp_PRODUCER  TYPE saplane-producer,         "fabricante do avião (VIA SELECT)
       END OF tp_l_sflight,

       BEGIN OF tp_l_sbook,
         vtp_CARRID     TYPE sbook-carrid,       "PK  "código da cia aérea
         vtp_CONNID     TYPE sbook-connid,       "PK  "número do voo
         vtp_FLDATE     TYPE sbook-fldate,       "PK  "data do voo
         vtp_BOOKID     TYPE sbook-bookid,       "PK  "número da reserva
         vtp_CUSTOMID   TYPE sbook-customid,          "número do passageiro
         vtp_LUGGWEIGHT TYPE sbook-luggweight,        "peso da bagagem (KG)
       END OF tp_l_sbook.

DATA:
  v_l_scarr        TYPE tp_l_scarr,
  v_l_spfli        TYPE tp_l_spfli,
  v_l_sflight      TYPE tp_l_sflight,
  v_l_sbook        TYPE tp_l_sbook,
  v_idquery_carrid TYPE i,
  v_idquery_connid TYPE i,
  v_idquery_fldate TYPE i,
  v_idquery_bookid TYPE i.


SELECTION-SCREEN BEGIN OF BLOCK b_search WITH FRAME TITLE TEXT-004.
  PARAMETERS:
    p_carrid TYPE scarr-carrid   OBLIGATORY,
    p_connid TYPE spfli-connid   OBLIGATORY,
    p_fldate TYPE sflight-fldate OBLIGATORY,
    p_bookid TYPE sbook-bookid   OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b_search.

INITIALIZATION.
  p_fldate = sy-datum.

* """ INICIALIZAÇÃO RÁPIDA, PARA FACILITAR OS TESTES """
  p_carrid = 'DL'.
  p_connid = '0106'.
  p_fldate = '20240813'.
  p_bookid = '95'.
* """ APÓS OS TESTES, O BLOCO ACIMA DEVE SER APAGADO/COMENTADO NOVAMENTE """

START-OF-SELECTION.

  SELECT SINGLE carrid carrname url
  FROM scarr
  INTO v_l_scarr
  WHERE carrid = p_carrid.
  v_idquery_carrid = sy-subrc.

  SELECT SINGLE carrid connid countryfr cityfrom countryto cityto fltime airpfrom airpto
  FROM spfli
  INTO v_l_spfli
  WHERE carrid = p_carrid AND connid = p_connid.
  v_idquery_connid = sy-subrc.

  "Buscar os 2 últimos elementos (Nome do Aeroporto de Origem e Nome do Aeroporto de Destino).
  SELECT a~name AS airfrom_name,
         b~name AS airto_name
  FROM sairport AS a
  INNER JOIN sairport AS b
  ON a~id = @v_l_spfli-vtp_AIRPFROM AND b~id = @v_l_spfli-vtp_AIRPTO
  INTO (@v_l_spfli-vtp_AIRPFROM_NAME, @v_l_spfli-vtp_AIRPTO_NAME).
  ENDSELECT.

  SELECT SINGLE carrid connid fldate price currency planetype
  FROM sflight
  INTO v_l_sflight
  WHERE carrid = p_carrid AND connid = p_connid AND fldate = p_fldate.
  v_idquery_fldate = sy-subrc.

  "Buscar os 2 últimos elementos (Velocidade de cruzeiro e Fabricante do avião).
  SELECT SINGLE op_speed producer
  FROM saplane
  INTO (v_l_sflight-vtp_OP_SPEED, v_l_sflight-vtp_PRODUCER)
  WHERE planetype = v_l_sflight-vtp_PLANETYPE.

  SELECT SINGLE carrid connid fldate bookid customid luggweight
  FROM sbook
  INTO v_l_sbook
  WHERE carrid = p_carrid AND connid = p_connid AND fldate = p_fldate AND bookid = p_bookid.
  v_idquery_bookid = sy-subrc.

END-OF-SELECTION.

  IF v_idquery_carrid <> 0.
    WRITE: / |Cia aérea { p_carrid } não encontrada.|.
  ELSE.
    WRITE: / |# Informações da Cia Aérea { p_carrid }:|.
    WRITE: / 'Código da Cia Aérea:', v_l_scarr-vtp_CARRID .
    WRITE: / 'Nome da Cia Aérea:', v_l_scarr-vtp_CARRNAME.
    WRITE: / |Site: { v_l_scarr-vtp_URL }|.
  ENDIF.
  ULINE.

  IF v_idquery_connid <> 0.
    WRITE: / |Horário de voo { p_connid } não encontrado.|.
  ELSE.
    WRITE: / |# Informações do Horário de Voo { p_connid }:|.
    WRITE: / 'Código da Cia Aérea:', v_l_spfli-vtp_CARRID.
    WRITE: / 'Número do Voo:', v_l_spfli-vtp_CONNID.
    WRITE: / 'País de Origem:', v_l_spfli-vtp_COUNTRYFR.
    WRITE: / 'Cidade de Origem:', v_l_spfli-vtp_CITYFROM.
    WRITE: / 'País de Destino:', v_l_spfli-vtp_COUNTRYTO.
    WRITE: / 'Cidade de Destino:', v_l_spfli-vtp_CITYTO.
    WRITE: / |Duração do Voo: { v_l_spfli-vtp_FLTIME }|.
    WRITE: / 'Nome do Aeroporto de Origem:', v_l_spfli-vtp_AIRPFROM_NAME.
    WRITE: / 'Nome do Aeroporto de Destino:', v_l_spfli-vtp_AIRPTO_NAME.
  ENDIF.
  ULINE.

  IF v_idquery_fldate <> 0.
    WRITE: / |Voo { p_fldate } não encontrado.|.
  ELSE.
    WRITE: / |# Informações do Voo { p_fldate }:|.
    WRITE: / 'Código da Cia Aérea:', v_l_sflight-vtp_CARRID.
    WRITE: / 'Número do Voo:', v_l_sflight-vtp_CONNID.
    WRITE: / 'Data do Voo:', v_l_sflight-vtp_FLDATE.
    WRITE: / |Preço: { v_l_sflight-vtp_PRICE }|.
    WRITE: / 'Moeda do Voo:', v_l_sflight-vtp_CURRENCY.
    WRITE: / 'Tipo de Avião:', v_l_sflight-vtp_PLANETYPE.
    WRITE: / |Velocidade de Cruzeiro: { v_l_sflight-vtp_OP_SPEED }|.
    WRITE: / 'Fabricante do Avião:', v_l_sflight-vtp_PRODUCER.
  ENDIF.
  ULINE.

  IF v_idquery_bookid <> 0.
    WRITE: / |Reserva { p_bookid } não encontrada.|.
  ELSE.
    WRITE: / |# Informações da Reserva { p_bookid }:|.
    WRITE: / 'Código da Cia Aérea:', v_l_sbook-vtp_CARRID.
    WRITE: / 'Número do Voo:', v_l_sbook-vtp_CONNID.
    WRITE: / 'Data do Voo:', v_l_sbook-vtp_FLDATE.
    WRITE: / 'Número da Reserva:', v_l_sbook-vtp_BOOKID.
    WRITE: / 'Número do Passageiro:', v_l_sbook-vtp_CUSTOMID.
    WRITE: / |Peso da Bagagem: { v_l_sbook-vtp_LUGGWEIGHT }|.
  ENDIF.