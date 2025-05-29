*&---------------------------------------------------------------------*
*& Include /s4tax/cl_badi_nfse_t99
*&---------------------------------------------------------------------*
CLASS lcl_event_badi_nfse DEFINITION
  INHERITING FROM /s4tax/nfse_events.

  PUBLIC SECTION.
    METHODS:
      get_reporter REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_event_badi_nfse IMPLEMENTATION.

  METHOD get_reporter.
    DATA: reporter_setting TYPE REF TO /s4tax/ireporter_settings.

    CREATE OBJECT reporter_setting TYPE /s4tax/reporter_settings.
    reporter_setting->set_autosave( abap_false ).

  ENDMETHOD.

ENDCLASS.

CLASS lcl_badi_nfse DEFINITION
CREATE PUBLIC INHERITING FROM /s4tax/cl_badi_nfse.

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS:
      call_send_email_bcs REDEFINITION,
      call_j_1b_nf_document_cancel REDEFINITION,
      call_bapi_transaction_rollback REDEFINITION,
      call_bapi_transaction_commit REDEFINITION,
      call_bapi_billingdoc_cancel1 REDEFINITION,
      fill_danfe_select REDEFINITION.

  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_badi_nfse IMPLEMENTATION.

  METHOD call_send_email_bcs.

    IF email_data IS NOT BOUND OR email_data->get_recipient( ) IS INITIAL.
      RAISE EXCEPTION TYPE cx_address_bcs.
    ENDIF.

  ENDMETHOD.

  METHOD call_j_1b_nf_document_cancel.

    IF item->struct-cean IS INITIAL.
      result = '1'.
    ENDIF.
  ENDMETHOD.

  METHOD call_bapi_transaction_rollback.
  ENDMETHOD.

  METHOD call_bapi_transaction_commit.
  ENDMETHOD.

  METHOD call_bapi_billingdoc_cancel1.

    IF vbeln = '123'.
      APPEND 'E' TO return.
    ENDIF.

  ENDMETHOD.

  METHOD fill_danfe_select.
    danfe_select->select( ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_cl_badi_nfse DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS: interface_reporter        TYPE seoclsname VALUE '/S4TAX/IREPORTER',
               interface_danfe_select    TYPE seoclsname VALUE '/S4TAX/IDANFE_SELECT_DATA',
               interface_danfe_generator TYPE seoclsname VALUE '/S4TAX/IDANFE_GENERATOR',
               interface_danfe_maneger   TYPE seoclsname VALUE '/S4TAX/IF_DANFE_MANAGER',
               interface_api_document    TYPE seoclsname VALUE '/S4TAX/IAPI_DOCUMENT',
               interface_nfse_processor  TYPE seoclsname VALUE '/S4TAX/INFSE_PROCESSOR',
               interface_document        TYPE seoclsname VALUE '/S4TAX/IDAO_DOCUMENT',
               interface_dao_email_cfg   TYPE seoclsname VALUE '/S4TAX/IDAO_DFE_EMAIL_CFG',
               interface_dao_dfe_cfg     TYPE seoclsname VALUE '/S4TAX/IDAO_DFE_CFG'.

    DATA: cut             TYPE REF TO lcl_badi_nfse,
          active          TYPE REF TO /s4tax/nfse_active,
          doc             TYPE REF TO /s4tax/doc,
          document        TYPE REF TO /s4tax/nfse_documents,
          danfe_select    TYPE REF TO /s4tax/idanfe_select_data,
          dfe_email_cfg   TYPE REF TO /s4tax/dfe_email_cfg,
          dfe_email_cfg_t TYPE  /s4tax/dfe_email_cfg_t,
          email           TYPE /s4tax/string_t,
          email_body      TYPE /s4tax/string_t,
          pdf             TYPE xstring,
          nfse_consulta   TYPE /s4tax/e_dfe_id,
          item            TYPE REF TO /s4tax/item,
          event           TYPE REF TO lcl_event_badi_nfse,
          dfe_cfg         TYPE REF TO /s4tax/document_config.

    CLASS-DATA: mock_reporter        TYPE REF TO /s4tax/ireporter,
                mock_danfe_select    TYPE REF TO /s4tax/idanfe_select_data,
                mock_danfe_generator TYPE REF TO /s4tax/idanfe_generator,
                mock_danfe_maneger   TYPE REF TO /s4tax/if_danfe_manager,
                mock_api_document    TYPE REF TO /s4tax/iapi_document,
                mock_document        TYPE REF TO /s4tax/idao_document,
                mock_nfse_processor  TYPE REF TO /s4tax/infse_processor,
                mock_dao_email_cfg   TYPE REF TO /s4tax/idao_dfe_email_cfg,
                mock_dao_dfe_cfg     TYPE REF TO /s4tax/idao_dfe_cfg,
                mock_dfe_cfg         TYPE REF TO /s4tax/document_config.

    METHODS:
      setup,
      mount_data,
      mock_configuration,
      email_auto_send_true FOR TESTING RAISING cx_static_check,
      nfse_authorized FOR TESTING RAISING cx_static_check,
      nfse_unauthorized FOR TESTING RAISING cx_static_check,
      nfse_canceled FOR TESTING RAISING cx_static_check,
      nfse_not_canceled FOR TESTING RAISING cx_static_check,
      cancel_doc_and_invoice FOR TESTING RAISING cx_static_check,
      cancel_doc FOR TESTING RAISING cx_static_check,
      erro_cancel FOR TESTING RAISING cx_static_check,
      save_docs_standard FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_cl_badi_nfse IMPLEMENTATION.

  METHOD setup.
    DATA: settings TYPE REF TO /s4tax/reporter_settings.

    mock_danfe_generator    ?= cl_abap_testdouble=>create( interface_danfe_generator ).
    mock_danfe_select       ?= cl_abap_testdouble=>create( interface_danfe_select ).
    mock_reporter           ?= cl_abap_testdouble=>create( interface_reporter ).
    mock_danfe_maneger      ?= cl_abap_testdouble=>create( interface_danfe_maneger ).
    mock_api_document       ?= cl_abap_testdouble=>create( interface_api_document ).
    mock_nfse_processor     ?= cl_abap_testdouble=>create( interface_nfse_processor ).
    mock_document           ?= cl_abap_testdouble=>create( interface_document ).
    mock_dao_email_cfg      ?= cl_abap_testdouble=>create( interface_dao_email_cfg ).

    "TODO: Criar mock para dao_dfe_config *****
    mock_dao_dfe_cfg        ?= cl_abap_testdouble=>create( interface_dao_dfe_cfg ).

    CREATE OBJECT settings.
    settings->/s4tax/ireporter_settings~set_autosave( i_auto_save = abap_false ).

    mount_data(  ).
    mock_configuration(  ).

    TRY.
        cut = NEW #( reporter       = mock_reporter
                     danfe_manager  = mock_danfe_maneger
                     dao_document   = mock_document
                     nfse_processor = mock_nfse_processor ).
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD mount_data.
    DATA: string_utils TYPE REF TO /s4tax/string_utils.

    APPEND 'pedro@email.com.br' TO me->email.
    APPEND 'Corpo do email' TO me->email_body.

    CREATE OBJECT string_utils.
    me->pdf = string_utils->to_xstring( 'pdf' ).

    active = NEW #(  ).
    active->set_id( 'id' ).
    doc = NEW #(  ).

    CREATE OBJECT dfe_email_cfg.
    dfe_email_cfg->set_auto_send( '1' ).

    APPEND dfe_email_cfg TO dfe_email_cfg_t.

    document = NEW #(  ).
    document->set_active( active ).
    document->set_doc( doc ).

    doc = document->get_doc( ).

  ENDMETHOD.

  METHOD mock_configuration.
    cl_abap_testdouble=>configure_call( mock_danfe_select )->ignore_all_parameters( ).
    mock_danfe_select->select(  ).

    cl_abap_testdouble=>configure_call( mock_danfe_generator )->ignore_all_parameters( ).
    mock_danfe_generator->generate( ).

    cl_abap_testdouble=>configure_call( mock_danfe_maneger )->returning( mock_danfe_select )->ignore_all_parameters( ).
    mock_danfe_maneger->select( ).

    cl_abap_testdouble=>configure_call( mock_danfe_maneger )->returning( mock_danfe_generator )->ignore_all_parameters( ).
    mock_danfe_maneger->generate( danfe_select ).

    "Gets
    cl_abap_testdouble=>configure_call( mock_danfe_generator )->returning( email )->ignore_all_parameters( ).
    mock_danfe_generator->get_email_recipient( ).

    cl_abap_testdouble=>configure_call( mock_danfe_generator )->returning( 'douglas@email.com.br' )->ignore_all_parameters( ).
    mock_danfe_generator->get_email_sender( ).

    cl_abap_testdouble=>configure_call( mock_danfe_generator )->returning( 'assunto' )->ignore_all_parameters( ).
    mock_danfe_generator->get_email_subject( ).

    cl_abap_testdouble=>configure_call( mock_danfe_generator )->returning( email_body )->ignore_all_parameters( ).
    mock_danfe_generator->get_email_body( ).

    cl_abap_testdouble=>configure_call( mock_danfe_generator )->returning( 'NFSe_MG_1234' )->ignore_all_parameters( ).
    mock_danfe_generator->get_attach_name( ).

    "get's attachment
    cl_abap_testdouble=>configure_call( mock_api_document )->returning( 'teste' )->ignore_all_parameters( ).
    mock_api_document->nfse_consulta_xml( nfse_consulta ).

    cl_abap_testdouble=>configure_call( mock_nfse_processor )->returning( '7465737465' )->ignore_all_parameters( ).
    mock_nfse_processor->get_nfse_xml( id  = '' source = '' ).

    cl_abap_testdouble=>configure_call( mock_danfe_generator )->returning( pdf )->ignore_all_parameters( ).
    mock_danfe_generator->get_pdf_data( ).

    cl_abap_testdouble=>configure_call( mock_document )->returning( mock_dao_email_cfg )->ignore_all_parameters( ).
    mock_document->dfe_email_cfg( ).

    "dfe_cfg
    cl_abap_testdouble=>configure_call( mock_document )->returning( mock_dao_dfe_cfg )->ignore_all_parameters( ).
    mock_document->dfe_cfg( ).

    cl_abap_testdouble=>configure_call( mock_dao_dfe_cfg )->returning( mock_dfe_cfg )->ignore_all_parameters( ).
    mock_dao_dfe_cfg->get_first( ).

    "TODO: Configure a CALL para mock_dfe_cfg->get_first( ), retornando o valor que for necessário para seu teste.
    "      Dica: se for testar os dois cenários: LOGBR e FTX, defina a variável de retorno na definição da classe,
    "            altere o valor dela no método teste e tente chamar mock_configuration dentro deste método.
    "            Se não for possível chamar o mock_configuration, crie um método de mock config próprio para o
    "            mock_dao_dfe_cfg e chame dentro do método de teste.

    cl_abap_testdouble=>configure_call( mock_dao_email_cfg )->returning( dfe_email_cfg )->ignore_all_parameters( ).
    mock_dao_email_cfg->get( '' ).

    cl_abap_testdouble=>configure_call( mock_dao_email_cfg )->returning( dfe_email_cfg_t )->ignore_all_parameters( ).
    mock_dao_email_cfg->get_many( package_list = VALUE #( ) ).


  ENDMETHOD.

  METHOD email_auto_send_true.
    DATA: act            TYPE abap_bool.

    APPEND 'pedro2@email.com.br' TO email.

    cut->/s4tax/if_badi_nfse~nfse_send_email( EXPORTING documents = document
                                              CHANGING  result    = act ).

    cl_abap_unit_assert=>assert_equals( exp = abap_true act = act ).

    cl_abap_unit_assert=>assert_bound( act = cut->get_email_data( ) ).

    DATA(attachments) = cut->get_email_data( )->get_attachments( ).
    cl_abap_unit_assert=>assert_not_initial( act = attachments ).

    DATA(attachment_size) = lines( attachments ).
    cl_abap_unit_assert=>assert_equals( act = attachment_size exp = 2 ).
  ENDMETHOD.

  METHOD nfse_authorized.

    cut->/s4tax/if_badi_nfse~nfse_authorized( document ).
    cl_abap_unit_assert=>assert_bound( act = cut->get_email_data( ) ).

  ENDMETHOD.

  METHOD nfse_unauthorized.

    dfe_email_cfg->set_auto_send( '' ).
    mock_configuration(  ).

    cut->/s4tax/if_badi_nfse~nfse_authorized( document ).
    cl_abap_unit_assert=>assert_not_bound( act = cut->get_email_data( ) ).

  ENDMETHOD.

  METHOD nfse_canceled.
    DATA: act TYPE abap_bool.

    DATA(doc) = document->get_doc( ).
    doc->set_cancel( iv_cancel = abap_true ).
    cut->/s4tax/if_badi_nfse~nfse_canceled( EXPORTING documents = document
                                            CHANGING  result    = act ).

    cl_abap_unit_assert=>assert_not_bound( act = me->item ).
  ENDMETHOD.

  METHOD nfse_not_canceled.
    DATA: item_list TYPE /s4tax/item_t,
          act       TYPE abap_bool.

    item = NEW #( ).
    APPEND item TO item_list.
    event = NEW #( ).
    active->add_event( event = event ).

    doc->set_item_list( item_list ).
    doc->set_cancel( iv_cancel = abap_false ).


    cut->/s4tax/if_badi_nfse~nfse_canceled( EXPORTING documents = document
                                            CHANGING  result    = act ).

    cl_abap_unit_assert=>assert_true( act = act ).
  ENDMETHOD.

  METHOD cancel_doc. "abap_bool - false
    DATA: item_list TYPE /s4tax/item_t,
          act       TYPE abap_bool,
          lx_nfse   TYPE REF TO /s4tax/cx_nfse.

    doc->set_cancel( iv_cancel = abap_false ).

    item = NEW #( ).
    item->set_cean( '1' ).
    APPEND item TO item_list.
    doc->set_item_list( item_list ).

    TRY.
        cut->/s4tax/if_badi_nfse~nfse_canceled( EXPORTING documents = document
                                                CHANGING  result    = act ).
      CATCH /s4tax/cx_nfse INTO lx_nfse.
        cl_abap_unit_assert=>assert_bound( act = lx_nfse ).
    ENDTRY.

  ENDMETHOD.

  METHOD cancel_doc_and_invoice.
    DATA: item_list TYPE /s4tax/item_t,
          act       TYPE abap_bool.

    doc->set_cancel( iv_cancel = abap_false ).

    item = NEW #( ).
    item->set_reftyp( iv_reftyp = 'BI' ).
    item->set_refkey( '12345678901234567890123456789012345' ).
    APPEND item TO item_list.
    doc->set_item_list( item_list ).
    cut->/s4tax/if_badi_nfse~nfse_canceled( EXPORTING documents = document
                                            CHANGING  result    = act ).

    cl_abap_unit_assert=>assert_true( act = act ).

  ENDMETHOD.

  METHOD erro_cancel.
    DATA: item_list TYPE /s4tax/item_t,
          act       TYPE abap_bool,
          lx_nfse   TYPE REF TO /s4tax/cx_nfse.

    doc->set_cancel( iv_cancel = abap_false ).

    item = NEW #( ).

    item->set_reftyp( iv_reftyp = 'BI' ).
    item->set_refkey( '123' ).
    APPEND item TO item_list.
    doc->set_item_list( item_list ).

    TRY.
        cut->/s4tax/if_badi_nfse~nfse_canceled( EXPORTING documents = document
                                                CHANGING  result    = act ).
      CATCH /s4tax/cx_nfse INTO lx_nfse.
        cl_abap_unit_assert=>assert_bound( act = lx_nfse ).
    ENDTRY.

  ENDMETHOD.

  METHOD save_docs_standard.

    DATA: reporter TYPE REF TO /s4tax/ireporter.

    mock_dfe_cfg = NEW /s4tax/document_config(
      iw_struct = VALUE /s4tax/tdfe_cfg(
        start_operation    = '20250514'
        job_ex_type        = '1'
        status_update_time = '120500'
        grc_destination    = 'test_value_grc_rfc'
        save_xml           = 'X' )
    ).

    mock_dfe_cfg->set_source_text( '1' ). "FTX
    mock_dfe_cfg->set_source_text( '2' ). "LOGBR

    mock_configuration( ).
    reporter = NEW /s4tax/reporter( ).

    "TODO: Implementar este teste
    "cut->/s4tax/if_badi_nfse~save_docs_standard( doc = doc reporter = reporter ).

  ENDMETHOD.

ENDCLASS.