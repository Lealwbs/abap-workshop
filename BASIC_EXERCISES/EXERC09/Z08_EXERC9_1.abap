*&---------------------------------------------------------------------*
*& Report Z08_EXERC9_1
*&---------------------------------------------------------------------*
*& Smartform: Z08_LISTA_VOO
*& Estrutura: Z08_ESTRUT_VOO
*& Módulo de Função: /1BCDWB/SF00000280
*&---------------------------------------------------------------------*
REPORT Z08_EXERC9_1.

DATA: tp_range_carrid TYPE spfli-carrid.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS v_carrid FOR tp_range_carrid OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b_input.

START-OF-SELECTION.

DATA: it_voo_tmp TYPE TABLE OF Z08_ESTRUT_VOO.

CALL FUNCTION '/1BCDWB/SF00000280'
  EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
*   OUTPUT_OPTIONS             =
*   USER_SETTINGS              = 'X'
    aeroporto_origem           = 'AZ'
    aeroporto_destino          = 'QF'
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    t_voos                     = it_voo_tmp
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

END-OF-SELECTION.

cl_demo_output=>display( it_voo_tmp ).
