CLASS /s4tax/dfe_integration DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING dao                     TYPE REF TO /s4tax/idao                    OPTIONAL
                  dao_document            TYPE REF TO /s4tax/idao_document           OPTIONAL
                  api_document            TYPE REF TO /s4tax/iapi_document           OPTIONAL
                  api_dfe                 TYPE REF TO /s4tax/iapi_dfe                OPTIONAL
                  dao_pack_model_business TYPE REF TO /s4tax/idao_pack_model_busines OPTIONAL
                  reporter                TYPE REF TO /s4tax/ireporter               OPTIONAL,

      nfe_out  IMPORTING nfe_data TYPE REF TO /s4tax/dfe_merchant_dto,
      nfce_out IMPORTING nfe_data TYPE REF TO /s4tax/dfe_merchant_dto,

      nfe_event_out
        IMPORTING docnum           TYPE j_1bdocnum
                  nfe_access_key   TYPE j_1b_nfe_access_key_dtel44
                  event_type       TYPE num6
                  event_seq_number TYPE j_1bnfe_event_seqno
                  branch_config    TYPE REF TO /s4tax/branch_config
                  authcode         TYPE j_1bnfeauthcode         OPTIONAL
                  text             TYPE string                  OPTIONAL
                  ext_seqnum       TYPE j_1bnfe_event_seqno_ext OPTIONAL
        RETURNING VALUE(result)    TYPE REF TO /s4tax/dfeevent,

      nfe_inutilizacao
        IMPORTING nfe_data      TYPE REF TO /s4tax/dfe_merchant_dto
        RETURNING VALUE(result) TYPE REF TO /s4tax/dfe,

      nfe_check_active_server
        IMPORTING company_code            TYPE bukrs
                  branch_code             TYPE j_1bbranc_
                  regio                   TYPE sadr-regio
                  model                   TYPE j_1bmodel
        CHANGING  server_status           TYPE j_1bnfe_server_check
                  nfe_contingency_control TYPE j_1bnfe_contin
                  contingency_date        TYPE /s4tax/e_last_status OPTIONAL,

      get_dfe_xml
        IMPORTING docnum        TYPE j_1bdocnum
                  model         TYPE j_1bnfe_active-model
                  access_key    TYPE j_1b_nfe_access_key
        RETURNING VALUE(result) TYPE xstring
        RAISING   /s4tax/cx_dfe_integration
                  /s4tax/cx_http
                  /s4tax/cx_auth
                  cx_bcs,

      save_xml_in_local_repo
        IMPORTING !doc TYPE REF TO /s4tax/doc
                  !xml TYPE /s4tax/xmlrawstring.

  PRIVATE SECTION.
    DATA: reporter                TYPE REF TO /s4tax/ireporter,
          dao                     TYPE REF TO /s4tax/idao,
          dao_document            TYPE REF TO /s4tax/idao_document,
          dao_pack_model_business TYPE REF TO /s4tax/idao_pack_model_busines,
          api_document            TYPE REF TO /s4tax/iapi_document,
          api_dfe                 TYPE REF TO /s4tax/iapi_dfe.

    METHODS:
      return_if_is_not_initial
        IMPORTING input         TYPE any
        RETURNING VALUE(result) TYPE string,

      return_if_value
        IMPORTING input         TYPE any
        RETURNING VALUE(result) TYPE string,

      create_date
        IMPORTING date          TYPE d
        RETURNING VALUE(result) TYPE REF TO /s4tax/date,

      fill_compra
        IMPORTING compra        TYPE j_1bnfe_s_rfc_compra
        RETURNING VALUE(result) TYPE /s4tax/s_nfe_compra,

      save_event IMPORTING !event TYPE REF TO /s4tax/dfeevent,

      get_svc_code_sap
        IMPORTING svc_authorizer TYPE /s4tax/e_dfe_stat_servico-authorizer
        CHANGING  server_status  TYPE j_1bnfe_server_check,

      get_api_nfe_input
        IMPORTING nfe_data      TYPE REF TO /s4tax/dfe_merchant_dto
        RETURNING VALUE(result) TYPE /s4tax/s_nfe_document_input,

      get_s4tax_dfe
        IMPORTING docnum        TYPE j_1bdocnum
                  dh_sai_ent    TYPE j_1bnfe_dhsaient_utc
        RETURNING VALUE(result) TYPE REF TO /s4tax/dfe,

      set_error_dfe
        IMPORTING s4tax_dfe TYPE REF TO /s4tax/dfe
                  !message  TYPE string
                  !errors   TYPE /s4tax/s_nfe_emit_errors OPTIONAL,

      save_dfe_objects
        IMPORTING s4tax_dfe  TYPE REF TO /s4tax/dfe           OPTIONAL
                  obj_errors TYPE REF TO cl_object_collection OPTIONAL,

      clear_errors_before_send IMPORTING s4tax_dfe TYPE REF TO /s4tax/dfe OPTIONAL,

      mount_input_for_event_out
        IMPORTING event_type     TYPE num6
                  nfe_access_key TYPE j_1b_nfe_access_key_dtel44
                  authcode       TYPE j_1bnfeauthcode
                  !text          TYPE string
                  ext_seqnum     TYPE j_1bnfe_event_seqno_ext
                  branch_config  TYPE REF TO /s4tax/branch_config
        RETURNING VALUE(result)  TYPE /s4tax/s_nfe_recepcao_evento_i,

      create_dfe_event
        IMPORTING docnum           TYPE j_1bdocnum
                  event_seq_number TYPE j_1bnfe_event_seqno
                  ext_seqnum       TYPE j_1bnfe_event_seqno_ext
                  event_type       TYPE num6
        RETURNING VALUE(result)    TYPE REF TO /s4tax/dfeevent,

      nfe_event_register
        IMPORTING input         TYPE /s4tax/s_nfe_recepcao_evento_i
                  dfe_event     TYPE REF TO /s4tax/dfeevent
        RETURNING VALUE(result) TYPE /s4tax/s_nfe_recepcao_evento_o,

      nfe_event
        IMPORTING input         TYPE /s4tax/s_nfe_recepcao_evento_i
                  dfe_event     TYPE REF TO /s4tax/dfeevent
        RETURNING VALUE(result) TYPE /s4tax/s_nfe_recepcao_evento_o,

      mount_input_for_nfe_recep_cc
        IMPORTING !input        TYPE /s4tax/s_nfe_recepcao_evento_i
                  docnum        TYPE j_1bdocnum
        RETURNING VALUE(result) TYPE /s4tax/iapi_dfe=>nfe_recepcao_input,

      mount_input_nfe_inutilizacao
        IMPORTING nfe_data      TYPE REF TO /s4tax/dfe_merchant_dto
                  xjust         TYPE j1b_nf_xml_extension2
        RETURNING VALUE(result) TYPE /s4tax/s_nfe_inutilizacao_in,

      process_output_nfe_event
        IMPORTING dfe_event TYPE REF TO /s4tax/dfeevent
                  response  TYPE /s4tax/s_nfe_recepcao_evento_o,

      process_output_nfe_ev_register
        IMPORTING dfe_event TYPE REF TO /s4tax/dfeevent
                  !response TYPE /s4tax/s_nfe_recepcao_evento_o,

      mount_dfe_inutilizacao
        IMPORTING dfe              TYPE REF TO /s4tax/dfe
                  inutilizacao_out TYPE /s4tax/s_nfe_inutilizacao_out,

      create_bad_request
        IMPORTING bad_request TYPE /s4tax/s_bad_request_o,

      mount_output_for_nfe_rec_cc
        IMPORTING dfe_output    TYPE /s4tax/iapi_dfe=>nfe_recepcao_evento_output
        RETURNING VALUE(result) TYPE /s4tax/s_nfe_recepcao_evento_o,

      save_svc IMPORTING output        TYPE /s4tax/s_status_servico_o
                         regio         TYPE /s4tax/tserver-regio
                         model         TYPE /s4tax/tserver-model
                         active_server TYPE /s4tax/active_server,

      get_xml_from_local_repository
        IMPORTING access_key    TYPE j_1b_nfe_access_key
        RETURNING VALUE(result) TYPE xstring,


      get_xml_from_orbit
        IMPORTING docnum        TYPE j_1bdocnum
                  model         TYPE j_1bnfe_active-model
        RETURNING VALUE(result) TYPE xstring
        RAISING   /s4tax/cx_dfe_integration /s4tax/cx_http /s4tax/cx_auth cx_bcs,

      get_nfe_xml_by_nfe_id
        IMPORTING nfe_id        TYPE /s4tax/e_dfe_id
                  model         TYPE j_1bnfe_active-model
        RETURNING VALUE(result) TYPE string
        RAISING   /s4tax/cx_http
                  /s4tax/cx_auth.


ENDCLASS.



CLASS /s4tax/dfe_integration IMPLEMENTATION.


  METHOD constructor.

    me->dao = dao.
    IF me->dao IS NOT BOUND.
      me->dao = /s4tax/dao=>default_instance( ).
    ENDIF.

    me->dao_document = dao_document.
    IF me->dao_document IS NOT BOUND.
      me->dao_document = /s4tax/dao_document=>get_instance( ).
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

  ENDMETHOD.


  METHOD create_date.
    CREATE OBJECT result EXPORTING date = date.
  ENDMETHOD.


  METHOD fill_compra.

    result-x_ped  = return_if_is_not_initial( compra-x_ped ).
    result-x_cont = return_if_is_not_initial( compra-x_cont ).

    DATA x_nemp_variantions TYPE STANDARD TABLE OF string.

    FIELD-SYMBOLS: <field_name> TYPE string,
                   <field>      TYPE any.

    APPEND: 'X_NEMP' TO x_nemp_variantions,
            'XN_EMP' TO x_nemp_variantions.

    LOOP AT x_nemp_variantions ASSIGNING <field_name>.

      ASSIGN COMPONENT <field_name> OF STRUCTURE compra TO <field>.

      IF <field> IS ASSIGNED.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF <field> IS ASSIGNED.
      result-xn_emp = return_if_is_not_initial( <field> ).
    ENDIF.

  ENDMETHOD.


  METHOD get_nfe_xml_by_nfe_id.

    DATA: consulta_input TYPE /s4tax/iapi_document=>nfe_consulta_xml_input,
          lx_root        TYPE REF TO cx_root,
          msg            TYPE string.


    consulta_input = nfe_id.

    TRY.
        CASE model.
          WHEN /s4tax/dfe_constants=>dfe_model-nfe.
            result = api_document->nfe_consulta_xml( consulta_input ).
          WHEN /s4tax/dfe_constants=>dfe_model-cte.
            result = api_document->cte_consulta_xml( consulta_input ).
          WHEN /s4tax/dfe_constants=>dfe_model-cteos.
            result = api_document->cteos_consulta_xml( consulta_input ).
        ENDCASE.

      CATCH cx_root INTO lx_root.
        msg = lx_root->get_text( ).
        reporter->error( msg ).
    ENDTRY.

  ENDMETHOD.


  METHOD nfe_event.

    DATA: lx_root TYPE REF TO cx_root,
          code    TYPE j_1bstatuscode,
          msg     TYPE string.

    TRY.
        result = api_document->nfe_recepcao_evento( input ).

      CATCH cx_root INTO lx_root.
        code = /s4tax/dfe_constants=>c_event_statuscode-rej_unknown.
        dfe_event->set_code( code ).
        msg = lx_root->get_text( ).
        reporter->error( msg ).
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD nfe_event_register.

    DATA: dfe_input  TYPE /s4tax/iapi_dfe=>nfe_recepcao_input,
          dfe_output TYPE /s4tax/iapi_dfe=>nfe_recepcao_evento_output,
          lx_root    TYPE REF TO cx_root,
          code       TYPE j_1bstatuscode,
          msg        TYPE string.

    dfe_input = mount_input_for_nfe_recep_cc( input = input docnum = dfe_event->struct-docnum ).

    TRY.
        dfe_output = api_dfe->nfe_recepcao_evento( dfe_input ).
      CATCH cx_root INTO lx_root.
        code = /s4tax/dfe_constants=>c_event_statuscode-rej_unknown.
        dfe_event->set_code( code ).
        msg = lx_root->get_text( ).
        reporter->error( msg ).
        RETURN.
    ENDTRY.

    result = mount_output_for_nfe_rec_cc( dfe_output ).

  ENDMETHOD.


  METHOD nfe_event_out.

    DATA: dao_dfe        TYPE REF TO /s4tax/idao_dfe,
          tdfe           TYPE REF TO /s4tax/dfe,
          input          TYPE /s4tax/s_nfe_recepcao_evento_i,
          event_response TYPE /s4tax/s_nfe_recepcao_evento_o.

    dao_dfe = dao_document->dfe( ).
    tdfe = dao_dfe->get( docnum ).

    input = mount_input_for_event_out( authcode       = authcode
                                       branch_config  = branch_config
                                       event_type     = event_type
                                       ext_seqnum     = ext_seqnum
                                       nfe_access_key = nfe_access_key
                                       text           = text ).

    result = create_dfe_event( docnum           = docnum
                               event_seq_number = event_seq_number
                               ext_seqnum       = ext_seqnum
                               event_type       = event_type ).

    IF tdfe IS BOUND.

      event_response = nfe_event( input = input dfe_event = result ).
      process_output_nfe_event( dfe_event = result response = event_response ).

    ELSE.

      event_response = nfe_event_register( input = input dfe_event = result ).
      process_output_nfe_ev_register( dfe_event = result response = event_response ).

    ENDIF.

    save_event( result ).

  ENDMETHOD.


  METHOD nfe_inutilizacao.

    DATA: dao_dfe          TYPE REF TO /s4tax/idao_dfe,
          inutilizacao_in  TYPE /s4tax/s_nfe_inutilizacao_in,
          inutilizacao_out TYPE /s4tax/s_nfe_inutilizacao_out,
          lx_root          TYPE REF TO cx_root,
          inut_code        TYPE j_1bstatuscode,
          msg              TYPE string.

    FIELD-SYMBOLS <xjust> TYPE j1b_nf_xml_extension2.

    dao_dfe = dao_document->dfe( ).
    result  = dao_dfe->get( nfe_data->is_nfe_header-docnum ).

    IF result IS NOT BOUND.
      CREATE OBJECT result.
      result->set_docnum( nfe_data->is_nfe_header-docnum ).
    ENDIF.

    READ TABLE nfe_data->it_nfe_ext2 ASSIGNING <xjust> WITH KEY field = 'XJUST'.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    TRY.
        inutilizacao_in = mount_input_nfe_inutilizacao( nfe_data = nfe_data xjust = <xjust> ).
        inutilizacao_out = api_document->nfe_inutilizacao( inutilizacao_in ).

      CATCH cx_root INTO lx_root.
        inut_code = /s4tax/dfe_constants=>status_code-s4tax_error.
        result->set_inut_code( inut_code ).
        dao_dfe->save( result ).
        msg = lx_root->get_text( ).
        reporter->error( msg ).
        RETURN.
    ENDTRY.

    mount_dfe_inutilizacao( dfe              = result
                            inutilizacao_out = inutilizacao_out ).

    dao_dfe->save( result ).

  ENDMETHOD.


  METHOD nfe_out.

    DATA: dao_branch           TYPE REF TO /s4tax/idao_branch_config,
          dao_doc              TYPE REF TO /s4tax/idao_doc,
          doc                  TYPE REF TO /s4tax/doc,
          msg                  TYPE string,
          nfe                  TYPE /s4tax/s_nfe_document_input,
          s4tax_dfe            TYPE REF TO /s4tax/dfe,
          branch_config        TYPE REF TO /s4tax/branch_config,
          api_auth             TYPE REF TO /s4tax/iapi_auth,
          session              TYPE REF TO /s4tax/session,
          dfe_communication    TYPE REF TO dfe_model_communication,
          output               TYPE /s4tax/s_nfe_emit_output,
          communication_status TYPE /s4tax/tdfe-communication_status,
          dfe_id               TYPE /s4tax/e_dfe_id,
          nfe_id               TYPE /s4tax/e_dfe_id,
          lx_auth              TYPE REF TO /s4tax/cx_auth,
          lx_root              TYPE REF TO cx_root.

    dao_branch = dao->branch_config( ).
    dao_doc    = dao_pack_model_business->doc( ).

    doc = dao_doc->get( nfe_data->is_nfe_header-docnum ).
    IF doc IS NOT BOUND.
      MESSAGE e000(/s4tax/docs) WITH nfe_data->is_nfe_header-docnum INTO msg.
      reporter->error( msg ).
      RETURN.
    ENDIF.

    nfe = get_api_nfe_input( nfe_data ).
    s4tax_dfe = get_s4tax_dfe( docnum     = nfe_data->is_nfe_header-docnum
                               dh_sai_ent = nfe_data->is_nfe_ide-dh_sai_ent ).
    branch_config = dao_branch->get( company_code = doc->struct-bukrs
                                     branch_code  = doc->struct-branch ).
    clear_errors_before_send( s4tax_dfe ).

    IF branch_config IS NOT BOUND.
      s4tax_dfe->set_communication_status( /s4tax/dfe_constants=>status_communication-configuration_error ).
      MESSAGE e010(/s4tax/docs) WITH nfe_data->is_nfe_header-docnum INTO msg.
      reporter->error( msg ).
      set_error_dfe( s4tax_dfe = s4tax_dfe message = msg ).
      RETURN.
    ENDIF.

    TRY.
        nfe-branch_id = branch_config->get_branch_id( ).
        api_auth = /s4tax/api_auth=>default_instance( ).
        session = api_auth->login( /s4tax/defaults=>customer_profile_name ).

        dfe_communication = dfe_model_factory=>get_dfe_model( model = nfe_data->is_nfe_ide-mod session = session ).

        output = dfe_communication->emit( nfe ).
        output-request->set_output_data( CHANGING output_data = output-response ).
        output-request->send( ).

        nfe_id = output-response-nfe_id.
        s4tax_dfe->set_id( nfe_id ).
        communication_status = /s4tax/dfe_constants=>status_communication-request_sent.

        IF output-response IS INITIAL.
          communication_status = /s4tax/dfe_constants=>status_communication-business_error.
          dfe_communication->change_response_for_error( CHANGING output_data = output-errors ).
          set_error_dfe( s4tax_dfe = s4tax_dfe message = msg errors = output-errors ).
        ENDIF.

        IF output-errors-nfe_id IS NOT INITIAL.
          dfe_id = output-errors-nfe_id.
          s4tax_dfe->set_id( dfe_id ).
          communication_status = /s4tax/dfe_constants=>status_communication-request_sent.
        ENDIF.

      CATCH /s4tax/cx_auth INTO lx_auth.
        communication_status = /s4tax/dfe_constants=>status_communication-configuration_error.
        msg = lx_auth->get_text( ).
        reporter->error( msg ).
        RETURN.
      CATCH cx_root INTO lx_root.
        communication_status = /s4tax/dfe_constants=>status_communication-communication_error.
        msg = lx_root->get_text( ).
        reporter->error( msg ).
        RETURN.
    ENDTRY.

    s4tax_dfe->set_communication_status( communication_status ).
    save_dfe_objects( s4tax_dfe = s4tax_dfe ).

  ENDMETHOD.


  METHOD nfce_out.

    DATA: dao_branch           TYPE REF TO /s4tax/idao_branch_config,
          dao_doc              TYPE REF TO /s4tax/idao_doc,
          doc                  TYPE REF TO /s4tax/doc,
          msg                  TYPE string,
          nfe                  TYPE /s4tax/s_nfe_document_input,
          s4tax_dfe            TYPE REF TO /s4tax/dfe,
          branch_config        TYPE REF TO /s4tax/branch_config,
          api_auth             TYPE REF TO /s4tax/iapi_auth,
          session              TYPE REF TO /s4tax/session,
          dfe_communication    TYPE REF TO dfe_model_communication,
          output               TYPE /s4tax/s_nfce_emit_output,
          communication_status TYPE /s4tax/tdfe-communication_status,
          dfe_id               TYPE /s4tax/e_dfe_id,
          nfe_id               TYPE /s4tax/e_dfe_id,
          lx_auth              TYPE REF TO /s4tax/cx_auth,
          lx_root              TYPE REF TO cx_root.

    dao_branch = dao->branch_config( ).
    dao_doc    = dao_pack_model_business->doc( ).

    doc = dao_doc->get( nfe_data->is_nfe_header-docnum ).
    IF doc IS NOT BOUND.
      MESSAGE e000(/s4tax/docs) WITH nfe_data->is_nfe_header-docnum INTO msg.
      reporter->error( msg ).
      RETURN.
    ENDIF.

    nfe = get_api_nfe_input( nfe_data ).
    s4tax_dfe = get_s4tax_dfe( docnum     = nfe_data->is_nfe_header-docnum
                               dh_sai_ent = nfe_data->is_nfe_ide-dh_sai_ent ).
    branch_config = dao_branch->get( company_code = doc->struct-bukrs
                                     branch_code  = doc->struct-branch ).
    clear_errors_before_send( s4tax_dfe ).

    IF branch_config IS NOT BOUND.
      s4tax_dfe->set_communication_status( /s4tax/dfe_constants=>status_communication-configuration_error ).
      MESSAGE e010(/s4tax/docs) WITH nfe_data->is_nfe_header-docnum INTO msg.
      reporter->error( msg ).
      set_error_dfe( s4tax_dfe = s4tax_dfe message = msg ).
      RETURN.
    ENDIF.

    TRY.
        nfe-branch_id = branch_config->get_branch_id( ).
        api_auth = /s4tax/api_auth=>default_instance( ).
        session = api_auth->login( /s4tax/defaults=>customer_profile_name ).

        dfe_communication = dfe_model_factory=>get_dfe_model( model = nfe_data->is_nfe_ide-mod session = session ).

        output = dfe_communication->emit_nfce( nfe ).
        output-request->set_output_data( CHANGING output_data = output-response ).
        output-request->send( ).

        nfe_id = output-response-nfce_id.
        s4tax_dfe->set_id( nfe_id ).
        communication_status = /s4tax/dfe_constants=>status_communication-request_sent.

        IF output-response IS INITIAL.
          communication_status = /s4tax/dfe_constants=>status_communication-business_error.
          dfe_communication->change_response_for_error( CHANGING output_data = output-errors ).
          set_error_dfe( s4tax_dfe = s4tax_dfe message = msg errors = output-errors ).
        ENDIF.

        IF output-errors-nfe_id IS NOT INITIAL.
          dfe_id = output-errors-nfe_id.
          s4tax_dfe->set_id( dfe_id ).
          communication_status = /s4tax/dfe_constants=>status_communication-request_sent.
        ENDIF.

      CATCH /s4tax/cx_auth INTO lx_auth.
        communication_status = /s4tax/dfe_constants=>status_communication-configuration_error.
        msg = lx_auth->get_text( ).
        reporter->error( msg ).
        RETURN.
      CATCH cx_root INTO lx_root.
        communication_status = /s4tax/dfe_constants=>status_communication-communication_error.
        msg = lx_root->get_text( ).
        reporter->error( msg ).
        RETURN.
    ENDTRY.

    s4tax_dfe->set_communication_status( communication_status ).
    save_dfe_objects( s4tax_dfe = s4tax_dfe ).

  ENDMETHOD.


  METHOD get_s4tax_dfe.
    DATA: dao_dfe TYPE REF TO /s4tax/idao_dfe,
          date    TYPE REF TO /s4tax/date.

    dao_dfe = dao_document->dfe( ).

    result = dao_dfe->get( docnum ).
    IF result IS NOT BOUND.
      CREATE OBJECT result.
      result->set_docnum( docnum ).
      result->set_send_email( /s4tax/dfe_constants=>email_status-not_sent ).
    ENDIF.

    date = /s4tax/date=>create_by_timestamp( timestamp = dh_sai_ent
                                             timezone  = /s4tax/date=>timezone_code-utc ).
    result->set_d_ent_sai( date->date ).
    result->set_h_ent_sai( date->time ).

  ENDMETHOD.


  METHOD get_api_nfe_input.

    " Identificação
    result-versao        = '4.00'.
    result-identificacao = nfe_data->get_identificacao( ).

    " Destinatário
    result-destinatario = nfe_data->get_destinatario( ).

    " Retirada
    result-retirada = nfe_data->get_retirada( ).

    " Entega
    result-entrega = nfe_data->get_entrega( ).

    " autXML
    result-aut_xml = nfe_data->get_autxml( ).

    " Det
    result-det = nfe_data->get_det( ).

    " total icms
    result-total = nfe_data->get_total( ).

    " transp
    result-transp = nfe_data->get_transp( ).

    " cobr
    result-cobr = nfe_data->get_cobr( ).

    " pag
    result-pag = nfe_data->get_pag( ).

    " infAdic
    result-inf_adic = nfe_data->get_inf_adic( ).

    " exporta
    result-exporta = nfe_data->get_exporta( ).

    " compra
    result-compra = fill_compra( nfe_data->is_nfe_compra ).

    " cana
    result-cana = nfe_data->get_cana( ).

    " infItermed
    result-inf_intermed = nfe_data->get_inf_intermed( ).

  ENDMETHOD.


  METHOD clear_errors_before_send.
    DATA dao_errors TYPE REF TO /s4tax/idao_dfe_error.

    dao_errors = dao_document->dfe_error( ).
    dao_errors->delete_errors_by_docnum( s4tax_dfe->struct-docnum ).
  ENDMETHOD.


  METHOD set_error_dfe.

    DATA: errors_list   TYPE REF TO cl_object_collection,
          obj_dfe_error TYPE REF TO /s4tax/dfe_error,
          msg           TYPE string,
          code          TYPE j_1bstatuscode.

    FIELD-SYMBOLS <error> TYPE /s4tax/s_nfe_param_error.

    CREATE OBJECT errors_list.

    IF errors-nfe_id IS INITIAL.
      CREATE OBJECT obj_dfe_error.
      obj_dfe_error->set_docnum( s4tax_dfe->struct-docnum ).
      MESSAGE e017(/s4tax/docs) INTO msg.
      reporter->error( msg ).
      obj_dfe_error->set_msg( msg ).
      errors_list->add( element = obj_dfe_error ).
    ENDIF.

    IF message IS NOT INITIAL.
      CREATE OBJECT obj_dfe_error.
      obj_dfe_error->set_docnum( s4tax_dfe->struct-docnum ).
      reporter->error( message ).
      obj_dfe_error->set_msg( message ).
      errors_list->add( element = obj_dfe_error ).
    ENDIF.

    LOOP AT errors-errors ASSIGNING <error>.

      CREATE OBJECT obj_dfe_error.
      obj_dfe_error->set_docnum( s4tax_dfe->struct-docnum ).
      obj_dfe_error->set_param( <error>-param ).
      obj_dfe_error->set_value( <error>-value ).
      obj_dfe_error->set_msg( <error>-msg ).
      errors_list->add( element = obj_dfe_error ).

    ENDLOOP.
    code = /s4tax/dfe_constants=>status_code-s4tax_error.
    s4tax_dfe->set_code( code ).
    save_dfe_objects( s4tax_dfe = s4tax_dfe obj_errors = errors_list ).

  ENDMETHOD.


  METHOD save_dfe_objects.
    DATA: dao_dfe    TYPE REF TO /s4tax/idao_dfe,
          iterator   TYPE REF TO if_object_collection_iterator,
          dao_errors TYPE REF TO /s4tax/idao_dfe_error.

    IF s4tax_dfe IS BOUND.
      dao_dfe = dao_document->dfe( ).
      dao_dfe->save( s4tax_dfe ).
    ENDIF.

    IF obj_errors IS BOUND.
      iterator = obj_errors->get_iterator( ).
      dao_errors = dao_document->dfe_error( ).
      dao_errors->save_errors( iterator ).
    ENDIF.

  ENDMETHOD.


  METHOD return_if_is_not_initial.
    IF input IS INITIAL.
      RETURN.
    ENDIF.
    result = input.
  ENDMETHOD.


  METHOD return_if_value.
    IF input CO '0' OR input IS INITIAL.
      RETURN.
    ENDIF.
    result = input.
  ENDMETHOD.


  METHOD save_event.
    DATA dao_dfe_event TYPE REF TO /s4tax/idao_dfe_event.

    dao_dfe_event = dao_document->dfe_event( ).
    dao_dfe_event->save( event ).
  ENDMETHOD.


  METHOD nfe_check_active_server.

    DATA: dao_branch_config TYPE REF TO /s4tax/idao_branch_config,
          branch_config     TYPE REF TO /s4tax/branch_config,
          consulta_input    TYPE /s4tax/s_status_servico_i,
          consulta_output   TYPE /s4tax/s_status_servico_o,
          lx_root           TYPE REF TO cx_root,
          msg               TYPE string,
          date              TYPE REF TO /s4tax/date,
          dfe_std           TYPE REF TO /s4tax/dfe_std.

    dao_branch_config = dao->branch_config( ).
    branch_config = dao_branch_config->get( company_code = company_code branch_code = branch_code ).

    IF branch_config IS NOT BOUND.
      RETURN.
    ENDIF.

    consulta_input-branch_id    = branch_config->get_branch_id( ).
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

    IF  nfe_contingency_control-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-active
    AND consulta_output-svc-active = abap_false.

      nfe_contingency_control-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-default.
      nfe_contingency_control-xi_out          = 'X'.
      dfe_std = /s4tax/dfe_std=>get_instance( ).
      dfe_std->j_1b_nfe_contingency_update( update_contigency = nfe_contingency_control ).

      save_svc( EXPORTING output        = consulta_output
                          active_server = 'MAIN'
                          regio         = regio
                          model         = model ).

      RETURN.
    ENDIF.

    IF ( consulta_output-main-active = abap_false AND consulta_output-svc-active  = abap_true )
    OR  nfe_contingency_control-cont_reason_reg = /s4tax/dfe_constants=>svc_reason-active.

      get_svc_code_sap( EXPORTING svc_authorizer = consulta_output-svc-authorizer
                        CHANGING  server_status  = server_status ).

      save_svc( EXPORTING output        = consulta_output
                          active_server = 'SVC'
                          regio         = regio
                          model         = model ).
      CLEAR server_status-sefaz_active.
    ENDIF.

  ENDMETHOD.


  METHOD get_svc_code_sap.
    CASE svc_authorizer.
      WHEN /s4tax/dfe_constants=>svc_provider-rs.
        server_status-svc_rs_active = abap_true.

      WHEN /s4tax/dfe_constants=>svc_provider-sp.
        server_status-svc_sp_active = abap_true.

      WHEN /s4tax/dfe_constants=>svc_provider-national.
        server_status-svc_active = abap_true.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD mount_input_for_event_out.

    DATA: event        TYPE /s4tax/s_eventos,
          string_utils TYPE REF TO /s4tax/string_utils.

    result-branch_id = branch_config->get_branch_id( ).
    result-versao    = '1.00'.
    result-id_lote   = '1'.

    event-ch_nfe    = nfe_access_key.
    event-tp_evento = event_type.

    CREATE OBJECT string_utils.

    CASE event-tp_evento.
      WHEN /s4tax/dfe_constants=>c_event_type-cancellation.
        event-n_prot = authcode.
        event-x_just = text.
        event-x_just = string_utils->trim( event-x_just ).
      WHEN /s4tax/dfe_constants=>c_event_type-correction_letter.
        event-n_seq_evento = ext_seqnum.
        event-x_correcao   = text.
        event-x_correcao   = string_utils->trim( event-x_correcao ).
    ENDCASE.

    APPEND event TO result-eventos.

  ENDMETHOD.


  METHOD create_dfe_event.

    DATA: date        TYPE REF TO /s4tax/date,
          date_tstamp TYPE /s4tax/e_reply_tstamp.

    CREATE OBJECT result.

    CASE event_type.
      WHEN /s4tax/dfe_constants=>c_event_type-cancellation.
        result->set_int_event( /s4tax/dfe_constants=>int_event-cancellation ).
      WHEN /s4tax/dfe_constants=>c_event_type-correction_letter.
        result->set_int_event( /s4tax/dfe_constants=>int_event-correction_letter ).
    ENDCASE.

    result->set_docnum( docnum ).
    result->set_seqnum( event_seq_number ).
    result->set_ext_seqnum( ext_seqnum ).

    date = /s4tax/date=>create_utc_now( ).
    date_tstamp = date->to_timestamp( ).
    result->set_dh_evento( date_tstamp ).

  ENDMETHOD.


  METHOD mount_input_nfe_inutilizacao.

    DATA: doc           TYPE REF TO /s4tax/doc,
          branch_config TYPE REF TO /s4tax/branch_config,
          dao_branch    TYPE REF TO /s4tax/idao_branch_config,
          dao_doc       TYPE REF TO /s4tax/idao_doc,
          docdat        TYPE j_1bnfdoc-docdat,
          string_utils  TYPE REF TO /s4tax/string_utils.

    CREATE OBJECT doc.
    CREATE OBJECT branch_config.
    dao_branch = dao->branch_config( ).
    dao_doc    = dao_pack_model_business->doc( ).

    doc = dao_doc->get( nfe_data->is_nfe_header-docnum ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    branch_config = dao_branch->get( company_code = doc->struct-bukrs
                                     branch_code  = doc->struct-branch ).
    IF branch_config IS INITIAL.
      RETURN.
    ENDIF.

    docdat = doc->get_docdat( ).

    result-branch_id = branch_config->get_branch_id( ).
    result-versao    = '4.00'.
    result-serie     = nfe_data->is_nfe_ide-serie.

    CREATE OBJECT string_utils.
    result-serie = string_utils->trim( input = result-serie no_gaps = abap_true ).
    IF result-serie CO '0' AND result-serie IS NOT INITIAL.
      result-serie = '0'.
    ENDIF.

    result-n_nf_ini  = nfe_data->is_nfe_ide-n_nf.
    result-n_nf_fin  = nfe_data->is_nfe_ide-n_nf.
    result-x_just    = xjust-value.
    result-ano       = docdat+2(2).

  ENDMETHOD.


  METHOD process_output_nfe_event.

    DATA: bad_request TYPE /s4tax/s_bad_request_o,
          code        TYPE j_1bstatuscode VALUE /s4tax/dfe_constants=>status_code-rej_unknown,
          dh_evento   TYPE /s4tax/e_reply_tstamp,
          authcode    TYPE j_1bnfeauthcode.

    FIELD-SYMBOLS <ret_evento> TYPE /s4tax/s_nfe_ret_evento.

    READ TABLE response-ret_env_evento-ret_evento ASSIGNING <ret_evento> INDEX 1.
    IF sy-subrc <> 0.
      api_document->change_response_for_error( CHANGING output_data = bad_request ).
      create_bad_request( bad_request ).

      code = bad_request-c_stat.
      IF code IS INITIAL.
        code = /s4tax/dfe_constants=>status_code-s4tax_communic_error.
      ENDIF.

      dfe_event->set_code( code ).
      RETURN.
    ENDIF.

    code      = <ret_evento>-inf_evento-c_stat.
    dh_evento = <ret_evento>-inf_evento-dh_reg_evento.
    authcode  = <ret_evento>-inf_evento-n_prot.

    dfe_event->set_code( code ).
    dfe_event->set_dh_evento( dh_evento ).
    dfe_event->set_authcode( authcode ).

  ENDMETHOD.


  METHOD process_output_nfe_ev_register.

    DATA: bad_request TYPE /s4tax/s_bad_request_o,
          code        TYPE j_1bstatuscode,
          dh_evento   TYPE /s4tax/e_reply_tstamp,
          authcode    TYPE j_1bnfeauthcode.

    FIELD-SYMBOLS <ret_evento> TYPE /s4tax/s_nfe_ret_evento.

    READ TABLE response-ret_env_evento-ret_evento ASSIGNING <ret_evento> INDEX 1.
    IF sy-subrc <> 0.
      api_dfe->change_response_for_error( CHANGING output_data = bad_request ).
      create_bad_request( bad_request ).

      code = bad_request-c_stat.
      IF code IS INITIAL.
        code = /s4tax/dfe_constants=>status_code-s4tax_communic_error.
      ENDIF.

      dfe_event->set_code( code ).
      RETURN.
    ENDIF.

    code      = <ret_evento>-inf_evento-c_stat.
    dh_evento = <ret_evento>-inf_evento-dh_reg_evento.
    authcode  = <ret_evento>-inf_evento-n_prot.

    IF code IS INITIAL.
      code = /s4tax/dfe_constants=>status_code-s4tax_error.
    ENDIF.

    dfe_event->set_code( code ).
    dfe_event->set_dh_evento( dh_evento ).
    dfe_event->set_authcode( authcode ).

  ENDMETHOD.


  METHOD create_bad_request.

    DATA msg TYPE string.

    FIELD-SYMBOLS <error> TYPE string.

    LOOP AT bad_request-errors ASSIGNING <error>.
      MESSAGE e000(/s4tax/dfe_integr) WITH <error> INTO msg.
      reporter->error( msg ).
    ENDLOOP.

  ENDMETHOD.


  METHOD mount_dfe_inutilizacao.

    DATA: bad_request    TYPE /s4tax/s_bad_request_o,
          inut_code      TYPE j_1bstatuscode VALUE /s4tax/dfe_constants=>status_code-rej_unknown,
          inut_dh_evento TYPE /s4tax/e_reply_tstamp,
          inut_authcode  TYPE j_1bnfeauthcode.

    IF inutilizacao_out-ret_inut_nfe-inf_inut IS INITIAL.
      api_document->change_response_for_error( CHANGING output_data = bad_request ).
      create_bad_request( bad_request ).

      inut_code = bad_request-c_stat.
      IF inut_code IS INITIAL.
        inut_code = /s4tax/dfe_constants=>status_code-s4tax_communic_error.
      ENDIF.

      dfe->set_inut_code( inut_code ).
      RETURN.
    ENDIF.

    inut_code      = inutilizacao_out-ret_inut_nfe-inf_inut-c_stat.
    inut_dh_evento = inutilizacao_out-ret_inut_nfe-inf_inut-dh_recbto.
    inut_authcode  = inutilizacao_out-ret_inut_nfe-inf_inut-n_prot.

    IF inut_code IS INITIAL.
      inut_code = /s4tax/dfe_constants=>status_code-s4tax_error.
      dfe->set_inut_code( inut_code ).
      RETURN.
    ENDIF.

    dfe->set_inut_code( inut_code ).
    dfe->set_inut_dh_evento( inut_dh_evento ).
    dfe->set_inut_authcode( inut_authcode ).

  ENDMETHOD.


  METHOD mount_input_for_nfe_recep_cc.

    DATA: ev_input TYPE /s4tax/s_eventos,
          event    TYPE /s4tax/iapi_dfe=>nfe_recepcao_evento_input.

    result-branch_id = input-branch_id.
    result-versao    = input-versao.
    result-id_lote   = input-id_lote.

    READ TABLE input-eventos INTO ev_input INDEX 1.
    event-ch_nfe       = ev_input-ch_nfe.
    event-tp_evento    = ev_input-tp_evento.
    event-n_prot       = ev_input-n_prot.
    event-x_just       = ev_input-x_just.
    event-n_seq_evento = ev_input-n_seq_evento.
    event-x_correcao   = ev_input-x_correcao.

    APPEND event TO result-eventos.

  ENDMETHOD.


  METHOD mount_output_for_nfe_rec_cc.

    DATA: recepcao_ret_evento TYPE /s4tax/iapi_dfe=>recepcao_ret_evento,
          s_nfe_ret_evento    TYPE /s4tax/s_nfe_ret_evento.

    result-ret_env_evento-attributes = dfe_output-ret_env_evento-attributes.
    result-ret_env_evento-id_lote    = dfe_output-ret_env_evento-id_lote.
    result-ret_env_evento-tp_amb     = dfe_output-ret_env_evento-tp_amb.
    result-ret_env_evento-ver_aplic  = dfe_output-ret_env_evento-ver_aplic.
    result-ret_env_evento-c_orgao    = dfe_output-ret_env_evento-c_orgao.
    result-ret_env_evento-x_motivo   = dfe_output-ret_env_evento-x_motivo.
    result-ret_env_evento-c_stat     = dfe_output-ret_env_evento-c_stat.

    IF result-ret_env_evento-c_stat IS INITIAL.
      result-ret_env_evento-c_stat = /s4tax/dfe_constants=>status_code-s4tax_communic_error.
    ENDIF.

    READ TABLE dfe_output-ret_env_evento-ret_evento INTO recepcao_ret_evento INDEX 1.

    s_nfe_ret_evento-inf_evento-attributes    = recepcao_ret_evento-attributes.
    s_nfe_ret_evento-inf_evento-tp_amb        = recepcao_ret_evento-inf_evento-tp_amb.
    s_nfe_ret_evento-inf_evento-ver_aplic     = recepcao_ret_evento-inf_evento-ver_aplic.
    s_nfe_ret_evento-inf_evento-c_orgao       = recepcao_ret_evento-inf_evento-c_orgao.
    s_nfe_ret_evento-inf_evento-x_motivo      = recepcao_ret_evento-inf_evento-x_motivo.
    s_nfe_ret_evento-inf_evento-ch_nfe        = recepcao_ret_evento-inf_evento-ch_nfe.
    s_nfe_ret_evento-inf_evento-tp_evento     = recepcao_ret_evento-inf_evento-tp_evento.
    s_nfe_ret_evento-inf_evento-x_evento      = recepcao_ret_evento-inf_evento-x_evento.
    s_nfe_ret_evento-inf_evento-n_seq_evento  = recepcao_ret_evento-inf_evento-n_seq_evento.
    s_nfe_ret_evento-inf_evento-c_orgao_autor = recepcao_ret_evento-inf_evento-c_orgao_autor.
    s_nfe_ret_evento-inf_evento-email_dest    = recepcao_ret_evento-inf_evento-email_dest.
    s_nfe_ret_evento-inf_evento-dh_reg_evento = recepcao_ret_evento-inf_evento-dh_reg_evento.
    s_nfe_ret_evento-inf_evento-n_prot        = recepcao_ret_evento-inf_evento-n_prot.
    s_nfe_ret_evento-inf_evento-c_stat        = recepcao_ret_evento-inf_evento-c_stat.

    IF s_nfe_ret_evento-inf_evento-c_stat IS INITIAL.
      s_nfe_ret_evento-inf_evento-c_stat = /s4tax/dfe_constants=>status_code-s4tax_communic_error.
    ENDIF.

    APPEND s_nfe_ret_evento TO result-ret_env_evento-ret_evento.

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


  METHOD get_xml_from_local_repository.
    DATA: dao_dfe_xml TYPE REF TO /s4tax/idao_dfe_xml
    .
    IF access_key IS INITIAL.
      RETURN.
    ENDIF.

    dao_dfe_xml = dao_document->dfe_xml( ).

    result = dao_dfe_xml->get_xml_with_dockey( access_key ).

  ENDMETHOD.


  METHOD get_xml_from_orbit.

    DATA: dao                TYPE REF TO /s4tax/idao_document,
          dao_dfe            TYPE REF TO /s4tax/idao_dfe,
          dfe                TYPE REF TO /s4tax/dfe,
          msg_v1             TYPE string,
          nfe_id             TYPE /s4tax/e_dfe_id,
          xml_content_string TYPE string,
          dao_doc            TYPE REF TO /s4tax/idao_doc,
          dal_doc            TYPE REF TO /s4tax/idal_doc,
          doc                TYPE REF TO /s4tax/doc.

    dao     = /s4tax/dao_document=>get_instance( ).
    dao_dfe = dao->dfe( ).
    dao_doc = dao_pack_model_business->doc( ).
    dal_doc = dao_pack_model_business->doc_dal( ).
    dfe = dao_dfe->get( docnum = docnum ).
    doc = dao_doc->get( docnum ).
    dal_doc->fill_active( doc ).

    IF dfe IS NOT BOUND OR dfe->get_id( ) IS INITIAL.
      msg_v1 = docnum.
      RAISE EXCEPTION TYPE /s4tax/cx_dfe_integration
        EXPORTING
          textid = /s4tax/cx_dfe_integration=>nfe_id_not_found
          msg_v1 = msg_v1.
    ENDIF.

    nfe_id = dfe->get_id( ).
    xml_content_string = get_nfe_xml_by_nfe_id( nfe_id = nfe_id model = model ).

    IF xml_content_string IS INITIAL.
      RAISE EXCEPTION TYPE /s4tax/cx_dfe_integration EXPORTING textid = /s4tax/cx_dfe_integration=>xml_not_found.
    ENDIF.

    result = cl_bcs_convert=>string_to_xstring( iv_string = xml_content_string ).
    me->save_xml_in_local_repo( doc = doc xml = result ).

  ENDMETHOD.


  METHOD get_dfe_xml.
    DATA: xml_from_legacy TYPE xstring,
          xml_from_orbit  TYPE xstring.

    result = me->get_xml_from_local_repository( access_key = access_key ).
    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.
    result = me->get_xml_from_orbit( docnum = docnum model = model ).

    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    RAISE EXCEPTION TYPE /s4tax/cx_dfe_integration EXPORTING textid = /s4tax/cx_dfe_integration=>xml_not_found.


  ENDMETHOD.


  METHOD save_xml_in_local_repo.

    DATA:
      xml_item TYPE /s4tax/tdfe_xml,
      date     TYPE REF TO /s4tax/date,
      dfe_xml  TYPE REF TO /s4tax/dfe_xml,
      dao_dfe  TYPE REF TO /s4tax/idao_dfe_xml.

    IF doc IS NOT BOUND.
      RETURN.
    ENDIF.

    MOVE-CORRESPONDING doc->struct TO xml_item.
    xml_item-dockey = doc->get_active( )->get_access_key( ).
    xml_item-source = '01'. "Alterar para obter valor de uma CFG
    xml_item-xmlraw = xml.
    xml_item-created_by = sy-uname.

    date = /s4tax/date=>create_utc_now( ).
    xml_item-created_at = date->to_timestamp(  ).

    IF xml_item-dockey IS INITIAL.
      RETURN.
    ENDIF.

    CREATE OBJECT dfe_xml
      EXPORTING
        iw_struct = xml_item.

    dao_dfe = dao_document->dfe_xml(  ).
    dao_dfe->save( dfe_xml ).

  ENDMETHOD.
ENDCLASS.