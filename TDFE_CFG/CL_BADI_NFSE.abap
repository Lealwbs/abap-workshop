CLASS /s4tax/cl_badi_nfse DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPE-POOLS abap.

    INTERFACES if_badi_interface .
    INTERFACES /s4tax/if_badi_nfse .

    METHODS:
      constructor IMPORTING reporter       TYPE REF TO /s4tax/ireporter OPTIONAL
                            danfe_manager  TYPE REF TO /s4tax/if_danfe_manager OPTIONAL
                            dao_document   TYPE REF TO /s4tax/idao_document OPTIONAL
                            nfse_processor TYPE REF TO /s4tax/infse_processor OPTIONAL,

      get_email_data RETURNING VALUE(result) TYPE REF TO /s4tax/email_data .

  PROTECTED SECTION.
    TYPES:
      ty_return  TYPE STANDARD TABLE OF bapireturn1 WITH DEFAULT KEY,
      ty_success TYPE STANDARD TABLE OF bapivbrksuccess WITH DEFAULT KEY.

    DATA:
      api_document      TYPE REF TO /s4tax/iapi_document,
      dao_pack_document TYPE REF TO /s4tax/idao_document,
      reporter          TYPE REF TO /s4tax/ireporter,
      email_data        TYPE REF TO /s4tax/email_data,
      danfe_manager     TYPE REF TO /s4tax/if_danfe_manager,
      go_badi_nfse      TYPE REF TO /s4tax/badi_nfse,
      nfse_processor    TYPE REF TO /s4tax/infse_processor.

    METHODS:
      create_email_nfse IMPORTING danfe_generator TYPE REF TO /s4tax/idanfe_generator
                                  dfe_id          TYPE /s4tax/tnfse_act-id
                        RETURNING VALUE(result)   TYPE REF TO /s4tax/email_data
                        RAISING   /s4tax/cx_http /s4tax/cx_auth,

      get_nfse_processor RETURNING VALUE(result) TYPE REF TO /s4tax/infse_processor,

      attach_xml IMPORTING email_data  TYPE REF TO /s4tax/email_data
                           dfe_id      TYPE /s4tax/tnfse_act-id
                           attach_name TYPE string
                 RAISING   /s4tax/cx_http /s4tax/cx_auth,

      attach_pdf IMPORTING email_data  TYPE REF TO /s4tax/email_data
                           dfe_id      TYPE /s4tax/tnfse_act-id
                           attach_name TYPE string
                 RAISING   /s4tax/cx_http /s4tax/cx_auth,

*      attach_pdf IMPORTING email_data      TYPE REF TO /s4tax/email_data
*                           danfe_generator TYPE REF TO /s4tax/idanfe_generator
*                           attach_name     TYPE string,

      cancel_nfse IMPORTING reversal_date TYPE dats OPTIONAL
                            documents     TYPE REF TO /s4tax/nfse_documents
                  RETURNING VALUE(result) TYPE abap_bool
                  RAISING   /s4tax/cx_nfse,

      cancel_doc_and_invoice IMPORTING reversal_date TYPE dats OPTIONAL
                                       item          TYPE REF TO /s4tax/item
                                       reporter      TYPE REF TO /s4tax/ireporter
                             RETURNING VALUE(result) TYPE abap_bool,

      cancel_doc IMPORTING item          TYPE REF TO /s4tax/item
                           reporter      TYPE REF TO /s4tax/ireporter
                 RETURNING VALUE(result) TYPE   abap_bool,

      check_send_email  IMPORTING branch           TYPE REF TO /s4tax/branch OPTIONAL
                                  doc              TYPE REF TO /s4tax/doc OPTIONAL
                                  check_email_type TYPE abap_bool OPTIONAL
                        RETURNING VALUE(result)    TYPE abap_bool,

      call_send_email_bcs IMPORTING email_data TYPE REF TO /s4tax/email_data
                          RAISING   cx_bcs,

      call_j_1b_nf_document_cancel IMPORTING item          TYPE REF TO /s4tax/item
                                             ref_type      TYPE j_1bnflin-reftyp
                                             ref_key       TYPE j_1bnflin-refkey
                                   RETURNING VALUE(result) TYPE j_1bnfdoc-docnum,

      call_bapi_transaction_rollback,

      call_bapi_transaction_commit,

      call_bapi_billingdoc_cancel1 IMPORTING vbeln         TYPE vbeln
                                             reversal_date TYPE dats OPTIONAL
                                   RETURNING VALUE(return) TYPE ty_return ,

      fill_danfe_select IMPORTING danfe_select TYPE REF TO /s4tax/idanfe_select_data
                                  documents    TYPE REF TO /s4tax/nfse_documents.

  PRIVATE SECTION.
    DATA: dfe_email_cfg   TYPE REF TO /s4tax/dfe_email_cfg,
          dfe_email_cfg_t TYPE /s4tax/dfe_email_cfg_t.

    METHODS: fill_texts,
      save_doc.

ENDCLASS.

CLASS /s4tax/cl_badi_nfse IMPLEMENTATION.

  METHOD constructor.
    DATA: docnum        TYPE /s4tax/tdfe-docnum,
          dao_email_cfg TYPE REF TO /s4tax/idao_dfe_email_cfg,
          range         TYPE ace_generic_range_t.

    me->reporter = reporter.
    IF me->reporter IS NOT BOUND.

      me->reporter = /s4tax/reporter_factory=>create( object    = /s4tax/reporter_factory=>object-s4tax
                                                      subobject = /s4tax/reporter_factory=>subobject-docs ).
    ENDIF.

    me->nfse_processor = nfse_processor.
    IF me->nfse_processor IS NOT BOUND.
      CREATE OBJECT me->nfse_processor TYPE /s4tax/nfse_processor EXPORTING reporter = me->reporter.
    ENDIF.

    me->danfe_manager = danfe_manager.
    IF me->danfe_manager IS NOT BOUND.
      me->danfe_manager = /s4tax/nfse_danfe_manager=>create_instance( docnum = docnum reporter = me->reporter ).
    ENDIF.

    me->dao_pack_document = dao_document.
    IF me->dao_pack_document IS NOT BOUND.
      me->dao_pack_document = /s4tax/dao_document=>get_instance( ).
    ENDIF.

    dao_email_cfg = dao_pack_document->dfe_email_cfg( ).
    "me->dfe_email_cfg = dao_email_cfg->get( /s4tax/constants=>package_name-nfse ).
    range = /s4tax/range_utils=>simple_range( /s4tax/constants=>package_name-nfse ).
    me->dfe_email_cfg_t = dao_email_cfg->get_many( package_list = range ).

  ENDMETHOD.

  METHOD /s4tax/if_badi_nfse~nfse_authorized.
    DATA: is_sent    TYPE abap_bool,
          send_email TYPE abap_bool.

    me->/s4tax/if_badi_nfse~nfse_send_email( EXPORTING documents        = documents
                                                       check_email_type = abap_true
                                             CHANGING  result           = is_sent ).


  ENDMETHOD.

  METHOD /s4tax/if_badi_nfse~nfse_canceled.
    result = me->cancel_nfse( documents ).
  ENDMETHOD.

  METHOD /s4tax/if_badi_nfse~nfse_send_email.
    DATA:
      active          TYPE REF TO /s4tax/nfse_active,
      cx_root         TYPE REF TO cx_root,
      danfe_select    TYPE REF TO /s4tax/idanfe_select_data,
      danfe_generator TYPE REF TO /s4tax/idanfe_generator,
      msg             TYPE string,
      send_email      TYPE abap_bool,
      doc             TYPE REF TO /s4tax/doc,
      branch          TYPE REF TO /s4tax/branch.

    active = documents->get_active( ).

    TRY.
        danfe_manager->set_docnum( active->struct-docnum ).
        danfe_select = danfe_manager->select( ).
        fill_danfe_select( danfe_select = danfe_select documents = documents ).
        danfe_generator = danfe_manager->generate( danfe_select ).

        doc = danfe_select->get_doc( ).
        branch = danfe_select->get_branch( ).
        send_email = me->check_send_email( check_email_type = check_email_type doc = doc branch = branch ).
        IF send_email = abap_false.
          RETURN.
        ENDIF.

        email_data = create_email_nfse( danfe_generator = danfe_generator dfe_id = active->struct-id ).
        call_send_email_bcs( email_data ).

      CATCH cx_root INTO cx_root.
        active->set_send_email( /s4tax/dfe_constants=>email_status-error ).
        msg = cx_root->get_text(  ).
        me->reporter->error( msg ).
        RETURN.
    ENDTRY.

    active->set_send_email( /s4tax/dfe_constants=>email_status-sent ).
    result = abap_true.
  ENDMETHOD.

  METHOD /s4tax/if_badi_nfse~nfse_tax_recalculation.
    "Implement client"

  ENDMETHOD.

  METHOD attach_pdf.
    DATA: attachment  TYPE REF TO /s4tax/email_attachment,
          pdf_xstring TYPE xstring,
          encoding    TYPE abap_encoding,
          output      TYPE string.

    me->get_nfse_processor(  ).

    TRY.
        pdf_xstring = me->nfse_processor->get_nfse_pdf( id = dfe_id source = /s4tax/nfse_constants=>document_source-orbit ).
      CATCH /s4tax/cx_nfse.
        RETURN.
    ENDTRY.

    CREATE OBJECT attachment
      EXPORTING
        name    = attach_name
        content = pdf_xstring
        type    = /s4tax/email_attachment=>attachment_type-pdf.

    email_data->add_attachment( attachment ).

  ENDMETHOD.

  METHOD attach_xml.

    DATA: attachment   TYPE REF TO /s4tax/email_attachment,
          string_utils TYPE REF TO /s4tax/string_utils,
          xml_xstring  TYPE xstring,
          encoding     TYPE abap_encoding,
          output       TYPE string.

    me->get_nfse_processor(  ).

    TRY.
        xml_xstring = me->nfse_processor->get_nfse_xml( id = dfe_id source = /s4tax/nfse_constants=>document_source-orbit ).
      CATCH /s4tax/cx_nfse.
        RETURN.
    ENDTRY.

    CREATE OBJECT attachment
      EXPORTING
        name    = attach_name
        content = xml_xstring
        type    = /s4tax/email_attachment=>attachment_type-xml.
    email_data->add_attachment( attachment ).

  ENDMETHOD.

  METHOD cancel_doc.
    DATA: msg        TYPE string,
          doc_cancel TYPE j_1bnfdoc-docnum,
          ref_type   TYPE j_1bnflin-reftyp,
          ref_key    TYPE j_1bnflin-refkey,
          vbeln      TYPE vbeln.

    IF item IS NOT BOUND.
      RETURN.
    ENDIF.

    vbeln = item->get_sales_code_from_refkey(  ).
    IF vbeln IS NOT INITIAL.
      ref_type = 'BI'.
      ref_key = vbeln.
    ENDIF.

    doc_cancel = call_j_1b_nf_document_cancel( item = item ref_type = ref_type ref_key = ref_key )."
    IF doc_cancel IS INITIAL.

      call_bapi_transaction_rollback( ).
      MESSAGE e015(/s4tax/nfse) WITH item->struct-docnum INTO msg.
      reporter->error( msg ).
      RETURN.
    ENDIF.

    call_bapi_transaction_commit( ).

    result = abap_true.

  ENDMETHOD.

  METHOD cancel_doc_and_invoice.
    DATA: vbeln     TYPE vbeln,
          return    TYPE TABLE OF bapireturn1,
          wa_return TYPE bapireturn1,
          msg       TYPE string.

    IF item IS NOT BOUND.
      RETURN.
    ENDIF.

    vbeln = item->get_sales_code_from_refkey(  ).
    IF vbeln IS INITIAL.
      RETURN.
    ENDIF.

    return = call_bapi_billingdoc_cancel1( vbeln = vbeln reversal_date = reversal_date ).

    READ TABLE return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      call_bapi_transaction_commit( ).
      result = abap_true.
      RETURN.
    ENDIF.

    call_bapi_transaction_rollback( ).
    DELETE return WHERE type <> 'E'.
    MESSAGE e015(/s4tax/nfse) WITH item->struct-docnum INTO msg.
    reporter->error( msg ).

    LOOP AT return INTO wa_return.
      CONCATENATE wa_return-type wa_return-id wa_return-number wa_return-message INTO msg SEPARATED BY '/'.
      reporter->error( msg ).
    ENDLOOP.

  ENDMETHOD.

  METHOD cancel_nfse.
    DATA: doc      TYPE REF TO /s4tax/doc,
          item     TYPE REF TO /s4tax/item,
          canceled TYPE abap_bool,
          active   TYPE REF TO /s4tax/nfse_active,
          event    TYPE REF TO /s4tax/nfse_events,
          msg      TYPE string.

    doc = documents->get_doc( ).
    canceled = doc->get_cancel( ).
    item = doc->get_item_by_index( 1 ).
    IF canceled = abap_true OR item IS NOT BOUND.
      RETURN.
    ENDIF.

    active = documents->get_active( ).
    event = active->get_last_event( ).
    IF event IS BOUND.
      reporter = event->get_reporter( ).
    ENDIF.

    IF item->struct-reftyp = 'BI'.
      canceled = cancel_doc_and_invoice( reversal_date = reversal_date item = item reporter = me->reporter ). "Tenta cancelar nota e fatura
    ELSE.
      canceled = cancel_doc( item = item reporter = reporter ). "Tenta cancelar apenas nota
    ENDIF.

    IF canceled <> abap_true.
      msg = doc->struct-docnum.
      RAISE EXCEPTION TYPE /s4tax/cx_nfse EXPORTING textid = /s4tax/cx_nfse=>cancel_impossible msg_v1 = msg.
    ENDIF.

    result = canceled.

  ENDMETHOD.

  METHOD create_email_nfse.

    DATA:
      recipient      TYPE string,
      recipient_cc   TYPE /s4tax/string_t,
      recipient_line TYPE string,
      recipient_list TYPE /s4tax/string_t,
      sender         TYPE string,
      text           TYPE /s4tax/string_t,
      attach_name    TYPE string,
      subject        TYPE string.

    recipient_list = danfe_generator->get_email_recipient( ).
    LOOP AT recipient_list INTO recipient_line.
      IF sy-tabix = 1.
        recipient = recipient_line.
        CONTINUE.
      ENDIF.
      APPEND recipient_line TO recipient_cc.
    ENDLOOP.

    sender = danfe_generator->get_email_sender( ).
    subject = danfe_generator->get_email_subject( ).

    CREATE OBJECT result
      EXPORTING
        recipient = recipient
        sender    = sender
        subject   = subject.

    text = danfe_generator->get_email_body( ).

    result->set_text( text ).
    result->set_type( /s4tax/email_data=>document_type-htm ).
    result->set_recipient_cc( recipient_cc = recipient_cc ).

    attach_name = danfe_generator->get_attach_name(  ).
    attach_xml( email_data = result dfe_id = dfe_id attach_name = attach_name ).
    attach_pdf( email_data = result dfe_id = dfe_id attach_name = attach_name ).
*    attach_pdf( email_data = result danfe_generator = danfe_generator attach_name = attach_name ).

  ENDMETHOD.


  METHOD call_send_email_bcs.

    DATA send_email TYPE REF TO /s4tax/send_email_bcs.

    CREATE OBJECT send_email EXPORTING data = email_data reporter = me->reporter.
    send_email->set_send_immediately( immediately = abap_false ).
    send_email->set_with_error_screen( with_error_screen = abap_false ).
    send_email->/s4tax/isend_email~send( ).

  ENDMETHOD.

  METHOD check_send_email.
    DATA: bukrs      TYPE docnum,
          branch_num TYPE j_1bbranc_.

    IF doc IS BOUND AND branch IS BOUND.
      bukrs = doc->struct-bukrs.
      branch_num = branch->struct-branch.
    ENDIF.

    READ TABLE dfe_email_cfg_t INTO dfe_email_cfg WITH KEY table_line->struct-bukrs = bukrs table_line->struct-branch = branch_num.
    IF sy-subrc <> 0.
      READ TABLE dfe_email_cfg_t INTO dfe_email_cfg WITH KEY table_line->struct-bukrs = bukrs table_line->struct-branch = ''.
      IF sy-subrc <> 0.
        READ TABLE dfe_email_cfg_t INTO dfe_email_cfg WITH KEY table_line->struct-bukrs = '' table_line->struct-branch = ''.
      ENDIF.
    ENDIF.

    IF dfe_email_cfg IS NOT BOUND OR dfe_email_cfg->struct-auto_send = ''.
      RETURN.
    ENDIF.

    IF check_email_type = abap_true AND dfe_email_cfg->struct-auto_send <> '1'.
      RETURN.
    ENDIF.

    result = abap_true.

  ENDMETHOD.

  METHOD get_email_data.
    result = me->email_data.
  ENDMETHOD.

  METHOD call_j_1b_nf_document_cancel.
    DATA: dfe_std TYPE REF TO /s4tax/dfe_std.

    dfe_std = /s4tax/dfe_std=>get_instance( ).
    result = dfe_std->j_1b_nf_document_cancel( doc_number = item->struct-docnum ref_type = ref_type ref_key = ref_key ).

  ENDMETHOD.

  METHOD call_bapi_transaction_rollback.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ENDMETHOD.

  METHOD call_bapi_transaction_commit.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ENDMETHOD.

  METHOD call_bapi_billingdoc_cancel1.

    DATA: success      TYPE ty_success,
          return_error TYPE bapireturn1.

    CALL FUNCTION 'BAPI_BILLINGDOC_CANCEL1'
      EXPORTING
        billingdocument = vbeln
        billingdate     = reversal_date
      TABLES
        return          = return
        success         = success
      EXCEPTIONS
        error_message   = 1.

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO return_error-message.
      return_error-id = sy-msgid.
      return_error-type = sy-msgty.
      return_error-number = sy-msgno.
      return_error-message_v1 = sy-msgv1.
      return_error-message_v2 = sy-msgv2.
      return_error-message_v3 = sy-msgv3.
      return_error-message_v4 = sy-msgv4.
      APPEND return_error TO return.

    ENDIF.

  ENDMETHOD.

  METHOD fill_danfe_select.
    DATA: nfse_danfe_select TYPE REF TO /s4tax/nfse_danfe_select.

    nfse_danfe_select ?= danfe_select.
    IF documents IS NOT BOUND OR nfse_danfe_select IS NOT BOUND.
      danfe_select->select( ).
      RETURN.
    ENDIF.

    nfse_danfe_select->set_nfse_documents( documents ).
    nfse_danfe_select->fill_branch_info( ).

  ENDMETHOD.

  METHOD /s4tax/if_badi_nfse~nfse_select.
*  fill_texts()
* redefinir e copiar o metodo "fill_texts" para a implementação do cliente em clientes aonde a tabela de textos for a LOGBR e nao a FTX.
  ENDMETHOD.

  METHOD /s4tax/if_badi_nfse~customize_json_emit.

  ENDMETHOD.

  METHOD /s4tax/if_badi_nfse~save_docs_standard.
* substituir o codigo atual pelo do metodo "save_doc" para a implementação do cliente em clientes aonde a tabela de textos for a LOGBR e nao a FTX.

    CONSTANTS: c_ftx   TYPE i VALUE 1,
               c_logbr TYPE i VALUE 2.

    DATA: dfe_cfg_obj TYPE REF TO /s4tax/dao_dfe_cfg.
    DATA: dao_dfe_cfg TYPE REF TO /s4tax/document_config.
    CREATE OBJECT dfe_cfg_obj.
    dao_dfe_cfg = dfe_cfg_obj->/s4tax/idao_dfe_cfg~get_first(  ).

    DATA: dfe_cfg_source_text type /s4tax/e_source_text.
    dfe_cfg_source_text = dao_dfe_cfg->get_source_text(  ).

    DATA: source_text TYPE /s4tax/e_source_text.
    source_text = 1. "Precisa de Implementação
    source_text = dfe_cfg_source_text. "Implementação Precisa de Testes

    IF source_text EQ c_logbr.
      "save_doc( ).     "QUANDO TERMINAR A TAREFA GERAR UM CARD NOVO

    ELSE. "source_text = c_ftx or source_text IS INITIAL
      DATA: doc_partner    TYPE ty_j_1bnfnad,
            doc_item       TYPE j_1bnflin_tab,
            doc_item_tax   TYPE j_1bnfstx_tab,
            doc_header_msg TYPE j_1bnfftx_tab,
            doc_refer_msg  TYPE j_1bnfref_tab,
            doc_header     TYPE j_1bnfdoc,
            dfe_std        TYPE REF TO /s4tax/dfe_std.

      IF doc->struct IS INITIAL.
        RETURN.
      ENDIF.

      dfe_std = /s4tax/dfe_std=>get_instance( ).
      dfe_std->j_1b_nf_document_read(
        EXPORTING
          doc_number         = doc->struct-docnum
        IMPORTING
          doc_header         = doc_header
          doc_partner        = doc_partner
          doc_item           = doc_item
          doc_item_tax       = doc_item_tax
          doc_header_msg     = doc_header_msg
          doc_refer_msg      = doc_refer_msg
        EXCEPTIONS
          document_not_found = 1
          docum_lock         = 2
          partner_blocked    = 3
          OTHERS             = 4 ).

      IF sy-subrc <> 0.
        reporter->error( ).
        RETURN.
      ENDIF.

      MOVE-CORRESPONDING doc->struct TO doc_header.

      dfe_std->j_1b_nf_document_update(
        EXPORTING
          doc_number            = doc_header-docnum
          doc_header            = doc_header
          doc_partner           = doc_partner
          doc_item              = doc_item
          doc_item_tax          = doc_item_tax
          doc_header_msg        = doc_header_msg
          doc_refer_msg         = doc_refer_msg
        EXCEPTIONS
          document_not_found    = 1
          update_problem        = 2
          doc_number_is_initial = 3
          OTHERS                = 4
      ).
      IF sy-subrc <> 0.
        reporter->error( ).
      ENDIF.

      COMMIT WORK.

    ENDIF.
  ENDMETHOD.

  METHOD fill_texts.

*          DATA: range_utils   TYPE REF TO /s4tax/range_utils,
*          string_utils  TYPE REF TO /s4tax/string_utils,
*          doc_message   TYPE LINE OF /s4tax/doc_message_t,
*          doc_msg_ref   TYPE LINE OF /s4tax/doc_message_ref_t,
*          dao_doc       TYPE REF TO /s4tax/dao_doc,
*          doc_range     TYPE ace_generic_range_t,
*          index         TYPE i,
*          logbr_docs    TYPE TABLE OF  logbr_nf_texts,
*          logbr_doc     TYPE logbr_nf_texts,
*          linum         TYPE j_1blinnum,
*          message       TYPE string,
*          separator     TYPE string,
*          message_split TYPE /s4tax/string_t,
*          length_split  TYPE /s4tax/string_t,
*          message_t     TYPE /s4tax/string_t,
*          j1_message    TYPE j_1bmessag,
*          seq_num       TYPE j_1bseqnum,
*          doc_table     TYPE /s4tax/j_1bnfdoc_t,
*          docs          TYPE /s4tax/doc_t,
*          doc           TYPE REF TO /s4tax/doc,
*          doc_ref       TYPE j_1bnfref,
*          doc_msg       TYPE j_1bnfftx.
*
*
*    CREATE OBJECT dao_doc.
*    docs = documents.
*    SORT docs BY table_line->struct-docnum.
*    doc_table = dao_doc->/s4tax/idao_doc~object_to_struct( object_table = docs ).
*    CREATE OBJECT: range_utils,
*                   string_utils.
*    doc_range = range_utils->specific_range( range = doc_table low = 'DOCNUM' ).
*
*    SELECT * FROM logbr_nf_texts
*    INTO TABLE logbr_docs
*    WHERE docnum IN doc_range.
*
*    SORT logbr_docs BY docnum itmnum type counter.
*
*    LOOP AT docs INTO doc.
*
*      READ TABLE logbr_docs TRANSPORTING NO FIELDS WITH KEY docnum = doc->struct-docnum.
*      IF sy-subrc <> 0.
*        CONTINUE.
*      ENDIF.
*
*      index = sy-tabix.
*
*      LOOP AT logbr_docs INTO logbr_doc FROM index.
*
*        IF logbr_doc-docnum <> doc->struct-docnum.
*          EXIT.
*        ENDIF.
*        linum = 1.
*
*        IF logbr_doc-itmnum IS INITIAL.
*
*          CLEAR message_t.
*          separator = cl_abap_char_utilities=>cr_lf.
*          message = logbr_doc-text.
*          message_split = string_utils->split_in_table( input = message separator = separator ).
*
*          LOOP AT message_split INTO message.
*            length_split = string_utils->split_in_table_by_lenght( input = message line_length = 72 ).
*            APPEND LINES OF length_split TO message_t.
*          ENDLOOP.
*
*          LOOP AT message_t INTO message.
*            j1_message = message.
*            CREATE OBJECT doc_message.
*            doc_message->set_docnum( logbr_doc-docnum ).
*
*            doc_message->set_message( j1_message ).
*            doc_message->set_linnum( iv_linnum = linum ).
*            doc->add_doc_message( doc_message ).
*            linum = linum + 1.
*          ENDLOOP.
*
*        ELSE.
*
*          CREATE OBJECT doc_message.
*          doc_message->set_docnum( logbr_doc-docnum ).
*          j1_message = logbr_doc-text.
*          doc_message->set_message( j1_message ).
*          doc->add_doc_message( doc_message ).
*
*          linum = logbr_doc-counter.
*          doc_message->set_seqnum( iv_seqnum = linum ).
*
*          CREATE OBJECT doc_msg_ref.
*          doc_msg_ref->set_docnum( logbr_doc-docnum ).
*          doc_msg_ref->set_itmnum( logbr_doc-itmnum ).
*          doc_msg_ref->set_seqnum( linum ).
*          doc->add_doc_msg_ref( doc_msg_ref ).
*
*        ENDIF.
*
*
*      ENDLOOP.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD save_doc.

*
* DATA: doc_partner      TYPE ty_j_1bnfnad,
*          doc_item         TYPE j_1bnflin_tab,
*          doc_item_tax     TYPE j_1bnfstx_tab,
*          doc_header_msg   TYPE j_1bnfftx_tab,
*          doc_refer_msg    TYPE j_1bnfref_tab,
*          doc_header       TYPE j_1bnfdoc,
*          doc_texts        TYPE logbr_nf_text_tt,
*          doc_texts_object TYPE REF TO if_logbr_nf_texts_data,
*          dfe_std          TYPE REF TO /s4tax/dfe_std.
*
*    IF doc->struct IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    if doc_texts_object is not bound.
*    create object doc_texts_object type logbr_nf_texts_data.
*    ENDIF.
*
*    CALL FUNCTION 'J_1B_NF_DOCUMENT_READ'
*      EXPORTING
*        doc_number         = doc->struct-docnum
*      IMPORTING
*        doc_header         = doc_header
*        doc_texts          = doc_texts_object
*       TABLES
*           doc_partner        = doc_partner
*        doc_item           = doc_item
*        doc_item_tax       = doc_item_tax
*        doc_header_msg     = doc_header_msg
*        doc_refer_msg      = doc_refer_msg.
*
*    IF sy-subrc <> 0.
*      reporter->error( ).
*      RETURN.
*    ENDIF.
*
*IF doc_texts_object IS NOT INITIAL.
*  doc_texts = doc_texts_object->get_text_table( ).
*  ENDIF.
*
*    MOVE-CORRESPONDING doc->struct TO doc_header.
*
*   CALL FUNCTION 'J_1B_NF_DOCUMENT_UPDATE'
*      EXPORTING
*        doc_number            = doc_header-docnum
*        doc_header            = doc_header
*        doc_texts             = doc_texts
*        TABLES
*        doc_partner           = doc_partner
*        doc_item              = doc_item
*        doc_item_tax          = doc_item_tax
*        doc_header_msg        = doc_header_msg
*        doc_refer_msg         = doc_refer_msg
*      EXCEPTIONS
*        document_not_found    = 1
*        update_problem        = 2
*        doc_number_is_initial = 3
*        OTHERS                = 4.
*    IF sy-subrc <> 0.
*      reporter->error( ).
*    ENDIF.
*
*    COMMIT WORK.

  ENDMETHOD.

  METHOD get_nfse_processor.
    IF me->nfse_processor IS BOUND.
      RETURN.
    ENDIF.

    CREATE OBJECT me->nfse_processor TYPE /s4tax/nfse_processor
      EXPORTING
        reporter = me->reporter.
  ENDMETHOD.

ENDCLASS.