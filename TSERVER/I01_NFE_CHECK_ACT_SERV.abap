*&---------------------------------------------------------------------*
*& Include /S4TAX/I01_NFE_CHECK_ACT_SERV
*&---------------------------------------------------------------------*
DATA: cust3                   TYPE j_1bnfe_cust3,
dao_document            TYPE REF TO /s4tax/idao_document,
dao                     TYPE REF TO /s4tax/idao,
dao_pack_model_business TYPE REF TO /s4tax/idao_pack_model_busines,
defaults                TYPE REF TO /s4tax/defaults,
ls_set_cont             TYPE j_1bnfe_contin,
date                    TYPE REF TO /s4tax/date,
branch                  TYPE REF TO /s4tax/branch,
dao_branch              TYPE REF TO /s4tax/idao_branch,
dal_branch              TYPE REF TO /s4tax/idal_branch,
server_check            TYPE j_1bnfe_server_check,
branch_address          TYPE REF TO /s4tax/address,
dfe_std                 TYPE REF TO /s4tax/dfe_std,
dfe_integration         TYPE REF TO /s4tax/dfe_integration,
dfe_cfg                 TYPE REF TO /s4tax/document_config,
dfe_cfg_list            TYPE /s4tax/document_config_t,
dao_dfe_cfg             TYPE REF TO /s4tax/idao_dfe_cfg,
dao_pack_doc            TYPE REF TO /s4tax/idao_document,
timestamp_now           TYPE /s4tax/tserver-contingency_date,
timestamp_server        TYPE /s4tax/tserver-contingency_date,
today_date              TYPE REF TO /s4tax/date,
dao_server              TYPE REF TO /s4tax/idao_server,
server                  TYPE REF TO /s4tax/server,
contingency_date        TYPE /s4tax/e_last_status,
last_update_sefaz       TYPE timestamp.

CREATE OBJECT dao_server TYPE /s4tax/dao_server.

dao_pack_doc = /s4tax/dao_document=>get_instance(  ).
dao_dfe_cfg = dao_pack_doc->dfe_cfg(  ).
dfe_cfg_list = dao_dfe_cfg->get_all( ).
server = dao_server->get(  ).

IF dfe_cfg_list IS INITIAL.
EXIT.
ENDIF.

READ TABLE dfe_cfg_list INTO dfe_cfg INDEX 1.

IF sy-subrc <> 0.
RETURN.
ENDIF.

dfe_std = /s4tax/dfe_std=>get_instance( ).
dfe_std->j_1bnfe_cust3_read( EXPORTING bukrs  = is_branch_info-bukrs
                                 branch = is_branch_info-branch
                                 model  = is_branch_info-model
                       IMPORTING cust3  = cust3 ).

* Check is not executed in following cases: 1) when no entry exists in customizing  2) automatic server determination is not active in customizing
IF cust3 IS INITIAL OR cust3-autoserver IS INITIAL.
EXIT.
ENDIF.

dao_pack_model_business = /s4tax/dao_pack_model_business=>default_instance( ).
dao_branch = dao_pack_model_business->branch( ).
branch = dao_branch->get( company_code = is_branch_info-bukrs
                    branch_code  = is_branch_info-branch ).

IF branch IS NOT BOUND.
EXIT.
ENDIF.

dal_branch = dao_pack_model_business->branch_dal( ).
dal_branch->fill_branch_data( branch ).
branch_address = branch->get_address( ).

IF branch_address IS NOT BOUND.
EXIT.
ENDIF.

dfe_std->j_1b_nfe_contin_table_read( EXPORTING land1       = branch_address->struct-land1
                                         regio       = branch_address->struct-regio
                                         bukrs       = is_branch_info-bukrs
                                         branch      = is_branch_info-branch
                                         model       = is_branch_info-model
                                         contin_type = '2'
                               IMPORTING es_contin   = ls_set_cont ).

server_check-regio = is_branch_info-regio.
server_check-tpamb = cust3-tpamb.
server_check-sefaz_active = 'X'.

date = /s4tax/date=>create_utc_now( ).
date = date->to_timezone( sy-zonlo ).
server_check-checktmpl = date->to_timestamp( ).
server_check-version   = cust3-version.

IF ls_set_cont IS NOT INITIAL.

CREATE OBJECT today_date EXPORTING date = sy-datum time = sy-timlo.
timestamp_now = today_date->to_timestamp( ).
last_update_sefaz = server->struct-contingency_date.
timestamp_server = today_date->to_time_timestamp( time = dfe_cfg->struct-status_update_time timestamp = last_update_sefaz ).

IF timestamp_now <= timestamp_server AND server->struct-regio = branch_address->struct-regio AND server IS BOUND.

IF server->struct-active_server = 'SVC'.

CLEAR server_check-sefaz_active.

CASE server->struct-authorizer.
  WHEN /s4tax/dfe_constants=>svc_provider-rs.
    server_check-svc_rs_active = abap_true.

  WHEN /s4tax/dfe_constants=>svc_provider-sp.
    server_check-svc_sp_active = abap_true.

  WHEN /s4tax/dfe_constants=>svc_provider-national.
    server_check-svc_active = abap_true.

  WHEN OTHERS.
ENDCASE.

ENDIF.

server_check-checktmpl = server->struct-contingency_date.
APPEND server_check TO gt_active_server.

EXIT.
ENDIF.

defaults      = /s4tax/defaults=>get_default_instance( ).
dao           = defaults->get_dao( ).
dao_document  = /s4tax/dao_document=>get_instance( ).

CREATE OBJECT dfe_integration EXPORTING dao = dao dao_document = dao_document.
dfe_integration->nfe_check_active_server( EXPORTING company_code            = is_branch_info-bukrs
                                                branch_code             = is_branch_info-branch
                                      CHANGING  server_status           = server_check
                                                nfe_contingency_control = ls_set_cont
                                                contingency_date        = contingency_date ).

server->set_contingency_date( contingency_date ).
server->set_regio( branch_address->struct-regio ).
dao_dfe_cfg->save( dfe_cfg ).

ENDIF.

APPEND server_check TO gt_active_server.

EXIT.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CÓDIGO MAIN ADAPTADO DO /s4tax/contingency_integration
" OBS: A IDEIA É QUE O CÓDIGO ABAIXO SUBSTITUA TODO O CÓDIGO ACIMA
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

*  DATA: ctg_int            TYPE REF TO /s4tax/contingency_integration,
*        server_check_nfe_t TYPE TABLE OF j_1bnfe_server_check.
*
*  CREATE OBJECT ctg_int.
*
*  dao_server = /s4tax/dao_server=>get_instance(  ).
*  server = dao_server->get(  ).
*
*  ctg_int->initialize_dao( ).
*  ctg_int->load_branch_information( is_branch_info ).
*  ctg_int->contingency_read( is_branch_info ).
*
*  ctg_int->nfe_server_check( is_branch_info ).
*
*  ctg_int->read_dfe_cfg_list( ).
*  IF ls_set_cont IS NOT INITIAL AND dfe_cfg IS BOUND.
*
*    ctg_int->timestamp_cfg( ).
*
*    IF timestamp_now <= timestamp_server AND server->struct-regio = branch_address->struct-regio AND server IS BOUND.
*      ctg_int->nfe_active_server( CHANGING server_check_nfe_t = server_check_nfe_t ).
*      EXIT.
*    ENDIF.
*
*    defaults      = /s4tax/defaults=>get_default_instance( ).
*    dao           = defaults->get_dao( ).
*    dao_document  = /s4tax/dao_document=>get_instance( ).
*
*    ctg_int->nfe_integration( is_branch_info ).
*
*    server->set_contingency_date( contingency_date ).
*    server->set_regio( branch_address->struct-regio ).
*
*  ENDIF.
*
*  APPEND ctg_int->server_check_nfe TO server_check_nfe_t.
*
*  EXIT.