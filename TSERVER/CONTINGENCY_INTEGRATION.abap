CLASS /s4tax/contingency_integration DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: tt_nfe_server_check TYPE TABLE OF j_1bnfe_server_check,
           tt_dfe_server_check TYPE TABLE OF j_1bdfe_server_check.

    METHODS:
      constructor,
      run_contingency_process IMPORTING is_main_branch_info   TYPE j_1bnfe_branch_info
                              CHANGING  ot_server_check_nfe_t TYPE tt_nfe_server_check OPTIONAL
                                        ot_server_check_dfe_t TYPE tt_dfe_server_check OPTIONAL.

  PROTECTED SECTION.
    DATA: cust3                   TYPE j_1bnfe_cust3,
          dao_dfe_cfg             TYPE REF TO /s4tax/idao_dfe_cfg,
          dao_document            TYPE REF TO /s4tax/idao_document,
          dao_pack_model_business TYPE REF TO /s4tax/idao_pack_model_busines,
          dao_server              TYPE REF TO /s4tax/idao_server,
          dao_branch              TYPE REF TO /s4tax/idao_branch,
          dal_branch              TYPE REF TO /s4tax/idal_branch,
          ls_set_cont             TYPE j_1bnfe_contin,

          server                  TYPE REF TO /s4tax/server,
          server_check_nfe        TYPE j_1bnfe_server_check,
          server_check_dfe        TYPE j_1bdfe_server_check,
          document_type           TYPE j_1bmodel,

          branch_info             TYPE j_1bnfe_branch_info, "
          branch                  TYPE REF TO /s4tax/branch,
          branch_address          TYPE REF TO /s4tax/address,
          dfe_std                 TYPE REF TO /s4tax/dfe_std,
          dfe_cfg                 TYPE REF TO /s4tax/document_config,
*          dfe_cfg_list            TYPE /s4tax/document_config_t,

          date                    TYPE REF TO /s4tax/date,
          timestamp_now           TYPE /s4tax/tserver-contingency_date,
          today_date              TYPE REF TO /s4tax/date,
          timestamp_server        TYPE timestamp,
          status_update_time      TYPE /s4tax/update_time,
          contingency_date        TYPE /s4tax/e_last_status,

          server_check_nfe_t      TYPE TABLE OF j_1bnfe_server_check,
          server_check_dfe_t      TYPE TABLE OF j_1bdfe_server_check,

          reporter                TYPE REF TO /s4tax/ireporter,
          msg                     TYPE string.


    METHODS:
      load_branch_information,

      mount_server_check_nfe,
      mount_server_check_dfe,

      initialize_dao_and_server,
      get_timestamps,

      update_svc_server_check_nfe IMPORTING case_item TYPE /s4tax/authorizer,
      update_svc_server_check_dfe IMPORTING case_item TYPE regio,

      run_check_active_server.

  PRIVATE SECTION.
    DATA: was_return_forced TYPE abap_bool VALUE abap_false.

    METHODS:
      save_svc IMPORTING output TYPE /s4tax/s_status_servico_o
                         regio  TYPE /s4tax/tserver-regio
                         model  TYPE /s4tax/tserver-model.

ENDCLASS.



CLASS /s4tax/contingency_integration IMPLEMENTATION.

  METHOD constructor.
    me->reporter = /s4tax/reporter_factory=>create( object    = /s4tax/reporter_factory=>object-s4tax
                                                    subobject = /s4tax/reporter_factory=>subobject-docs ).
  ENDMETHOD.

  METHOD load_branch_information.
    dfe_std = /s4tax/dfe_std=>get_instance( ).
    dfe_std->j_1bnfe_cust3_read( EXPORTING bukrs  = branch_info-bukrs
                                           branch = branch_info-branch
                                           model  = branch_info-model
                                 IMPORTING cust3  = cust3 ).

* Check is not executed in following cases: 1) when no entry exists in customizing  2) automatic server determination is not active in customizing
    IF cust3 IS INITIAL OR cust3-autoserver IS INITIAL.
      MESSAGE e004(/s4tax/dfe_integr) INTO msg.
      reporter->error( msg ).
      was_return_forced = abap_true.
      RETURN.
    ENDIF.

    dao_pack_model_business = /s4tax/dao_pack_model_business=>default_instance( ).
    dao_branch = dao_pack_model_business->branch( ).
    branch = dao_branch->get( company_code = branch_info-bukrs
                              branch_code  = branch_info-branch ).

    IF branch IS NOT BOUND.
      MESSAGE e005(/s4tax/dfe_integr) INTO msg.
      reporter->error( msg ).
      was_return_forced = abap_true.
      RETURN.
    ENDIF.

    dal_branch = dao_pack_model_business->branch_dal( ).
    dal_branch->fill_branch_data( branch ).
    branch_address = branch->get_address( ).

    IF branch_address IS NOT BOUND.
      MESSAGE e006(/s4tax/dfe_integr) INTO msg.
      reporter->error( msg ).
      was_return_forced = abap_true.
      RETURN.
    ENDIF.

    dfe_std->j_1b_nfe_contingency_read( EXPORTING land1       = branch_address->struct-land1
                                                  regio       = branch_address->struct-regio
                                                  bukrs       = branch_info-bukrs
                                                  branch      = branch_info-branch
                                                  model       = branch_info-model
                                                  contin_type = '2'
                                        IMPORTING es_set_cont = ls_set_cont ).
  ENDMETHOD.

  METHOD mount_server_check_nfe.
    date = /s4tax/date=>create_utc_now( ).
    date = date->to_timezone( sy-zonlo ).

    server_check_nfe-regio        = branch_info-regio.
    server_check_nfe-tpamb        = cust3-tpamb.
    server_check_nfe-version      = cust3-version.
    server_check_nfe-checktmpl    = date->to_timestamp( ).
    server_check_nfe-sefaz_active = 'X'.
    server_check_nfe-scan_active  = ''.
  ENDMETHOD.

  METHOD mount_server_check_dfe.
    date = /s4tax/date=>create_utc_now( ).
    date = date->to_timezone( sy-zonlo ).

    server_check_dfe-cnpj           = branch_info-bukrs.
    server_check_dfe-tpamb          = cust3-tpamb.
    server_check_dfe-version        = cust3-version.
    server_check_dfe-checktmpl      = date->to_timestamp( ).
    server_check_dfe-model          = branch_info-model.
    server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-sefaz.
  ENDMETHOD.

  METHOD initialize_dao_and_server.
    dao_document = /s4tax/dao_document=>get_instance( ).
    dao_dfe_cfg  = dao_document->dfe_cfg( ).
    dfe_cfg      = dao_dfe_cfg->get_first( ). "Antes era dfe_cfg_list = dao_dfe_cfg->get_all( ).

    dao_server = /s4tax/dao_server=>get_instance( ).
    server     = dao_server->get( ).
  ENDMETHOD.

  METHOD get_timestamps.
    CREATE OBJECT today_date EXPORTING date = sy-datum time = sy-timlo.
    timestamp_now = today_date->to_timestamp( ).

    status_update_time = dfe_cfg->get_status_update_time( ).
    contingency_date = server->get_contingency_date( ).
    timestamp_server = today_date->to_time_timestamp( time = status_update_time timestamp = contingency_date ).
  ENDMETHOD.

  METHOD update_svc_server_check_nfe.
    CLEAR server_check_nfe-sefaz_active.
    CASE case_item.
      WHEN /s4tax/dfe_constants=>svc_provider-rs.
        server_check_nfe-svc_rs_active = abap_true.
      WHEN /s4tax/dfe_constants=>svc_provider-sp.
        server_check_nfe-svc_sp_active = abap_true.
      WHEN /s4tax/dfe_constants=>svc_provider-national.
        server_check_nfe-svc_active = abap_true.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD update_svc_server_check_dfe.
    CLEAR server_check_dfe-active_service.
    CASE case_item.
      WHEN 'AP' OR 'SP' OR 'MT' OR 'MS' OR 'PE' OR 'RR'.
        server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-rs.
      WHEN OTHERS.
        server_check_dfe-active_service = /s4tax/dfe_constants=>svc_code_sap-sp.
    ENDCASE.
  ENDMETHOD.

  METHOD run_check_active_server. "Método adaptado de /S4TAX/DFE_INTEGRATION e /S4TAX/CTE_INTEGRATION

    DATA: dao               TYPE REF TO /s4tax/idao,
          defaults          TYPE REF TO /s4tax/defaults,
          dao_branch_config TYPE REF TO /s4tax/idao_branch_config,
          branch_config     TYPE REF TO /s4tax/branch_config,
          consulta_input    TYPE /s4tax/s_status_servico_i,
          consulta_output   TYPE /s4tax/s_status_servico_o,
          lx_root           TYPE REF TO cx_root,
          msg               TYPE string,
          date              TYPE REF TO /s4tax/date,
          dfe_std           TYPE REF TO /s4tax/dfe_std,
          api_dfe           TYPE REF TO /s4tax/iapi_dfe.

    dao_document = /s4tax/dao_document=>get_instance( ).
    defaults = /s4tax/defaults=>get_default_instance( ).
    dao = defaults->get_dao( ).

    TRY.
        api_dfe = /s4tax/api_dfe=>get_instance( ).
      CATCH /s4tax/cx_http /s4tax/cx_auth INTO lx_root.
        msg = lx_root->get_text( ).
        reporter->error( msg ).
        was_return_forced = abap_true.
        RETURN.
    ENDTRY.

    dao_branch_config = dao->branch_config( ).
    branch_config = dao_branch_config->get( company_code = me->branch_info-bukrs
                                            branch_code  = me->branch_info-branch ).

    IF branch_config IS NOT BOUND.
      MESSAGE e011(/s4tax/dfe_integr) INTO msg.
      reporter->error( msg ).
      was_return_forced = abap_true.
      RETURN.
    ENDIF.

    consulta_input-branch_id = branch_config->get_branch_id( ).
    consulta_input-contingencia = /s4tax/constants=>proposition-true.

    TRY.
        consulta_output = api_dfe->nfe_status_servico( input = consulta_input ).
      CATCH cx_root INTO lx_root.
        msg = lx_root->get_text( ).
        reporter->error( msg ).
        was_return_forced = abap_true.
        RETURN.
    ENDTRY.

    TRY.
        date = /s4tax/date=>create_by_utc( utc = consulta_output-main-date ).
        IF date IS BOUND.
          server_check_nfe-checktmpl = date->to_timestamp( ).
          server_check_dfe-checktmpl = date->to_timestamp( ).
        ENDIF.
      CATCH cx_sy_conversion_no_date_time.
    ENDTRY.

    IF  ls_set_cont-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-active
    AND consulta_output-svc-active = abap_false.
      ls_set_cont-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-default.
      ls_set_cont-xi_out          = 'X'.
      dfe_std = /s4tax/dfe_std=>get_instance( ).
      dfe_std->j_1b_nfe_contingency_update( update_contigency = ls_set_cont ).
    ENDIF.

    IF ( consulta_output-main-active = abap_false AND consulta_output-svc-active = abap_true )
    OR ls_set_cont-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-active.

      CASE me->document_type.

        WHEN 55.
          DATA: tmp_authorizer TYPE /s4tax/tserver-authorizer.
          tmp_authorizer = consulta_output-svc-authorizer.
          update_svc_server_check_nfe( case_item = tmp_authorizer ).

        WHEN 57.
          update_svc_server_check_dfe( case_item = ls_set_cont-regio ).

      ENDCASE.
    ENDIF.

    save_svc( EXPORTING output = consulta_output
                        regio  = branch_address->get_regio( )
                        model  = me->branch_info-model ).
  ENDMETHOD.

  METHOD save_svc.

    DATA: active           TYPE /s4tax/tserver-active_server,
          authorizer       TYPE /s4tax/tserver-authorizer,
          environment_type TYPE /s4tax/tserver-environment_type,
          dao_server       TYPE REF TO /s4tax/idao_server,
          date             TYPE REF TO /s4tax/date,
          server           TYPE REF TO /s4tax/server,
          contingency_date TYPE /s4tax/e_last_status.

    dao_server = /s4tax/dao_server=>get_instance(  ).

    IF dao_server IS NOT BOUND.
      MESSAGE e009(/s4tax/dfe_integr) INTO msg.
      reporter->error( msg ).
      was_return_forced = abap_true.
      RETURN.
    ENDIF.

    CREATE OBJECT server.

    IF output-main-active = abap_true.

      active = 'MAIN'.
      authorizer = output-main-authorizer.
      environment_type = output-main-tp_amb.
      date = /s4tax/date=>create_by_utc( output-main-date ).

    ELSE.

      active = 'SVC'.
      authorizer = output-svc-authorizer.
      environment_type = output-svc-tp_amb.
      date = /s4tax/date=>create_by_utc( output-svc-date ).

    ENDIF.

    contingency_date = date->to_timestamp( ).
    server->set_regio( regio ).
    server->set_model( model ).
    server->set_active_server( active ).
    server->set_authorizer( authorizer ).
    server->set_environment_type( environment_type ).
    server->set_contingency_date( contingency_date ).

    IF server IS NOT BOUND.
      MESSAGE e010(/s4tax/dfe_integr) INTO msg.
      reporter->error( msg ).
      was_return_forced = abap_true.
      RETURN.
    ENDIF.

    dao_server->save( server ).
  ENDMETHOD.

  METHOD run_contingency_process.

    branch_info   = is_main_branch_info.
    document_type = branch_info-model.

    IF document_type <> 55 AND document_type <> 57.
      MESSAGE e007(/s4tax/dfe_integr) WITH branch_info-model INTO msg.
      reporter->error( msg ).
      RETURN.
    ENDIF.

    load_branch_information( ).
    IF was_return_forced EQ abap_true.
      RETURN.
    ENDIF.

    CASE document_type.
      WHEN 55.
        mount_server_check_nfe( ).
      WHEN 57.
        mount_server_check_dfe( ).
    ENDCASE.

    initialize_dao_and_server( ).

    IF ls_set_cont IS NOT INITIAL AND dfe_cfg IS BOUND. "Antes era: IF ls_set_cont IS NOT INITIAL AND dfe_cfg_list IS NOT INITIAL.

      IF server IS BOUND.
        get_timestamps( ).

        IF timestamp_now <= timestamp_server.
          CASE document_type.
            WHEN 55.
              IF server->struct-active_server = 'SVC'.
                update_svc_server_check_nfe( case_item = server->struct-authorizer ).
              ENDIF.
              server_check_nfe-checktmpl = server->struct-contingency_date.
              APPEND server_check_nfe TO ot_server_check_nfe_t.

            WHEN 57.
              IF server->struct-active_server = 'SVC'.
                update_svc_server_check_dfe( case_item = branch_address->struct-regio ).
              ENDIF.
              server_check_dfe-checktmpl = server->struct-contingency_date.
              APPEND server_check_dfe TO ot_server_check_dfe_t.
          ENDCASE.
          RETURN.
        ENDIF.
      ENDIF.

      run_check_active_server( ).
      IF was_return_forced = abap_true.
        RETURN.
      ENDIF.

    ENDIF.

    CASE document_type.
      WHEN 55.
        APPEND server_check_nfe TO ot_server_check_nfe_t.
      WHEN 57.
        APPEND server_check_dfe TO ot_server_check_dfe_t.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.