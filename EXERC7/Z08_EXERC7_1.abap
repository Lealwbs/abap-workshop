*&---------------------------------------------------------------------*
*& Report Z08_EXERC7_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc7_1.

TYPES: BEGIN OF tp_l_material,
         vtp_codigo_material TYPE mara-matnr, "18
         vtp_descricao       TYPE makt-maktx, "40
         vtp_numero_antigo   TYPE mara-bismt, "18
         vtp_numero_desenho  TYPE mara-zeinr, "22
       END OF tp_l_material.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  PARAMETERS: v_flname TYPE string OBLIGATORY DEFAULT 'D:\Codigos\ABAP\abap-workshop\EXERC7\materiais.txt'.
SELECTION-SCREEN END OF BLOCK b_input.

DATA: it_bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA: it_messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: it_material TYPE TABLE OF tp_l_material.

START-OF-SELECTION.

  PERFORM f_read_file USING v_flname it_material.

  "cl_demo_output=>display( it_material ).

  LOOP AT it_material ASSIGNING FIELD-SYMBOL(<line>).
    CLEAR it_bdcdata.
    REFRESH it_bdcdata.

    PERFORM f_binput USING 'SAPLMGMM' '0060' 'X' '' ''.
    PERFORM f_binput USING '' '' '' 'BDC_OKCODE' '=ENTR'.
    PERFORM f_binput USING '' '' '' 'RMMG1-MATNR' <line>-vtp_codigo_material.

    PERFORM f_binput USING 'SAPLMGMM' '0070' 'X' '' ''.
    PERFORM f_binput USING '' '' '' 'BDC_OKCODE' '=ENTR'.
    PERFORM f_binput USING '' '' '' 'MSICHTAUSW-KZSEL(01)' 'X'.

    PERFORM f_binput USING 'SAPLMGMM' '4004' 'X' '' ''.
    PERFORM f_binput USING '' '' '' 'BDC_OKCODE' '=SP02'.
    PERFORM f_binput USING '' '' '' 'MARA-BISMT' <line>-vtp_numero_antigo.

    PERFORM f_binput USING 'SAPLMGMM' '4004' 'X' '' ''.
    PERFORM f_binput USING '' '' '' 'BDC_OKCODE' '/00'.
    PERFORM f_binput USING '' '' '' 'MARA-ZEINR' <line>-vtp_numero_desenho.

    PERFORM f_binput USING 'SAPLSPO1' '0300' 'X' '' ''.
    PERFORM f_binput USING '' '' '' 'BDC_OKCODE' '=YES'.

    CALL TRANSACTION 'MM02' USING it_bdcdata MODE 'N'
          MESSAGES INTO it_messtab.
  ENDLOOP.

  MESSAGE s022(z08).

END-OF-SELECTION.

FORM f_read_file
  USING f_filename   TYPE string          "READ FILE.TXT
        f_it_datatab TYPE STANDARD TABLE. "STORAGE INTO

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = f_filename
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = f_it_datatab
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

  IF f_it_datatab IS NOT INITIAL. "Apagar o cabeçalho'.
    DELETE f_it_datatab INDEX 1.
  ENDIF.
ENDFORM.

FORM f_binput USING f_program f_dynpro f_dynbegin f_fnam f_fval.
  DATA f_l_bdcdata TYPE bdcdata.
  IF f_program IS INITIAL.
    f_l_bdcdata-fnam = f_fnam.
    f_l_bdcdata-fval = f_fval.
  ELSE.
    f_l_bdcdata-program  = f_program.
    f_l_bdcdata-dynpro   = f_dynpro.
    f_l_bdcdata-dynbegin = f_dynbegin.
  ENDIF.
  APPEND f_l_bdcdata TO it_bdcdata.
ENDFORM.