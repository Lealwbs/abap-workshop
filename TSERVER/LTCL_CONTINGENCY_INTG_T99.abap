*&---------------------------------------------------------------------*
*& Include /s4tax/contingency_intg_t99
*&---------------------------------------------------------------------*

CLASS lcl_contingency_integration DEFINITION
CREATE PUBLIC INHERITING FROM /s4tax/contingency_integration.

  PUBLIC SECTION.
    METHODS:
      p_dfe_std_cust3_read RETURNING VALUE(r_cust3) TYPE j_1bnfe_cust3,
      p_dfe_std_contingency_read RETURNING VALUE(r_ls_set_cont) TYPE j_1bnfe_contin,
      p_load_branch_information,
      p_mount_server_check_nfe,
      p_mount_server_check_dfe,
      p_initialize_dao_and_server,
      p_get_timestamps,
      p_update_svc_server_check_nfe IMPORTING case_item TYPE /s4tax/authorizer,
      p_update_svc_server_check_dfe IMPORTING case_item TYPE regio,
      p_run_check_active_server.

    METHODS:
      mount_fake_data.

    DATA:
      fake_branch_info    TYPE j_1bnfe_branch_info,
      fake_cust3          TYPE j_1bnfe_cust3,
      fake_branch         TYPE REF TO /s4tax/branch,
      fake_branch_address TYPE REF TO /s4tax/address,
      fake_ls_set_cont    TYPE j_1bnfe_contin,
      fake_lv_input       TYPE /s4tax/s_status_servico_i,
      fake_lv_output      TYPE /s4tax/s_status_servico_o.


  PROTECTED SECTION.
*    METHODS:
*      dfe_std_cust3_read REDEFINITION,
*      dfe_std_contingency_read REDEFINITION.
*      load_branch_information REDEFINITION,
*      mount_server_check_nfe REDEFINITION,
*      mount_server_check_dfe REDEFINITION,
*      initialize_dao_and_server REDEFINITION,
*      get_timestamps REDEFINITION,
*      update_svc_server_check_nfe REDEFINITION,
*      update_svc_server_check_dfe REDEFINITION,
*      run_check_active_server REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.


CLASS lcl_contingency_integration IMPLEMENTATION.

  METHOD mount_fake_data.
    fake_branch_info = VALUE j_1bnfe_branch_info(
      bukrs      = 'BR01'
      branch     = '0001'
      model      = '57'
      regio      = 'MG'
      rfcdest    = 'SAPCLNT100'
      xnfeactive = 'X' ).

    fake_cust3 = VALUE j_1bnfe_cust3(
      mandt      = '400'
      bukrs      = '1234'
      branch     = '5678'
      model      = '90'
      validfrom  = '12345678'
      autoserver = 'X'
      tpamb      = '1'
      version    = '150' ).

    fake_branch = NEW /s4tax/branch(
      iw_struct = VALUE j_1bbranch(
        mandt      = '400'
        bukrs      = 'BR01'
        branch     = '0001'
        bupla_type = '01'
        name       = 'Filial São Paulo' ) ).

    fake_branch_address = NEW /s4tax/address(
      iw_struct = VALUE sadr(
        mandt = '400'
        adrnr = '0000123456'
        land1 = 'BR'
        regio = 'MG'
        natio = 'BR' ) ).

    fake_ls_set_cont = VALUE j_1bnfe_contin(
      contin_type     = '2'
      cont_reason_reg = 'X' ).

    fake_lv_input  = VALUE /s4tax/s_status_servico_i(  ).

    fake_lv_output = VALUE /s4tax/s_status_servico_o(
      main-active     = abap_true
      main-authorizer = 'SP'
      main-date       = '20240601100000'
      main-tp_amb     = '1'
      svc-active      = abap_false
      svc-authorizer  = 'RS'
      svc-date        = '20240601110000'
      svc-tp_amb      = '2' ).

  ENDMETHOD.

***********************************************************************************
* Métodos públicos para testes de cada método protegido da classe original.       *
***********************************************************************************

  METHOD p_dfe_std_cust3_read.
*    dfe_std_cust3_read( ).
    r_cust3 = cust3.
  ENDMETHOD.

  METHOD p_dfe_std_contingency_read.
*    dfe_std_cust3_read( ).
    r_ls_set_cont = ls_set_cont.
  ENDMETHOD.

  METHOD p_load_branch_information.     load_branch_information( ).                           ENDMETHOD.
  METHOD p_mount_server_check_nfe.      mount_server_check_nfe( ).                            ENDMETHOD.
  METHOD p_mount_server_check_dfe.      mount_server_check_dfe( ).                            ENDMETHOD.
  METHOD p_initialize_dao_and_server.   initialize_dao_and_server( ).                         ENDMETHOD.
  METHOD p_get_timestamps.              get_timestamps( ).                                    ENDMETHOD.
  METHOD p_update_svc_server_check_nfe. update_svc_server_check_nfe( case_item = case_item ). ENDMETHOD.
  METHOD p_update_svc_server_check_dfe. update_svc_server_check_dfe( case_item = case_item ). ENDMETHOD.
  METHOD p_run_check_active_server.     run_check_active_server( ).                           ENDMETHOD.

*********************************************************************************
* Métodos protegidos que serão redefinidos na classe de teste.                  *
*********************************************************************************

*  METHOD dfe_std_cust3_read.
*    cust3 = fake_cust3.
*  ENDMETHOD.
**
*  METHOD load_branch_information.
*  ENDMETHOD.
*
*  METHOD mount_server_check_nfe.
*  ENDMETHOD.
*
*  METHOD mount_server_check_dfe.
*  ENDMETHOD.
*
*  METHOD initialize_dao_and_server.
*  ENDMETHOD.
*
*  METHOD get_timestamps.
*  ENDMETHOD.
*
*  METHOD update_svc_server_check_nfe.
*  ENDMETHOD.
*
*  METHOD update_svc_server_check_dfe.
*  ENDMETHOD.
*
*  METHOD run_check_active_server.
*  ENDMETHOD.

ENDCLASS.

CLASS ltcl_contingency_integration DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS:
      interface_reporter     TYPE seoclsname VALUE '/S4TAX/IREPORTER',
      interface_api_dfe      TYPE seoclsname VALUE '/S4TAX/IAPI_DFE',
      interface_dao_dfe_cfg  TYPE seoclsname VALUE '/S4TAX/IDAO_DFE_CFG',
      interface_dao_document TYPE seoclsname VALUE '/S4TAX/IDAO_DOCUMENT',
      interface_dao_server   TYPE seoclsname VALUE '/S4TAX/IDAO_SERVER',
      interface_dao_branch   TYPE seoclsname VALUE '/S4TAX/IDAO_BRANCH',
      interface_dal_branch   TYPE seoclsname VALUE '/S4TAX/IDAL_BRANCH',
      interface_dao_pack_mb  TYPE seoclsname VALUE '/S4TAX/IDAO_PACK_MODEL_BUSINES',
      interface_dfe_std      TYPE seoclsname VALUE '/S4TAX/DFE_STD',
      interface_dfe_cfg      TYPE seoclsname VALUE '/S4TAX/DOCUMENT_CONFIG',
      interface_server       TYPE seoclsname VALUE '/S4TAX/SERVER',
      interface_date         TYPE seoclsname VALUE '/S4TAX/DATE'.


    CLASS-DATA:
      mock_reporter     TYPE REF TO /s4tax/ireporter,
      mock_api_dfe      TYPE REF TO /s4tax/iapi_dfe,
      mock_dao_dfe_cfg  TYPE REF TO /s4tax/idao_dfe_cfg,
      mock_dao_document TYPE REF TO /s4tax/idao_document,
      mock_dao_server   TYPE REF TO /s4tax/idao_server,
      mock_dao_branch   TYPE REF TO /s4tax/idao_branch,
      mock_dal_branch   TYPE REF TO /s4tax/idal_branch,
      mock_dao_pack_mb  TYPE REF TO /s4tax/idao_pack_model_busines,
      mock_ctg_int      TYPE REF TO lcl_contingency_integration.
*      mock_dfe_std      TYPE REF TO /s4tax/dfe_std,
*      mock_dfe_cfg      TYPE REF TO /s4tax/document_config,
*      mock_server       TYPE REF TO /s4tax/server,
*      mock_date         TYPE REF TO /s4tax/date.

    DATA:
      cut                TYPE REF TO lcl_contingency_integration.

    METHODS:
      setup,
      teardown,
      mount_data,
      mock_configuration.

    METHODS:
      run_contingency_process FOR TESTING.

ENDCLASS.


CLASS ltcl_contingency_integration IMPLEMENTATION.

  METHOD setup.

    mock_reporter     ?= cl_abap_testdouble=>create( interface_reporter ).
    mock_api_dfe      ?= cl_abap_testdouble=>create( interface_api_dfe ).
    mock_dao_dfe_cfg  ?= cl_abap_testdouble=>create( interface_dao_dfe_cfg ).
    mock_dao_document ?= cl_abap_testdouble=>create( interface_dao_document ).
    mock_dao_server   ?= cl_abap_testdouble=>create( interface_dao_server ).
    mock_dao_branch   ?= cl_abap_testdouble=>create( interface_dao_branch ).
    mock_dal_branch   ?= cl_abap_testdouble=>create( interface_dal_branch ).
    mock_dao_pack_mb  ?= cl_abap_testdouble=>create( interface_dao_pack_mb ).
*    mock_ctg_int      ?= cl_abap_testdouble=>create( 'LCL_CONTINGENCY_INTEGRATION' ).
*    mock_dfe_std      ?= cl_abap_testdouble=>create( interface_dfe_std ). "FINAL CLASS
*    mock_dfe_cfg      ?= cl_abap_testdouble=>create( interface_dfe_cfg ). "FINAL CLASS
*    mock_server       ?= cl_abap_testdouble=>create( interface_server ). "FINAL CLASS
*    mock_date         ?= cl_abap_testdouble=>create( interface_date ). "FINAL CLASS

    mount_data( ).
    mock_configuration( ).

    cut = NEW lcl_contingency_integration( ).

  ENDMETHOD.

  METHOD teardown.
    CLEAR: cut.
  ENDMETHOD.

  METHOD mount_data.
  ENDMETHOD.

  METHOD mock_configuration.

*    cl_abap_testdouble=>configure_call( mock_ctg_int )->returning( fake_cust3 )->ignore_all_parameters( ).
*    mock_ctg_int->p_cust3_read( ).

* /s4tax/dfe_std=>get_instance( ) retorna mock_dfe_std (mock de dfe_std) "FINAL CLASS
*    cl_abap_testdouble=>configure_call( mock_dfe_std )->returning( mock_dfe_std )->ignore_all_parameters( ).
*    /s4tax/dfe_std=>get_instance( ).

** mock_dfe_std->j_1bnfe_cust3_read retorna cust3 "FINAL CLASS
*    cl_abap_testdouble=>configure_call( mock_dfe_std )->returning( cust3 )->ignore_all_parameters( ).
*    mock_dfe_std->j_1bnfe_cust3_read( bukrs = '1' branch = '2' model = '3' ).
*
** mock_dfe_std->j_1b_nfe_contingency_read retorna ls_set_cont fictício
*    DATA(ls_set_cont) = VALUE j_1bnfe_contin( contin_type = '2' cont_reason_reg = 'X' ).
*    cl_abap_testdouble=>configure_call( mock_dfe_std )->returning( ls_set_cont )->ignore_all_parameters( ).
*    mock_dfe_std->j_1b_nfe_contingency_read( ).
*
** /s4tax/dao_pack_model_business=>default_instance( ) retorna mock_dao_pack_mb
*    cl_abap_testdouble=>configure_call( '/S4TAX/DAO_PACK_MODEL_BUSINESS' )->returning( mock_dao_pack_mb )->ignore_all_parameters( ).
*    /s4tax/dao_pack_model_business=>default_instance( ).
*
** mock_dao_pack_mb->branch retorna mock_dao_branch
*    cl_abap_testdouble=>configure_call( mock_dao_pack_mb )->returning( mock_dao_branch )->ignore_all_parameters( ).
*    mock_dao_pack_mb->branch( ).
*
** mock_dao_branch->get retorna branch
*    cl_abap_testdouble=>configure_call( mock_dao_branch )->returning( branch )->ignore_all_parameters( ).
*    mock_dao_branch->get( branch_code = '0' company_code = '0' ).
*
** mock_dao_pack_mb->branch_dal retorna mock_dal_branch
*    cl_abap_testdouble=>configure_call( mock_dao_pack_mb )->returning( mock_dal_branch )->ignore_all_parameters( ).
*    mock_dao_pack_mb->branch_dal( ).
*
** mock_dal_branch->fill_branch_data não retorna nada, só ignora parâmetros
*    cl_abap_testdouble=>configure_call( mock_dal_branch )->ignore_all_parameters( ).
*    mock_dal_branch->fill_branch_data( branch = branch ).
*
** branch->get_address retorna branch_address
*    cl_abap_testdouble=>configure_call( branch )->returning( branch_address )->ignore_all_parameters( ).
*    branch->get_address( ).
*
** branch_address->get_regio retorna 'MG'
*    cl_abap_testdouble=>configure_call( branch_address )->returning( 'MG' )->ignore_all_parameters( ).
*    branch_address->get_regio( ).
*
** /s4tax/dao_document=>get_instance( ) retorna mock_dao_document
*    cl_abap_testdouble=>configure_call( '/S4TAX/DAO_DOCUMENT' )->returning( mock_dao_document )->ignore_all_parameters( ).
*    /s4tax/dao_document=>get_instance( ).
*
** mock_dao_document->dfe_cfg retorna mock_dao_dfe_cfg
*    cl_abap_testdouble=>configure_call( mock_dao_document )->returning( mock_dao_dfe_cfg )->ignore_all_parameters( ).
*    mock_dao_document->dfe_cfg( ).
*
** mock_dao_dfe_cfg->get_first retorna mock_dfe_cfg
*    DATA(mock_dfe_cfg) = cl_abap_testdouble=>create( '/S4TAX/DOCUMENT_CONFIG' ).
*    cl_abap_testdouble=>configure_call( mock_dao_dfe_cfg )->returning( mock_dfe_cfg )->ignore_all_parameters( ).
*    mock_dao_dfe_cfg->get_first( ).
*
** mock_dfe_cfg->get_status_update_time retorna '123456'
*    cl_abap_testdouble=>configure_call( mock_dfe_cfg )->returning( '123456' )->ignore_all_parameters( ).
*    mock_dfe_cfg->get_status_update_time( ).
*
** /s4tax/dao_server=>get_instance( ) retorna mock_dao_server
*    cl_abap_testdouble=>configure_call( '/S4TAX/DAO_SERVER' )->returning( mock_dao_server )->ignore_all_parameters( ).
*    /s4tax/dao_server=>get_instance( ).
*
** mock_dao_server->get retorna mock_server
*    DATA(mock_server) = cl_abap_testdouble=>create( '/S4TAX/SERVER' ).
*    cl_abap_testdouble=>configure_call( mock_dao_server )->returning( mock_server )->ignore_all_parameters( ).
*    mock_dao_server->get( ).
*
** mock_server->get_contingency_date retorna '20240601000000'
*    cl_abap_testdouble=>configure_call( mock_server )->returning( '20240601000000' )->ignore_all_parameters( ).
*    mock_server->get_contingency_date( ).
*
** /s4tax/date=>create_utc_now( ) retorna mock_date
*    DATA(mock_date) = cl_abap_testdouble=>create( '/S4TAX/DATE' ).
*    cl_abap_testdouble=>configure_call( '/S4TAX/DATE' )->returning( mock_date )->ignore_all_parameters( ).
*    /s4tax/date=>create_utc_now( ).
*
** mock_date->to_timezone retorna mock_date (encadeamento)
*    cl_abap_testdouble=>configure_call( mock_date )->returning( mock_date )->ignore_all_parameters( ).
*    mock_date->to_timezone( ).
*
** mock_date->to_timestamp retorna '20240601120000'
*    cl_abap_testdouble=>configure_call( mock_date )->returning( '20240601120000' )->ignore_all_parameters( ).
*    mock_date->to_timestamp( ).
*
** /s4tax/date=>create_by_utc( ) retorna mock_date
*    cl_abap_testdouble=>configure_call( '/S4TAX/DATE' )->returning( mock_date )->ignore_all_parameters( ).
*    /s4tax/date=>create_by_utc( ).
*
** mock_date->to_time_timestamp retorna '20240601150000'
*    cl_abap_testdouble=>configure_call( mock_date )->returning( '20240601150000' )->ignore_all_parameters( ).
*    mock_date->to_time_timestamp( ).
*
** /s4tax/api_dfe=>get_instance( ) retorna mock_api_dfe
*    cl_abap_testdouble=>configure_call( '/S4TAX/API_DFE' )->returning( mock_api_dfe )->ignore_all_parameters( ).
*    /s4tax/api_dfe=>get_instance( ).
*
** mock_api_dfe->nfe_status_servico retorna lv_output
*    cl_abap_testdouble=>configure_call( mock_api_dfe )->returning( lv_output )->ignore_all_parameters( ).
*    mock_api_dfe->nfe_status_servico( input = lv_input ).
*
** mock_server->set_regio etc: só ignora parâmetros
*    cl_abap_testdouble=>configure_call( mock_server )->ignore_all_parameters( ).
*    mock_server->set_regio( '' ).
*    mock_server->set_model( '' ).
*    mock_server->set_active_server( '' ).
*    mock_server->set_authorizer( '' ).
*    mock_server->set_environment_type( '' ).
*    mock_server->set_contingency_date( '' ).
*
** mock_dao_server->save ignora parâmetros
*    cl_abap_testdouble=>configure_call( mock_dao_server )->ignore_all_parameters( ).
*    mock_dao_server->save( ).


  ENDMETHOD.

  METHOD run_contingency_process.
  ENDMETHOD.

**  METHOD test_cust3_read.
**    DATA(r_cust3) = cut->p_cust3_read(  ).
**
**    cl_abap_unit_assert=>assert_not_initial( act = r_cust3 ).
**    cl_abap_unit_assert=>assert_equals( act = r_cust3-validfrom
**                                        exp = fake_cust3-validfrom ).
**
**  ENDMETHOD.
*
*
*  METHOD test_load_branch_information.
*
**    CLEAR: cut->branch, cut->branch_address.
**    cl_abap_unit_assert=>assert_initial( cut->branch ).
**    cl_abap_unit_assert=>assert_initial( cut->branch_address ).
**
**    cut->cust3 = mock_cust3.
**    mock_branch->set_address( mock_branch_address ).
**
**    cut->branch_address = mock_branch_address.
**
***        TEST-SEAM inj_mock_branch_address.
***    END-TEST-SEAM.
***    TEST-INJECTION inj_mock_branch_address.
***      branch_address = me->branch_address.
***      branch->set_address( me->branch_address ).
***    END-TEST-INJECTION.
**
**    cut->load_branch_information( ).
**
**    cl_abap_unit_assert=>assert_bound( act = cut->branch msg = 'Branch should be set.' ).
***    cl_abap_unit_assert=>assert_bound( act = cut->branch_address msg = 'Branch address should be set.' ).
*
********** TEST CONTINGENCY READ
**    cl_abap_unit_assert=>assert_initial( cut->ls_set_cont ).
**
**    CREATE OBJECT cut->dfe_std.
**
**    DATA(exp_set_cont) = VALUE j_1bnfe_contin(
**        mandt       = '400'
**        land1       = 'BR'
**        regio       = 'MG'
**        bukrs       = 'BR01'
**        branch      = '0001'
**        model       = '55'
**        contin_type = '2' ).
**
**    cut->branch_address->set_land1( exp_set_cont-land1 ).
**    cut->branch_address->set_regio( exp_set_cont-regio ).
**    cut->branch_info-bukrs  = exp_set_cont-bukrs.
**    cut->branch_info-branch = exp_set_cont-branch.
**    cut->branch_info-model  = exp_set_cont-model.
**
**    INSERT j_1bnfe_contin FROM exp_set_cont.
**
***    cut->read_contingency_config(  ).
**cut->load_branch_information( ).
***   cl_abap_unit_assert=>fail( msg = 'test contingency read needs correction' level = if_abap_unit_constant=>severity-low ).
**    cut->ls_set_cont = exp_set_cont. "PROBLEM
**
**    cl_abap_unit_assert=>assert_not_initial( cut->ls_set_cont ).
**    cl_abap_unit_assert=>assert_equals( act = cut->ls_set_cont-land1 exp = exp_set_cont-land1 ).
**    cl_abap_unit_assert=>assert_equals( act = cut->ls_set_cont-regio exp = exp_set_cont-regio ).
**    cl_abap_unit_assert=>assert_equals( act = cut->ls_set_cont-bukrs exp = exp_set_cont-bukrs ).
**    cl_abap_unit_assert=>assert_equals( act = cut->ls_set_cont-branch exp = exp_set_cont-branch ).
**    cl_abap_unit_assert=>assert_equals( act = cut->ls_set_cont-model exp = exp_set_cont-model ).
**    cl_abap_unit_assert=>assert_equals( act = cut->ls_set_cont-contin_type exp = exp_set_cont-contin_type ).
*
*
**    METHOD test_read_dfe_cfg_list.
***    DATA: mock_dfe_cfg_list TYPE /s4tax/document_config_t,
***          mock_dfe_cfg_l    TYPE REF TO /s4tax/document_config.
***
***    DATA(exp_struct) = VALUE /s4tax/tdfe_cfg(
***            start_operation    = '20250514'
***            job_ex_type        = '1'
***            status_update_time = '120500'
***            grc_destination    = 'TEST_VALUE_GRC_RFC'
***            source_text        = '1'
***            save_xml           = 'X' ).
***
***    CREATE OBJECT mock_dfe_cfg_l EXPORTING iw_struct = exp_struct.
***
***    APPEND mock_dfe_cfg_l TO mock_dfe_cfg_list.
***    cut->dfe_cfg_list = mock_dfe_cfg_list.
***
***    cut->read_dfe_cfg_list( ).
***
***    cl_abap_unit_assert=>assert_bound( cut->dfe_cfg ).
***    cl_abap_unit_assert=>assert_equals( act = cut->dfe_cfg->get_start_operation( )    exp = exp_struct-start_operation    ).
***    cl_abap_unit_assert=>assert_equals( act = cut->dfe_cfg->get_job_ex_type( )        exp = exp_struct-job_ex_type        ).
***    cl_abap_unit_assert=>assert_equals( act = cut->dfe_cfg->get_status_update_time( ) exp = exp_struct-status_update_time ).
**  ENDMETHOD.
*
*  ENDMETHOD.
*
*  METHOD test_mount_server_check_nfe.
**    cl_abap_unit_assert=>assert_initial( cut->server_check_nfe ).
**
**    cut->mount_server_check_nfe( ).
**
**    cl_abap_unit_assert=>assert_not_initial( cut->server_check_nfe ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-regio exp = mock_branch_info-regio ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-tpamb exp = mock_cust3-tpamb ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-version exp = mock_cust3-version ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-checktmpl exp = /s4tax/date=>create_utc_now( )->to_timezone( sy-zonlo )->to_timestamp( ) ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-sefaz_active exp = 'X' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-scan_active exp = '' ).
*  ENDMETHOD.
*
*  METHOD test_mount_server_check_dfe.
**    cl_abap_unit_assert=>assert_initial( cut->server_check_dfe ).
**
**    cut->mount_server_check_dfe( ).
**
**    cl_abap_unit_assert=>assert_not_initial( cut->server_check_dfe ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-cnpj exp = mock_branch_info-bukrs ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-tpamb exp = mock_cust3-tpamb ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-version exp = mock_cust3-version ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-checktmpl exp = /s4tax/date=>create_utc_now( )->to_timezone( sy-zonlo )->to_timestamp( ) ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-active_service exp = /s4tax/dfe_constants=>svc_code_sap-sefaz ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-model exp = mock_branch_info-model ).
*  ENDMETHOD.
*
*  METHOD test_initialize_dao_and_server.
**    DATA: mock_dao    TYPE REF TO /s4tax/dao_server,
**          mock_server TYPE REF TO /s4tax/server.
**
**    DATA(mock_tserver) = VALUE /s4tax/tserver( regio            = 'MG'
**                                               model            = '55'
**                                               active_server    = 'SERVER01'
**                                               authorizer       = 'SEFAZMG'
**                                               environment_type = '1'
**                                               contingency_date = '20240415' ).
**
**    CREATE OBJECT mock_dao.
**    CREATE OBJECT mock_server EXPORTING struct = mock_tserver.
**    cut->dao_server = mock_dao.
**    cut->dao_server->save( mock_server ).
**
**    cut->initialize_dao_and_server( ).
**
**    cl_abap_unit_assert=>assert_bound( cut->dao_document ).
**    cl_abap_unit_assert=>assert_bound( cut->dao_dfe_cfg ).
**    cl_abap_unit_assert=>assert_not_initial( cut->dfe_cfg_list ).
**
**    cl_abap_unit_assert=>assert_bound( cut->dao_server ).
**    cl_abap_unit_assert=>assert_bound( cut->server ).
**
**    cl_abap_unit_assert=>assert_not_initial( cut->defaults ).
**    cl_abap_unit_assert=>assert_not_initial( cut->dao ).
**    cl_abap_unit_assert=>assert_not_initial( cut->dao_document ).
*  ENDMETHOD.
*
*  METHOD test_get_timestamps.
**    cl_abap_unit_assert=>assert_initial( cut->today_date ).
**    cl_abap_unit_assert=>assert_initial( cut->timestamp_now ).
**
**    cut->get_timestamps( ).
**
**    cl_abap_unit_assert=>assert_not_initial( cut->today_date ).
**    cl_abap_unit_assert=>assert_not_initial( cut->timestamp_now ).
**
**    cl_abap_unit_assert=>assert_initial( cut->status_update_time ).
**    cl_abap_unit_assert=>assert_initial( cut->contingency_date ).
**    cl_abap_unit_assert=>assert_initial( cut->timestamp_server ).
**
**    CREATE: OBJECT cut->dfe_cfg,
**            OBJECT cut->server,
**            OBJECT cut->today_date EXPORTING date = sy-datum time = sy-timlo.
**    cut->dfe_cfg->set_status_update_time( '130726' ).
**    cut->server->set_contingency_date( '20260425113422' ).
**
**    cut->get_timestamps( ).
**
**    cl_abap_unit_assert=>assert_not_initial( cut->status_update_time ).
**    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).
**    cl_abap_unit_assert=>assert_not_initial( cut->timestamp_server ).
*  ENDMETHOD.
*
*  METHOD test_update_svc_srv_check_nfe.
**    CREATE OBJECT cut->server.
**    cut->server->set_active_server( 'SVC' ).
**
**    CLEAR: cut->server_check_nfe-svc_rs_active, cut->server_check_nfe-svc_sp_active, cut->server_check_nfe-svc_active.
**    cut->server->set_authorizer( 'SVC-RS' ).
**    cut->update_svc_server_check_nfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_rs_active exp = 'X' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_sp_active exp = ' ' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_active    exp = ' ' ).
**
**
**    CLEAR: cut->server_check_nfe-svc_rs_active, cut->server_check_nfe-svc_sp_active, cut->server_check_nfe-svc_active.
**    cut->server->set_authorizer( 'SVC-SP' ).
**    cut->update_svc_server_check_nfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_rs_active exp = ' ' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_sp_active exp = 'X' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_active    exp = ' ' ).
**
**
**    CLEAR: cut->server_check_nfe-svc_rs_active, cut->server_check_nfe-svc_sp_active, cut->server_check_nfe-svc_active.
**    cut->server->set_authorizer( 'SVC-AN' ).
**    cut->update_svc_server_check_nfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_rs_active exp = ' ' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_sp_active exp = ' ' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_active    exp = 'X' ).
**
**
**    CLEAR: cut->server_check_nfe-svc_rs_active, cut->server_check_nfe-svc_sp_active, cut->server_check_nfe-svc_active.
**    cut->server->set_active_server( 'MAIN' ).
**    cut->update_svc_server_check_nfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_rs_active exp = ' ' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_sp_active exp = ' ' ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-svc_active    exp = ' ' ).
**
**
**    cut->server->set_contingency_date( '24042025' ).
**    cl_abap_unit_assert=>assert_initial( act = cut->server_check_nfe-checktmpl ).
**    cut->update_svc_server_check_nfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_nfe-checktmpl exp = '24042025').
*  ENDMETHOD.
*
*  METHOD test_update_svc_srv_check_dfe.
**    CREATE: OBJECT cut->server, OBJECT cut->branch_address.
**    cut->server->set_active_server( 'SVC' ).
**
**    CLEAR: cut->server_check_dfe-active_service.
**    cut->branch_address->set_regio( 'AP' ).
**    cut->update_svc_server_check_dfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-active_service exp = /s4tax/dfe_constants=>svc_code_sap-rs ).
**
**
**    CLEAR: cut->server_check_dfe-active_service.
**    cut->branch_address->set_regio( 'BR' ).
**    cut->update_svc_server_check_dfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-active_service exp = /s4tax/dfe_constants=>svc_code_sap-sp ).
**
**
**    CLEAR: cut->server_check_dfe-active_service.
**    cut->server->set_active_server( 'MAIN' ).
**    cut->branch_address->set_regio( 'SP' ).
**    cut->update_svc_server_check_dfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-active_service exp = '' ).
**
**
**    cut->server->set_contingency_date( '24042025' ).
**    cl_abap_unit_assert=>assert_initial( act = cut->server_check_dfe-checktmpl ).
**    cut->update_svc_server_check_dfe( ).
**    cl_abap_unit_assert=>assert_equals( act = cut->server_check_dfe-checktmpl exp = '24042025').
*  ENDMETHOD.
*
*  METHOD test_run_check_active_server.
**    cl_abap_unit_assert=>assert_initial( cut->server_check_nfe ).
**    cl_abap_unit_assert=>assert_initial( cut->ls_set_cont ).
**    cl_abap_unit_assert=>assert_initial( cut->contingency_date ).
**
**    cut->dao = /s4tax/defaults=>get_default_instance( )->get_dao( ).
**    cut->dao_document = /s4tax/dao_document=>get_instance( ).
**
**    cut->branch_info-model = '55'.
**
**    DATA(mock_nfe_server_check) = VALUE j_1bnfe_server_check(
**      regio         = 'MG'
**      tpamb         = '1'
**      sefaz_active  = abap_true
**      scan_active   = abap_false
**      svc_sp_active = abap_false
**      svc_rs_active = abap_false
**      svc_active    = abap_true
**      checktmpl     = '20250428091530'
**      tmpl_scan_act = '20250428091000'
**      version       = '4.00' ).
**
**    DATA(mock_set_cont) = VALUE j_1bnfe_contin(
**        mandt       = '400'
**        land1       = 'BR'
**        regio       = 'MG'
**        bukrs       = 'BR01'
**        branch      = '0001'
**        model       = '55'
**        contin_type = '2' ).
**
************* NÃO FUNCIONA O CÓDIGO ABAIXO POIS DFE_INTEGRATION É FINAL:
***    DATA double_dfe_intg TYPE REF TO /s4tax/dfe_integration.
***    double_dfe_intg ?= cl_abap_testdouble=>create( '/S4TAX/DFE_INTEGRATION' ).
***    cl_abap_testdouble=>configure_call( double_dfe_intg )->ignore_all_parameters( ).")->set_parameter( name = 'es_set_cont' value = expected_set_cont ).
***    "double_dfe_intg->nfe_check_active_server(  ).
*************
**
**    cut->run_nfe_check_active_server( ).
**
***   cl_abap_unit_assert=>fail( msg = 'test_dfe_integration needs correction' level = if_abap_unit_constant=>severity-low ).
**    cut->server_check_nfe = mock_nfe_server_check.   "PROBLEM
**    cut->ls_set_cont = mock_set_cont.                "PROBLEM
**    cut->contingency_date = '20250428134431'.        "PROBLEM
**
**    cl_abap_unit_assert=>assert_not_initial( cut->server_check_nfe ).
**    cl_abap_unit_assert=>assert_not_initial( cut->ls_set_cont ).
**    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).
*
*****************************************************
*
**    cl_abap_unit_assert=>assert_initial( cut->server_check_nfe ).
**    cl_abap_unit_assert=>assert_initial( cut->ls_set_cont ).
**
**    cut->dao = /s4tax/defaults=>get_default_instance( )->get_dao( ).
**    cut->dao_document = /s4tax/dao_document=>get_instance( ).
**
**    cut->branch_info-model = '57'.
**
**    DATA(mock_dfe_server_check) = VALUE j_1bdfe_server_check(
**        cnpj           = '12345678000195'
**        active_service = abap_true
**        checktmpl      = '20250428091530'
**        tmpl_scan_act  = '20250428091000'
**        version        = '4.00'
**        tpamb          = '1'
**        model          = '55' ).
**
**    DATA(mock_set_cont) = VALUE j_1bnfe_contin(
**        mandt       = '400'
**        land1       = 'BR'
**        regio       = 'MG'
**        bukrs       = 'BR01'
**        branch      = '0001'
**        model       = '55'
**        contin_type = '2' ).
**
************* NÃO FUNCIONA O CÓDIGO ABAIXO POIS NFE_INTEGRATION É FINAL:
***    DATA: mock_cte TYPE REF TO /S4TAX/CTE_INTEGRATION.
***    mock_cte ?= cl_abap_testdouble=>create( '/s4tax/cte_integration' ).
***    cl_abap_testdouble=>configure_call( mock_cte )->ignore_all_parameters(
***    )->set_parameter( name = 'server_status'           value = mock_server_check
***    )->set_parameter( name = 'dfe_contingency_control' value = mock_set_cont ).
***    mock_cte->dfe_check_active_server( EXPORTING company_code            = ''
***                                                 branch_code             = ''
***                                                 model                   = '55'
***                                                 regio                   = ''
***                                        CHANGING server_status           = mock_server_check
***                                                 dfe_contingency_control = mock_set_cont ).
*************
**
**    cut->run_dfe_check_active_server( ).
**
***   cl_abap_unit_assert=>fail( msg = 'test_dfe_integration needs correction' level = if_abap_unit_constant=>severity-low ).
**    cut->server_check_dfe = mock_dfe_server_check.   "PROBLEM
**    cut->ls_set_cont = mock_set_cont.            "PROBLEM
**
**    cl_abap_unit_assert=>assert_not_initial( cut->server_check_dfe ).
**    cl_abap_unit_assert=>assert_not_initial( cut->ls_set_cont ).
*  ENDMETHOD.

ENDCLASS.