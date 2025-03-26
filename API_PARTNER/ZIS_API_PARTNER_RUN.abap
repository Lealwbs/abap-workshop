CLASS zis_api_partner_run DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    DATA: string_utils TYPE REF TO /s4tax/string_utils,
          api_is       TYPE REF TO zis_iapi_partner,
          dao_obj      TYPE REF TO zis_dao,
          bo_obj       TYPE REF TO zis_bo.

    METHODS:

      constructor         IMPORTING api TYPE REF TO zis_iapi_partner OPTIONAL
                                    dao TYPE REF TO zis_dao OPTIONAL
                          RAISING   /s4tax/cx_http /s4tax/cx_auth,

      run                 IMPORTING partnerid      TYPE string
                          RETURNING VALUE(success) TYPE abap_bool,

      write_response      IMPORTING response        TYPE /s4tax/s_search_partner_o,

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
        success = abap_false.
        RETURN.
    ENDTRY.

    "=================================================================
    "= SAVE RESPONSE INTO TABLE
    "=================================================================

    DATA: error_table TYPE /s4tax/s_default_error,
          body        TYPE zis_table_t-id,
          msg_error   TYPE string.

    IF api_response IS INITIAL.     "WRITE: / '--- RESPONSE IS EMPTY ---'. ULINE.
      api_is->change_response_for_error( CHANGING response_data = error_table ).
      body = process_bad_request( error_table ).
      "WRITE: / body.
    ELSE.                           "WRITE: / '--- SUCCESS ---'. ULINE.
      body = api_response-data-partner-id.
      "write_response( api_response ).
      success = abap_true.
    ENDIF.

*   CLEAR zis_table_t "Limpar a tabela quando tiver cheia
    DATA: last_id TYPE int1.
    SELECT COUNT(*) INTO last_id FROM zis_table_t.

    DATA: bo_obj TYPE REF TO zis_bo.
    CREATE OBJECT bo_obj
      EXPORTING
        iv_vcount = last_id + 1
        iv_id     = body.

    dao_obj->zis_idao~save( obj = bo_obj ).

  ENDMETHOD.

  METHOD write_response.

    IF response IS INITIAL. "Redundante
      "WRITE: / 'ERROR: The write_response method was called, but the response is empty'.
      RETURN.
    ENDIF.

    WRITE: / 'Partner ID:   ', response-data-partner-id,
           / 'Partner Name: ', response-data-partner-name,
           / 'Fantasy Name: ', response-data-partner-fantasy_name,
           / 'Birth Date:   ', response-data-partner-birth_date,
           / 'Partner Type: ', response-data-partner-partner_type,
           / 'Created at:   ', response-data-partner-created_at,
           / 'Updated at:   ', response-data-partner-updated_at.

    ULINE.
    WRITE: / 'Address ID:      ', response-data-partner-addresses-id,
           / 'Country:         ', response-data-partner-addresses-country,
           / 'Country_code:    ', response-data-partner-addresses-country_code,
           / 'Zip_code:        ', response-data-partner-addresses-zip_code,
           / 'Main:            ', response-data-partner-addresses-main,
           / 'UF:              ', response-data-partner-addresses-uf,
           / 'UF_code:         ', response-data-partner-addresses-uf_code,
           / 'City_code:       ', response-data-partner-addresses-city_code,
           / 'City:            ', response-data-partner-addresses-city,
           / 'Type:            ', response-data-partner-addresses-type,
           / 'Public_place:    ', response-data-partner-addresses-public_place,
           / 'Home_number:     ', response-data-partner-addresses-home_number,
           / 'Neighborhood:    ', response-data-partner-addresses-neighborhood,
           / 'Complement:      ', response-data-partner-addresses-complement,
           / 'Reference_point: ', response-data-partner-addresses-reference_point,
           / 'Province:        ', response-data-partner-addresses-province,
           / 'Category:        ', response-data-partner-addresses-category.

    ULINE.
    WRITE: / 'Fiscal ID:       ', response-data-partner-fiscal_ids-id,
           / 'Fiscal Type:     ', response-data-partner-fiscal_ids-type,
           / 'Fiscal Value:    ', response-data-partner-fiscal_ids-value,
           / 'Fiscal Issuer:   ', response-data-partner-fiscal_ids-issuer.


    ULINE.
    WRITE: / 'Contact ID:          ', response-data-partner-contacts-id,
           / 'Contact Type:        ', response-data-partner-contacts-type,
           / 'Contact Address:     ', response-data-partner-contacts-value-address,
           / 'Contact Observation: ', response-data-partner-contacts-observation,
           / 'Contact Responsible: ', response-data-partner-contacts-responsible.

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