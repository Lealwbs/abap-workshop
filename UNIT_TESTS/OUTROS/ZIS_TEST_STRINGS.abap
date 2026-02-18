*&---------------------------------------------------------------------*
*& Report zis_test_strings
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_test_strings.


DATA: string_utils TYPE REF TO /s4tax/string_utils.

DATA: v TYPE J_1BEXCBAS VALUE ' 400.00 ',
      s TYPE string.


START-OF-SELECTION.

CREATE OBJECT string_utils.

WRITE /: v.

s = v.
WRITE /: s.

s = |{ v }|.
WRITE /: s.

WRITE /:'Os 2 proixmos'.
s = v.
WRITE /: s.
s = string_utils->shift_left_deleting( input = s char_delete = ' ').
WRITE /: s.

WRITE: /.
WRITE /:'Os 2 proixmos'.
s = |{ v }|.
WRITE /: s.
s = string_utils->shift_left_deleting( input = s char_delete = ' ').
WRITE /: s.



*
*
*
*END-OF-SELECTION.
*
*DATA: obj TYPE REF TO /s4tax/dao_dfe_cfg.
*CREATE OBJECT obj.
*
*START-OF-SELECTION.
*
*LOOP.
*  WAIT UP TO 10 seconds.
*write: sy-repid.
*
*
*
*  DATA(dfe_cfg) = NEW /s4tax/document_config(
*    iw_struct = VALUE /s4tax/tdfe_cfg(
*      start_operation    = '20250514'
*      job_ex_type        = /s4tax/dfe_constants=>job_execution_type-constant
*      status_update_time = '120500'
*      grc_destination    = 'TEST_VALUE_GRC_RFC'
*      source_text        = /s4tax/dfe_constants=>source_text-ftx
*      save_xml           = abap_true  )
*  ).
*
*
* obj->/s4tax/idao_dfe_cfg~save( dfe_cfg ).
*" obj->/s4tax/idao_dfe_cfg~delete( '20230428' ).
*
*
*  DATA: cl_badi TYPE REF TO /s4TAX/cl_badi_nfse.
*
*  CREATE OBJECT cl_badi.
*
*  DATA(doc) = NEW /s4tax/doc( ).
*  DATA(reporter) = NEW /s4tax/reporter( ).
*
*  DATA(int_tmp) = 1.
*
*  IF int_tmp EQ 1.
*
*    cl_badi->/s4tax/if_badi_nfse~save_docs_standard( doc      = doc
*                                                     reporter = reporter ).
*
*  ENDIF.
*
