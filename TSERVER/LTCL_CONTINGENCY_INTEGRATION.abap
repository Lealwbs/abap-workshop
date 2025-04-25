CLASS ltcl_contingency_integration DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CLASS-DATA: db_mock TYPE REF TO if_osql_test_environment.

    DATA: test_double         TYPE REF TO /s4tax/contingency_integration,
          mock_branch_info    TYPE j_1bnfe_branch_info,
          mock_cust3          TYPE j_1bnfe_cust3,
          mock_branch         TYPE REF TO /s4tax/branch,
          mock_branch_address TYPE REF TO /s4tax/address.

    DATA: cut                TYPE REF TO /s4tax/contingency_integration.


    CLASS-METHODS: class_setup, class_teardown.
    METHODS: setup, teardown.

    METHODS:
      test_load_branch_information FOR TESTING,
      test_contingency_read FOR TESTING,
      test_nfe_server_check FOR TESTING,
      test_dfe_server_check FOR TESTING,
      test_initialize_dao_and_server FOR TESTING,
      test_read_dfe_cfg_list FOR TESTING,
      test_timestamp_cfg FOR TESTING,
      test_nfe_active_server FOR TESTING,
      test_dfe_active_server FOR TESTING,
      test_nfe_integration FOR TESTING,
      test_dfe_integration FOR TESTING,
      test_main FOR TESTING.

ENDCLASS.


CLASS ltcl_contingency_integration IMPLEMENTATION.

  METHOD class_setup.
    db_mock = cl_osql_test_environment=>create(  i_dependency_list = VALUE #( ( '/S4TAX/TSERVER' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    db_mock->destroy(  ).
  ENDMETHOD.

  METHOD setup.

    test_double ?= cl_abap_testdouble=>create( '/S4TAX/CONTINGENCY_INTEGRATION' ).

    mock_branch_info = VALUE j_1bnfe_branch_info(
        bukrs      = 'BR01'
        branch     = '0001'
        model      = '57'
        regio      = 'MG'
        rfcdest    = 'SAPCLNT100'
        xnfeactive = 'X' ).

    mock_cust3 = VALUE j_1bnfe_cust3(
        mandt      = '400'
        bukrs      = '1234'
        branch     = '5678'
        model      = '90'
        validfrom  = '12345678'
        autoserver = 'X'
        tpamb      = '1'
        version    = '150' ).

    mock_branch = NEW /s4tax/branch(
      iw_struct = VALUE j_1bbranch(
        mandt      = '400'
        bukrs      = 'BR01'
        branch     = '1000'
        bupla_type = '01'
        name       = 'Filial São Paulo' ) ).

    mock_branch_address = NEW /s4tax/address(
      iw_struct = VALUE sadr(
        mandt  = '400'
        adrnr  = '0000123456'
        natio  = 'BR'  ) ).


    cut = NEW #( cs_branch_info = mock_branch_info ).
    cut->cust3 = mock_cust3.
    cut->branch = mock_branch.
    cut->branch_address = mock_branch_address.


    "TODO: RESOLVER MOCKAGEM DO dao_branch"

*    mock_dfe_cfg->set_status_update_time( '105523' ).
*    INSERT mock_dfe_cfg INTO TABLE mock_dfe_cfg_t.

  ENDMETHOD.

  METHOD teardown.
    CLEAR: cut, mock_branch_info, mock_cust3.
  ENDMETHOD.

  METHOD test_load_branch_information.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).

    cut->cust3 = mock_cust3.

*  DATA(mock_dao_branch) = cl_abap_testdouble=>create( '/S4TAX/IDAO_BRANCH' ).
*
*  cl_abap_testdouble=>configure_call( mock_dao_branch )->ignore_all_parameters( )->returning( mock_branch ).
*  mock_dao_brach->get( ).
*
*  cut->dao_branch = mock_dao_branch.
*
*
*    cut->load_branch_information( branch_info ).
**    cut->branch = mock_branch.
**    cut->branch_address = mock_branch_address.
*
*    cl_abap_unit_assert=>assert_bound( act = cut->branch
*                                       msg = 'MSG 1 BRANCH' ).
**    cl_abap_unit_assert=>assert_bound( act = cut->branch_address
*                                       msg = 'MSG 1 BRANCH ADDRESS ').
  ENDMETHOD.

  METHOD test_contingency_read.

cl_abap_unit_assert=>fail( msg = 'Needs Correction' level = if_abap_unit_constant=>severity-low ).
    cl_abap_unit_assert=>assert_initial( cut->ls_set_cont ).

    DATA(expected_set_cont) = VALUE j_1bnfe_contin( mandt       = '100'
                                                    land1       = 'BR'
                                                    regio       = 'MG'
                                                    bukrs       = 'BR01'
                                                    branch      = '0001'
                                                    model       = '55'
                                                    contin_type = '2' ).
    CREATE OBJECT cut->dfe_std.

    cut->branch_address->set_land1( 'BR' ).
    cut->branch_address->set_regio( 'MG' ).
    cut->branch_info-bukrs = 'BR01'.
    cut->branch_info-branch = '0001'.
    cut->branch_info-model = '55'.

*    DATA(lr_contin) = VALUE j_1bnfe_contin(
*      mandt       = sy-mandt
*      land1       = 'BR'
*      regio       = 'MG'
*      bukrs       = 'BR01'
*      branch      = '0001'
*      model       = '55'
*      contin_type = '2'
*      xi_out      = abap_true
*    ).
*    INSERT j_1b_nfe_contin FROM lr_contin.

    cut->contingency_read(  ).

    cl_abap_unit_assert=>assert_not_initial( cut->ls_set_cont ).

  ENDMETHOD.

  METHOD test_nfe_server_check.
    cl_abap_unit_assert=>assert_initial( cut->server_check_nfe ).

    cut->nfe_server_check( ).

    cl_abap_unit_assert=>assert_not_initial( cut->server_check_nfe ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-regio exp = mock_branch_info-regio ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-tpamb exp = mock_cust3-tpamb ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-version exp = mock_cust3-version ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-checktmpl exp = /s4tax/date=>create_utc_now( )->to_timezone( sy-zonlo )->to_timestamp( ) ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-sefaz_active exp = 'X' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-scan_active exp = '' ).
  ENDMETHOD.

  METHOD test_dfe_server_check.
    cl_abap_unit_assert=>assert_initial( cut->server_check_dfe ).

    cut->dfe_server_check( ).

    cl_abap_unit_assert=>assert_not_initial( cut->server_check_dfe ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-cnpj exp = mock_branch_info-bukrs ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-tpamb exp = mock_cust3-tpamb ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-version exp = mock_cust3-version ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-checktmpl exp = /s4tax/date=>create_utc_now( )->to_timezone( sy-zonlo )->to_timestamp( ) ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-active_service exp = /s4tax/dfe_constants=>svc_code_sap-sefaz ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-model exp = mock_branch_info-model ).
  ENDMETHOD.

  METHOD test_initialize_dao_and_server.
    DATA: mock_dao    TYPE REF TO /s4tax/dao_server,
          mock_server TYPE REF TO /s4tax/server.

    DATA(mock_tserver) = VALUE /s4tax/tserver( regio            = 'MG'
                                               model            = '55'
                                               active_server    = 'SERVER01'
                                               authorizer       = 'SEFAZMG'
                                               environment_type = '1'
                                               contingency_date = '20240415' ).

    CREATE OBJECT mock_dao.
    CREATE OBJECT mock_server EXPORTING struct = mock_tserver.
    cut->dao_server = mock_dao.
    cut->dao_server->save( mock_server ).

    cut->initialize_dao_and_server( ).

    cl_abap_unit_assert=>assert_bound( cut->dao_document ).
    cl_abap_unit_assert=>assert_bound( cut->dao_dfe_cfg ).
    cl_abap_unit_assert=>assert_not_initial( cut->dfe_cfg_list ).

    cl_abap_unit_assert=>assert_bound( cut->dao_server ).
    cl_abap_unit_assert=>assert_bound( cut->server ).

    cl_abap_unit_assert=>assert_not_initial( cut->defaults ).
    cl_abap_unit_assert=>assert_not_initial( cut->dao ).
    cl_abap_unit_assert=>assert_not_initial( cut->dao_document ).
  ENDMETHOD.

  METHOD test_read_dfe_cfg_list.
    DATA: mock_dfe_cfg_list TYPE /s4tax/document_config_t,
          mock_dfe_cfg_l    TYPE REF TO /s4tax/document_config.

    cut->read_dfe_cfg_list( ).
    cl_abap_unit_assert=>assert_initial( cut->dfe_cfg_list ).

    DATA(exp_struct) = VALUE /s4tax/tdfe_cfg(
            mandt              = sy-mandt
            start_operation    = 'DFE_START_001'
            job_ex_type        = 'JOB_CFG_TYPE_A'
            status_update_time = '20250423103045'
            grc_destination    = 'GRC_RFC_DEST1' ).

    CREATE OBJECT mock_dfe_cfg_l EXPORTING iw_struct = exp_struct.

    APPEND mock_dfe_cfg_l TO mock_dfe_cfg_list.
    cut->dfe_cfg_list = mock_dfe_cfg_list.

    cut->read_dfe_cfg_list( ).

    cl_abap_unit_assert=>assert_bound( cut->dfe_cfg ).
    cl_abap_unit_assert=>assert_equals( act = cut->dfe_cfg->get_start_operation( )    exp = exp_struct-start_operation    ).
    cl_abap_unit_assert=>assert_equals( act = cut->dfe_cfg->get_job_ex_type( )        exp = exp_struct-job_ex_type        ).
    cl_abap_unit_assert=>assert_equals( act = cut->dfe_cfg->get_status_update_time( ) exp = exp_struct-status_update_time ).
  ENDMETHOD.

  METHOD test_timestamp_cfg.
    cl_abap_unit_assert=>assert_initial( cut->today_date ).
    cl_abap_unit_assert=>assert_initial( cut->timestamp_now ).
    cl_abap_unit_assert=>assert_initial( cut->status_update_time ).
    cl_abap_unit_assert=>assert_initial( cut->contingency_date ).
    cl_abap_unit_assert=>assert_initial( cut->timestamp_server ).

    CREATE: OBJECT cut->dfe_cfg, OBJECT cut->server.
    cut->dfe_cfg->set_status_update_time( '130726' ).
    cut->server->set_contingency_date( '20260425113422' ).

    cut->timestamp_cfg( ).

    cl_abap_unit_assert=>assert_not_initial( cut->today_date ).
    cl_abap_unit_assert=>assert_not_initial( cut->timestamp_now ).
    cl_abap_unit_assert=>assert_not_initial( cut->status_update_time ).
    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).
    cl_abap_unit_assert=>assert_not_initial( cut->timestamp_server ).
  ENDMETHOD.

  METHOD test_nfe_active_server.
    CREATE OBJECT cut->server.
    cut->server->set_active_server( 'SVC' ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_nfe_t ) exp = 0 ).


    CLEAR: cut->server_check_nfe-svc_rs_active, cut->server_check_nfe-svc_sp_active, cut->server_check_nfe-svc_active.
    cut->server->set_authorizer( 'SVC-RS' ).
    cut->nfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_rs_active exp = 'X' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_sp_active exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_active    exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_nfe_t ) exp = 1 ).


    CLEAR: cut->server_check_nfe-svc_rs_active, cut->server_check_nfe-svc_sp_active, cut->server_check_nfe-svc_active.
    cut->server->set_authorizer( 'SVC-SP' ).
    cut->nfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_rs_active exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_sp_active exp = 'X' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_active    exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_nfe_t ) exp = 2 ).


    CLEAR: cut->server_check_nfe-svc_rs_active, cut->server_check_nfe-svc_sp_active, cut->server_check_nfe-svc_active.
    cut->server->set_authorizer( 'SVC-AN' ).
    cut->nfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_rs_active exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_sp_active exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_active    exp = 'X' ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_nfe_t ) exp = 3 ).


    CLEAR: cut->server_check_nfe-svc_rs_active, cut->server_check_nfe-svc_sp_active, cut->server_check_nfe-svc_active.
    cut->server->set_active_server( 'MAIN' ).
    cut->nfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_rs_active exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_sp_active exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_active    exp = ' ' ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_nfe_t ) exp = 4 ).


    cut->server->set_contingency_date( '24042025' ).
    cl_abap_unit_assert=>assert_initial( act = cut->server_check_nfe-checktmpl ).
    cut->nfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-checktmpl exp = '24042025').
  ENDMETHOD.

  METHOD test_dfe_active_server.
    CREATE: OBJECT cut->server, OBJECT cut->branch_address.
    cut->server->set_active_server( 'SVC' ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_dfe_t ) exp = 0 ).


    CLEAR: cut->server_check_dfe-active_service.
    cut->branch_address->set_regio( 'AP' ).
    cut->dfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-active_service exp = /s4tax/dfe_constants=>svc_code_sap-rs ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_dfe_t ) exp = 1 ).


    CLEAR: cut->server_check_dfe-active_service.
    cut->branch_address->set_regio( 'BR' ).
    cut->dfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-active_service exp = /s4tax/dfe_constants=>svc_code_sap-sp ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_dfe_t ) exp = 2 ).


    CLEAR: cut->server_check_dfe-active_service.
    cut->server->set_active_server( 'MAIN' ).
    cut->branch_address->set_regio( 'SP' ).
    cut->dfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-active_service exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->server_check_dfe_t ) exp = 3 ).


    cut->server->set_contingency_date( '24042025' ).
    cl_abap_unit_assert=>assert_initial( act = cut->server_check_dfe-checktmpl ).
    cut->dfe_active_server( ).
    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-checktmpl exp = '24042025').
  ENDMETHOD.

  METHOD test_nfe_integration.

    cl_abap_unit_assert=>assert_initial( cut->server_check_nfe ).
    cl_abap_unit_assert=>assert_initial( cut->ls_set_cont ).
    cl_abap_unit_assert=>assert_initial( cut->contingency_date ).

    cut->dao = /s4tax/defaults=>get_default_instance( )->get_dao( ).
    cut->dao_document = /s4tax/dao_document=>get_instance( ).

    cut->branch_info-model = '55'.
    cut->nfe_integration( ).

*********** NÃO FUNCIONA O CÓDIGO ABAIXO POIS DFE_INTEGRATION É FINAL:
*    DATA double_dfe_intg TYPE REF TO /s4tax/dfe_integration.
*    double_dfe_intg ?= cl_abap_testdouble=>create( '/S4TAX/DFE_INTEGRATION' ).
*    cl_abap_testdouble=>configure_call( double_dfe_intg )->ignore_all_parameters( ).")->set_parameter( name = 'es_set_cont' value = expected_set_cont ).
*    "double_dfe_intg->nfe_check_active_server(  ).
***********

    cl_abap_unit_assert=>fail( msg   = 'test_nfe_integration Needs implementation'
                               level = if_abap_unit_constant=>severity-low ).
*    cl_abap_unit_assert=>assert_not_initial( cut->server_check_nfe ).
*    cl_abap_unit_assert=>assert_not_initial( cut->ls_set_cont ).
*    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).

  ENDMETHOD.

  METHOD test_dfe_integration.

    cl_abap_unit_assert=>assert_initial( cut->server_check_nfe ).
    cl_abap_unit_assert=>assert_initial( cut->ls_set_cont ).

    cut->dao = /s4tax/defaults=>get_default_instance( )->get_dao( ).
    cut->dao_document = /s4tax/dao_document=>get_instance( ).

    cut->branch_info-model = '57'.
    cut->dfe_integration( ).

    cl_abap_unit_assert=>fail( msg   = 'test_dfe_integration Needs implementation'
                               level = if_abap_unit_constant=>severity-low ).
*    cl_abap_unit_assert=>assert_not_initial( cut->server_check_nfe ).
*    cl_abap_unit_assert=>assert_not_initial( cut->ls_set_cont ).
*    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).

  ENDMETHOD.

  METHOD test_main.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
*    cut->main( EXPORTING is_branch_info     = mock_branch_info
*               IMPORTING server_check_nfe_t = server_check_nfe_t ).
*    cl_abap_unit_assert=>assert_not_initial( server_check_nfe_t ).
*
*    branch_info-model = '57'.
*    cut->main( EXPORTING is_branch_info     = mock_branch_info
*               IMPORTING server_check_dfe_t = server_check_dfe_t ).
*    cl_abap_unit_assert=>assert_not_initial( server_check_dfe_t ).
  ENDMETHOD.

ENDCLASS.