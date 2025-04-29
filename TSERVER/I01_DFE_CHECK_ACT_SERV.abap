*&---------------------------------------------------------------------*
*& Include /S4TAX/I01_DFE_CHECK_ACT_SERV
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
server_check            TYPE j_1bdfe_server_check,
branch_address          TYPE REF TO /s4tax/address,
dfe_std                 TYPE REF TO /s4tax/dfe_std,
cte_integration         TYPE REF TO /s4tax/cte_integration,
dfe_cfg                 TYPE REF TO /s4tax/document_config,
dfe_cfg_list            TYPE /s4tax/document_config_t,
dao_dfe_cfg             TYPE REF TO /s4tax/idao_dfe_cfg,
dao_pack_doc            TYPE REF TO /s4tax/idao_document,
timestamp_now           TYPE /s4tax/tserver-contingency_date,
timestamp_server        TYPE /s4tax/tserver-contingency_date,
today_date              TYPE REF TO /s4tax/date,
dao_server              TYPE REF TO /s4tax/idao_server,
server                  TYPE REF TO /s4tax/server,
status_update_time      TYPE /s4tax/update_time,
contingency_date        TYPE /s4tax/e_last_status.

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

dfe_std->j_1b_nfe_contingency_read( EXPORTING land1       = branch_address->struct-land1
                                        regio       = branch_address->struct-regio
                                        bukrs       = is_branch_info-bukrs
                                        branch      = is_branch_info-branch
                                        model       = is_branch_info-model
                                        contin_type = '2'
                              IMPORTING es_set_cont = ls_set_cont ).

server_check-cnpj    = iv_branch_cnpj.
server_check-version = cust3-version.
server_check-tpamb   = cust3-tpamb.
server_check-model   = is_branch_info-model.

date = /s4tax/date=>create_utc_now( ).
date = date->to_timezone( sy-zonlo ).
server_check-checktmpl      = date->to_timestamp( ).
server_check-active_service = /s4tax/dfe_constants=>svc_code_sap-sefaz.

dao_pack_doc = /s4tax/dao_document=>get_instance(  ).
dao_dfe_cfg = dao_pack_doc->dfe_cfg(  ).
dao_server = /s4tax/dao_server=>get_instance( ).
server = dao_server->get_by_regio_and_model( regio = branch_address->struct-regio model = is_branch_info-model ).
dfe_cfg_list = dao_dfe_cfg->get_all( ).

IF ls_set_cont IS NOT INITIAL AND dfe_cfg_list IS NOT INITIAL.

READ TABLE dfe_cfg_list INTO dfe_cfg INDEX 1.

IF dfe_cfg IS NOT BOUND.
EXIT.
ENDIF.

CREATE OBJECT today_date EXPORTING date = sy-datum time = sy-timlo.
timestamp_now = today_date->to_timestamp( ).

IF server IS BOUND.
status_update_time = dfe_cfg->get_status_update_time( ).
contingency_date = server->get_contingency_date( ).
timestamp_server = today_date->to_time_timestamp( time = status_update_time timestamp = contingency_date ).

IF timestamp_now <= timestamp_server.

IF server->struct-active_server = 'SVC'.
  CLEAR server_check-active_service.
  CASE  branch_address->struct-regio.
    WHEN 'AP' OR 'SP' OR 'MT' OR 'MS' OR 'PE' OR 'RR'.
      server_check-active_service  = /s4tax/dfe_constants=>svc_code_sap-rs.
    WHEN OTHERS.
      server_check-active_service  = /s4tax/dfe_constants=>svc_code_sap-sp.
  ENDCASE.
ENDIF.

server_check-checktmpl = server->struct-contingency_date.
APPEND server_check TO gt_server_check.

EXIT.
ENDIF.

ENDIF.

defaults      = /s4tax/defaults=>get_default_instance( ).
dao           = defaults->get_dao( ).
dao_document  = /s4tax/dao_document=>get_instance( ).

CREATE OBJECT cte_integration EXPORTING dao = dao dao_document = dao_document.
cte_integration->dfe_check_active_server( EXPORTING company_code            = is_branch_info-bukrs
                                                branch_code             = is_branch_info-branch
                                                regio                   = branch_address->struct-regio
                                                model                   = is_branch_info-model
                                      CHANGING  server_status           = server_check
                                                dfe_contingency_control = ls_set_cont ).

ENDIF.

APPEND server_check TO gt_server_check.

EXIT.