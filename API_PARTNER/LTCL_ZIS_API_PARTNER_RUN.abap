*"* use this source file for your ABAP unit test classes

CLASS ltcl_zis_api_partner_run DEFINITION FINAL FOR TESTING
  INHERITING FROM /s4tax/api_signed_test
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA: sut      TYPE REF TO zis_api_partner_run,
          mock_api TYPE REF TO zis_iapi_partner,
          mock_dao TYPE REF TO zis_idao.

    METHODS:
      setup, tierdown,
      get_valid_partner   FOR TESTING,
      get_unvalid_partner FOR TESTING.

ENDCLASS.

CLASS ltcl_zis_api_partner_run IMPLEMENTATION.

  METHOD setup.

    mock_api ?= cl_abap_testdouble=>create( 'zis_iapi_partner' ).
    mock_dao ?= cl_abap_testdouble=>create( 'zis_idao' ).

    TRY.
        sut = NEW zis_api_partner_run(
          api = mock_api
          dao = mock_dao ).
      CATCH /s4tax/cx_http /s4tax/cx_auth.
    ENDTRY.

  ENDMETHOD.

  METHOD tierdown.
    FREE sut.
  ENDMETHOD.

  METHOD get_valid_partner.

    DATA: valid_response TYPE /s4tax/s_search_partner_o.

    valid_response-data-partner-id = '80123'.
    valid_response-data-partner-name = 'Nome de Teste'.

    cl_abap_testdouble=>configure_call( mock_api )->ignore_all_parameters( )->returning( value = valid_response ).

    mock_api->search_partner( '' ).

    DATA valid_partner_id TYPE string VALUE '8c8ff9e0-3811-48a1-bb86-6d6a53d6b0f3'.
    DATA(result) = sut->run( partnerid = valid_partner_id ).

    cl_abap_unit_assert=>assert_equals(
      act = result-success
      exp = abap_true
      msg = |EXPECTED: Search Successful / ACTUAL: Search Failed - | &&
            |PartnerID { valid_partner_id } does not exist or was not found.| ).

  ENDMETHOD.

  METHOD get_unvalid_partner.

    DATA: unvalid_response TYPE /s4tax/s_search_partner_o.

    cl_abap_testdouble=>configure_call( mock_api )->ignore_all_parameters( )->returning( value = unvalid_response ).

    mock_api->search_partner( '' ).

    DATA unvalid_partner_id TYPE string VALUE '20700980-f726-42bc-907b-945e07cd7d27'.
    DATA(result) = sut->run( partnerid = unvalid_partner_id ).

    cl_abap_unit_assert=>assert_equals(
      act = result-success
      exp = abap_false
      msg = |EXPECTED: Search Failed / ACTUAL: Other -  | &&
            |PartnerID { unvalid_partner_id } should not exist, but it was found.| ).

  ENDMETHOD.

ENDCLASS.