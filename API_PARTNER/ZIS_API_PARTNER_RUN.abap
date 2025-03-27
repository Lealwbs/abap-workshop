CLASS zis_api_partner_run DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF return_struct,
             success        TYPE abap_bool,
             return_partner TYPE /s4tax/s_search_partner_o,
             return_error   TYPE string,
           END OF return_struct.

    DATA: string_utils    TYPE REF TO /s4tax/string_utils,
          api_is          TYPE REF TO zis_iapi_partner,
          dao_obj         TYPE REF TO zis_idao,
          bo_obj          TYPE REF TO zis_bo.


    METHODS:

      constructor         IMPORTING api TYPE REF TO zis_iapi_partner OPTIONAL
                                    dao TYPE REF TO zis_idao OPTIONAL
                          RAISING   /s4tax/cx_http /s4tax/cx_auth,

      run                 IMPORTING partnerid       TYPE string
                          RETURNING VALUE(return_response)  TYPE return_struct,

      process_bad_request IMPORTING errors          TYPE /s4tax/s_default_error
                          RETURNING VALUE(msg_erro) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zis_api_partner_run IMPLEMENTATION.

  METHOD constructor.

    IF api IS NOT INITIAL.
      api_is = api.
    ELSE.
      api_is = zis_api_partner=>get_instance( ).
    ENDIF.

    IF api_is IS NOT BOUND.  "NOT BOUND = Não está preenchido
      "WRITE: / 'ERROR: API_IS was not initialized'.
    ENDIF.

    IF dao IS NOT INITIAL.
      dao_obj = dao.
    ELSE.
      CREATE OBJECT dao_obj TYPE zis_dao.
    ENDIF.

  ENDMETHOD.

  METHOD run.

    DATA: api_response TYPE /s4tax/s_search_partner_o.

    TRY.
        api_response = api_is->search_partner( EXPORTING partner_id = partnerid ).
      CATCH /s4tax/cx_http /s4tax/cx_auth.
        "WRITE: / 'ERROR: API_IS->SEARCH_PARTNER was not called'.
        return_response-success = abap_false.
        RETURN.
    ENDTRY.

    "=================================================================
    "= SAVE RESPONSE INTO TABLE
    "=================================================================

    DATA: error_table TYPE /s4tax/s_default_error,
          body        TYPE zis_table_t-id,
          msg_error   TYPE string.

    IF api_response IS INITIAL.
      api_is->change_response_for_error( CHANGING response_data = error_table ).
      body = process_bad_request( error_table ).
      return_response-return_error = body.
    ELSE.
      body = api_response-data-partner-id.
      return_response-return_partner = api_response.
      return_response-success = abap_true.
    ENDIF.

    "CLEAR zis_table_t. "Limpar a tabela quando tiver cheia
    DATA: last_id TYPE int1.
    SELECT COUNT(*) INTO last_id FROM zis_table_t.

    DATA: bo_obj TYPE REF TO zis_bo.
    CREATE OBJECT bo_obj
      EXPORTING
        iv_vcount = last_id + 1
        iv_id     = body.

    dao_obj->save( obj = bo_obj ).

  ENDMETHOD.

  METHOD process_bad_request.

    DATA: msg   TYPE string.
    CREATE OBJECT string_utils.

    IF errors IS INITIAL.
      RETURN.
    ENDIF.

    msg = me->string_utils->concatenate( msg1 = 'Error'
                                         msg2 = errors-code
                                         msg3 = errors-message ).
    msg_erro = msg.

  ENDMETHOD.

ENDCLASS.