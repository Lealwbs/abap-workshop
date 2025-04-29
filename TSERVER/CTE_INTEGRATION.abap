CLASS /s4tax/cte_integration DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .

PUBLIC SECTION.

  METHODS:
    constructor IMPORTING dao                     TYPE REF TO /s4tax/idao OPTIONAL
                          dao_document            TYPE REF TO /s4tax/idao_document OPTIONAL
                          api_document            TYPE REF TO /s4tax/iapi_document OPTIONAL
                          api_dfe                 TYPE REF TO /s4tax/iapi_dfe OPTIONAL
                          dao_pack_model_business TYPE REF TO /s4tax/idao_pack_model_busines OPTIONAL
                          reporter                TYPE REF TO /s4tax/ireporter OPTIONAL,

    cte_out IMPORTING cte_data TYPE REF TO /s4tax/dfe_integration_cte,

    cteos_out IMPORTING cte_data TYPE REF TO /s4tax/dfe_integration_cte,

    cte_inutilizacao IMPORTING cte_data TYPE REF TO /s4tax/dfe_integration_cte,

    cte_event_out IMPORTING branch_config    TYPE REF TO /s4tax/branch_config
                            docnum           TYPE j_1bdocnum
                            cte_access_key   TYPE j_1b_nfe_access_key_dtel44
                            event_type       TYPE num6
                            event_seq_number TYPE j_1bnfe_event_seqno
                            timestamp        TYPE timestampl
                            authcode         TYPE j_1bnfeauthcode OPTIONAL
                            content_table    TYPE j_1bnfe_t_ccecontent OPTIONAL
                            text             TYPE string OPTIONAL
                            ext_seqnum       TYPE j_1bnfe_event_seqno_ext OPTIONAL
                            model            TYPE j_1bmodel OPTIONAL,

    dfe_check_active_server IMPORTING company_code            TYPE bukrs
                                      branch_code             TYPE j_1bbranc_
                                      regio                   TYPE sadr-regio
                                      model                   TYPE j_1bmodel
                                      svc_priority            TYPE abap_bool DEFAULT abap_false
                            CHANGING  server_status           TYPE j_1bdfe_server_check
                                      dfe_contingency_control TYPE j_1bnfe_contin.

PROTECTED SECTION.
  METHODS get_api_document RETURNING VALUE(result) TYPE REF TO /s4tax/iapi_document
                           RAISING   /s4tax/cx_http /s4tax/cx_auth.

PRIVATE SECTION.

  DATA: reporter                TYPE REF TO /s4tax/ireporter,
        dao                     TYPE REF TO /s4tax/idao,
        dao_document            TYPE REF TO /s4tax/idao_document,
        dao_pack_model_business TYPE REF TO /s4tax/idao_pack_model_busines,
        api_document            TYPE REF TO /s4tax/iapi_document,
        api_dfe                 TYPE REF TO /s4tax/iapi_dfe,
        string_utils            TYPE REF TO /s4tax/string_utils.

  METHODS:
    process_bad_request IMPORTING api_document  TYPE REF TO /s4tax/iapi_document
                        RETURNING VALUE(result) TYPE /s4tax/s_bad_request_o,

    process_emit_bad_request_cteos IMPORTING dfe                  TYPE REF TO /s4tax/dfe
                                   CHANGING  output               TYPE /s4tax/s_cteos_emit_output
                                             communication_status TYPE /s4tax/tdfe-communication_status,

    process_emit_bad_request IMPORTING dfe                  TYPE REF TO /s4tax/dfe
                             CHANGING  output               TYPE /s4tax/s_cte_emit_output
                                       communication_status TYPE /s4tax/tdfe-communication_status,

    save_event IMPORTING event TYPE REF TO /s4tax/dfeevent,

    save_svc IMPORTING output        TYPE /s4tax/s_status_servico_o
                       regio         TYPE /s4tax/tserver-regio
                       model         TYPE /s4tax/tserver-model
                       active_server TYPE /s4tax/active_server,

    fill_cte_input IMPORTING cte_data      TYPE REF TO /s4tax/dfe_integration_cte
                             branch_config TYPE REF TO /s4tax/branch_config
                   RETURNING VALUE(result) TYPE /s4tax/s_cte_document_input,

    get_doc IMPORTING docnum        TYPE j_1bdocnum
            RETURNING VALUE(result) TYPE REF TO /s4tax/doc,

    get_dfe IMPORTING docnum        TYPE j_1bnfdoc-docnum
            RETURNING VALUE(result) TYPE REF TO /s4tax/dfe,

    get_svc_code_sap IMPORTING svc_authorizer TYPE /s4tax/e_dfe_stat_servico-authorizer
                               regio          TYPE regio
                     RETURNING VALUE(result)  TYPE j_1bdfe_server_check-active_service.

ENDCLASS.



CLASS /s4tax/cte_integration IMPLEMENTATION.


METHOD constructor.
  me->dao = dao.
  IF me->dao IS NOT BOUND.
    CREATE OBJECT me->dao TYPE /s4tax/dao.
  ENDIF.

  me->dao_document = dao_document.
  IF me->dao_document IS NOT BOUND.
    CREATE OBJECT me->dao_document TYPE /s4tax/dao_document.
  ENDIF.

  me->dao_pack_model_business = dao_pack_model_business.
  IF me->dao_pack_model_business IS NOT BOUND.
    CREATE OBJECT me->dao_pack_model_business TYPE /s4tax/dao_pack_model_business.
  ENDIF.

  me->reporter = reporter.
  IF me->reporter IS NOT BOUND.
    me->reporter = /s4tax/reporter_factory=>create( object    = /s4tax/reporter_factory=>object-s4tax
                                                    subobject = /s4tax/reporter_factory=>subobject-docs ).
  ENDIF.

  me->api_document = api_document.
  IF me->api_document IS NOT BOUND.
    TRY.
        me->api_document = /s4tax/api_document=>get_instance( ).
      CATCH /s4tax/cx_http /s4tax/cx_auth.
    ENDTRY.
  ENDIF.

  me->api_dfe = api_dfe.
  IF me->api_dfe IS NOT BOUND.
    TRY.
        me->api_dfe = /s4tax/api_dfe=>get_instance( ).
      CATCH /s4tax/cx_http /s4tax/cx_auth.
    ENDTRY.
  ENDIF.

  CREATE OBJECT string_utils.
ENDMETHOD.


METHOD cte_event_out.

  DATA: dao_dfe_event TYPE REF TO /s4tax/idao_dfe_event,
        api_document  TYPE REF TO /s4tax/iapi_document,
        input         TYPE /s4tax/s_cte_recepcao_evento_i,
        response      TYPE /s4tax/s_cte_recepcao_evento_o,
        event         TYPE /s4tax/s_eventos_cte,
        lx_root       TYPE REF TO cx_root,
        dfe_event     TYPE REF TO /s4tax/dfeevent,
        event_struct  TYPE /s4tax/tdfeevent,
        bad_request   TYPE /s4tax/s_bad_request_o,
        date          TYPE REF TO /s4tax/date,
        content       LIKE LINE OF content_table,
        inf_correcao  TYPE /s4tax/s_eventos_cte_correcao,
        msg           TYPE string.

  dao_dfe_event = me->dao_document->dfe_event( ).

  input-branch_id    = branch_config->get_branch_id( ).
  input-versao       = '4.00'.
  input-ch_cte       = cte_access_key.
  input-n_seq_evento = event_seq_number.

  event-tp_evento = event_type.
  CREATE OBJECT string_utils.

  CASE event_type.
    WHEN /s4tax/dfe_constants=>c_event_type-cancellation.
      event-n_prot = authcode.
      event-x_just = text.
      event-x_just = me->string_utils->trim( event-x_just ).
      event_struct-int_event = /s4tax/dfe_constants=>int_event-cancellation.

    WHEN /s4tax/dfe_constants=>c_event_type-correction_letter.

      event_struct-int_event = /s4tax/dfe_constants=>int_event-correction_letter.
      input-n_seq_evento = ext_seqnum.

      LOOP AT content_table INTO content.
        MOVE-CORRESPONDING content TO inf_correcao.
        APPEND inf_correcao TO event-inf_correcao.
      ENDLOOP.

  ENDCASE.

  input-evento = event.

  CREATE OBJECT dfe_event.
  dfe_event->set_docnum( docnum ).
  dfe_event->set_int_event( event_struct-int_event ).
  dfe_event->set_seqnum( event_seq_number ).
  dfe_event->set_ext_seqnum( ext_seqnum ).

  TRY.
      api_document = get_api_document( ).
      response = api_document->cte_recepcao_evento( input = input model = model ).

    CATCH cx_root INTO lx_root.
      event_struct-code = /s4tax/dfe_constants=>c_event_statuscode-rej_unknown.
      save_event( dfe_event ).
      msg = lx_root->get_text( ).
      reporter->error( msg ).
      RETURN.
  ENDTRY.

  IF response-ret_evento_cte-inf_evento IS NOT INITIAL.
    event_struct-code      = response-ret_evento_cte-inf_evento-c_stat.
    event_struct-dh_evento = response-ret_evento_cte-inf_evento-dh_reg_evento.
    event_struct-authcode  = response-ret_evento_cte-inf_evento-n_prot.
  ELSE.
    bad_request = me->process_bad_request( api_document ).
    event_struct-code = bad_request-c_stat.
  ENDIF.

  IF event_struct-code IS INITIAL.
    event_struct-code = /s4tax/dfe_constants=>c_event_statuscode-rej_unknown.
  ENDIF.

  IF event_struct-dh_evento IS INITIAL.
    date = /s4tax/date=>create_utc_now( ).
    date = date->to_timezone( sy-zonlo ).
    event_struct-dh_evento = date->to_timestamp( ).
  ENDIF.

  dfe_event->set_code( event_struct-code ).
  dfe_event->set_dh_evento( event_struct-dh_evento ).
  dfe_event->set_authcode( event_struct-authcode ).
  save_event( dfe_event ).

ENDMETHOD.


METHOD cte_inutilizacao.

  DATA: dao_dfe          TYPE REF TO /s4tax/idao_dfe,
        dao_branch       TYPE REF TO /s4tax/idao_branch_config,
        dao_doc          TYPE REF TO /s4tax/idao_doc,
        dfe              TYPE REF TO /s4tax/dfe,
        branch_config    TYPE REF TO /s4tax/branch_config,
        api_document     TYPE REF TO /s4tax/iapi_document,
        lx_root          TYPE REF TO cx_root,
        inutilizacao_in  TYPE /s4tax/s_cte_inutilizacao_in,
        inutilizacao_out TYPE /s4tax/s_cte_inutilizacao_out,
        dfe_struct       TYPE /s4tax/tdfe,
        sap_doc          TYPE REF TO /s4tax/doc,
        accesskey        TYPE j_1b_nfe_access_key_dtel44,
        date             TYPE REF TO /s4tax/date,
        bad_request      TYPE /s4tax/s_bad_request_o,
        string_utils     TYPE REF TO /s4tax/string_utils,
        msg              TYPE string.

  FIELD-SYMBOLS: <xjust> LIKE LINE OF cte_data->it_xml_ext2.

  CREATE OBJECT string_utils.

  dao_dfe    = me->dao_document->dfe( ).
  dao_branch = me->dao->branch_config( ).
  dao_doc    = me->dao_pack_model_business->doc( ).

  dfe = get_dfe( docnum =  cte_data->get_docnum( ) ).
  sap_doc = dao_doc->get( dfe->struct-docnum ).

  IF sap_doc IS NOT BOUND.
    " Exception
  ENDIF.

  READ TABLE cte_data->it_xml_ext2 ASSIGNING <xjust> WITH KEY field = 'XJUST'.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

  branch_config = dao_branch->get( company_code = sap_doc->struct-bukrs
                                   branch_code  = sap_doc->struct-branch ).

  TRY.
      api_document = get_api_document(  ).
      inutilizacao_in-branch_id = branch_config->get_branch_id( ).
      inutilizacao_in-versao    = cte_data->get_version( ).
      inutilizacao_in-versao    = string_utils->trim( inutilizacao_in-versao ).
      accesskey = cte_data->get_accesskey( ).
      inutilizacao_in-serie     = accesskey+22(3).
      SHIFT inutilizacao_in-serie LEFT DELETING LEADING '0'.
      inutilizacao_in-n_ct_ini  = accesskey+25(9).
      inutilizacao_in-n_ct_fin  = accesskey+25(9).
      inutilizacao_in-x_just    = <xjust>-value.
      inutilizacao_in-ano       = sap_doc->struct-docdat+2(2).

      inutilizacao_out = api_document->cte_inutilizacao( inutilizacao_in ).

    CATCH cx_root INTO lx_root.
      msg = lx_root->get_text( ).
      reporter->error( msg ).
      RETURN.
  ENDTRY.

  IF inutilizacao_out-ret_inut_cte-inf_inut IS NOT INITIAL.
    dfe_struct-inut_code      = inutilizacao_out-ret_inut_cte-inf_inut-c_stat.
    dfe_struct-inut_dh_evento = inutilizacao_out-ret_inut_cte-inf_inut-dh_recbto.
    dfe_struct-inut_authcode  = inutilizacao_out-ret_inut_cte-inf_inut-n_prot.
  ELSE.
    bad_request = me->process_bad_request( api_document ).
    dfe_struct-inut_code = bad_request-c_stat.
  ENDIF.

  IF dfe_struct-inut_dh_evento IS INITIAL.
    date = /s4tax/date=>create_utc_now( ).
    date = date->to_timezone( sy-zonlo ).
    dfe_struct-inut_dh_evento = date->to_timestamp( ).
  ENDIF.

  dfe->set_inut_code( dfe_struct-inut_code ).
  dfe->set_inut_dh_evento( dfe_struct-inut_dh_evento ).
  dfe->set_inut_authcode( dfe_struct-inut_authcode ).
  dao_dfe->save( dfe ).

ENDMETHOD.


METHOD cte_out.

  DATA: sap_doc              TYPE REF TO /s4tax/doc,
        dao_dfe              TYPE REF TO /s4tax/idao_dfe,
        dao_errors           TYPE REF TO /s4tax/idao_dfe_error,
        dao_branch           TYPE REF TO /s4tax/idao_branch_config,
        dfe                  TYPE REF TO /s4tax/dfe,
        cte_input            TYPE /s4tax/s_cte_document_input,
        branch_config        TYPE REF TO /s4tax/branch_config,
        lx_root              TYPE REF TO cx_root,
        lx_auth              TYPE REF TO /s4tax/cx_auth,
        output               TYPE /s4tax/s_cte_emit_output,
        communication_status TYPE /s4tax/tdfe-communication_status,
        dfe_communication    TYPE REF TO /s4tax/idfe_communication,
        api_document         TYPE REF TO /s4tax/iapi_document,
        cte_id               TYPE /s4tax/e_dfe_id,
        msg                  TYPE string.

  dao_dfe    = dao_document->dfe( ).
  dao_errors = dao_document->dfe_error( ).
  dao_branch = me->dao->branch_config( ).

  sap_doc = get_doc( cte_data->iv_docnum ).
  IF sap_doc IS NOT BOUND.
    " Exception
    "TODO - Adicionar a mensagem
  ENDIF.

  dfe = get_dfe( docnum = sap_doc->struct-docnum ).
  branch_config = dao_branch->get( company_code = sap_doc->struct-bukrs branch_code = sap_doc->struct-branch ).

  IF branch_config IS NOT BOUND.
    dfe->set_communication_status( /s4tax/dfe_constants=>status_communication-configuration_error ).
    dao_dfe->save( dfe ).
    RETURN.
  ENDIF.

  cte_input = fill_cte_input( cte_data = cte_data branch_config = branch_config ).

  TRY.

      api_document = get_api_document(  ).
      dfe_communication = /s4tax/dfe_model_factory=>get_dfe_model( model = sap_doc->struct-model api_document = api_document ).
      output = dfe_communication->emit( input = cte_input ).
      dao_errors->delete_errors_by_docnum( sap_doc->struct-docnum ).
      output-request->set_output_data( CHANGING output_data = output-response ).
      output-request->send( ).

      IF output-response-cte_id IS NOT INITIAL.
        cte_id = output-response-cte_id.
        dfe->set_id( cte_id ).
        communication_status = /s4tax/dfe_constants=>status_communication-request_sent.
      ENDIF.

      IF output-request->error IS BOUND AND output-request->error->http_status = /s4tax/http_response=>http_status_code-bad_request.

        me->process_emit_bad_request( EXPORTING dfe                  = dfe
                                      CHANGING  output               = output
                                                communication_status = communication_status ).
      ENDIF.

    CATCH /s4tax/cx_auth INTO lx_auth.
      msg = lx_auth->get_text( ).
      reporter->error( msg ).
      communication_status = /s4tax/dfe_constants=>status_communication-configuration_error.

    CATCH cx_root INTO lx_root.
      msg = lx_root->get_text( ).
      reporter->error( msg ).
      communication_status = /s4tax/dfe_constants=>status_communication-communication_error.
  ENDTRY.

  dfe->set_communication_status( communication_status ).
  dao_dfe->save( dfe ).

ENDMETHOD.


METHOD cteos_out.

  DATA: sap_doc              TYPE REF TO /s4tax/doc,
        dao_dfe              TYPE REF TO /s4tax/idao_dfe,
        dao_errors           TYPE REF TO /s4tax/idao_dfe_error,
        dao_branch           TYPE REF TO /s4tax/idao_branch_config,
        dfe                  TYPE REF TO /s4tax/dfe,
        cteos_input          TYPE /s4tax/s_cte_document_input,
        branch_config        TYPE REF TO /s4tax/branch_config,
        lx_root              TYPE REF TO cx_root,
        lx_auth              TYPE REF TO /s4tax/cx_auth,
        output               TYPE /s4tax/s_cteos_emit_output,
        communication_status TYPE /s4tax/tdfe-communication_status,
        dfe_communication    TYPE REF TO /s4tax/idfe_communication,
        api_document         TYPE REF TO /s4tax/iapi_document,
        cteos_id             TYPE /s4tax/e_dfe_id,
        msg                  TYPE string.

  dao_dfe    = dao_document->dfe( ).
  dao_errors = dao_document->dfe_error( ).
  dao_branch = me->dao->branch_config( ).

  sap_doc = get_doc( cte_data->iv_docnum ).

  IF sap_doc IS NOT BOUND.
    MESSAGE e000(/s4tax/docs) WITH cte_data->iv_docnum INTO msg.
    reporter->error( msg ).
    RETURN.
  ENDIF.

  dfe = get_dfe( docnum = sap_doc->struct-docnum ).
  branch_config = dao_branch->get( company_code = sap_doc->struct-bukrs branch_code = sap_doc->struct-branch ).

  IF branch_config IS NOT BOUND.
    dfe->set_communication_status( /s4tax/dfe_constants=>status_communication-configuration_error ).
    dao_dfe->save( dfe ).
    CLEAR msg.
    MESSAGE e010(/s4tax/docs) WITH cte_data->iv_docnum INTO msg.
    reporter->error( msg ).
    RETURN.
  ENDIF.

  cteos_input = fill_cte_input( cte_data = cte_data branch_config = branch_config ).

  TRY.

      api_document = get_api_document(  ).
      output = api_document->cteos_recepcao_sincrona( cteos_input  ).
      dao_errors->delete_errors_by_docnum( sap_doc->struct-docnum ).
      output-request->set_output_data( CHANGING output_data = output-response ).
      output-request->send( ).

      IF output-response-id IS NOT INITIAL.
        cteos_id = output-response-id.
        dfe->set_id( cteos_id ).
        communication_status = /s4tax/dfe_constants=>status_communication-request_sent.
      ENDIF.

      IF output-request->error IS BOUND AND output-request->error->http_status = /s4tax/http_response=>http_status_code-bad_request.

        me->process_emit_bad_request_cteos( EXPORTING dfe                  = dfe
                                            CHANGING  output               = output
                                                      communication_status = communication_status ).
      ENDIF.

    CATCH /s4tax/cx_auth INTO lx_auth.
      communication_status = /s4tax/dfe_constants=>status_communication-configuration_error.
      CLEAR msg.
      msg = lx_auth->get_text( ).
      reporter->error( msg ).
      RETURN.

    CATCH cx_root INTO lx_root.
      CLEAR msg.
      communication_status = /s4tax/dfe_constants=>status_communication-communication_error.
      msg = lx_root->get_text( ).
      reporter->error( msg ).
      RETURN.
  ENDTRY.

  dfe->set_communication_status( communication_status ).
  dao_dfe->save( dfe ).

ENDMETHOD.


METHOD fill_cte_input.

  result-branch_id = branch_config->get_branch_id( ).
  result-ide = cte_data->get_ide( ).
  result-versao = cte_data->get_version( ).
  result-compl = cte_data->get_compl( ).
  result-rem = cte_data->get_rem( ).
  result-exped = cte_data->get_exped( ).
  result-receb = cte_data->get_receb( ).
  result-dest = cte_data->get_dest( ).
  result-v_prest = cte_data->get_vprest( ).
  result-imp = cte_data->get_imp( ).
  result-inf_cte_norm = cte_data->get_infctenorm( ).
  result-inf_cte_comp = cte_data->get_infctecomp( ).
  result-inf_cte_anu = cte_data->get_infcteanu( ).
  result-aut_xml = cte_data->get_autxml( ).
  result-toma = cte_data->get_tomador( ).

ENDMETHOD.


METHOD get_api_document.

  DATA: session  TYPE REF TO /s4tax/session,
        api_auth TYPE REF TO /s4tax/iapi_auth.

  api_auth = /s4tax/api_auth=>default_instance( ).
  session = api_auth->login( /s4tax/defaults=>customer_profile_name ).

  CREATE OBJECT result TYPE /s4tax/api_document
    EXPORTING
      session = session.

ENDMETHOD.


METHOD get_dfe.

  DATA:
    dao_dfe    TYPE REF TO /s4tax/idao_dfe,
    dao_errors TYPE REF TO /s4tax/idao_dfe_error.

  dao_dfe    = dao_document->dfe( ).
  dao_errors = dao_document->dfe_error( ).

  result = dao_dfe->get( docnum ).
  IF result IS NOT BOUND.
    CREATE OBJECT result.
    result->set_docnum( docnum ).
  ENDIF.

ENDMETHOD.


METHOD get_doc.

  DATA:
    dao_errors TYPE REF TO /s4tax/idao_dfe_error,
    dao_doc    TYPE REF TO /s4tax/idao_doc.

  dao_errors = dao_document->dfe_error( ).
  dao_doc    = me->dao_pack_model_business->doc( ).
  result = dao_doc->get( docnum ).

ENDMETHOD.


METHOD process_bad_request.

  DATA:
    config_generator TYPE REF TO /s4tax/json_config_generator,
    json_config      TYPE REF TO /s4tax/json_element_config,
    element_config   TYPE REF TO /s4tax/json_element_config,
    last_request     TYPE REF TO /s4tax/http_request,
    api_doc          TYPE REF TO /s4tax/api_document.

  IF api_document IS NOT BOUND.
    RETURN.
  ENDIF.
  api_doc ?= api_document.

  last_request = api_doc->get_last_request( ).
  last_request->remove_prop( /s4tax/http_request=>commom_props_name-response_element_config ).

  CREATE OBJECT config_generator.
  json_config = config_generator->generate_data_type_config( result ).
  element_config = json_config->get_child_by_abap_name( 'c_stat' ).
  element_config->ext_name = 'cStat'.

  last_request->add_prop( name = /s4tax/http_request=>commom_props_name-response_element_config obj = json_config ).
  last_request->set_output_data( CHANGING output_data = result ).
  last_request->unmarshal( ).

ENDMETHOD.


METHOD process_emit_bad_request_cteos.

  DATA: obj_dfe_error TYPE REF TO /s4tax/dfe_error,
        dao_errors    TYPE REF TO /s4tax/idao_dfe_error,
        error_list    TYPE /s4tax/dfe_error_t,
        dfe_id        TYPE /s4tax/e_dfe_id.

  FIELD-SYMBOLS: <error> TYPE /s4tax/s_cte_param_error.

  output-request->set_output_data( CHANGING output_data = output-errors ).
  output-request->unmarshal( ).

  me->reporter->error( output-errors-code ).
  me->reporter->error( output-errors-message ).

  CREATE OBJECT obj_dfe_error.
  obj_dfe_error->set_docnum( dfe->struct-docnum ).
  obj_dfe_error->set_value( output-errors-code ).
  obj_dfe_error->set_msg( output-errors-message ).
  dfe->add_error( obj_dfe_error ).

  LOOP AT output-errors-errors ASSIGNING <error>.

    CREATE OBJECT obj_dfe_error.
    obj_dfe_error->set_docnum( dfe->struct-docnum ).
    obj_dfe_error->set_param( <error>-param ).
    obj_dfe_error->set_value( <error>-value ).
    obj_dfe_error->set_msg( <error>-msg ).
    dfe->add_error( obj_dfe_error ).

  ENDLOOP.

  communication_status   = /s4tax/dfe_constants=>status_communication-business_error.
  IF output-errors-dfe_id IS NOT INITIAL.
    dfe_id = output-errors-dfe_id.
    dfe->set_id( dfe_id ).
    communication_status = /s4tax/dfe_constants=>status_communication-request_sent.
  ENDIF.

  dao_errors = dao_document->dfe_error( ).
  error_list = dfe->get_error_list( ).
  dao_errors->save_many( error_list ).

ENDMETHOD.


METHOD process_emit_bad_request.

  DATA: obj_dfe_error TYPE REF TO /s4tax/dfe_error,
        dao_errors    TYPE REF TO /s4tax/idao_dfe_error,
        error_list    TYPE /s4tax/dfe_error_t,
        cte_id        TYPE /s4tax/e_dfe_id.

  FIELD-SYMBOLS: <error> TYPE /s4tax/s_cte_param_error.

  output-request->set_output_data( CHANGING output_data = output-errors ).
  output-request->unmarshal( ).

  me->reporter->error( output-errors-code ).
  me->reporter->error( output-errors-message ).

  CREATE OBJECT obj_dfe_error.
  obj_dfe_error->set_docnum( dfe->struct-docnum ).
  obj_dfe_error->set_value( output-errors-code ).
  obj_dfe_error->set_msg( output-errors-message ).
  dfe->add_error( obj_dfe_error ).

  LOOP AT output-errors-errors ASSIGNING <error>.

    CREATE OBJECT obj_dfe_error.
    obj_dfe_error->set_docnum( dfe->struct-docnum ).
    obj_dfe_error->set_param( <error>-param ).
    obj_dfe_error->set_value( <error>-value ).
    obj_dfe_error->set_msg( <error>-msg ).
    dfe->add_error( obj_dfe_error ).

  ENDLOOP.

  communication_status   = /s4tax/dfe_constants=>status_communication-business_error.
  IF output-errors-cte_id IS NOT INITIAL.
    cte_id = output-errors-cte_id.
    dfe->set_id( cte_id ).
    communication_status = /s4tax/dfe_constants=>status_communication-request_sent.
  ENDIF.

  dao_errors = dao_document->dfe_error( ).
  error_list = dfe->get_error_list( ).
  dao_errors->save_many( error_list ).

ENDMETHOD.


METHOD save_event.
  DATA:  dao_dfe_event TYPE REF TO /s4tax/idao_dfe_event.

  dao_dfe_event   = me->dao_document->dfe_event( ).
  dao_dfe_event->save( event ).
ENDMETHOD.


METHOD dfe_check_active_server.

  DATA: dao_branch_config TYPE REF TO /s4tax/idao_branch_config,
        branch_config     TYPE REF TO /s4tax/branch_config,
        consulta_input    TYPE /s4tax/s_status_servico_i,
        consulta_output   TYPE /s4tax/s_status_servico_o,
        lx_root           TYPE REF TO cx_root,
        msg               TYPE string,
        date              TYPE REF TO /s4tax/date,
        dfe_std           TYPE REF TO /s4tax/dfe_std.

  dao_branch_config = me->dao->branch_config( ).
  branch_config = dao_branch_config->get( company_code = company_code branch_code = branch_code ).

  IF branch_config IS NOT BOUND.
    RETURN.
  ENDIF.

  consulta_input-branch_id = branch_config->get_branch_id( ).
  consulta_input-contingencia = /s4tax/constants=>proposition-true.
  TRY.
      consulta_output = me->api_dfe->nfe_status_servico( input = consulta_input ).
    CATCH cx_root INTO lx_root.
      msg = lx_root->get_text( ).
      reporter->error( msg ).
      RETURN.
  ENDTRY.

  TRY.
      date = /s4tax/date=>create_by_utc( utc = consulta_output-main-date ).
      IF date IS BOUND.
        server_status-checktmpl = date->to_timestamp( ).
      ENDIF.
    CATCH cx_sy_conversion_no_date_time.
  ENDTRY.


  IF  dfe_contingency_control-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-active
  AND consulta_output-svc-active = abap_false.

    dfe_contingency_control-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-default.
    dfe_contingency_control-xi_out = 'X'.
    dfe_std = /s4tax/dfe_std=>get_instance( ).
    dfe_std->j_1b_nfe_contingency_update( update_contigency = dfe_contingency_control ).

    save_svc( EXPORTING output = consulta_output
                        active_server = 'MAIN'
                        regio = regio
                        model = model ).

    RETURN.
  ENDIF.

  IF ( consulta_output-main-active = abap_false AND consulta_output-svc-active  = abap_true )
  OR dfe_contingency_control-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-active.

    CLEAR server_status-active_service.
    server_status-active_service = get_svc_code_sap( svc_authorizer = consulta_output-svc-authorizer regio = dfe_contingency_control-regio ).

    save_svc( EXPORTING output = consulta_output
                 active_server = 'SVC'
                         regio = regio
                         model = model ).

  ENDIF.

ENDMETHOD.


METHOD get_svc_code_sap.

  CASE regio.
    WHEN 'AP' OR 'SP' OR 'MT' OR 'MS' OR 'PE' OR 'RR'.

      result = /s4tax/dfe_constants=>svc_code_sap-rs.

    WHEN OTHERS.

      result = /s4tax/dfe_constants=>svc_code_sap-sp.

  ENDCASE.
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
    RETURN.
  ENDIF.

  CREATE OBJECT server.

  IF active_server = 'MAIN'.

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
    RETURN.
  ENDIF.

  dao_server->save( server ).

ENDMETHOD.
ENDCLASS.