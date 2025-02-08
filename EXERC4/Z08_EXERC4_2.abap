*&---------------------------------------------------------------------*
*& Report Z08_EXERC4_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc4_2.

TYPES: BEGIN OF tp_l_datatab,
         vtp_material     TYPE c LENGTH 18,
         vtp_centro       TYPE c LENGTH 4,
         vtp_unidade      TYPE c LENGTH 3,
         vtp_qtde_estoque TYPE bapiwmdve-com_qty,
       END OF tp_l_datatab,
       BEGIN OF tp_l_material,
         vtp_mara_mtart TYPE mara-mtart,
         vtp_mara_matkl TYPE mara-matkl,
         vtp_mara_bismt TYPE mara-bismt,
         vtp_makt_maktx TYPE makt-maktx,
       END OF tp_l_material,
       BEGIN OF tp_l_compras,
         vtp_MARC_EKGRP   TYPE marc-ekgrp,
         vtp_T024_EKNAM   TYPE t024-eknam,
         vtp_qtde_compras TYPE i,
       END OF tp_l_compras.

DATA: it_datatab     TYPE TABLE OF tp_l_datatab,
      it_BAPIWMDVE   TYPE TABLE OF bapiwmdve,
      it_BAPIWMDVS   TYPE TABLE OF bapiwmdvs,
      v_material_tmp TYPE tp_l_material,
      v_compras_tmp  TYPE tp_l_compras,
      v_return       TYPE  bapireturn.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  PARAMETERS: v_flname TYPE string OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b_input.

INITIALIZATION.
  v_flname = 'D:\Codigos\ABAP\abap-workshop\MATERIAIS\Material-Centro-TR2.txt'.

AT SELECTION-SCREEN.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = v_flname
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = it_datatab
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE e020(z08). "Não foi possível ler o arquivo de texto.
  ENDIF.

  IF it_datatab IS NOT INITIAL. "Apagar o cabeçalho: 'Material  Centro  Unidade de medida'.
    DELETE it_datatab INDEX 1.
  ENDIF.

START-OF-SELECTION.

  LOOP AT it_datatab ASSIGNING FIELD-SYMBOL(<line>).
    CLEAR: it_BAPIWMDVE,
           v_material_tmp,
           v_compras_tmp,
           v_return.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <line>-vtp_material
      IMPORTING
        output = <line>-vtp_material.

    CALL FUNCTION 'BAPI_MATERIAL_AVAILABILITY'
      EXPORTING
        material = <line>-vtp_material
        plant    = <line>-vtp_centro
        unit     = <line>-vtp_unidade
      IMPORTING
        return   = v_return
      TABLES
        wmdvex   = it_BAPIWMDVE  "Contém a quantidade de Estoque
        wmdvsx   = it_BAPIWMDVS.

    IF v_return IS INITIAL. "Se não houve erros

*     LOOP AT it_BAPIWMDVE ASSIGNING FIELD-SYMBOL(<unique_line>).     "Evitando usar Linha de Cabeçalho e Workarea
*       <line>-vtp_qtde_estoque = <unique_line>-com_qty.              "Solução alternativa para o Read Table
*     ENDLOOP.

      READ TABLE it_BAPIWMDVE INDEX 1 ASSIGNING FIELD-SYMBOL(<unique_line>).
      IF sy-subrc = 0.
        <line>-vtp_qtde_estoque = <unique_line>-com_qty.
      ENDIF.

      WRITE: / |Código do Material:     { <line>-vtp_material     } |,
             / |Centro:                 { <line>-vtp_centro       } |,
             / |Unidade de Medida:      { <line>-vtp_unidade      } |,
             / |Qtde em Estoque:        { <line>-vtp_qtde_estoque } |.

      SELECT SINGLE mara~mtart, mara~matkl, mara~bismt, makt~maktx
               FROM mara
          LEFT JOIN makt
                 ON mara~matnr = makt~matnr
        INTO @v_material_tmp
       WHERE mara~matnr = @<line>-vtp_material
         AND makt~spras = @sy-langu.
      IF sy-subrc IS INITIAL.
        WRITE: / |Tipo de Material:       { v_material_tmp-vtp_mara_mtart } |,
               / |Grupo de Mercadorias:   { v_material_tmp-vtp_mara_matkl } |,
               / |N. do Antigo Material:  { v_material_tmp-vtp_mara_bismt } |,
               / |Descrição do Material:  { v_material_tmp-vtp_makt_maktx } |. "No idioma de logon
      ELSE.
        WRITE: / |* Não foi possível consultar AS INFORMAÇÕES DO MATERIAL.|.
      ENDIF.

      SELECT SINGLE marc~ekgrp, t024~eknam
               FROM marc
          LEFT JOIN t024
                 ON marc~ekgrp = t024~ekgrp
        INTO @v_compras_tmp
       WHERE marc~matnr = @<line>-vtp_material.
      IF sy-subrc IS INITIAL AND v_compras_tmp-vtp_MARC_EKGRP IS NOT INITIAL.
        WRITE: / |Codigo Gp Compradores:  { v_compras_tmp-vtp_MARC_EKGRP } |,
               / |Nome Gp Compradores:    { v_compras_tmp-vtp_T024_EKNAM } |.
      ELSE.
        WRITE: / |# Não foi possível consultar O CÓDIGO E NOME DO GRUPO DE COMPRADORES, ou o valor está vazio.|.
      ENDIF.

      SELECT COUNT( * )
        FROM ekpo
        INTO @v_compras_tmp-vtp_qtde_compras
       WHERE ekpo~matnr = @<line>-vtp_material.
      IF sy-subrc IS INITIAL.
        WRITE: / |Qtde Pedidos Compra:    { v_compras_tmp-vtp_qtde_compras } |.
      ELSE.
        WRITE: / |# Não foi possível consultar A QUANTIDADE TOTAL DE PEDIDOS DE COMPRA, ou o valor é nulo.|.
      ENDIF.

    ELSE.
      WRITE: / v_return-message.
    ENDIF.

    ULINE.
  ENDLOOP.

END-OF-SELECTION.

  "cl_demo_output=>display( it_datatab ).