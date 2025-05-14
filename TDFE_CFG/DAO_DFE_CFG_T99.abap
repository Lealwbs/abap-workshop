*&---------------------------------------------------------------------*
*& Include /s4tax/dao_dfe_cfg_t99
*&---------------------------------------------------------------------*
CLASS ltcl_dao_nfse_cfg DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA: db_mock TYPE REF TO if_osql_test_environment.

    DATA: cut            TYPE REF TO /s4tax/dao_dfe_cfg,
          dfe_cfg_mock_t TYPE TABLE OF /s4tax/tdfe_cfg.

    CLASS-METHODS: class_setup, class_teardown.
    METHODS: setup, teardown.

    METHODS:
      delete FOR TESTING RAISING cx_static_check,
      get_first FOR TESTING RAISING cx_static_check,
      get_all FOR TESTING RAISING cx_static_check,
      get_by_start_operation FOR TESTING RAISING cx_static_check,
      save FOR TESTING RAISING cx_static_check,
      save_many FOR TESTING RAISING cx_static_check,
      struct_to_objects FOR TESTING RAISING cx_static_check,
      objects_to_struct  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_dao_nfse_cfg IMPLEMENTATION.

  METHOD class_setup.
    db_mock = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( '/S4TAX/TDFE_CFG' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    db_mock->destroy( ).
  ENDMETHOD.

  METHOD setup.
    cut = NEW #(  ).

    dfe_cfg_mock_t = VALUE #(
    ( start_operation    = '20250514'
      job_ex_type        = /s4tax/dfe_constants=>job_execution_type-constant
      status_update_time = '121035'
      grc_destination    = 'GRC_RFC'
      source_text        = /s4tax/dfe_constants=>source_text-ftx
      save_xml           = abap_true  )

    ( start_operation    = '20250729'
      job_ex_type        = /s4tax/dfe_constants=>job_execution_type-single
      status_update_time = '093320'
      grc_destination    = 'GRC_RFC'
      source_text        = /s4tax/dfe_constants=>source_text-logbr
      save_xml           = abap_false  ) ).
  ENDMETHOD.

  METHOD teardown.
    db_mock->clear_doubles( ).
  ENDMETHOD.

  METHOD delete.
    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( act ) ).

    db_mock->insert_test_data( dfe_cfg_mock_t ).

    cut->/s4tax/idao_dfe_cfg~delete( '00000000' ).

    act = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( act ) ).

    cut->/s4tax/idao_dfe_cfg~delete( '20250514' ).

    act = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( act ) ).
    cl_abap_unit_assert=>assert_equals( exp = '20250729' act = act[ 1 ]->get_start_operation(  ) ).
  ENDMETHOD.

  METHOD get_first.
    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_first( ).
    cl_abap_unit_assert=>assert_initial( act ).

    db_mock->insert_test_data( dfe_cfg_mock_t ).

    act = cut->/s4tax/idao_dfe_cfg~get_first( ).
    cl_abap_unit_assert=>assert_equals( exp = '20250514' act = act->get_start_operation( ) ).
  ENDMETHOD.


  METHOD get_all.
    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = lines( act ) ).

    db_mock->insert_test_data( dfe_cfg_mock_t ).

    act = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( act ) ).
  ENDMETHOD.

  METHOD get_by_start_operation.
    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_by_start_operation( '20250729' ).
    cl_abap_unit_assert=>assert_initial( act ).

    db_mock->insert_test_data( dfe_cfg_mock_t ).

    act = cut->/s4tax/idao_dfe_cfg~get_by_start_operation( '20250729' ).
    cl_abap_unit_assert=>assert_equals( exp = dfe_cfg_mock_t[ 2 ]-status_update_time
                                        act = act->get_status_update_time( ) ).
  ENDMETHOD.


  METHOD save.
    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_initial( act ).

    DATA: dfe_cfg_obj_mock_null TYPE REF TO /s4tax/document_config.
    DATA(dfe_cfg_obj_mock_1) = NEW /s4tax/document_config( iw_struct = dfe_cfg_mock_t[ 1 ] ).
    DATA(dfe_cfg_obj_mock_2) = NEW /s4tax/document_config( iw_struct = dfe_cfg_mock_t[ 2 ] ).

    cut->/s4tax/idao_dfe_cfg~save( dfe_cfg_obj_mock_null ).
    cut->/s4tax/idao_dfe_cfg~save( dfe_cfg_obj_mock_1 ).
    cut->/s4tax/idao_dfe_cfg~save( dfe_cfg_obj_mock_2 ).

    act = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( act ) ).
    cl_abap_unit_assert=>assert_equals( exp = '20250514' act = act[ 1 ]->get_start_operation( ) ).
    cl_abap_unit_assert=>assert_equals( exp = '20250729' act = act[ 2 ]->get_start_operation( ) ).
  ENDMETHOD.

  METHOD save_many.
    DATA: dfe_cfg_obj_mock_t TYPE /s4tax/document_config_t.
    cut->/s4tax/idao_dfe_cfg~save_many( dfe_cfg_obj_mock_t ).

    DATA(act) = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_initial( act ).

    DATA: dfe_cfg_obj_mock_null TYPE REF TO /s4tax/document_config.
    DATA(dfe_cfg_obj_mock_1) = NEW /s4tax/document_config( iw_struct = dfe_cfg_mock_t[ 1 ] ).
    DATA(dfe_cfg_obj_mock_2) = NEW /s4tax/document_config( iw_struct = dfe_cfg_mock_t[ 2 ] ).

    APPEND: dfe_cfg_obj_mock_null TO dfe_cfg_obj_mock_t,
            dfe_cfg_obj_mock_1 TO dfe_cfg_obj_mock_t,
            dfe_cfg_obj_mock_2 TO dfe_cfg_obj_mock_t.

    cut->/s4tax/idao_dfe_cfg~save_many( dfe_cfg_obj_mock_t ).

    act = cut->/s4tax/idao_dfe_cfg~get_all(  ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( act ) ).
    cl_abap_unit_assert=>assert_equals( exp = '20250514' act = act[ 1 ]->get_start_operation( ) ).
    cl_abap_unit_assert=>assert_equals( exp = '20250729' act = act[ 2 ]->get_start_operation( ) ).
  ENDMETHOD.

  METHOD struct_to_objects.
    DATA: dfe_cfg_obj_t TYPE /s4tax/document_config_t.
    DATA: dfe_cfg_struct_t TYPE /s4tax/tdfe_cfg_t.

    dfe_cfg_obj_t = cut->/s4tax/idao_dfe_cfg~struct_to_objects( dfe_cfg_struct_t ).

    APPEND: dfe_cfg_mock_t[ 1 ] TO dfe_cfg_struct_t,
            dfe_cfg_mock_t[ 2 ] TO dfe_cfg_struct_t.

    dfe_cfg_obj_t = cut->/s4tax/idao_dfe_cfg~struct_to_objects( dfe_cfg_struct_t ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( dfe_cfg_obj_t ) ).
    cl_abap_unit_assert=>assert_equals( exp = '20250514' act = dfe_cfg_obj_t[ 1 ]->get_start_operation( ) ).
    cl_abap_unit_assert=>assert_equals( exp = '20250729' act = dfe_cfg_obj_t[ 2 ]->get_start_operation( ) ).
  ENDMETHOD.

  METHOD objects_to_struct.
    DATA: dfe_cfg_obj_t TYPE /s4tax/document_config_t.
    DATA: dfe_cfg_struct_t TYPE /s4tax/tdfe_cfg_t.

    dfe_cfg_struct_t = cut->/s4tax/idao_dfe_cfg~objects_to_struct( dfe_cfg_obj_t ).

    DATA: dfe_cfg_obj_mock_null TYPE REF TO /s4tax/document_config.
    DATA(dfe_cfg_obj_mock_1) = NEW /s4tax/document_config( iw_struct = dfe_cfg_mock_t[ 1 ] ).
    DATA(dfe_cfg_obj_mock_2) = NEW /s4tax/document_config( iw_struct = dfe_cfg_mock_t[ 2 ] ).

    APPEND: dfe_cfg_obj_mock_null TO dfe_cfg_obj_t,
            dfe_cfg_obj_mock_1 TO dfe_cfg_obj_t,
            dfe_cfg_obj_mock_2 TO dfe_cfg_obj_t.

    dfe_cfg_struct_t = cut->/s4tax/idao_dfe_cfg~objects_to_struct( dfe_cfg_obj_t ).

    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( dfe_cfg_struct_t ) ).
    cl_abap_unit_assert=>assert_equals( exp = '20250514' act = dfe_cfg_struct_t[ 1 ]-start_operation ).
    cl_abap_unit_assert=>assert_equals( exp = '20250729' act = dfe_cfg_struct_t[ 2 ]-start_operation ).
  ENDMETHOD.

ENDCLASS.