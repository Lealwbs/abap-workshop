*&---------------------------------------------------------------------*
*& Include /s4tax/dao_dfe_cfg_t99
*&---------------------------------------------------------------------*
CLASS ltcl_dao_nfse_cfg DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA: db_mock TYPE REF TO if_osql_test_environment,
                dfe_cfg TYPE TABLE OF /s4tax/tdfe_cfg.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      save               FOR TESTING RAISING cx_static_check,
      get_all            FOR TESTING,
      get_by_start_operation     FOR TESTING RAISING cx_static_check.

    DATA: cut TYPE REF TO /s4tax/dao_dfe_cfg.
ENDCLASS.


CLASS ltcl_dao_nfse_cfg IMPLEMENTATION.

  METHOD class_setup.
    db_mock = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( '/S4TAX/TDFE_CFG' ) )
    ).
  ENDMETHOD.

  METHOD class_teardown.
    db_mock->destroy( ).
  ENDMETHOD.

  METHOD setup.
    DATA: start_operation TYPE /s4tax/e_start_operation.

    start_operation = sy-datum.

    cut = NEW #(  ).

    dfe_cfg = VALUE #(
        (
            start_operation = start_operation
            job_ex_type = /s4tax/dfe_constants=>job_execution_type-constant
        )
        ).

    db_mock->insert_test_data( dfe_cfg ).
  ENDMETHOD.

  METHOD teardown.
    db_mock->clear_doubles( ).
  ENDMETHOD.

  METHOD save.
    DATA: dfe_config TYPE REF TO /s4tax/document_config.

    dfe_config = NEW #(  ).
    dfe_config->set_start_operation( sy-datum ).
    dfe_config->set_job_ex_type( type = /s4tax/dfe_constants=>job_execution_type-constant ).

    cut->/s4tax/idao_dfe_cfg~save( dfe_config ).

    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( act ) ).
  ENDMETHOD.


  METHOD get_all.
    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( act ) ).
  ENDMETHOD.

  METHOD get_by_start_operation.
    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_by_start_operation( sy-datum ).
    cl_abap_unit_assert=>assert_bound( act ).
  ENDMETHOD.

ENDCLASS.