CLASS /s4tax/contingency_integration DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    DATA: cust3                   TYPE j_1bnfe_cust3,
          dao                     TYPE REF TO /s4tax/idao,
          dao_dfe_cfg             TYPE REF TO /s4tax/idao_dfe_cfg,
          dao_document            TYPE REF TO /s4tax/idao_document,
          dao_pack_model_business TYPE REF TO /s4tax/idao_pack_model_busines,
          dao_server              TYPE REF TO /s4tax/idao_server,
          dao_branch              TYPE REF TO /s4tax/idao_branch,
          dal_branch              TYPE REF TO /s4tax/idal_branch,
          defaults                TYPE REF TO /s4tax/defaults,
          ls_set_cont             TYPE j_1bnfe_contin,

          server                  TYPE REF TO /s4tax/server,
          server_check_nfe        TYPE j_1bnfe_server_check,
          server_check_dfe        TYPE j_1bdfe_server_check,

          branch                  TYPE REF TO /s4tax/branch,
          branch_address          TYPE REF TO /s4tax/address,
          dfe_std                 TYPE REF TO /s4tax/dfe_std,
          dfe_cfg                 TYPE REF TO /s4tax/document_config,
          dfe_cfg_list            TYPE /s4tax/document_config_t,

          date                    TYPE REF TO /s4tax/date,
          timestamp_now           TYPE /s4tax/tserver-contingency_date,
          timestamp_server        TYPE /s4tax/tserver-contingency_date,
          today_date              TYPE REF TO /s4tax/date,
          last_update_sefaz       TYPE timestamp,

          contingency_date        TYPE /s4tax/e_last_status.

    TYPES: tt_nfe_server_check TYPE TABLE OF j_1bnfe_server_check,
           tt_dfe_server_check TYPE TABLE OF j_1bdfe_server_check.

    METHODS: main  "NESSE CASO O MAIN ESTÁ SEM USO POR ENQUANTO
      IMPORTING is_branch_info     TYPE j_1bnfe_branch_info
      EXPORTING server_check_nfe_t TYPE tt_nfe_server_check
                server_check_dfe_t TYPE tt_dfe_server_check.

    METHODS:
      initialize_dao,
      load_branch_information IMPORTING is_branch_info TYPE j_1bnfe_branch_info,
      contingency_read IMPORTING is_branch_info TYPE j_1bnfe_branch_info,
      timestamp_cfg,
      read_dfe_cfg_list,

      nfe_server_check IMPORTING is_branch_info TYPE j_1bnfe_branch_info,
      nfe_active_server CHANGING server_check_nfe_t TYPE tt_nfe_server_check,
      nfe_integration IMPORTING is_branch_info TYPE j_1bnfe_branch_info,

      dfe_server_check IMPORTING is_branch_info TYPE j_1bnfe_branch_info,
      dfe_active_server CHANGING server_check_dfe_t TYPE tt_dfe_server_check,
      dfe_integration IMPORTING is_branch_info TYPE j_1bnfe_branch_info.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS /s4tax/contingency_integration IMPLEMENTATION.

  METHOD initialize_dao.
    dao_document = /s4tax/dao_document=>get_instance(  ).
    dao_dfe_cfg = dao_document->dfe_cfg(  ).
    dfe_cfg_list = dao_dfe_cfg->get_all( ).
  ENDMETHOD.

  METHOD read_dfe_cfg_list.
    IF dfe_cfg_list IS INITIAL.
      EXIT.
    ENDIF.

    READ TABLE dfe_cfg_list INTO dfe_cfg INDEX 1.

    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDMETHOD.

  METHOD load_branch_information.
    dfe_std = /s4tax/dfe_std=>get_instance( ).
    dfe_std->j_1bnfe_cust3_read( EXPORTING bukrs  = is_branch_info-bukrs
                                           branch = is_branch_info-branch
                                           model  = is_branch_info-model
                                 IMPORTING cust3  = cust3 ).
    " Check is not executed in following cases:
    " 1) WHEN no entry exists in customizing
    " 2) automatic server determination is not active in customizing
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
  ENDMETHOD.

  METHOD contingency_read.
    dfe_std->j_1b_nfe_contingency_read( EXPORTING land1       = branch_address->struct-land1
                                                  regio       = branch_address->struct-regio
                                                  bukrs       = is_branch_info-bukrs
                                                  branch      = is_branch_info-branch
                                                  model       = is_branch_info-model
                                                  contin_type = '2'
                                        IMPORTING es_set_cont = ls_set_cont ).
  ENDMETHOD.

  METHOD nfe_server_check.
    date = /s4tax/date=>create_utc_now( ).
    date = date->to_timezone( sy-zonlo ).

    server_check_nfe-regio = is_branch_info-regio.
    server_check_nfe-tpamb = cust3-tpamb.
    server_check_nfe-sefaz_active = 'X'.
    server_check_nfe-scan_active = ''.
    server_check_nfe-checktmpl = date->to_timestamp( ).
    server_check_nfe-version   = cust3-version.
  ENDMETHOD.

  METHOD dfe_server_check.
    server_check_dfe-cnpj           = is_branch_info-bukrs.
    server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-sefaz.
    server_check_dfe-checktmpl      = date->to_timestamp( ).
    server_check_dfe-version        = cust3-version.
    server_check_dfe-tpamb          = cust3-tpamb.
    server_check_dfe-model          = is_branch_info-model.
  ENDMETHOD.

  METHOD timestamp_cfg.
    CREATE OBJECT today_date EXPORTING date = sy-datum time = sy-timlo.
    timestamp_now = today_date->to_timestamp( ).
    last_update_sefaz = server->struct-contingency_date.
    timestamp_server = today_date->to_time_timestamp(
      time      = dfe_cfg->struct-status_update_time
      timestamp = last_update_sefaz ).
  ENDMETHOD.

  METHOD nfe_active_server.

    IF server->struct-active_server = 'SVC'.
      CLEAR server_check_nfe-sefaz_active.
      CASE server->struct-authorizer.
        WHEN /s4tax/dfe_constants=>svc_provider-rs.
          server_check_nfe-svc_rs_active = abap_true.
        WHEN /s4tax/dfe_constants=>svc_provider-sp.
          server_check_nfe-svc_sp_active = abap_true.
        WHEN /s4tax/dfe_constants=>svc_provider-national.
          server_check_nfe-svc_active = abap_true.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    server_check_nfe-checktmpl = server->struct-contingency_date.
    APPEND server_check_nfe TO server_check_nfe_t.

  ENDMETHOD.

  METHOD dfe_active_server.

    IF server->struct-active_server = 'SVC'.
      CLEAR server_check_dfe-active_service.
      CASE  branch_address->struct-regio.
        WHEN 'AP' OR 'SP' OR 'MT' OR 'MS' OR 'PE' OR 'RR'.
          server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-rs.
        WHEN OTHERS.
          server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-sp.
      ENDCASE.
    ENDIF.

    server_check_dfe-checktmpl = server->struct-contingency_date.
    APPEND server_check_dfe TO server_check_dfe_t.

  ENDMETHOD.

  METHOD nfe_integration.
    DATA: dfe_integration TYPE REF TO /s4tax/dfe_integration.
    CREATE OBJECT dfe_integration EXPORTING dao = dao dao_document = dao_document.
    dfe_integration->nfe_check_active_server( EXPORTING company_code            = is_branch_info-bukrs
                                                        branch_code             = is_branch_info-branch
                                              CHANGING  server_status           = server_check_nfe
                                                        nfe_contingency_control = ls_set_cont
                                                        contingency_date        = contingency_date ).
  ENDMETHOD.

  METHOD dfe_integration.
    DATA: cte_integration TYPE REF TO /s4tax/cte_integration.
    CREATE OBJECT cte_integration EXPORTING dao = dao dao_document = dao_document.
    cte_integration->dfe_check_active_server( EXPORTING company_code            = is_branch_info-bukrs
                                                        branch_code             = is_branch_info-branch
                                              CHANGING  server_status           = server_check_dfe
                                                        dfe_contingency_control = ls_set_cont
                                                        contingency_date        = contingency_date ).
  ENDMETHOD.

  METHOD main.

    dao_server = /s4tax/dao_server=>get_instance(  ).
    server = dao_server->get(  ).

    initialize_dao( ).
    load_branch_information( is_branch_info ).
    contingency_read( is_branch_info ).

    CASE is_branch_info-model.
      WHEN '55'. nfe_server_check( is_branch_info ).
      WHEN '57'. dfe_server_check( is_branch_info ).
    ENDCASE.

    read_dfe_cfg_list( ).
    IF ls_set_cont IS NOT INITIAL AND dfe_cfg IS BOUND.

      timestamp_cfg( ).

      IF timestamp_now <= timestamp_server AND server->struct-regio = branch_address->struct-regio AND server IS BOUND.
        CASE is_branch_info-model.
          WHEN '55'. nfe_active_server( CHANGING server_check_nfe_t = server_check_nfe_t ).
          WHEN '57'. dfe_active_server( CHANGING server_check_dfe_t = server_check_dfe_t ).
        ENDCASE.
        EXIT.
      ENDIF.

      defaults      = /s4tax/defaults=>get_default_instance( ).
      dao           = defaults->get_dao( ).
      dao_document  = /s4tax/dao_document=>get_instance( ).

      CASE is_branch_info-model.
        WHEN '55'. nfe_integration( is_branch_info ).
        WHEN '57'. dfe_integration( is_branch_info ).
      ENDCASE.

      server->set_contingency_date( contingency_date ).
      server->set_regio( branch_address->struct-regio ).

    ENDIF.

    CASE is_branch_info-model.
      WHEN '55'. APPEND server_check_nfe TO server_check_nfe_t.
      WHEN '57'. APPEND server_check_dfe TO server_check_dfe_t.
    ENDCASE.
    EXIT.

  ENDMETHOD.

ENDCLASS.

