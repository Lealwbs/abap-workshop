CLASS /s4tax/contingency_integration DEFINITION PUBLIC CREATE PUBLIC.

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

          dfe_intg                TYPE REF TO /s4tax/dfe_integration,
          cte_intg                TYPE REF TO /s4tax/cte_integration,
          document_type           TYPE j_1bmodel,

          branch_info             TYPE j_1bnfe_branch_info,
          branch                  TYPE REF TO /s4tax/branch,
          branch_address          TYPE REF TO /s4tax/address,
          dfe_std                 TYPE REF TO /s4tax/dfe_std,
          dfe_cfg                 TYPE REF TO /s4tax/document_config,
          dfe_cfg_list            TYPE /s4tax/document_config_t,

          date                    TYPE REF TO /s4tax/date,
          timestamp_now           TYPE /s4tax/tserver-contingency_date,
          today_date              TYPE REF TO /s4tax/date,
          timestamp_server        TYPE timestamp,
          status_update_time      TYPE /s4tax/update_time,
          contingency_date        TYPE /s4tax/e_last_status,

          server_check_nfe_t      TYPE TABLE OF j_1bnfe_server_check,
          server_check_dfe_t      TYPE TABLE OF j_1bdfe_server_check.

    TYPES: tt_nfe_server_check TYPE TABLE OF j_1bnfe_server_check,
           tt_dfe_server_check TYPE TABLE OF j_1bdfe_server_check.

    METHODS:
      constructor IMPORTING cs_branch_info TYPE j_1bnfe_branch_info OPTIONAL,
      run_contingency_process CHANGING is_main_branch_info   TYPE j_1bnfe_branch_info OPTIONAL
                                       ot_server_check_nfe_t TYPE tt_nfe_server_check OPTIONAL
                                       ot_server_check_dfe_t TYPE tt_dfe_server_check OPTIONAL.

    METHODS:
      load_branch_information,
      read_contingency_config,

      mount_server_check_nfe,
      mount_server_check_dfe,

      initialize_dao_and_server,
      read_dfe_cfg_list,
      get_timestamp_now,
      get_timestamp_server,

      update_svc_server_check_nfe,
      update_svc_server_check_dfe,

      run_nfe_check_active_server,
      run_dfe_check_active_server.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS /s4tax/contingency_integration IMPLEMENTATION.

  METHOD constructor.
    IF cs_branch_info IS NOT INITIAL.
      me->branch_info = cs_branch_info.
    ENDIF.
  ENDMETHOD.

  METHOD load_branch_information.
    dfe_std = /s4tax/dfe_std=>get_instance( ).
    dfe_std->j_1bnfe_cust3_read( EXPORTING bukrs  = me->branch_info-bukrs
                                           branch = me->branch_info-branch
                                           model  = me->branch_info-model
                                 IMPORTING cust3  = cust3 ).

* Check is not executed in following cases: 1) when no entry exists in customizing  2) automatic server determination is not active in customizing
    IF cust3 IS INITIAL OR cust3-autoserver IS INITIAL.
      EXIT.
    ENDIF.

    dao_pack_model_business = /s4tax/dao_pack_model_business=>default_instance( ).
    dao_branch = dao_pack_model_business->branch( ).
    branch = dao_branch->get( company_code = me->branch_info-bukrs
                              branch_code  = me->branch_info-branch ).

    IF branch IS NOT BOUND.
      EXIT.
    ENDIF.

    TEST-SEAM inj_mock_branch_address.
    END-TEST-SEAM.

    dal_branch = dao_pack_model_business->branch_dal( ).
    dal_branch->fill_branch_data( branch ).
    branch_address = branch->get_address( ).

    IF branch_address IS NOT BOUND.
      EXIT.
    ENDIF.
  ENDMETHOD.

  METHOD read_contingency_config.
    dfe_std->j_1b_nfe_contingency_read( EXPORTING land1       = me->branch_address->struct-land1
                                                  regio       = me->branch_address->struct-regio
                                                  bukrs       = me->branch_info-bukrs
                                                  branch      = me->branch_info-branch
                                                  model       = me->branch_info-model
                                                  contin_type = '2'
                                        IMPORTING es_set_cont = me->ls_set_cont ).
  ENDMETHOD.

  METHOD mount_server_check_nfe.
    date = /s4tax/date=>create_utc_now( ).
    date = date->to_timezone( sy-zonlo ).

    server_check_nfe-regio        = me->branch_info-regio.
    server_check_nfe-tpamb        = me->cust3-tpamb.
    server_check_nfe-version      = me->cust3-version.
    server_check_nfe-checktmpl    = me->date->to_timestamp( ).
    server_check_nfe-sefaz_active = 'X'.
    server_check_nfe-scan_active  = ''.
  ENDMETHOD.

  METHOD mount_server_check_dfe.
    date = /s4tax/date=>create_utc_now( ).
    date = date->to_timezone( sy-zonlo ).

    server_check_dfe-cnpj           = me->branch_info-bukrs.
    server_check_dfe-tpamb          = me->cust3-tpamb.
    server_check_dfe-version        = me->cust3-version.
    server_check_dfe-checktmpl      = me->date->to_timestamp( ).
    server_check_dfe-model          = me->branch_info-model.
    server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-sefaz.
  ENDMETHOD.

  METHOD initialize_dao_and_server.
    dao_document = /s4tax/dao_document=>get_instance(  ).
    dao_dfe_cfg = dao_document->dfe_cfg(  ).
    dfe_cfg_list = dao_dfe_cfg->get_all( ).

    dao_server = /s4tax/dao_server=>get_instance(  ).
    server = dao_server->get(  ).

    defaults      = /s4tax/defaults=>get_default_instance( ).
    dao           = defaults->get_dao( ).
    dao_document  = /s4tax/dao_document=>get_instance( ).
  ENDMETHOD.

  METHOD read_dfe_cfg_list.
    READ TABLE dfe_cfg_list INTO dfe_cfg INDEX 1.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    IF dfe_cfg IS NOT BOUND.
      EXIT.
    ENDIF.
  ENDMETHOD.

  METHOD get_timestamp_now.
    CREATE OBJECT today_date EXPORTING date = sy-datum time = sy-timlo.
    timestamp_now = today_date->to_timestamp( ).
  ENDMETHOD.

  METHOD get_timestamp_server.
    status_update_time = dfe_cfg->get_status_update_time( ).
    contingency_date = server->get_contingency_date( ).
    timestamp_server = today_date->to_time_timestamp( time = status_update_time timestamp = contingency_date ).
  ENDMETHOD.

  METHOD update_svc_server_check_nfe.
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
  ENDMETHOD.

  METHOD update_svc_server_check_dfe.
    IF server->struct-active_server = 'SVC'.
      CLEAR server_check_dfe-active_service.

      CASE branch_address->struct-regio.
        WHEN 'AP' OR 'SP' OR 'MT' OR 'MS' OR 'PE' OR 'RR'.
          server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-rs.
        WHEN OTHERS.
          server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-sp.
      ENDCASE.
    ENDIF.
    server_check_dfe-checktmpl = server->struct-contingency_date.
  ENDMETHOD.

  METHOD run_nfe_check_active_server.
    CREATE OBJECT dfe_intg EXPORTING dao = dao dao_document = dao_document.
    dfe_intg->nfe_check_active_server( EXPORTING company_code            = me->branch_info-bukrs
                                                 branch_code             = me->branch_info-branch
                                                 model                   = me->branch_info-model
                                                 regio                   = branch_address->get_regio( )
                                       CHANGING  server_status           = server_check_nfe
                                                 nfe_contingency_control = ls_set_cont
                                                 contingency_date        = contingency_date ).
  ENDMETHOD.

  METHOD run_dfe_check_active_server.
    CREATE OBJECT cte_intg EXPORTING dao = dao dao_document = dao_document.
    cte_intg->dfe_check_active_server( EXPORTING company_code            = me->branch_info-bukrs
                                                 branch_code             = me->branch_info-branch
                                                 model                   = me->branch_info-model
                                                 regio                   = branch_address->get_regio( )
                                       CHANGING  server_status           = server_check_dfe
                                                 dfe_contingency_control = ls_set_cont ).
  ENDMETHOD.

  METHOD run_contingency_process.

    IF is_main_branch_info IS NOT INITIAL.
      me->branch_info = is_main_branch_info.
    ENDIF.

    document_type = me->branch_info-model.

    IF document_type IS INITIAL.
    EXIT.
    ENDIF.

    load_branch_information( ).
    read_contingency_config( ).

    CASE document_type.
      WHEN '55'. mount_server_check_nfe( ).
      WHEN '57'. mount_server_check_dfe( ).
    ENDCASE.

    initialize_dao_and_server( ).

    IF me->ls_set_cont IS NOT INITIAL AND me->dfe_cfg_list IS NOT INITIAL.
      me->read_dfe_cfg_list( ).
      me->get_timestamp_now( ).

      IF me->server IS BOUND.
        me->get_timestamp_server( ).
        IF timestamp_now <= timestamp_server.
          CASE document_type.
            WHEN '55'.
              update_svc_server_check_nfe( ).
              APPEND server_check_nfe TO server_check_nfe_t.
            WHEN '57'.
              update_svc_server_check_dfe( ).
              APPEND server_check_dfe TO server_check_dfe_t.
          ENDCASE.
          EXIT.
        ENDIF.
      ENDIF.

      CASE document_type.
        WHEN '55'. run_nfe_check_active_server( ).
        WHEN '57'. run_dfe_check_active_server( ).
      ENDCASE.
    ENDIF.

    CASE document_type.
      WHEN '55'. APPEND server_check_nfe TO server_check_nfe_t.
      WHEN '57'. APPEND server_check_dfe TO server_check_dfe_t.
    ENDCASE.
    EXIT.

  ENDMETHOD.

ENDCLASS.