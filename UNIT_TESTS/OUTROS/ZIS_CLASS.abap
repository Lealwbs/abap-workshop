class ZIS_CLASS definition
  public
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_J_1BNF_ADD_DATA .

  constants MARCA type STRING value '' ##NO_TEXT.

  methods ADD_DATA_HEADER
    importing
      !HEADER type J_1BNFDOC
      !NFLIN type J_1BNFLIN_TAB
      !VBRK type VBRKVB
      !VBRP type VBRP_TAB
      !NFSTX type J_1BNFSTX_TAB
      !IT_PARTNER type J_1B_TT_NFNAD
    changing
      !TRANSVOL type J_1BNFTRANSVOL_TAB
      !TRADENOTES type J_1BNFTRADENOTES_TAB
      !EXT_HEADER type J_1BNF_BADI_HEADER
      !PAYMENT type J_1BNFE_T_BADI_PAYMENT_400 .
  methods ADD_DATA_ITEM
    importing
      !NFLIN type J_1BNFLIN_TAB
      !VBRP type VBRP_TAB
    changing
      !ITEM type J_1BNF_BADI_ITEM_TAB
      !TRACEABILITY type J_1BNFE_T_BADI_TRACE_400 .
  methods ADD_DATA_AUTXML .
  methods ADD_DATA_J1B1N
    importing
      !HEADER type J_1BNFDOC
    changing
      !ITEM type J_1BNF_BADI_ITEM_TAB
      !EXT_HEADER type J_1BNF_BADI_HEADER
      !TRADENOTES type J_1BNFTRADENOTES_TAB .
  methods CONSTRUCTOR
    importing
      !DAO_PACK_MODEL_BUSINESS type ref to /S4TAX/IDAO_PACK_MODEL_BUSINES optional .
  PROTECTED SECTION.

    DATA: top_text_table TYPE STANDARD TABLE OF vtopis.

    METHODS:

      print_terms_of_payment_spli IMPORTING  bldat            TYPE vbrk-fkdat
                                             budat            TYPE vbrk-fkdat
                                             cpudt            TYPE sy-datum
                                             terms_of_payment TYPE vbrk-zterm
                                             wert             TYPE acccr-wrbtr
                                  EXCEPTIONS terms_of_payment_not_in_t052
                                             terms_of_payment_not_in_t052s,

      net_due_date_get IMPORTING zfbdt TYPE bsid-zfbdt
                                 zbd1t TYPE bsid-zbd1t
                                 zbd2t TYPE bsid-zbd2t
                                 zbd3t TYPE bsid-zbd3t
                                 shkzg TYPE bsid-shkzg
                                 rebzg TYPE bsid-rebzg
                       EXPORTING faedt TYPE rfpos-faedt,

      document_partner_read IMPORTING  parvw TYPE vbpa-parvw
                                       posnr TYPE vbup-posnr
                                       vbeln TYPE vbuk-vbeln
                            EXPORTING  vbadr TYPE vbadr
                            EXCEPTIONS not_found.
private section.

  data DAO_PACK_MODEL_BUSINESS type ref to /S4TAX/IDAO_PACK_MODEL_BUSINES .
  data DAO_PAYMENT_CONDITION type ref to /S4TAX/IDAO_PAYMENT_CONDITIONS .
  data PAYMENT_CONDITIONS type ref to /S4TAX/PAYMENT_CONDITIONS .

  methods VOLUMES_TRANSPORTADOS
    importing
      !HEADER type J_1BNFDOC
    changing
      !TRANSVOL type J_1BNFTRANSVOL_TAB .
  methods DADOS_COBRANCA
    importing
      !VBRK type VBRKVB
      !HEADER type J_1BNFDOC
      !NFLIN_TAB type J_1BNFLIN_TAB
    changing
      !TRADENOTES type J_1BNFTRADENOTES_TAB
      !EXT_HEADER type J_1BNF_BADI_HEADER .
  methods VALOR_LIQUIDO
    importing
      !NFLIN_TAB type J_1BNFLIN_TAB
      !HEADER type J_1BNFDOC
      !VBRK type VBRKVB
    changing
      !EXT_HEADER type J_1BNF_BADI_HEADER .
  methods DADOS_FATURA
    importing
      !NFLIN_TAB type J_1BNFLIN_TAB
      !HEADER type J_1BNFDOC
      !VBRK type VBRKVB
      !NFSTX type J_1BNFSTX_TAB
    changing
      !EXT_HEADER type J_1BNF_BADI_HEADER .
  methods DADOS_PAGAMENTO
    importing
      !IS_HEADER type J_1BNFDOC
      !VBRK type VBRKVB
    changing
      !PAYMENT type J_1BNFE_T_BADI_PAYMENT_400 .
  methods DADOS_INTERMEDIADOR
    changing
      !EXT_HEADER type J_1BNF_BADI_HEADER .
  methods DADOS_EAN_TRIB
    changing
      !ITEM type J_1BNF_BADI_ITEM_TAB .
  methods INFORMACOES_ADICIONAIS
    importing
      !NFLIN_TAB type J_1BNFLIN_TAB
      !VBRP_TABLE type VBRP_TAB
    changing
      !ITEM type J_1BNF_BADI_ITEM_TAB .
  methods INFORMACOES_COMPLEMENTARES
    importing
      !NFLIN_TAB type J_1BNFLIN_TAB
      !HEADER type J_1BNFDOC
      !VBRK type VBRKVB
      !VBRP_TAB type VBRP_TAB
      !IT_PARTNER type J_1B_TT_NFNAD
    changing
      !EXT_HEADER type J_1BNF_BADI_HEADER .
  methods DADOS_LOTE
    changing
      !TRACEABILITY type J_1BNFE_T_BADI_TRACE_400 .
  methods DADOS_EXPORTACAO
    importing
      !HEADER type J_1BNFDOC
      !VBRP_TABLE type VBRP_TAB
    changing
      !EXT_HEADER type J_1BNF_BADI_HEADER .
ENDCLASS.



CLASS ZIS_CLASS IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->ADD_DATA_AUTXML
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_data_autxml.

*  DATA: lt_zsd_nfe_accounta TYPE STANDARD TABLE OF zsd_nfe_accounta,
*        ls_accountant       TYPE zsd_nfe_accounta.
*
*  SELECT * FROM zsd_nfe_accounta
*   INTO TABLE lt_zsd_nfe_accounta
*  WHERE burks = is_header-bukrs
*    AND branch = is_header-branch
*    AND model = is_header-model
*    AND ( validfrom  IS NOT NULL AND validfrom <= sy-datum ).
*
*  IF lt_zsd_nfe_accounta IS INITIAL.
*    RETURN.
*  ENDIF.
*
*  APPEND INITIAL LINE TO et_autxml ASSIGNING FIELD-SYMBOL(<fs_autxml>).
*  LOOP AT lt_zsd_nfe_accounta INTO ls_accountant.
*    <fs_autxml>-cnpj = ls_accountant-yycnpj.
*    <fs_autxml>-cpf = ls_accountant-yycpf.
*  ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->ADD_DATA_HEADER
* +-------------------------------------------------------------------------------------------------+
* | [--->] HEADER                         TYPE        J_1BNFDOC
* | [--->] NFLIN                          TYPE        J_1BNFLIN_TAB
* | [--->] VBRK                           TYPE        VBRKVB
* | [--->] VBRP                           TYPE        VBRP_TAB
* | [--->] NFSTX                          TYPE        J_1BNFSTX_TAB
* | [--->] IT_PARTNER                     TYPE        J_1B_TT_NFNAD
* | [<-->] TRANSVOL                       TYPE        J_1BNFTRANSVOL_TAB
* | [<-->] TRADENOTES                     TYPE        J_1BNFTRADENOTES_TAB
* | [<-->] EXT_HEADER                     TYPE        J_1BNF_BADI_HEADER
* | [<-->] PAYMENT                        TYPE        J_1BNFE_T_BADI_PAYMENT_400
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_data_header.

    volumes_transportados(
      EXPORTING
        header   = header
      CHANGING
        transvol = transvol
    ).

    dados_cobranca(
      EXPORTING
        vbrk       = vbrk
        header     = header
        nflin_tab = nflin
      CHANGING
        tradenotes = tradenotes
        ext_header = ext_header
    ).

    dados_fatura(
      EXPORTING
        nflin_tab  = nflin
        header     = header
        vbrk       = vbrk
        nfstx      = nfstx
      CHANGING
        ext_header = ext_header
    ).

    informacoes_complementares(
      EXPORTING
        nflin_tab  = nflin
        header     = header
        vbrk       = vbrk
        vbrp_tab   = vbrp
        it_partner = it_partner
      CHANGING
        ext_header = ext_header
    ).

    dados_intermediador(
      CHANGING
        ext_header = ext_header
    ).

    dados_pagamento(
      EXPORTING
        is_header  = header
        vbrk    = vbrk
      CHANGING
        payment = payment
    ).

    dados_exportacao(
      EXPORTING
        header     = header
        vbrp_table = vbrp
      CHANGING
        ext_header = ext_header
    ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->ADD_DATA_ITEM
* +-------------------------------------------------------------------------------------------------+
* | [--->] NFLIN                          TYPE        J_1BNFLIN_TAB
* | [--->] VBRP                           TYPE        VBRP_TAB
* | [<-->] ITEM                           TYPE        J_1BNF_BADI_ITEM_TAB
* | [<-->] TRACEABILITY                   TYPE        J_1BNFE_T_BADI_TRACE_400
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_data_item.

    dados_ean_trib(
      CHANGING
        item = item
    ).

    informacoes_adicionais(
      EXPORTING
        nflin_tab  = nflin
        vbrp_table = vbrp
      CHANGING
        item      = item
    ).

    dados_lote(
      CHANGING
        traceability = traceability
    ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->ADD_DATA_J1B1N
* +-------------------------------------------------------------------------------------------------+
* | [--->] HEADER                         TYPE        J_1BNFDOC
* | [<-->] ITEM                           TYPE        J_1BNF_BADI_ITEM_TAB
* | [<-->] EXT_HEADER                     TYPE        J_1BNF_BADI_HEADER
* | [<-->] TRADENOTES                     TYPE        J_1BNFTRADENOTES_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_data_j1b1n.

    DATA: zbd1t              TYPE bsid-zbd1t,
          zbd2t              TYPE bsid-zbd2t,
          zbd3t              TYPE bsid-zbd3t,
          top_text           TYPE vtopis,
          wert               TYPE acccr-wrbtr,
          ndup               TYPE numc3,
          s1                 TYPE string,
          s2                 TYPE string,
          faedt              TYPE rfpos-faedt,
          xsplt              TYPE t052-xsplt,
          j_tradenotes       TYPE j_1bnftradenotes,
          payment_conditions TYPE REF TO /s4tax/payment_conditions.

    me->dados_ean_trib( CHANGING item = item ).

    me->dados_intermediador( CHANGING ext_header = ext_header ).

    payment_conditions = dao_payment_condition->get( zterm = header-zterm ).

    IF payment_conditions IS BOUND.

      zbd1t = payment_conditions->get_ztag1( ).
      zbd2t = payment_conditions->get_ztag2( ).
      zbd3t = payment_conditions->get_ztag3( ).
      xsplt = payment_conditions->get_xsplt( ).

    ENDIF.

    IF xsplt IS NOT INITIAL.

      wert  = header-nftot.

      print_terms_of_payment_spli(
        EXPORTING
          bldat                         = header-docdat
          budat                         = header-docdat
          cpudt                         = sy-datum
          terms_of_payment              = header-zterm
          wert                          = wert
      ).

      LOOP AT me->top_text_table INTO top_text.
        ndup = sy-tabix.
        SPLIT top_text-line AT ':' INTO s1 s2.
        CONDENSE s2 NO-GAPS.

        REPLACE ALL OCCURRENCES OF '.' IN s2 WITH ''.
        REPLACE ALL OCCURRENCES OF ',' IN s2 WITH '.'.

        j_tradenotes-docnum  = header-docnum.
        j_tradenotes-counter = sy-tabix.
        j_tradenotes-ndup    = ndup.
        j_tradenotes-dvenc   = top_text-hdatum.
        j_tradenotes-vdup    = s2.

        IF j_tradenotes IS INITIAL.
          CONTINUE.
        ENDIF.

        APPEND j_tradenotes TO tradenotes.
      ENDLOOP.

      RETURN.
    ENDIF.

    net_due_date_get(
      EXPORTING
        zfbdt = header-docdat
        zbd1t = zbd1t
        zbd2t = zbd2t
        zbd3t = zbd3t
        shkzg = space
        rebzg = space
      IMPORTING
        faedt = faedt
    ).

    IF sy-subrc <> 0 .
      RETURN.
    ENDIF.

    j_tradenotes-docnum  = header-docnum.
    j_tradenotes-counter = '1'.
    j_tradenotes-ndup    = '001'.
    j_tradenotes-dvenc   = faedt.
    j_tradenotes-vdup = header-nftot.

    IF j_tradenotes IS INITIAL.
      RETURN.
    ENDIF.

    APPEND j_tradenotes TO tradenotes.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] DAO_PACK_MODEL_BUSINESS        TYPE REF TO /S4TAX/IDAO_PACK_MODEL_BUSINES(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    me->dao_pack_model_business = dao_pack_model_business.
    IF me->dao_pack_model_business IS NOT BOUND.
      CREATE OBJECT me->dao_pack_model_business TYPE /s4tax/dao_pack_model_business.
    ENDIF.

    dao_payment_condition = me->dao_pack_model_business->payment_condition( ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->DADOS_COBRANCA
* +-------------------------------------------------------------------------------------------------+
* | [--->] VBRK                           TYPE        VBRKVB
* | [--->] HEADER                         TYPE        J_1BNFDOC
* | [--->] NFLIN_TAB                      TYPE        J_1BNFLIN_TAB
* | [<-->] TRADENOTES                     TYPE        J_1BNFTRADENOTES_TAB
* | [<-->] EXT_HEADER                     TYPE        J_1BNF_BADI_HEADER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD dados_cobranca.

    DATA:
      zbd1t           TYPE bsid-zbd1t,
      zbd2t           TYPE bsid-zbd2t,
      zbd3t           TYPE bsid-zbd3t,
      wert            TYPE acccr-wrbtr,
      ndup            TYPE numc3,
      s1              TYPE string,
      s2              TYPE string,
      faedt           TYPE rfpos-faedt,
      top_text        TYPE vtopis,
      xsplt           TYPE t052-xsplt,
      tradenotes_list TYPE j_1bnftradenotes.


    valor_liquido(
      EXPORTING
        nflin_tab  = nflin_tab
        header     = header
        vbrk       = vbrk
      CHANGING
        ext_header = ext_header
    ).

    IF payment_conditions IS NOT BOUND.
      RETURN.
    ENDIF.

    zbd1t = payment_conditions->get_ztag1( ).
    zbd2t = payment_conditions->get_ztag2( ).
    zbd3t = payment_conditions->get_ztag3( ).
    xsplt = payment_conditions->get_xsplt( ).

    IF xsplt IS NOT INITIAL.

      wert  = vbrk-netwr + vbrk-mwsbk.

      print_terms_of_payment_spli(
        EXPORTING
          bldat                         = vbrk-fkdat
          budat                         = vbrk-fkdat
          cpudt                         = sy-datum
          terms_of_payment              = vbrk-zterm
          wert                          = wert
      ).

      LOOP AT me->top_text_table INTO top_text.
        ndup = sy-tabix.
        SPLIT top_text-line AT ':' INTO s1 s2.
        CONDENSE s2 NO-GAPS.


        IF s2 CS ','.
          REPLACE ALL OCCURRENCES OF '.' IN s2 WITH space.
          REPLACE ALL OCCURRENCES OF ',' IN s2 WITH '.'.
          CONDENSE s2 NO-GAPS.

        ENDIF.

        tradenotes_list-docnum  = header-docnum.
        tradenotes_list-counter = sy-tabix.
        tradenotes_list-ndup    = ndup.
        tradenotes_list-dvenc   = top_text-hdatum.
        tradenotes_list-vdup    = s2.

        IF tradenotes_list IS INITIAL.
          RETURN.
        ENDIF.

        APPEND tradenotes_list TO tradenotes.

      ENDLOOP.
      RETURN.
    ENDIF.


    net_due_date_get(
      EXPORTING
        zfbdt = vbrk-fkdat
        zbd1t = zbd1t
        zbd2t = zbd2t
        zbd3t = zbd3t
        shkzg = space
        rebzg = space
      IMPORTING
        faedt = faedt
    ).


    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    tradenotes_list-docnum  = header-docnum.
    tradenotes_list-counter = '1'.
    tradenotes_list-ndup    = '001'.
    tradenotes_list-dvenc   = faedt.
    tradenotes_list-vdup = vbrk-netwr + vbrk-mwsbk.

    IF tradenotes_list IS INITIAL.
      RETURN.
    ENDIF.

    APPEND tradenotes_list TO tradenotes.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->DADOS_EAN_TRIB
* +-------------------------------------------------------------------------------------------------+
* | [<-->] ITEM                           TYPE        J_1BNF_BADI_ITEM_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD dados_ean_trib.

    DATA: c_ean(08) TYPE c VALUE 'SEM GTIN'.

    FIELD-SYMBOLS: <item> TYPE j_1bnf_badi_item.

    LOOP AT item ASSIGNING <item>.

      IF <item> IS NOT ASSIGNED.
        RETURN.
      ENDIF.


*CODIGO ANTIGO*
*IF <item>-cean_trib IS INITIAL OR <item>-cean_trib <> c_ean.
*        <item>-cean_trib = c_ean.
*      ELSE.
*        <item>-cean = c_ean.
*      ENDIF.

      IF <item>-cean IS INITIAL.
        <item>-cean = c_ean.
        <item>-cean_trib = c_ean.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->DADOS_EXPORTACAO
* +-------------------------------------------------------------------------------------------------+
* | [--->] HEADER                         TYPE        J_1BNFDOC
* | [--->] VBRP_TABLE                     TYPE        VBRP_TAB
* | [<-->] EXT_HEADER                     TYPE        J_1BNF_BADI_HEADER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD dados_exportacao.

    DATA: vbadr TYPE vbadr,
          vbrp  TYPE vbrp,
          posnr TYPE vbup-posnr.

    READ TABLE vbrp_table INTO vbrp INDEX 1.

    IF header-doctyp = '1' AND header-id_dest = '3'.

      posnr = '000000'.

      document_partner_read(
        EXPORTING
          parvw     = 'ZA'
          posnr     = posnr
          vbeln     = vbrp-vgbel
        IMPORTING
          vbadr     = vbadr
      ).

      IF vbadr IS INITIAL.
        RETURN.
      ENDIF.

      ext_header-ufembarq = vbadr-regio.
      ext_header-xlocembarq = vbadr-ort01.

    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->DADOS_FATURA
* +-------------------------------------------------------------------------------------------------+
* | [--->] NFLIN_TAB                      TYPE        J_1BNFLIN_TAB
* | [--->] HEADER                         TYPE        J_1BNFDOC
* | [--->] VBRK                           TYPE        VBRKVB
* | [--->] NFSTX                          TYPE        J_1BNFSTX_TAB
* | [<-->] EXT_HEADER                     TYPE        J_1BNF_BADI_HEADER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD dados_fatura.

    DATA: item   TYPE j_1bnflin,
          tax    TYPE  j_1bnfstx,
          taxval TYPE j_1btaxval.

    IF ext_header-vorig IS NOT INITIAL.
      RETURN.
    ENDIF.

    LOOP AT nflin_tab INTO item WHERE reftyp EQ 'BI'.

      READ TABLE nfstx INTO tax WITH KEY itmnum = item-itmnum taxtyp = 'IPI3'.

      taxval = tax-taxval.

      IF item-nfdis < 0.
        item-nfdis = item-nfdis * -1.
      ENDIF.

      ADD item-nfdis TO ext_header-vdesc.
*      ext_header-vliq = ext_header-vliq + ( item-nfnet - item-nfdis ) + taxval.
      ext_header-nfat  = item-refkey.
*      ext_header-vorig = ext_header-vorig + ( item-nfnet + taxval ).

      CLEAR: taxval.

    ENDLOOP.

    ext_header-vliq  = header-nftot.
    ext_header-vorig = header-nftot - ext_header-vdesc.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->DADOS_INTERMEDIADOR
* +-------------------------------------------------------------------------------------------------+
* | [<-->] EXT_HEADER                     TYPE        J_1BNF_BADI_HEADER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD dados_intermediador.

    IF ext_header-ind_pres EQ '5'.
      RETURN.
    ENDIF.

    ext_header-indintermed = '0'.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->DADOS_LOTE
* +-------------------------------------------------------------------------------------------------+
* | [<-->] TRACEABILITY                   TYPE        J_1BNFE_T_BADI_TRACE_400
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD dados_lote.


    FIELD-SYMBOLS: <traceability> TYPE j_1bnfe_s_badi_trace_400.

    IF traceability IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT traceability ASSIGNING <traceability>.

      IF <traceability> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      IF <traceability>-dfab IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      <traceability>-dfab = <traceability>-dval.

    ENDLOOP.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->DADOS_PAGAMENTO
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        J_1BNFDOC
* | [--->] VBRK                           TYPE        VBRKVB
* | [<-->] PAYMENT                        TYPE        J_1BNFE_T_BADI_PAYMENT_400
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD dados_pagamento.
*
*  DATA:
*    payment_conditions TYPE REF TO /s4tax/payment_conditions,
*    ls_payment         TYPE string, "zsd_nfe_payment,
*    lt_zsd_nfe_payment TYPE TABLE OF string "zsd_nfe_payment,
*    zlsch              TYPE t052-zlsch.
*
*  FIELD-SYMBOLS: <payment> TYPE j_1bnfe_s_badi_payment_400.
*
*  zlsch = vbrk-zlsch.
*
*  SELECT * FROM zsd_nfe_payment
*    INTO TABLE lt_zsd_nfe_payment
*   WHERE nftype = is_header-nftype
*     AND doctyp = is_header-doctyp
*     AND zlsch = ''.
*
*  IF lt_zsd_nfe_payment IS INITIAL.
*
*  IF zlsch IS INITIAL AND vbrk-zterm IS NOT INITIAL.
*
*    payment_conditions = dao_payment_condition->get( zterm = vbrk-zterm ).
*
*    CLEAR: zlsch.
*
*    zlsch = payment_conditions->get_zlsch( ).
*
*  ENDIF.
*
*  IF zlsch IS NOT INITIAL.
*
*      SELECT * FROM zsd_nfe_payment
*        INTO TABLE lt_zsd_nfe_payment
*       WHERE nftype = is_header-nftype
*         AND zlsch  = zlsch.
*
*
*  ELSE.
*
*    SELECT * FROM zsd_nfe_payment
*        INTO TABLE lt_zsd_nfe_payment
*       WHERE nftype = is_header-nftype
*         AND zlsch  = ' '.
*
*
*  ENDIF.
*  ENDIF.
*
*  IF lt_zsd_nfe_payment IS INITIAL.
*    RETURN.
*  ENDIF.
*
*
*  APPEND INITIAL LINE TO payment ASSIGNING <payment>.
*
*  IF <payment> IS NOT ASSIGNED.
*    RETURN.
*  ENDIF.
*
*  LOOP AT lt_zsd_nfe_payment INTO LS_PAYMENT.
*    <payment>-counter = '1'.
*    <payment>-ind_pag =  ls_payment-ind_pag.
*    <payment>-t_pag   =  ls_payment-t_pag.
*
*    IF <payment>-v_pag IS INITIAL.
*    <payment>-v_pag = is_header-nftot.
*    ENDIF.
*
*    IF ls_payment-rule01 IS INITIAL.
*      CONTINUE.
*    ENDIF.
*
*  <payment>-v_pag = '0'.
*  ENDLOOP.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZS4TAX_NF_ADD_DATA->DOCUMENT_PARTNER_READ
* +-------------------------------------------------------------------------------------------------+
* | [--->] PARVW                          TYPE        VBPA-PARVW
* | [--->] POSNR                          TYPE        VBUP-POSNR
* | [--->] VBELN                          TYPE        VBUK-VBELN
* | [<---] VBADR                          TYPE        VBADR
* | [EXC!] NOT_FOUND
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD document_partner_read.

    CALL FUNCTION 'SD_DOCUMENT_PARTNER_READ'
      EXPORTING
        i_parvw   = 'ZA'
        i_posnr   = posnr
        i_vbeln   = vbeln
      IMPORTING
        e_vbadr   = vbadr
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->IF_J_1BNF_ADD_DATA~ADD_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_APPLIC                      TYPE        J_1B_APPLIC
* | [--->] IS_HEADER                      TYPE        J_1BNFDOC
* | [--->] IT_NFLIN                       TYPE        J_1BNFLIN_TAB
* | [--->] IT_NFSTX                       TYPE        J_1BNFSTX_TAB
* | [--->] IT_PARTNER                     TYPE        J_1B_TT_NFNAD
* | [--->] IT_OT_PARTNER                  TYPE        J_1B_TT_NFCPD(optional)
* | [--->] IS_RBKP                        TYPE        RBKP(optional)
* | [--->] IT_NFFTX                       TYPE        J_1BNFFTX_TAB(optional)
* | [--->] IT_NFREF                       TYPE        J_1BNFREF_TAB(optional)
* | [--->] IT_RSEG                        TYPE        J_1B_TT_RSEG(optional)
* | [--->] IS_MKPF                        TYPE        MKPF(optional)
* | [--->] IT_MSEG                        TYPE        TY_T_MSEG(optional)
* | [--->] IS_VBRK                        TYPE        VBRKVB(optional)
* | [--->] IT_VBRP                        TYPE        VBRP_TAB(optional)
* | [--->] IT_VBFA                        TYPE        VBFA_T(optional)
* | [--->] IO_XML_IN                      TYPE REF TO CL_J_1BNFE_XML(optional)
* | [<-->] ES_HEADER                      TYPE        J_1BNF_BADI_HEADER
* | [<-->] ET_ITEM                        TYPE        J_1BNF_BADI_ITEM_TAB
* | [<-->] ET_TRANSVOL                    TYPE        J_1BNFTRANSVOL_TAB
* | [<-->] ET_TRAILER                     TYPE        J_1BNFTRAILER_TAB
* | [<-->] ET_TRADENOTES                  TYPE        J_1BNFTRADENOTES_TAB
* | [<-->] ET_REFPROC                     TYPE        J_1BNFREFPROC_TAB
* | [<-->] ET_ADD_INFO                    TYPE        J_1BNFADD_INFO_TAB
* | [<-->] ET_SUGARSUPPL                  TYPE        J_1BNFSUGARSUPPL_TAB
* | [<-->] ET_SUGARDEDUC                  TYPE        J_1BNFSUGARDEDUC_TAB
* | [<-->] ET_PHARMACEUT                  TYPE        J_1BNFPHARMACEUT_TAB
* | [<-->] ET_VEHICLE                     TYPE        J_1BNFVEHICLE_TAB
* | [<-->] ET_FUEL                        TYPE        J_1BNFFUEL_TAB
* | [<-->] ET_EXPORT                      TYPE        J_1BNFE_T_ADD_BADI_EXPORT(optional)
* | [<-->] ET_IMPORT_ADI                  TYPE        J_1BNFE_T_ADD_BADI_ADI_310(optional)
* | [<-->] ET_IMPORT_DI                   TYPE        J_1BNFE_T_BADI_DI_310(optional)
* | [<-->] ET_NVE                         TYPE        J_1BNFE_T_BADI_NVE_310(optional)
* | [<-->] ET_TRACEABILITY                TYPE        J_1BNFE_T_BADI_TRACE_400(optional)
* | [<-->] ET_PHARMA                      TYPE        J_1BNFE_T_BADI_PHARMA_400(optional)
* | [<-->] ET_PAYMENT                     TYPE        J_1BNFE_T_BADI_PAYMENT_400(optional)
* | [<-->] ES_TEC_RESP                    TYPE        J_1BNFE_S_BADI_TEC_RESP(optional)
* | [<-->] ET_PARTNER                     TYPE        J_1BNFE_T_BADI_PARTNER(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_j_1bnf_add_data~add_data.

    me->add_data_header(
      EXPORTING
        header     = is_header
        nflin      = it_nflin
        vbrk       = is_vbrk
        vbrp       = it_vbrp
        nfstx      = it_nfstx
        it_partner = it_partner
      CHANGING
        transvol   = et_transvol
        tradenotes = et_tradenotes
        ext_header = es_header
        payment    = et_payment
    ).

    me->add_data_item(
      EXPORTING
        nflin        = it_nflin
        vbrp         = it_vbrp
      CHANGING
        item         = et_item
        traceability = et_traceability
    ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->IF_J_1BNF_ADD_DATA~ADD_DATA_J1B1N
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        J_1BNFDOC
* | [--->] IT_NFLIN                       TYPE        J_1BNFLIN_TAB
* | [--->] IT_NFSTX                       TYPE        J_1BNFSTX_TAB
* | [--->] IT_PARTNER                     TYPE        J_1B_TT_NFNAD
* | [--->] IT_OT_PARTNER                  TYPE        J_1B_TT_NFCPD(optional)
* | [--->] IT_NFFTX                       TYPE        J_1BNFFTX_TAB(optional)
* | [--->] IT_NFREF                       TYPE        J_1BNFREF_TAB(optional)
* | [<-->] ES_HEADER                      TYPE        J_1BNF_BADI_HEADER
* | [<-->] ET_ITEM                        TYPE        J_1BNF_BADI_ITEM_TAB
* | [<-->] ET_TRANSVOL                    TYPE        J_1BNFTRANSVOL_TAB
* | [<-->] ET_TRAILER                     TYPE        J_1BNFTRAILER_TAB
* | [<-->] ET_TRADENOTES                  TYPE        J_1BNFTRADENOTES_TAB
* | [<-->] ET_REFPROC                     TYPE        J_1BNFREFPROC_TAB
* | [<-->] ET_ADD_INFO                    TYPE        J_1BNFADD_INFO_TAB
* | [<-->] ET_SUGARSUPPL                  TYPE        J_1BNFSUGARSUPPL_TAB
* | [<-->] ET_SUGARDEDUC                  TYPE        J_1BNFSUGARDEDUC_TAB
* | [<-->] ET_PHARMACEUT                  TYPE        J_1BNFPHARMACEUT_TAB
* | [<-->] ET_VEHICLE                     TYPE        J_1BNFVEHICLE_TAB
* | [<-->] ET_FUEL                        TYPE        J_1BNFFUEL_TAB
* | [<-->] ET_EXPORT                      TYPE        J_1BNFE_T_ADD_BADI_EXPORT(optional)
* | [<-->] ET_IMPORT_ADI                  TYPE        J_1BNFE_T_ADD_BADI_ADI_310(optional)
* | [<-->] ET_IMPORT_DI                   TYPE        J_1BNFE_T_BADI_DI_310(optional)
* | [<-->] ET_NVE                         TYPE        J_1BNFE_T_BADI_NVE_310(optional)
* | [<-->] ET_TRACEABILITY                TYPE        J_1BNFE_T_BADI_TRACE_400(optional)
* | [<-->] ET_PHARMA                      TYPE        J_1BNFE_T_BADI_PHARMA_400(optional)
* | [<-->] ET_PAYMENT                     TYPE        J_1BNFE_T_BADI_PAYMENT_400(optional)
* | [<-->] ES_TEC_RESP                    TYPE        J_1BNFE_S_BADI_TEC_RESP(optional)
* | [<-->] ET_PARTNER                     TYPE        J_1BNFE_T_BADI_PARTNER(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_j_1bnf_add_data~add_data_j1b1n.


    me->add_data_j1b1n(
      EXPORTING
        header     = is_header
      CHANGING
        item       = et_item
        ext_header = es_header
        tradenotes = et_tradenotes
    ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->IF_J_1BNF_ADD_DATA~FILL_AUTXML
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        J_1BNFDOC
* | [<-->] ET_AUTXML                      TYPE        J_1BNFE_T_BADI_AUTXML
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_j_1bnf_add_data~fill_autxml.

    me->add_data_autxml( ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->IF_J_1BNF_ADD_DATA~FILL_B2B_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        J_1BNFDOC
* | [--->] IT_PARTNER                     TYPE        J_1B_TT_NFNAD
* | [--->] IT_OT_PARTNER                  TYPE        J_1B_TT_NFCPD
* | [<---] ES_B2B                         TYPE        J_1BNFE_S_B2B
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_j_1bnf_add_data~fill_b2b_data.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->IF_J_1BNF_ADD_DATA~FILL_COD_SIT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_HEADER                      TYPE        J_1BNFDOC
* | [<-->] EV_COD_SIT                     TYPE        J_1B_STATUS_FISC_DOC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_j_1bnf_add_data~fill_cod_sit.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->IF_J_1BNF_ADD_DATA~FILL_EXPARAMETERS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DOC                         TYPE        J_1BNFDOC
* | [--->] IT_LIN                         TYPE        J_1BNFLIN(optional)
* | [<-->] CH_EXTENSION1                  TYPE        J1B_NF_XML_EXTENSION1_TAB
* | [<-->] CH_EXTENSION2                  TYPE        J1B_NF_XML_EXTENSION2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_j_1bnf_add_data~fill_exparameters.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZS4TAX_NF_ADD_DATA->IF_J_1BNF_ADD_DATA~FILL_PICMSINTER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IN_DOC                         TYPE        J_1BNFDOC
* | [--->] IN_LIN                         TYPE        J_1BNFLIN
* | [--->] IN_TAX                         TYPE        J_1BNFSTX_TAB
* | [<-->] CH_PICMSINTER                  TYPE        J1B_NF_XML_PICMSINTER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_j_1bnf_add_data~fill_picmsinter.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->INFORMACOES_ADICIONAIS
* +-------------------------------------------------------------------------------------------------+
* | [--->] NFLIN_TAB                      TYPE        J_1BNFLIN_TAB
* | [--->] VBRP_TABLE                     TYPE        VBRP_TAB
* | [<-->] ITEM                           TYPE        J_1BNF_BADI_ITEM_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD informacoes_adicionais.

  DATA:
    lips      TYPE lips,
    lgmng     TYPE string,
    nflin     TYPE j_1bnflin,
    posex     TYPE vbap-posex,
    vbrp_data TYPE vbrp,
    vbap_data TYPE vbap,
    vbkd_data TYPE vbkd.
    "zsd_brdgtxt_data type zsd_brdgtxt.

  FIELD-SYMBOLS: <item> TYPE j_1bnf_badi_item.

  SELECT * FROM lips
    UP TO 1 ROWS
    INTO lips
    FOR ALL ENTRIES IN vbrp_table
    WHERE vbeln = vbrp_table-vgbel
      AND posnr = vbrp_table-vgpos.
  ENDSELECT.

  IF lips IS INITIAL.
    RETURN.
  ENDIF.

"&-------- 1) Preenchimento InfAdProd --------&
  LOOP AT nflin_tab INTO nflin.
    READ TABLE item ASSIGNING <item> WITH KEY itmnum = nflin-itmnum.

    IF <item> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    "&-------- 6) Preenchimento Xprod --------&
*    SELECT SINGLE *
*        FROM zsd_brdgtxt
*        INTO zsd_brdgtxt_data
*        WHERE matnr = nflin-matnr AND
*              spras = 'PT'.
*
*    <item>-XPROD = zsd_brdgtxt_data-TEXT120.
    "&----------------------------------------&

    SELECT SINGLE *
      FROM vbrp
      INTO vbrp_data
      WHERE vbeln = nflin-refkey(10)
        AND posnr = nflin-refitm.

    IF sy-subrc NE 0 OR vbrp_data IS INITIAL.
      CONTINUE.
    ENDIF.

    SELECT SINGLE *
      INTO vbap_data
      FROM vbap
      WHERE vbeln = vbrp_data-aubel
        AND posnr = vbrp_data-aupos.

    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    SELECT SINGLE *
      FROM vbkd
      INTO vbkd_data
      WHERE vbeln = vbrp_data-aubel.

    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    lgmng = lips-lgmng.

    CONCATENATE
      'Lote: '     vbkd_data-bstkd
      'Dt Val: '   vbkd_data-bstdk+6(2) '-' vbkd_data-bstdk+4(2) '-' vbkd_data-bstdk(4)
      'Qtd: '      lgmng
      'Pedido: '   vbkd_data-bstkd
      'Item: '     vbap_data-posex
      'Material: ' vbap_data-kdmat
      INTO <item>-infadprod SEPARATED BY space.

    CONDENSE <item>-infadprod.
  ENDLOOP.
"&----------------------------------------&

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->INFORMACOES_COMPLEMENTARES
* +-------------------------------------------------------------------------------------------------+
* | [--->] NFLIN_TAB                      TYPE        J_1BNFLIN_TAB
* | [--->] HEADER                         TYPE        J_1BNFDOC
* | [--->] VBRK                           TYPE        VBRKVB
* | [--->] VBRP_TAB                       TYPE        VBRP_TAB
* | [--->] IT_PARTNER                     TYPE        J_1B_TT_NFNAD
* | [<-->] EXT_HEADER                     TYPE        J_1BNF_BADI_HEADER
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD informacoes_complementares.

  "&-------- 3) Personalização de Textos --------&

  "&- TEXTO 1 --------&
  IF header-bukrs = 'BR03'.
    CONCATENATE ext_header-infcpl
    'A partir da emissão desse documento a propriedade das mercadorias em referência passa a ser do Destinatário.'
    'Todos os clientes, autorizados ou conveniados concordam que (I) jamais, em conexão com qualquer produto Capsugel,'
    'será feito negócios com ou será vendido diretamente ou indiretamente ao Governo do Ira aos compradores ou importadores'
    'iranianos, ou entidades consideradas pelos EUA como apoiadores do terrorismo (tais entidades podem ser identificadas '
    'atraves do accesso ao U.S. Office of Foreign Asset Control Blocked Persons and Specifically Designated Nationals'
    'List http://sdnsearch.ofac.treas.gov/); e (II) que está ciente e, confirma a sua conformidade com todas as sanções'
    'economicas aplicaveis, incluindo quaisquer sanções econômicas aplicáveis pelos Estados Unidos. A partir da emissão'
    'desse documento a propriedade das mercadorias em referência passa a ser do Destinatário.'
    INTO ext_header-infcpl SEPARATED BY space.
  ENDIF.

  "&- TEXTO 2 --------&
  DATA: nflin     TYPE j_1bnflin,
        vbfa_data TYPE vbfa.

  READ TABLE nflin_tab INTO nflin WITH KEY docnum = header-docnum.

  SELECT SINGLE *
  FROM vbfa
  INTO vbfa_data
  WHERE vbeln = nflin-refkey
    AND posnn = nflin-itmnum
    AND vbtyp_v = 'J'
    AND rfmng > '0.00'.

  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

  CONCATENATE ext_header-infcpl
  '|| Remessa: ' vbfa_data-vbelv
  INTO ext_header-infcpl SEPARATED BY space.

  "&- TEXTO 3 --------&
  DATA: vbrk_data TYPE vbrk,
        konv_data TYPE konv,
        itd_konv  TYPE TABLE OF konv,
        wad_konv  TYPE konv,
        lvd_dolar TYPE string.

  SELECT SINGLE *
  FROM vbrk
  INTO vbrk_data
  WHERE vbeln = nflin-refkey.

  IF sy-subrc IS INITIAL.

    SELECT *
    FROM konv
    INTO TABLE itd_konv
    WHERE knumv = vbrk_data-knumv
      AND kawrt > '0.01'
      AND kherk = 'C'.

    IF sy-subrc IS INITIAL.

      SORT itd_konv BY knumv kposn stunr DESCENDING.

      READ TABLE itd_konv
      INTO wad_konv
      WITH KEY knumv = vbrk_data-knumv waers = 'USD'
      BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        lvd_dolar = wad_konv-kkurs.
        TRANSLATE lvd_dolar USING '.,'.
        CONCATENATE ext_header-infcpl
        ' - Taxa de Dolar Faturamento:R$ ' lvd_dolar '-'
        INTO ext_header-infcpl SEPARATED BY space.
      ENDIF.

    ELSE.

      SELECT SINGLE *
      FROM konv
      INTO konv_data
      WHERE knumv = vbrk_data-knumv
        AND kawrt > '0.01'
        AND kkurs > '1.00000'.

      IF sy-subrc IS INITIAL.
        lvd_dolar = konv_data-kkurs.
        TRANSLATE lvd_dolar USING '.,'.
        CONCATENATE ext_header-infcpl
        ' - Taxa de Dolar Faturamento:R$ ' lvd_dolar '-'
        INTO ext_header-infcpl SEPARATED BY space.
      ENDIF.

    ENDIF.

  ENDIF.

  "TABELA DA SOVOS
*  DATA: itd_drawback    TYPE TABLE OF zsovos_drawback,
*        wad_drawback    TYPE zsovos_drawback,
*        draw            TYPE zsovos_drawback,
*        mara_data       TYPE mara,
*        lvd_material    TYPE mara-matnr,
*        lvd_text_draw   TYPE string,
*        lvd_cod_old8(8) TYPE c.
*
*  SELECT *
*  FROM zsovos_drawback
*  INTO TABLE itd_drawback
*  WHERE ativo = abap_true
*    AND matnr = nflin-matnr
*    AND data_val >= sy-datum.
*
*  IF sy-subrc IS INITIAL.
*
*    FREE: lvd_text_draw.
*
*    READ TABLE itd_drawback INTO wad_drawback WITH KEY matnr = nflin-matnr.
*    IF sy-subrc IS INITIAL AND nflin-cfop(4) = '7127'.
*
*      "draw-ndraw = wad_drawback-draw_back.
*      "draw-item = wk_item-itmnum.
*      "APPEND draw.
*
*      SELECT SINGLE *
*      FROM mara
*      INTO mara_data      "lvd_cod_old     TYPE mara-matnr, "      lvd_material    TYPE mara-matnr,
*      WHERE matnr = nflin-matnr.
*
*      IF header-bukrs <> 'BR03'.
*
*        IF mara_data-matnr IS NOT INITIAL.
*          lvd_material = mara_data-matnr.
*        ELSE.
*          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
*            EXPORTING input  = nflin-matnr
*            IMPORTING output = lvd_material.
*        ENDIF.
*
*      ELSE.
*
*        IF mara_data-matnr IS NOT INITIAL AND header-bukrs = 'BR03' AND ( mara_data-zzmoldco = '003' OR mara_data-zzmoldco = '006' ).
*          lvd_material = mara_data-matnr.
*        ELSE.
*          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
*            EXPORTING input  = nflin-matnr
*            IMPORTING output = lvd_material.
*        ENDIF.
*
*      ENDIF.
*
*      lvd_text_draw = lvd_text_draw && '||' &&
*                      'Item:' && lvd_material &&
*                      ' - Ato Concessório:' && wad_drawback-draw_back &&
*                      '#' && 'de' && '#' && wad_drawback-data_reg+6(2) &&
*                      '/' && wad_drawback-data_reg+4(2) &&
*                      '/' && wad_drawback-data_reg(4).
*
*    ENDIF.
*
*    IF lvd_text_draw IS NOT INITIAL.
*      CONCATENATE ext_header-infcpl
*      ' - Venda de produção do estabelecimento Sob Regime Aduaneiro Especial Drawback Suspensão' lvd_text_draw
*      INTO ext_header-infcpl SEPARATED BY space.
*    ENDIF.
*
*  ENDIF.

  "&- TEXTO 4 --------&
  DATA: vbrp_data       TYPE vbrp,
        j_1batl1_data   TYPE j_1batl1,
        j_1bnfstx_data  TYPE j_1bnfstx,
        bcdiferido      TYPE vbrp-mwsbp,
        bcdiferido_char(20) TYPE c.

  LOOP AT vbrp_tab INTO vbrp_data WHERE posnr = nflin-itmnum.

    SELECT SINGLE taxsit
    FROM j_1batl1
    INTO j_1batl1_data-taxsit
    WHERE taxlaw = vbrp_data-j_1btaxlw1.

    IF sy-subrc = 0 AND j_1batl1_data-taxsit = '51'.

      SELECT SINGLE base
      FROM j_1bnfstx
      INTO j_1bnfstx_data-base
      WHERE docnum = header-docnum
        AND itmnum = vbrp_data-posnr
        AND taxtyp = 'ICM3'.

      IF sy-subrc = 0.
        bcdiferido = bcdiferido + j_1bnfstx_data-base.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF bcdiferido > 0.
    WRITE bcdiferido TO bcdiferido_char CURRENCY 'BRL'.
    CONDENSE bcdiferido_char NO-GAPS.
    CONCATENATE ext_header-infcpl
    '||' 'Base de Cálculo do ICMS Diferido R$:' bcdiferido_char '||'
    INTO ext_header-infcpl SEPARATED BY space.
  ENDIF.

  "&- TEXTO 5 --------&
  DATA: lvd_docnum TYPE j_1bnflin-docnum,
        lvd_xblnr  TYPE vbrk-xblnr,
        lvd_index  TYPE sy-tabix,
        j_1bnfe_active_data TYPE j_1bnfe_active.


  IF nflin-refkey NE vbrk_data-zuonr.

    SELECT SINGLE xblnr
    FROM vbrk
    INTO vbrk_data
    WHERE vbeln EQ vbrk_data-zuonr.

    IF lvd_xblnr IS NOT INITIAL.

      SELECT SINGLE docnum
      FROM j_1bnflin
      INTO lvd_docnum
      WHERE refkey EQ vbrk_data-zuonr.

      IF sy-subrc IS INITIAL.

        SELECT SINGLE *
        FROM j_1bnfe_active
        INTO j_1bnfe_active_data
        WHERE docnum = lvd_docnum.

        IF sy-subrc IS INITIAL.

*          MOVE-CORRESPONDING j_1bnfe_active_data TO lvd_acceskey.
*          nfref-refnfe = lvd_acceskey.
*          APPEND nfref.
*          DESCRIBE TABLE ext_header-infcpl LINES lvd_index.
*          READ TABLE ext_header-infcpl INDEX lvd_index.

          CONCATENATE ext_header-infcpl
          'NF-e Referencia:  ' lvd_xblnr
          INTO ext_header-infcpl SEPARATED BY space.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  "&- TEXTO 6 --------&
  IF header-bukrs NE 'BR03'.
    CONCATENATE ext_header-infcpl
    'DECLARO QUE OS PRODUTOS PERIGOSOS'
    'ESTÃO ADEQUADAMENTE CLASSIFICADOS, EMBALADOS, IDENTIFICADOS E'
    'ESTIVADOS PARA SUPORTAR OS RISCOS DAS OPERAÇÕES DE TRANSPORTE E'
    'QUE ATENDEM ÀS EXIGÊNCIAS DA REGULAMENTAÇÃO.'
    INTO ext_header-infcpl SEPARATED BY space.
  ENDIF.

  "&- TEXTO 7 --------&
  IF header-inco1 NE 'FOB'.
    CONCATENATE ext_header-infcpl
    'Venda na modalidade CIP.'
    INTO ext_header-infcpl SEPARATED BY space.
  ENDIF.

  "&- TEXTO 8 --------&
  DATA: j_1bnfdoc_data TYPE j_1bnfdoc,
        va_devol       TYPE string.

  IF header-nftype EQ 'ZD' OR header-nftype EQ 'ZE'.

    SELECT SINGLE * FROM j_1bnfdoc
    INTO j_1bnfdoc_data
    WHERE docnum = nflin-docref.
    IF sy-subrc = 0.
      CONCATENATE 'Dev. Ref. NF-e:' j_1bnfdoc_data-nfenum '(' j_1bnfdoc_data-docnum ').'
      INTO va_devol SEPARATED BY space.
    ENDIF.

  ENDIF.

  IF va_devol IS NOT INITIAL.
    CONCATENATE ext_header-infcpl va_devol
    INTO ext_header-infcpl SEPARATED BY space.
  ENDIF.

  "&- TEXTO 9 -------------------------&
  DATA: lips_data     TYPE lips,
        vbrp_ext_data TYPE vbrp.

  CONCATENATE ext_header-infcpl 'Ordem de Venda : '
  INTO ext_header-infcpl SEPARATED BY space.

  LOOP AT vbrp_tab INTO vbrp_ext_data.

    SELECT SINGLE *
    FROM lips
    INTO lips_data
    WHERE vbeln = vbrp_ext_data-vgbel
      AND posnr = vbrp_ext_data-vgpos.

    IF sy-subrc EQ 0.
      CONCATENATE ext_header-infcpl lips_data-vgbel ','
      INTO ext_header-infcpl SEPARATED BY space.
    ENDIF.

  ENDLOOP.

  CONCATENATE ext_header-infcpl '.'
  INTO ext_header-infcpl.

  "&- TEXTO 10 -------------------------&
  CONCATENATE ext_header-infcpl
  'Transporte: ' vbfa_data-vbeln '.'
  INTO ext_header-infcpl SEPARATED BY space.

  "&- TEXTO 11 -------------------------&
  DATA: lt_partners   TYPE TABLE OF vbpa,
        lv_carriers   TYPE string,
        lv_redespacho TYPE string,
        lv_email_all  TYPE string,
        lv_email_add  TYPE string,
        lfa1_data     TYPE lfa1,
        adrc_data     TYPE adrc,
        likp_data    TYPE likp,
        vbpa_table   TYPE TABLE OF vbpa,
        vbpa_data    TYPE vbpa.

  DATA: va_redespacho(20) TYPE c.

  SELECT SINGLE *
  FROM lips
  INTO lips_data.

  IF lips_data IS NOT INITIAL.

    SELECT SINGLE *
    FROM likp
    INTO likp_data
    WHERE vbeln = lips_data-vbeln.

    IF sy-subrc EQ 0.
      IF likp_data-inco1 EQ 'ZIF'.
        lv_redespacho = 'Emitente'.
      ELSEIF likp_data-inco1 EQ 'ZOB'.
        lv_redespacho = 'Destinatario'.
      ENDIF.
    ENDIF.

  ENDIF.

  SELECT *
  FROM vbpa
  INTO TABLE vbpa_table
  WHERE vbeln = nflin-refkey.

  IF sy-subrc = 0.

    LOOP AT vbpa_table INTO vbpa_data WHERE parvw = 'ZA'.

      SELECT SINGLE *
      FROM lfa1
      INTO lfa1_data
      WHERE lifnr = vbpa_data-lifnr.

      IF sy-subrc IS INITIAL.

        SELECT SINGLE *
        FROM adrc
        INTO adrc_data
        WHERE addrnumber = lfa1_data-adrnr.

        IF sy-subrc IS INITIAL.
          IF lv_carriers IS INITIAL.
            CONCATENATE
            'Redespacho Rodoviário por conta do' lv_redespacho 'pela:' lfa1_data-name1 lfa1_data-name2
            'Fone:' lfa1_data-telf1 'End:' adrc_data-street adrc_data-house_num1 ',' adrc_data-city1
            'I.E.' lfa1_data-stcd3
            'CNPJ' lfa1_data-stcd1
            INTO lv_carriers SEPARATED BY space.
          ELSE.
            CONCATENATE lv_carriers ',' lfa1_data-name1 lfa1_data-name2
            INTO lv_carriers SEPARATED BY space.
          ENDIF.
        ENDIF.

* "ESSA PARTE ABAIXO NO CÓDIGO NÃO ALTERA EM NADA O EXT_HEADER-INFCPL
*        CLEAR lv_email_add.
*        SELECT SINGLE smtp_addr
*        FROM adr6
*        INTO lv_email_add
*        WHERE addrnumber = lfa1_data-adrnr
*          AND home_flag = 'X'.
*
*        IF sy-subrc IS INITIAL AND lv_email_add IS NOT INITIAL.
*          IF lv_email_all IS INITIAL.
*            lv_email_all = lv_email_add.
*          ELSE.
*            CONCATENATE lv_email_all lv_email_add INTO lv_email_all SEPARATED BY ';'.
*          ENDIF.
*        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_carriers IS NOT INITIAL.
    CONCATENATE ext_header-infcpl
    lv_carriers '.'
    INTO ext_header-infcpl SEPARATED BY space.
  ENDIF.

  "&- TEXTO 12 -------------------------&
  DATA: xname      TYPE thead-tdname,
        xtline     TYPE TABLE OF tline,
        tline_data TYPE tline.

  WRITE nflin-refkey(10) TO xname.

  CLEAR xtline.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ZNFE'
      language                = 'P'
      name                    = xname
      object                  = 'VBBK'
    TABLES
      lines                   = xtline
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF sy-subrc <> 0.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'ZNFE'
        language                = 'E'
        name                    = xname
        object                  = 'VBBK'
      TABLES
        lines                   = xtline
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
  ENDIF.


  IF xtline[] IS NOT INITIAL.
    DATA sep(1) TYPE c.
    sep = '|'.
    LOOP AT xtline INTO tline_data.
      CONCATENATE ext_header-infcpl sep tline_data INTO ext_header-infcpl.
    ENDLOOP.
  ENDIF.

  "&- TEXTO 13 --------&
  DATA: va_vbc                 TYPE j_1bnfstx-base,
        va_vicms               TYPE j_1bnfstx-taxval,
        va_vbc_char(20)        TYPE c,
        va_vicms_char(20)      TYPE c.

  CLEAR: va_vbc, va_vicms.

  LOOP AT vbrp_tab INTO vbrp_data.

    IF vbrp_data-j_1btaxlw1 CP '*10' OR vbrp_data-j_1btaxlw1 CP '*70'.
      SELECT SINGLE base taxval
      INTO (j_1bnfstx_data-base, j_1bnfstx_data-taxval)
      FROM j_1bnfstx
      WHERE docnum = nflin-docref
        AND itmnum  = vbrp_data-posnr
        AND taxtyp = 'ICM3'.
      IF sy-subrc = 0.
        va_vbc   = va_vbc + j_1bnfstx_data-base.
        va_vicms = va_vicms + j_1bnfstx_data-taxval.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF va_vbc IS NOT INITIAL OR va_vicms IS NOT INITIAL.
    WRITE va_vbc TO va_vbc_char DECIMALS 2.
    WRITE va_vicms TO va_vicms_char DECIMALS 2.

    REPLACE ALL OCCURRENCES OF ',' IN va_vbc_char WITH space.
    REPLACE ALL OCCURRENCES OF '.' IN va_vbc_char WITH ','.
    CONDENSE va_vbc_char NO-GAPS.

    REPLACE ALL OCCURRENCES OF ',' IN va_vicms_char WITH space.
    REPLACE ALL OCCURRENCES OF '.' IN va_vicms_char WITH ','.
    CONDENSE va_vicms_char NO-GAPS.

    CONCATENATE ext_header-infcpl
    '|| Base ICMS Operação Própria = R$' va_vbc_char
    'ICMS Operação Própria R$' va_vicms_char '||'
    INTO ext_header-infcpl SEPARATED BY space.
  ENDIF.

  "&- TEXTO 14 -------------------------&
  DATA: suframa_number TYPE j_1bsuframa,
        nfdis_data     TYPE string.

  nfdis_data = nflin-nfdis.

  IF header-regio EQ 'AM'
  OR header-regio EQ 'AP'
  OR header-regio = 'RO'
  OR header-regio = 'RR'
  OR header-regio = 'AC'
  OR header-regio = 'ZC'.

    SELECT SINGLE suframa
    INTO suframa_number
    FROM kna1
    WHERE kunnr = header-parid.

    IF suframa_number IS NOT INITIAL.
      IF header-cnpj_bupla EQ '43677178001075'.

        IF nflin-nfdis NE 0.
          CONCATENATE ext_header-infcpl '|'
          'Registro do Destinatario/Remetente na SUFRAMA:' suframa_number
          'Desconto de 12% de ICMS referente a vendas Zona Franca' nfdis_data
           INTO ext_header-infcpl SEPARATED BY space.
        ELSE.
          CONCATENATE ext_header-infcpl '|'
          'Registro do Destinatario/Remetente na SUFRAMA:' suframa_number
          INTO ext_header-infcpl SEPARATED BY space.
        ENDIF.

      ELSE.

        IF nflin-nfdis NE 0.
          CONCATENATE ext_header-infcpl '|'
          'Registro do Destinatario/Remetente na SUFRAMA:' suframa_number
          'Desconto de 7% de ICMS referente a vendas Zona Franca'  nfdis_data
          INTO ext_header-infcpl SEPARATED BY space.
        ELSE.
          CONCATENATE ext_header-infcpl '|'
          'Registro do Destinatario/Remetente na SUFRAMA:' suframa_number
          INTO ext_header-infcpl SEPARATED BY space.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.

  "&- TEXTO 15 ------------------------&
*  DATA: lt_zmsmb_fci_cont TYPE TABLE OF zmsmb_fci_cont,
*        ls_zmsmb_fci_cont TYPE zmsmb_fci_cont,
*        lvd_tabix         TYPE sy-tabix,
*        wld_vbrk          TYPE vbrk,
*        wld_vbrp          TYPE vbrp,
*        wld_vbkd          TYPE vbkd,
*        wld_vbfa          TYPE vbfa,
*        wld_lips          TYPE lips,
*        va_xped           TYPE string,
*        lvd_lote          TYPE string,
*        lvd_val           TYPE string,
*        lv_substring      TYPE string,
*        lvd_count         TYPE i,
*        lvd_lenght        TYPE i,
*        lvd_uecha         TYPE lips-posnr,
*        lvd_kdmat         TYPE knmt-kdmat,
*        bkpf_data         TYPE bkpf.
*
*  CLEAR: lvd_tabix, va_xped, lvd_lote, xname, xtline, tline_data.
*
*  SELECT * FROM zmsmb_fci_cont
*    INTO TABLE lt_zmsmb_fci_cont
*    WHERE bukrs = header-bukrs
*      AND werks = nflin-werks
*      AND matnr = nflin-matnr
*      AND status = 'A'.
*
*  IF nflin-reftyp EQ 'BI'.
*    CLEAR: wld_vbrp, wld_vbkd.
*
*    SELECT SINGLE * INTO wld_vbrk FROM vbrk WHERE vbeln EQ nflin-refkey.
*
*    IF wld_vbrk-fkart EQ 'ZDOB' OR wld_vbrk-fkart EQ 'ZEQB' OR
*       wld_vbrk-fkart EQ 'ZFBB' OR wld_vbrk-fkart EQ 'ZKAB' OR
*       wld_vbrk-fkart EQ 'ZKBB' OR wld_vbrk-fkart EQ 'ZKEB' OR
*       wld_vbrk-fkart EQ 'ZKRB' OR wld_vbrk-fkart EQ 'ZRLB' OR
*       wld_vbrk-fkart EQ 'ZRQB' OR wld_vbrk-fkart EQ 'ZPAB' OR
*       wld_vbrk-fkart EQ 'ZSEB'.
*
*      SELECT SINGLE *
*        FROM bkpf
*        INTO bkpf_data
*        WHERE bukrs = header-bukrs AND
*              awtyp = 'VBRK' AND
*              awkey = nflin-refkey AND
*              blart = 'RV' AND
*              gjahr = header-pstdat(4).
*
*      IF sy-subrc NE 0.
*        CONCATENATE ext_header-infcpl
*          '|| Contabilização não encontrada para documento:' nflin-refkey
*          INTO ext_header-infcpl SEPARATED BY space.
*        RETURN.
*      ENDIF.
*    ENDIF.
*
*    READ TABLE vbrp_tab INTO wld_vbrp WITH KEY posnr = nflin-itmnum.
*    IF sy-subrc IS INITIAL.
*      SELECT SINGLE * INTO wld_vbkd FROM vbkd
*        WHERE vbeln = wld_vbrp-aubel AND posnr = wld_vbrp-aupos.
*      IF sy-subrc NE 0 OR wld_vbkd-bstkd IS INITIAL.
*        SELECT SINGLE * INTO wld_vbkd FROM vbkd
*          WHERE vbeln = wld_vbrp-aubel AND posnr = '000000'.
*      ENDIF.
*    ENDIF.
*
*    IF wld_vbkd-bstkd IS NOT INITIAL.
*      CONCATENATE ext_header-infcpl
*        '|| Pedido:' wld_vbkd-bstkd
*        INTO ext_header-infcpl SEPARATED BY space.
*    ENDIF.
*  ENDIF.
*
*  SELECT SINGLE * INTO wld_vbfa FROM vbfa
*    WHERE vbeln = nflin-refkey AND
*          mjahr = nflin-refkey+10(4) AND
*          posnn = nflin-itmnum.
*
*  IF sy-subrc IS INITIAL.
*    SELECT SINGLE * INTO wld_lips FROM lips
*      WHERE vbeln = wld_vbfa-vbelv AND posnr = wld_vbfa-posnv.
*
*    IF sy-subrc IS INITIAL AND wld_lips-charg IS NOT INITIAL.
*      lvd_val = wld_lips-lfimg.
*      CONDENSE lvd_val NO-GAPS.
*      lvd_count = strlen( lvd_val ).
*      lvd_lenght = lvd_count - 4.
*
*      lv_substring = substring( val = lvd_val off = lvd_lenght len = 4 ).
*      TRANSLATE lv_substring USING '.,'.
*      REPLACE SECTION OFFSET lvd_lenght LENGTH 4 OF lvd_val WITH lv_substring.
*
*      lvd_lenght = lvd_count - 1.
*      lvd_val = lvd_val(lvd_lenght).
*      CONDENSE lvd_val NO-GAPS.
*
*      CONCATENATE wld_lips-charg 'Dt Val:' wld_lips-vfdat+6(2)
*                  '/' wld_lips-vfdat+4(2) '/' wld_lips-vfdat(4)
*                  'Qtd:' lvd_val INTO lvd_lote SEPARATED BY space.
*
*      CONCATENATE ext_header-infcpl '|| Lote:' lvd_lote
*        INTO ext_header-infcpl SEPARATED BY space.
*    ENDIF.
*  ENDIF.
*
*  CLEAR xname.
*  CONCATENATE nflin-matnr wld_vbrk-vkorg wld_vbrk-vtweg INTO xname.
*
*  REFRESH xtline.
*  CALL FUNCTION 'READ_TEXT'
*    EXPORTING
*      id       = '0001'
*      language = 'P'
*      name     = xname
*      object   = 'MVKE'
*    TABLES
*      lines    = xtline
*    EXCEPTIONS
*      OTHERS   = 8.
*
*  LOOP AT xtline INTO tline_data.
*    CONCATENATE ext_header-infcpl '||' tline_data-tdline
*      INTO ext_header-infcpl SEPARATED BY space.
*  ENDLOOP.
*
*  SELECT SINGLE kdmat FROM knmt INTO lvd_kdmat
*    WHERE kunnr = header-parid AND matnr = nflin-matnr.
*
*  READ TABLE lt_zmsmb_fci_cont INTO ls_zmsmb_fci_cont
*    WITH KEY bukrs = header-bukrs
*             werks = nflin-werks
*             matnr = nflin-matnr.
*
*  IF sy-subrc = 0 AND ls_zmsmb_fci_cont-nrfci IS NOT INITIAL.
*    CONCATENATE ext_header-infcpl '|| FCI:' ls_zmsmb_fci_cont-nrfci
*      INTO ext_header-infcpl SEPARATED BY space.
*  ENDIF.

  "&- TEXTO 16 ------------------------&
  "Não são necessários ajustes, ext_header-infcpl é único e não requer controle de tamanho ou divisão em linhas.

  "&- TEXTO 17 ------------------------&
  DATA: lvd_text_17(800) TYPE c,
        tld_kna1         TYPE TABLE OF kna1,
        wld_kna1         TYPE kna1,
        lvd_matnr        TYPE mara-matnr,
        lvd_lines        TYPE sy-tabix,
        nflin_item       TYPE j_1bnflin,
        vbrk_count       TYPE i,
        mara_count       TYPE i,
        it_partner_data  TYPE J_1BNFNAD.

  CLEAR: lvd_text_17.

  CASE header-partyp.
    WHEN 'C'.
      SELECT *
      FROM kna1
      INTO TABLE tld_kna1
      WHERE kunnr = header-parid.
    WHEN 'V'.
    WHEN OTHERS.
  ENDCASE.

  READ TABLE it_partner INTO it_partner_data INDEX 1.

  IF sy-subrc EQ 0 AND it_partner_data-regio NE 'EX'.
    IF nflin-reftyp EQ 'BI'.
      SELECT COUNT(*)
      FROM vbrk
      INTO vbrk_count
      WHERE vbeln = nflin-refkey(10)
        AND ( fkart = 'ZSTB' OR fkart = 'ZBOB' ).

      IF vbrk_count > 0.
        SELECT COUNT(*)
        FROM mara
        INTO mara_count
        WHERE matnr = nflin_item-matnr
          AND bismt = '75.342B'.

        IF mara_count > 0.
          READ TABLE tld_kna1 INTO wld_kna1 INDEX 1.
          IF sy-subrc IS INITIAL.
            IF wld_kna1-crtn EQ '1'.

              CASE it_partner_data-regio.
                WHEN 'PR'.
                  CONCATENATE
                  'Operação destinada a contribuinte enquadrado no Simples Nacional -'
                  'MVA reduzida - art. 12- do Anexo X do RICMS/PR'
                  INTO lvd_text_17 SEPARATED BY space.
                WHEN 'SC'.
                  CONCATENATE
                  'Tributado pelo Simples Nacional'
                  ' - "ST - 30% de MVA - Anexo III, Art.232, § 3º do RICMS/SC"'
                  INTO lvd_text_17 SEPARATED BY space.
                WHEN OTHERS.
              ENDCASE.

              IF lvd_text_17 IS NOT INITIAL.
                CONCATENATE ext_header-infcpl lvd_text_17
                  INTO ext_header-infcpl SEPARATED BY space.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  "&- TEXTO 18 ------------------------&
  DATA: lvd_len    TYPE i,
        lvd_leninf TYPE i,
        lvd_offset TYPE i,
        lvd_len1   TYPE i,
        lvd_text   TYPE string.

  CLEAR: lvd_text.

  LOOP AT nflin_tab INTO nflin_item.

    IF nflin_item-cfop(4) EQ '7101' OR
       nflin_item-cfop(4) EQ '7102' OR
       nflin_item-cfop(4) EQ '7949'.

      CASE nflin_item-werks.
        WHEN 'BRS2'.
          CONCATENATE
          'NAO INCIDENCIA DO ICMS ART.7º, INCISO V, RICMS-SP - DECRETO 45490/00'
          'IMUNE DO IPI - ART. 18, INCISO II DO RIPI - DECRETO 7212/10'
          'ISENCAO DO SERVICO DE TRANSPORTE - ART. 149, ANEXO I DO RISMC/00'
          INTO lvd_text SEPARATED BY space.
        WHEN 'BRI2'.
          CONCATENATE
          'NAO INCIDENCIA DO ICMS ART.7º, III, "b" do RICMS-PE/1991'
          'IMUNE DO IPI - ART. 18, INCISO II DO RIPI - DECRETO 7212/10'
          INTO lvd_text SEPARATED BY space.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    IF lvd_text IS NOT INITIAL.
      CONCATENATE ext_header-infcpl
      lvd_text
      INTO ext_header-infcpl SEPARATED BY space.
    ENDIF.

  ENDLOOP.

  "&- TEXTO 19 ------------------------&
*  DATA: tld_likp    TYPE TABLE OF likp,
*        lt_vbfa     TYPE TABLE OF vbfa,
*        tld_vbap    TYPE TABLE OF vbap,
*        wld_vbap    TYPE vbap,
*        lv_qvol     TYPE zkfbc_nfe_200_vol-qvol,
*        lv_pesob    TYPE zkfbc_nfe_200_vol-pesob,
*        lv_pesol    TYPE zkfbc_nfe_200_vol-pesol.
*
*  CLEAR: lt_vbfa, lv_qvol, lv_pesob, lv_pesol.
*
*  SELECT *
*  FROM vbfa
*  INTO TABLE lt_vbfa
*  WHERE vbeln = nflin-refkey(10)
*    AND vbtyp_v = 'J'.
*
*  IF lt_vbfa[] IS INITIAL. " No document found
*
*    SELECT *
*      FROM vbfa
*      INTO TABLE lt_vbfa
*      WHERE vbeln = nflin-refkey(10)
*        AND vbtyp_v = 'C'.
*
*    IF lt_vbfa[] IS NOT INITIAL.
*      SORT lt_vbfa BY vbelv.
*      DELETE ADJACENT DUPLICATES FROM lt_vbfa COMPARING vbelv.
*
*      SELECT *
*      FROM vbap
*      INTO TABLE tld_vbap
*      FOR ALL ENTRIES IN lt_vbfa
*      WHERE vbeln = lt_vbfa-vbelv.
*    ENDIF.
*
*    IF tld_vbap[] IS NOT INITIAL.
*      CLEAR: lv_qvol, lv_pesob, lv_pesol.
*
*      LOOP AT tld_vbap INTO wld_vbap.
*        IF wld_vbap-volum IS NOT INITIAL OR
*           wld_vbap-brgew IS NOT INITIAL OR
*           wld_vbap-ntgew IS NOT INITIAL.
*
*          lv_qvol  = lv_qvol + wld_vbap-volum.
*          lv_pesob = lv_pesob + wld_vbap-brgew.
*          lv_pesol = lv_pesol + wld_vbap-ntgew.
*        ENDIF.
*      ENDLOOP.
*
*      READ TABLE tld_vbap INTO wld_vbap INDEX 1.
*      IF sy-subrc IS INITIAL.
*        CONCATENATE ext_header-infcpl
*        '|| Ordem de Venda: ' wld_vbap-vbeln
*        INTO ext_header-infcpl SEPARATED BY space.
*      ENDIF.
*    ENDIF.
*  ENDIF.

  "&- TEXTO 20 ------------------------&
  IF ( header-nftype NE 'ZD' AND  header-nftype NE 'ZE' ).

    DATA:  lvd_nfenum TYPE  j_1bnfdoc-nfenum,
           lvd_series TYPE  j_1bnfdoc-series.

    SELECT SINGLE nfenum series
    FROM j_1bnfdoc
    INTO ( lvd_nfenum ,lvd_series )
    WHERE docnum EQ header-docref.

    IF sy-subrc IS INITIAL.
      CONCATENATE ext_header-infcpl
      'Referente a nossa nota fiscal nr.: ' lvd_nfenum '-' lvd_series
      INTO ext_header-infcpl SEPARATED BY space.
    ENDIF.

  ENDIF.

  "&----------------------------------------&

  "&-------- 5) Tag de Exportação --------&
  DATA: v_exnum TYPE vbrk-exnum,
        wa_eikp TYPE eikp,
        wa_t615 TYPE t615t.
  DATA: tld_zsd_brdgtxt TYPE TABLE OF zsd_brdgtxt,
        wld_zsd_brdgtxt TYPE zsd_brdgtxt.

*IF wk_item-reftyp = 'BI'.
  SELECT SINGLE exnum
    INTO v_exnum
    FROM vbrk
    WHERE vbeln = nflin-refkey.
  IF sy-subrc = 0.
    SELECT SINGLE *
      INTO wa_eikp
      FROM eikp
      WHERE exnum = v_exnum.
    IF sy-subrc = 0.
      SELECT SINGLE *
      FROM t615t
      INTO wa_t615
      WHERE zolla = wa_eikp-zolla
      AND land1 = 'BR'.

      IF sy-subrc = 0.
        ext_header-ufembarq = wa_t615-text3.
        ext_header-xlocembarq = wa_t615-text2.
      ENDIF.
    ENDIF.
  ENDIF.
*ENDIF.

  DATA: kna1_data TYPE kna1,
        stcd1     TYPE kna1-stcd1.

  IF header-regio = 'EX'.
    CASE header-partyp.
      WHEN 'C'.
        SELECT SINGLE *
                 INTO kna1_data
                 FROM kna1
                WHERE kunnr = header-parid.
        stcd1 = kna1_data-stcd1.
      WHEN 'V'.
        SELECT SINGLE *
                 INTO lfa1_data
                 FROM lfa1
                WHERE lifnr = header-parid.
        stcd1 = lfa1_data-stcd1.
      WHEN OTHERS.
        stcd1 = header-cgc.
    ENDCASE.
    ext_header-isuf = kna1_data-stcd1.
    IF ext_header-isuf IS INITIAL.
      ext_header-isuf = 'NONDECLARED'.
    ENDIF.
  ENDIF.
  "&----------------------------------------&

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZS4TAX_NF_ADD_DATA->NET_DUE_DATE_GET
* +-------------------------------------------------------------------------------------------------+
* | [--->] ZFBDT                          TYPE        BSID-ZFBDT
* | [--->] ZBD1T                          TYPE        BSID-ZBD1T
* | [--->] ZBD2T                          TYPE        BSID-ZBD2T
* | [--->] ZBD3T                          TYPE        BSID-ZBD3T
* | [--->] SHKZG                          TYPE        BSID-SHKZG
* | [--->] REBZG                          TYPE        BSID-REBZG
* | [<---] FAEDT                          TYPE        RFPOS-FAEDT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD net_due_date_get.

    CALL FUNCTION 'NET_DUE_DATE_GET'
      EXPORTING
        i_zfbdt = zfbdt
        i_zbd1t = zbd1t
        i_zbd2t = zbd2t
        i_zbd3t = zbd3t
        i_shkzg = shkzg
        i_rebzg = rebzg
      IMPORTING
        e_faedt = faedt.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method ZS4TAX_NF_ADD_DATA->PRINT_TERMS_OF_PAYMENT_SPLI
* +-------------------------------------------------------------------------------------------------+
* | [--->] BLDAT                          TYPE        VBRK-FKDAT
* | [--->] BUDAT                          TYPE        VBRK-FKDAT
* | [--->] CPUDT                          TYPE        SY-DATUM
* | [--->] TERMS_OF_PAYMENT               TYPE        VBRK-ZTERM
* | [--->] WERT                           TYPE        ACCCR-WRBTR
* | [EXC!] TERMS_OF_PAYMENT_NOT_IN_T052
* | [EXC!] TERMS_OF_PAYMENT_NOT_IN_T052S
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD print_terms_of_payment_spli.

    CLEAR me->top_text_table.

    CALL FUNCTION 'SD_PRINT_TERMS_OF_PAYMENT_SPLI'
      EXPORTING
        bldat                         = bldat
        budat                         = budat
        cpudt                         = cpudt
        terms_of_payment              = terms_of_payment
        wert                          = wert
      TABLES
        top_text_split                = me->top_text_table
      EXCEPTIONS
        terms_of_payment_not_in_t052  = 1
        terms_of_payment_not_in_t052s = 2
        OTHERS                        = 3.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->VALOR_LIQUIDO
* +-------------------------------------------------------------------------------------------------+
* | [--->] NFLIN_TAB                      TYPE        J_1BNFLIN_TAB
* | [--->] HEADER                         TYPE        J_1BNFDOC
* | [--->] VBRK                           TYPE        VBRKVB
* | [<-->] EXT_HEADER                     TYPE        J_1BNF_BADI_HEADER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD valor_liquido.

*    DATA: nflin TYPE j_1bnflin.
*
*    LOOP AT nflin_tab INTO nflin WHERE reftyp EQ 'BI'.
*      IF nflin-nfdis < 0.
*        nflin-nfdis = nflin-nfdis * -1.
*      ENDIF.
*
*      ADD nflin-nfdis TO ext_header-vdesc.
*      ext_header-vliq = header-nftot - ext_header-vdesc.
*    ENDLOOP.

    payment_conditions = dao_payment_condition->get( zterm = vbrk-zterm ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZS4TAX_NF_ADD_DATA->VOLUMES_TRANSPORTADOS
* +-------------------------------------------------------------------------------------------------+
* | [--->] HEADER                         TYPE        J_1BNFDOC
* | [<-->] TRANSVOL                       TYPE        J_1BNFTRANSVOL_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD volumes_transportados.

    DATA: mseht      TYPE t006a-mseht,
          j_transvol TYPE j_1bnftransvol.

    SELECT SINGLE mseht FROM t006a
      INTO mseht
      WHERE msehi = header-shpunt
      and SPRAS = 'PT'.

    j_transvol-docnum = header-docnum.
    j_transvol-counter = '1'.

    IF mseht IS NOT INITIAL.
      j_transvol-esp     = mseht.
    ENDIF.

    j_transvol-marca   = me->marca.
    j_transvol-qvol    = header-anzpk.
    j_transvol-pesol   = header-ntgew.
    j_transvol-pesob   = header-brgew.

    IF j_transvol IS INITIAL.
      RETURN.
    ENDIF.

    APPEND j_transvol TO transvol.

  ENDMETHOD.
ENDCLASS.